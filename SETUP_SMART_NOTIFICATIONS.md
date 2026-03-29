# Setup Instructions - Smart Notifications

## Prerequisites
- Spring Boot application running
- Flutter environment configured
- MySQL database accessible

---

## BACKEND SETUP

### Step 1: Database Migration

**Option A: Using Flyway (Recommended)**
The migration script is already created at:
```
order-service/src/main/resources/db/migration/V2__add_status_updated_at.sql
```

If you have Flyway configured, it will run automatically on next startup.

**Option B: Manual MySQL Script**
Run this SQL directly in MySQL:

```sql
-- Add column
ALTER TABLE `Order` ADD COLUMN statusUpdatedAt DATETIME(6) DEFAULT NULL;

-- Initialize for existing orders
UPDATE `Order`
SET statusUpdatedAt = orderPlacedDate
WHERE statusUpdatedAt IS NULL AND orderPlacedDate IS NOT NULL;

UPDATE `Order`
SET statusUpdatedAt = NOW()
WHERE statusUpdatedAt IS NULL;

-- Add indexes
CREATE INDEX idx_order_status_updated_at ON `Order` (statusUpdatedAt);
CREATE INDEX idx_order_vendor_status_updated ON `Order` (vendorId, statusUpdatedAt);
```

### Step 2: Rebuild Order Service

```bash
cd order-service
mvn clean install
mvn spring-boot:run
```

### Step 3: Verify API Endpoint

Test the new polling endpoint:
```bash
# Get current timestamp (example)
curl "http://localhost:9092/order/vendor/VENDOR001/latest?since=2025-01-01T00:00:00"
```

You should see a JSON array of orders.

---

## FRONTEND SETUP

### Step 1: Get Flutter Dependencies

```bash
cd healthy_food_bank_flutter
flutter pub get
```

### Step 2: Run the App

```bash
flutter run -d chrome  # For web
# OR
flutter run -d android  # For Android
# OR
flutter run -d ios      # For iOS
```

### Step 3: Test Features

#### Vendor Side Testing:
1. Login as a vendor
2. Navigate to Orders screen
3. **Test NEW Badge:**
   - Have a customer create a new order
   - Wait for 15-second polling cycle
   - You should see "🆕 NEW" badge on the order card
   - Badge should disappear after 2 minutes

4. **Test UPDATED Badge:**
   - Change an order status (e.g., ISSUED → SCHEDULED)
   - Wait for polling cycle
   - You should see "🔄 UPDATED" badge
   - Badge should disappear after 2 minutes

5. **Test Background Polling:**
   - Switch to another app
   - Wait 30+ seconds
   - Return to the app
   - Orders should refresh automatically

#### Customer Side Testing:
1. Login as a customer
2. Navigate to My Orders screen
3. **Test Status Notifications:**
   - Have a vendor accept your order (ISSUED → SCHEDULED)
   - Wait for 30-second polling cycle
   - You should see a SnackBar: "✅ Order Confirmed..."
   - Tap "View" to navigate to order details

4. **Test Other Status Changes:**
   - SCHEDULED → READY: "📦 Ready for Pickup..."
   - READY → DELIVERED: "🎉 Order Delivered..."
   - Any → CANCELLED_BY_VENDOR: "❌ Order Cancelled..."

---

## CONFIGURATION

### Adjust Polling Intervals

**Vendor Side** (currently 15 seconds):
```dart
// File: healthy_food_bank_flutter/lib/screens/vendor/vendor_orders_screen.dart
static const _autoRefreshDuration = Duration(seconds: 15);
```

**Customer Side** (currently 30 seconds):
```dart
// File: healthy_food_bank_flutter/lib/screens/customer/customer_orders_screen.dart
static const _autoRefreshDuration = Duration(seconds: 30);
```

### Adjust Badge Duration (currently 2 minutes):
```dart
// File: healthy_food_bank_flutter/lib/providers/vendor_order_provider.dart
bool isOrderNew(Order order) {
  final diff = now.difference(order.orderPlacedDate!);
  return diff.inMinutes < 2; // Change this value
}

bool isOrderRecentlyUpdated(Order order) {
  final diff = now.difference(order.statusUpdatedAt!);
  return diff.inMinutes < 2; // Change this value
}
```

---

## TROUBLESHOOTING

### Backend Issues

**Problem:** `statusUpdatedAt` column not found
**Solution:** Run the migration script manually (see Step 1)

**Problem:** `/latest` endpoint returns 404
**Solution:** Rebuild the order-service and restart

**Problem:** Empty response from `/latest`
**Solution:** Check that orders have `statusUpdatedAt` populated:
```sql
SELECT id, orderStatus, statusUpdatedAt FROM `Order` LIMIT 10;
```

### Frontend Issues

**Problem:** NEW badge not showing
**Solution:**
- Check that polling is active (look for console logs)
- Verify order was created within last 2 minutes
- Ensure `statusUpdatedAt` is in API response

**Problem:** No status change notifications
**Solution:**
- Check polling interval (customer orders poll every 30s)
- Verify status actually changed in database
- Check console for errors

**Problem:** Badge stays forever
**Solution:**
- Verify `orderPlacedDate` or `statusUpdatedAt` has valid timestamp
- Check time calculation logic in provider

---

## VERIFICATION COMMANDS

### Check Database Schema
```sql
DESCRIBE `Order`;
```
Should show `statusUpdatedAt` column.

### Check Existing Data
```sql
SELECT
  id,
  orderStatus,
  orderPlacedDate,
  statusUpdatedAt,
  TIMESTAMPDIFF(MINUTE, statusUpdatedAt, NOW()) as minutes_since_update
FROM `Order`
ORDER BY statusUpdatedAt DESC
LIMIT 10;
```

### Test API Response Format
```bash
curl "http://localhost:9092/order/vendor/VENDOR001/latest?since=2025-01-01T00:00:00" | jq
```

Should include `statusUpdatedAt` field in response.

---

## MONITORING

### Backend Logs
Look for these log entries:
```
Fetching orders updated since <timestamp> for vendor <vendorId>
Found <N> orders updated since <timestamp> for vendor <vendorId>
```

### Frontend Debug
Add console logs to verify polling:
```dart
// In loadAllOrders()
print('Polling orders... Found ${newIds.length} new, ${updatedIds.length} updated');
```

---

## ROLLBACK (If Needed)

### Backend Rollback
```sql
ALTER TABLE `Order` DROP COLUMN statusUpdatedAt;
DROP INDEX idx_order_status_updated_at ON `Order`;
DROP INDEX idx_order_vendor_status_updated ON `Order`;
```

### Frontend Rollback
1. Revert changes to the 5 Flutter files
2. Run `flutter pub get`
3. Restart the app

---

## PRODUCTION CONSIDERATIONS

### Before Deploying:

1. **Test thoroughly** in staging environment
2. **Backup database** before running migration
3. **Monitor server load** - polling increases API calls
4. **Consider rate limiting** on `/latest` endpoint
5. **Add caching** if needed for high-traffic scenarios
6. **Set up alerts** for API errors

### Recommended Production Settings:
- Vendor polling: 20-30 seconds
- Customer polling: 45-60 seconds
- Badge duration: 5 minutes
- Enable API caching with 5-second TTL

---

## SUPPORT

For issues or questions:
1. Check the comprehensive documentation: `SMART_NOTIFICATIONS_IMPLEMENTATION.md`
2. Review backend logs in `order-service`
3. Check Flutter console for frontend errors
4. Verify database state with SQL queries above

---

## NEXT STEPS

After successful setup:
1. ✅ Test all user flows (vendor + customer)
2. ✅ Verify performance under load
3. ✅ Set appropriate polling intervals for your use case
4. ✅ Consider adding analytics tracking
5. ✅ Plan for future WebSocket upgrade if needed

**Estimated Setup Time:** 15-20 minutes
**Complexity Level:** Intermediate
**Breaking Changes:** None (backward compatible)
