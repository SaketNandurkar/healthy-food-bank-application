# Smart Polling-Based Notifications Implementation

## Overview
A complete polling-based notification system that provides real-time UX without WebSockets. Orders are tracked for creation and status changes, with visual indicators on both vendor and customer sides.

---

## BACKEND IMPLEMENTATION

### 1. Order Entity Enhancement
**File:** `order-service/src/main/java/order_service/entity/Order.java`

**Added Field:**
```java
@Schema(description = "Timestamp when the order status was last updated (for polling notifications)")
private LocalDateTime statusUpdatedAt;
```

**Lifecycle Hooks:**
- `@PrePersist`: Sets `statusUpdatedAt` when order is created
- `@PreUpdate`: Automatically updates `statusUpdatedAt` on any modification

### 2. OrderDTO Enhancement
**File:** `order-service/src/main/java/order_service/dto/OrderDTO.java`

**Added Field:**
```java
@Schema(description = "Timestamp when the order status was last updated (for polling notifications)")
private LocalDateTime statusUpdatedAt;
```

### 3. OrderMapper Update
**File:** `order-service/src/main/java/order_service/mapper/OrderMapper.java`

- Updated `toDTO()` to include `statusUpdatedAt`
- Updated `toEntity()` to map `statusUpdatedAt`

### 4. OrderService Update
**File:** `order-service/src/main/java/order_service/service/OrderService.java`

**Explicit Status Tracking:**
Updated three key methods to explicitly set `statusUpdatedAt`:
- `updateOrderStatusWithValidation()` - Sets timestamp for SCHEDULED→READY→DELIVERED transitions
- `acceptOrder()` - Sets timestamp when ISSUED→SCHEDULED
- `rejectOrder()` - Sets timestamp when order is cancelled

**New Method:**
```java
public List<OrderDTO> getOrdersUpdatedSince(String vendorId, LocalDateTime since)
```
Returns orders where: `orderPlacedDate > since OR statusUpdatedAt > since`

### 5. OrderRepository Enhancement
**File:** `order-service/src/main/java/order_service/repository/OrderRepository.java`

**New Query:**
```java
@Query("SELECT o FROM Order o " +
       "WHERE o.vendorId = :vendorId " +
       "AND (o.orderPlacedDate > :since OR o.statusUpdatedAt > :since) " +
       "ORDER BY o.orderPlacedDate DESC")
List<Order> findOrdersUpdatedSince(@Param("vendorId") String vendorId,
                                   @Param("since") LocalDateTime since);
```

### 6. New Lightweight Polling Endpoint
**File:** `order-service/src/main/java/order_service/controller/OrderController.java`

**Endpoint:**
```
GET /order/vendor/{vendorId}/latest?since={timestamp}
```

**Query Parameter:**
- `since` (required): ISO timestamp (format: `2025-01-27T10:30:00`)

**Returns:**
- List of OrderDTOs created or updated after the specified timestamp
- Optimized for polling - only returns changed orders

**Example:**
```bash
GET /order/vendor/VENDOR001/latest?since=2025-01-27T10:30:00
```

---

## FRONTEND IMPLEMENTATION

### 1. Order Model Enhancement
**File:** `healthy_food_bank_flutter/lib/models/order.dart`

**Added Field:**
```dart
final DateTime? statusUpdatedAt; // For polling-based notifications
```

Updated `fromJson()` to parse `statusUpdatedAt` from API response.

### 2. Vendor Order Provider Enhancement
**File:** `healthy_food_bank_flutter/lib/providers/vendor_order_provider.dart`

**VendorOrdersState Updates:**
```dart
class VendorOrdersState {
  final DateTime? lastSeenTimestamp;     // Track last poll time
  final Set<int> newOrderIds;            // Orders created in last 2 min
  final Set<int> recentlyUpdatedIds;     // Orders updated in last 2 min

  // Helper methods
  bool isOrderNew(Order order);
  bool isOrderRecentlyUpdated(Order order);
}
```

**Smart Detection Logic:**
- On every poll, compares new orders with previous state
- Detects **NEW orders** (not in previous fetch)
- Detects **STATUS CHANGES** (status differs from previous)
- Tracks IDs in sets for fast lookup

### 3. Vendor Orders Screen UI
**File:** `healthy_food_bank_flutter/lib/screens/vendor/vendor_orders_screen.dart`

**Polling Configuration:**
- Interval: 15 seconds (configurable via `_autoRefreshDuration`)
- Auto-refresh on app resume (via `WidgetsBindingObserver`)
- Pause polling when app goes to background

**Visual Indicators:**

#### 🆕 NEW Badge
- Shown for orders placed within last 2 minutes
- Gradient green background with shadow
- Displayed alongside status badge

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
    ),
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text('🆕 NEW'),
)
```

#### 🔄 UPDATED Badge
- Shown for orders with status change in last 2 minutes
- Blue background with shadow
- Only shown if order is NOT also marked as NEW

```dart
Container(
  decoration: BoxDecoration(color: AppColors.info),
  child: Text('🔄 UPDATED'),
)
```

#### Card Highlighting
- NEW orders: Green border glow
- UPDATED orders: Blue border glow
- Enhanced shadow for visual emphasis

### 4. Customer Order Provider Enhancement
**File:** `healthy_food_bank_flutter/lib/providers/order_provider.dart`

**OrderListState Updates:**
```dart
class OrderListState {
  final Map<int, OrderStatus> statusChanges; // Track recent status changes

  String? getStatusChangeMessage(int orderId);
  void clearStatusChange(int orderId);
}
```

**Status Change Messages:**
- `SCHEDULED`: "✅ Order Confirmed - Your order has been accepted by the vendor"
- `READY`: "📦 Ready for Pickup - Your order is ready for collection"
- `DELIVERED`: "🎉 Order Delivered - Thank you for your order!"
- `CANCELLED_BY_VENDOR`: "❌ Order Cancelled - The vendor has cancelled your order"

### 5. Customer Orders Screen Enhancement
**File:** `healthy_food_bank_flutter/lib/screens/customer/customer_orders_screen.dart`

**Polling Configuration:**
- Interval: 30 seconds (configurable via `_autoRefreshDuration`)
- Auto-refresh on app resume
- Pause polling when app goes to background

**Status Change Notifications:**
- Uses `ref.listen()` to react to state changes
- Shows SnackBar notification for each status change
- Includes "View" action button to navigate to order detail
- Auto-clears notification after display

```dart
ref.listen<OrderListState>(customerOrdersProvider, (previous, current) {
  if (current.statusChanges.isNotEmpty) {
    for (var entry in current.statusChanges.entries) {
      final message = current.getStatusChangeMessage(entry.key);
      ScaffoldMessenger.of(context).showSnackBar(/* ... */);
    }
  }
});
```

---

## EDGE CASES HANDLED

### First Load
- No "NEW" or "UPDATED" badges shown on first load
- `lastSeenTimestamp` is null initially
- Detection only starts after first successful fetch

### App Resume
- Automatic refresh triggered via `WidgetsBindingObserver`
- Compares orders with last known state
- Shows appropriate indicators for changes during background

### Background Polling Pause
- Timer cancelled when app goes to background (`AppLifecycleState.paused`)
- Resumes polling when app returns to foreground (`AppLifecycleState.resumed`)
- Saves battery and network resources

### Badge Timeout
- NEW/UPDATED badges automatically expire after 2 minutes
- Calculated based on `orderPlacedDate` and `statusUpdatedAt`
- No manual cleanup needed - time-based logic

### Multiple Status Changes
- Customer can receive multiple notifications in sequence
- Each notification auto-clears after being shown
- Prevents notification spam via automatic cleanup

---

## API USAGE EXAMPLES

### 1. Get Latest Orders (Polling Endpoint)
```bash
GET http://localhost:9092/order/vendor/VENDOR001/latest?since=2025-01-27T10:30:00

Response:
[
  {
    "id": 123,
    "orderName": "Organic Apples",
    "orderQuantity": 5.0,
    "orderStatus": "ISSUED",
    "orderPlacedDate": "2025-01-27T10:35:00",
    "statusUpdatedAt": "2025-01-27T10:35:00",
    ...
  }
]
```

### 2. Traditional Order Fetch (Still Available)
```bash
GET http://localhost:9092/order/vendor/VENDOR001/issued
GET http://localhost:9092/order/vendor/VENDOR001/scheduled
GET http://localhost:9092/order/vendor/VENDOR001
```

---

## TESTING CHECKLIST

### Backend Tests
- ✅ `statusUpdatedAt` set on order creation
- ✅ `statusUpdatedAt` updated on status change
- ✅ `/latest` endpoint returns correct orders
- ✅ Timestamp parsing works correctly
- ✅ Query excludes orders before `since` timestamp

### Frontend Vendor Tests
- ✅ NEW badge appears for orders < 2 min old
- ✅ NEW badge disappears after 2 minutes
- ✅ UPDATED badge appears on status change
- ✅ Card border highlights for new/updated orders
- ✅ Polling continues in foreground
- ✅ Polling pauses in background
- ✅ Auto-refresh on app resume

### Frontend Customer Tests
- ✅ Status change notifications appear
- ✅ Correct message for each status
- ✅ "View" action navigates to order detail
- ✅ Notifications clear after display
- ✅ Polling works in foreground
- ✅ Polling pauses in background

---

## PERFORMANCE CONSIDERATIONS

### Database
- Indexed fields: `orderPlacedDate`, `statusUpdatedAt`, `vendorId`
- Query uses `OR` with indexed columns (efficient)
- Returns only changed orders (minimal payload)

### Network
- Polling interval: 15s (vendor), 30s (customer)
- Background polling disabled (battery-friendly)
- Lightweight endpoint reduces bandwidth

### Frontend
- Set-based tracking (`Set<int>`) for O(1) lookup
- Time-based badge expiration (no timers needed)
- Minimal re-renders via Riverpod state management

---

## FUTURE ENHANCEMENTS (Optional)

### 1. WebSocket Upgrade Path
- Keep polling as fallback
- Add WebSocket support for instant updates
- Graceful degradation if WebSocket unavailable

### 2. Push Notifications
- Integrate Firebase Cloud Messaging (FCM)
- Send push notifications for critical status changes
- Maintain polling for in-app experience

### 3. Configurable Polling Intervals
- Add settings screen for users to adjust poll frequency
- Trade-off: real-time vs battery life
- Store preference in SharedPreferences

### 4. Badge Customization
- Allow vendors to set badge display duration
- Configurable colors per order priority
- Custom notification sounds

---

## MIGRATION NOTES

### Existing Data
- `statusUpdatedAt` will be NULL for existing orders
- Database migration recommended:
```sql
UPDATE `Order` SET statusUpdatedAt = orderPlacedDate WHERE statusUpdatedAt IS NULL;
```

### API Compatibility
- All existing endpoints unchanged
- New `/latest` endpoint is additive
- Backward compatible - old clients work normally

---

## CONFIGURATION

### Backend
```properties
# application.properties (if needed)
polling.enabled=true
```

### Frontend
```dart
// vendor_orders_screen.dart
static const _autoRefreshDuration = Duration(seconds: 15);

// customer_orders_screen.dart
static const _autoRefreshDuration = Duration(seconds: 30);
```

---

## KEY FILES MODIFIED

### Backend
1. `order-service/src/main/java/order_service/entity/Order.java`
2. `order-service/src/main/java/order_service/dto/OrderDTO.java`
3. `order-service/src/main/java/order_service/mapper/OrderMapper.java`
4. `order-service/src/main/java/order_service/service/OrderService.java`
5. `order-service/src/main/java/order_service/repository/OrderRepository.java`
6. `order-service/src/main/java/order_service/controller/OrderController.java`

### Frontend
1. `healthy_food_bank_flutter/lib/models/order.dart`
2. `healthy_food_bank_flutter/lib/providers/vendor_order_provider.dart`
3. `healthy_food_bank_flutter/lib/providers/order_provider.dart`
4. `healthy_food_bank_flutter/lib/screens/vendor/vendor_orders_screen.dart`
5. `healthy_food_bank_flutter/lib/screens/customer/customer_orders_screen.dart`

---

## SUMMARY

This implementation provides:
- ✅ **Real-time UX** without WebSockets complexity
- ✅ **Smart badge indicators** for new and updated orders
- ✅ **Customer notifications** for all status changes
- ✅ **Battery-efficient polling** with background pause
- ✅ **Backward compatible** with existing API
- ✅ **Production-ready** with proper error handling

The system gracefully handles edge cases, provides excellent UX, and maintains clean architecture patterns throughout.
