# Flutter Mobile App UI Prompt — Healthy Food Bank

## App Overview

Build a complete cross-platform mobile application (Android + iOS) using Flutter for **"Healthy Food Bank"** — a food marketplace that connects local vendors with customers to purchase fresh, healthy products. The app has three user roles: **Customer**, **Vendor**, and **Admin**. Each role has its own dedicated dashboard and features. The app communicates with existing REST APIs (Spring Boot microservices).

---

## Design System & Theme

### Color Palette (Earthy & Organic theme)
- **Primary (Leaf Green):** `#6A994E` — used for app bars, primary buttons, sidebar backgrounds, active states
- **Secondary (Clay Brown):** `#A47148` — used for secondary accents, vendor-specific highlights
- **Accent (Golden Wheat):** `#E9C46A` — used for active menu items, highlights, warning badges, toggle accents
- **Background (Off-White):** `#F7F6F0` — main scaffold background
- **Text (Charcoal):** `#2E2E2E` — primary text color
- **Success Green:** `#28A745` — success alerts, in-stock indicators, delivered status
- **Warning Yellow:** `#FFC107` — low stock, pending/issued status
- **Danger Red:** `#DC3545` — out of stock, delete buttons, cancelled status, errors
- **Info Blue:** `#17A2B8` — info alerts, processing status
- **Light Grey:** `#F8F9FA` — card backgrounds, input fields
- **Dark Grey:** `#343A40` — footer text, muted content

### Typography
- **Font Family:** Inter (Google Fonts) with fallback to system default
- **Headings:** Bold, sizes 24px (h1), 20px (h2), 18px (h3), 16px (h4)
- **Body:** Regular 14-15px
- **Captions/Labels:** 12-13px, medium weight
- **Prices:** Bold, 18-20px, Leaf Green color

### Design Tokens
- **Border Radius:** 12-16px for cards, 10px for inputs, 25px for badges/pills
- **Elevation/Shadow:** Subtle elevation (2-4) on cards, higher (6-8) on hover/pressed states
- **Spacing:** 8px base grid system, 16px standard padding, 24px section gaps
- **Transitions:** 300ms ease for all animations

### App Icon & Branding
- App name: "Healthy Food Bank"
- Branding: Leaf/plant icon combined with a food/basket element
- Splash screen: Green gradient background with centered white leaf logo and app name

---

## Navigation Architecture

### Authentication Flow (No bottom navigation)
1. **Splash Screen** → auto-navigate to Login after 2 seconds
2. **Login Screen**
3. **Register Screen**

### Customer Flow (Bottom Navigation Bar — 4 tabs)
1. **Browse Products** (home icon) — product catalog with search and filters
2. **My Cart** (shopping cart icon with item count badge) — cart management
3. **My Orders** (receipt/list icon) — order history and tracking
4. **Profile** (person icon) — profile, pickup points, settings

### Vendor Flow (Bottom Navigation Bar — 4 tabs)
1. **Stock Management** (inventory/box icon) — product CRUD
2. **Orders** (receipt icon with badge count for new orders) — order management tabs
3. **Pickup Points** (map pin icon) — manage delivery pickup locations
4. **Profile** (person icon) — profile and settings

### Admin Flow (Bottom Navigation Bar — 4 tabs)
1. **Analytics** (chart icon) — dashboard stats (placeholder/coming soon)
2. **Vendors** (people icon) — vendor code management
3. **Pickup Points** (map pin icon) — pickup point CRUD
4. **Profile** (person icon) — profile and settings

---

## Screen-by-Screen Specification

---

### SCREEN 1: Splash Screen

- Full screen green gradient background (top: `#6A994E`, bottom: `#4A7C3A`)
- Centered white leaf/plant logo icon (80x80px)
- App name "Healthy Food Bank" in white, bold, 28px below the logo
- Tagline "Fresh & Healthy, Delivered to You" in white, 14px, slightly transparent
- Auto-navigate to Login screen after 2 seconds
- Smooth fade-out transition

---

### SCREEN 2: Login Screen

**Layout:** Single scroll view, centered content

**Top Section:**
- Green gradient header area (curved bottom edge) — 35% of screen height
- White leaf icon (60px) centered
- "Healthy Food Bank" title in white, bold, 24px
- "Sign in to continue" subtitle in white, 14px, semi-transparent

**Form Section:** White card with 16px padding, elevated, rounded corners (16px), overlapping the header by 40px
- **Username field:** Text input with person icon prefix, placeholder "Enter your username", required validation
- **Password field:** Password input with lock icon prefix, placeholder "Enter your password", eye icon toggle for show/hide password, required validation
- **"Forgot Password?"** link text — aligned right, green color (placeholder, shows coming soon snackbar)
- **"Sign In" button:** Full-width, green gradient (`#6A994E` to `#5A8A3E`), white text, bold, rounded (12px), 50px height, shows circular loading indicator when processing
- **"Reset" button:** Full-width outline button, grey border, below sign-in button, 8px gap

**Bottom Section:**
- "Don't have an account?" text in grey
- **"Register here"** tappable text in green, bold — navigates to Register screen

**Demo Accounts Info:** Small card or expandable section at the bottom showing:
- "Demo Accounts" header
- Vendor: vendor / password
- Customer: customer / password

**Error Handling:**
- Red banner/snackbar at top for invalid credentials
- Session expiration alert if redirected from expired token
- Field-level validation errors shown below each input in red

---

### SCREEN 3: Register Screen

**Layout:** Scrollable form

**Top Section:**
- Green gradient app bar with back arrow to Login
- "Create Account" title, "Join Healthy Food Bank" subtitle

**Form Section:** White card with padding
- **First Name:** Text input, person icon, required (2-50 chars)
- **Last Name:** Text input, person icon, required (2-50 chars)
- **Email:** Email input, email icon, optional but validated if provided
- **Phone Number:** Number input, phone icon, required (exactly 10 digits)
- **Role Selection:** Dropdown or segmented control with options: CUSTOMER, VENDOR, ADMIN — required
- **Conditional Fields (VENDOR selected):**
  - **Vendor Code:** Text input, key icon, required (min 5 chars)
  - Real-time validation — shows green checkmark if valid, red X if invalid, loading spinner while checking
  - Helper text: "Enter the vendor code provided by admin"
- **Conditional Fields (CUSTOMER selected):**
  - **Pickup Point:** Dropdown selector showing active pickup points (name + address), required
  - Helper text: "Select your nearest pickup location"
- **Username:** Text input, person-badge icon, required (3-20 chars)
- **Password:** Password input, lock icon, required (min 6 chars), show/hide toggle
- **Confirm Password:** Password input, lock-check icon, required, must match password
  - Real-time mismatch indicator in red

**Actions:**
- **"Create Account" button:** Full-width, green gradient, white text, loading state
- **"Reset Form" button:** Full-width outline button
- "Already have an account? **Sign in here**" — green tappable text

**Success State:** Green success snackbar "Registration successful!", auto-navigate to Login after 2 seconds

---

### SCREEN 4: Customer — Browse Products (Home Tab)

**App Bar:**
- "Healthy Food Bank" title in white on green background
- Notification bell icon (right) — placeholder
- User avatar/initials circle (right) — tapping opens profile dropdown

**Active Pickup Point Banner:**
- If active pickup point exists: Green info banner showing pickup point name and address with a map pin icon
- If NO active pickup point: Yellow warning banner "No active pickup point selected" with "Manage" button that navigates to Pickup Points screen

**Search & Filter Section:** Sticky at top, white card with shadow
- **Search bar:** Rounded input with search icon, placeholder "Search products, vendors...", clear button (X) when text entered
- **Filter row:** Horizontal scrollable chips for categories: All, Vegetables, Fruits, Dairy, Grains, Proteins, Beverages, Organic, Others — selected chip is green filled, others are outlined
- **Sort dropdown:** Small dropdown icon showing current sort (Name, Price, Vendor) with ascending/descending toggle arrow button

**Product Grid:** 2-column grid with 8px gap, scrollable
Each **Product Card:**
- **Product image** (top, full card width, 140px height, rounded top corners, object-fit cover, placeholder image if none)
- **Stock badge** (top-right corner overlay):
  - Green pill "In Stock" if quantity > 10
  - Yellow pill "Low Stock" if quantity 1-10
  - Red pill "Out of Stock" if quantity = 0
- **Out of stock overlay:** Semi-transparent dark overlay on image with "Out of Stock" text centered, if quantity = 0
- **Product name** (bold, 15px, max 2 lines with ellipsis)
- **Description** (grey, 12px, max 2 lines with ellipsis)
- **Row:** Category badge (small green-outlined pill) + Vendor name (grey text, 12px)
- **Delivery schedule badge** (if set): Truck icon + "Saturday Delivery" or "Sunday Delivery" in a blue-tinted pill, with "Next: [calculated date]" below it in 11px grey text
- **Price:** Bold, 18px, green color — "₹{price} / {unitQuantity} {unit}"
- **Stock text:** "Stock: {quantity}" in 12px, color-coded (green/yellow/red)
- **Action area:**
  - If NOT in cart and in stock: Quantity selector (minus/plus buttons with number in middle, default 1, min 1, max stock) + "Add to Cart" green button below
  - If IN cart: Green checkmark + "In Cart ({qty})" text + small minus/plus buttons to adjust + "Remove" red text button
  - If out of stock: Grey disabled "Unavailable" button

**Empty States:**
- Loading: Centered circular progress indicator + "Loading fresh products..." text
- No results: Search icon + "No products found" + "Try adjusting your filters" + "Clear Filters" outlined button

**Pull-to-refresh:** Swipe down to refresh product list

---

### SCREEN 5: Customer — Cart Tab

**App Bar:** "Shopping Cart" title on green background, badge showing item count

**If cart has items:**

**Cart Item List:** Scrollable list of cart items, each item is a card:
- **Product image** (60x60px, rounded 8px) on the left
- **Middle section:**
  - Product name (bold, 15px, max 1 line)
  - Price per unit (grey, 13px) — "₹{price} / {unit}"
  - **Quantity controls:** Row with minus circle button, quantity number (16px bold), plus circle button
- **Right section:**
  - Item total "₹{price × quantity}" (bold, 16px, green)
  - Delete/trash icon button (red) at top-right

**Divider line** between items

**Cart Summary Section:** Fixed at bottom, white card with top shadow
- **Row:** "Total ({n} items)" label left, "₹{total}" bold green right (20px)
- **"Proceed to Checkout" button:** Full-width, green gradient, white text, bold, 50px height, rounded 12px
- **"Clear Cart" text button:** Below checkout button, red text, centered

**If cart is empty:**
- Centered large shopping cart outline icon (100px, grey)
- "Your cart is empty" title (18px, grey)
- "Browse products and add items to your cart" subtitle (14px, light grey)
- "Browse Products" green outlined button — navigates to Browse tab

---

### SCREEN 6: Customer — Checkout (Bottom Sheet or New Screen)

**Triggered from:** "Proceed to Checkout" button on Cart screen

**Layout:** Bottom sheet that slides up from bottom (85% screen height) OR full screen

**Order Summary Card:**
- "Order Summary" header
- List of items: product name, quantity × price = total per item
- Horizontal divider
- "Total Amount: ₹{total}" in bold green, 20px

**Delivery Details Form:**
- **Delivery Address:** Multi-line text input, map-pin icon, required (min 10 chars), placeholder "Enter your full delivery address"
- **Contact Number:** Phone number input, phone icon, required (10 digits), placeholder "10-digit phone number"

**Actions:**
- **"Place Order" button:** Full-width, green gradient, white text, loading state with spinner
- **"Cancel" text button:** Grey, closes the sheet

**Success State:** Success animation (checkmark), "Order placed successfully!" message, auto-navigate to Orders tab, cart cleared

---

### SCREEN 7: Customer — My Orders Tab

**App Bar:** "My Orders" title on green background

**Tab Bar or Segmented Control:**
1. **Active** — Pending, Processing, Issued, Scheduled orders
2. **History** — Delivered, Cancelled orders

**Active Orders Tab:**
Order cards with status-colored left border (4px):
- **Yellow border (PENDING/ISSUED):**
  - Status badge: Yellow pill "Pending" or "Issued"
  - Product name (bold) + Order ID (grey, small)
  - "Qty: {quantity}" + "₹{price}"
  - Order date (grey, 12px)
  - Pickup point info (if available)
- **Blue border (PROCESSING):**
  - Status badge: Blue pill "Processing"
  - Same info layout
- **Green border (SCHEDULED):**
  - Status badge: Green pill "Scheduled"
  - Expected delivery date (if available)

**History Tab:**
Order cards with status-colored left border:
- **Green border (DELIVERED):**
  - Status badge: Green pill "Delivered"
  - Delivery date shown
- **Red border (CANCELLED):**
  - Status badge: Red pill "Cancelled" or "Cancelled by Vendor"
  - Cancellation reason if available

**Empty State:**
- Receipt icon (large, grey)
- "No orders yet"
- "Your order history will appear here"
- "Start Shopping" button

---

### SCREEN 8: Customer — Profile Tab

**Scrollable list-style layout with sections:**

**Profile Header Card:**
- Green gradient background
- User avatar circle (initials or placeholder icon, 70px)
- User full name (white, bold, 20px)
- Email (white, 14px, semi-transparent)
- Role badge: "Customer" green pill

**Menu Sections:**

**Section: Account**
- "Edit Profile" — person icon → navigates to Edit Profile screen
- "My Pickup Points" — map-pin icon → navigates to Pickup Points screen
- "Order History" — receipt icon → navigates to Orders tab

**Section: Preferences**
- "Notifications" — bell icon → navigates to Notification Settings
- "Settings" — gear icon → navigates to Settings screen (change password)

**Section: Support**
- "Help & FAQ" — question-circle icon → placeholder
- "Contact Us" — headset icon → placeholder

**Section: Account Actions**
- "Logout" — exit/logout icon, red text → confirmation dialog, then logout and navigate to Login

---

### SCREEN 9: Customer — Edit Profile

**App Bar:** "Edit Profile" with back arrow, green background

**Form in a card:**
- **First Name:** Text input, required (min 2 chars), pre-filled
- **Last Name:** Text input, required (min 2 chars), pre-filled
- **Email:** Email input, required, pre-filled
- **Phone Number:** Phone input, 10 digits, pre-filled

**Action:**
- "Update Profile" full-width green button, loading state
- Success snackbar on completion

---

### SCREEN 10: Customer — My Pickup Points

**App Bar:** "My Pickup Points" with back arrow, green background, "+" add button on right

**Pickup Point Cards** (vertical list):
Each card:
- **Active indicator:** Green "ACTIVE" badge on card if this is the active pickup point; active card has green border
- **Pickup point name** (bold, 16px)
- **Address** with map-pin icon (grey, 14px)
- **City, State, ZIP** (grey, 13px)
- **Actions row:**
  - "Set as Active" green outlined button (hidden if already active)
  - "Delete" red icon button (disabled if only one pickup point remains)

**Floating Action Button:** "+" to add a new pickup point

**Add Pickup Point Bottom Sheet:**
- "Select Pickup Point" header
- Dropdown/list of all available pickup points (filtered to exclude already-added ones)
- Each option shows: Name — Address, City
- "Add" green button + "Cancel" text button
- Info message if all pickup points already added

**Empty State:**
- Map pin icon (large, grey)
- "No pickup points"
- "Add a pickup location to receive deliveries"
- "Add Pickup Point" green button

---

### SCREEN 11: Customer — Settings (Change Password)

**App Bar:** "Settings" with back arrow

**Change Password Card:**
- **Current Password:** Password input with lock icon, required
- **New Password:** Password input, required (min 6 chars)
- **Confirm New Password:** Password input, required, must match
- Real-time mismatch indicator
- "Change Password" green button, loading state

**Notification Preferences Card:**
- Toggle switches for:
  - Email Notifications (default ON)
  - SMS Notifications (default OFF)
  - Order Notifications (default ON)
  - Delivery Updates (default ON)
  - Marketing Emails (default OFF)
- "Update Preferences" button

---

### SCREEN 12: Vendor — Stock Management (Home Tab)

**App Bar:** "Stock Management" on green background, refresh icon button (right)

**Stats Row:** Horizontal scroll of 4 stat cards (compact):
1. **Total Products** — box icon, count number, green tint
2. **Total Value** — currency icon, "₹{sum}", golden tint
3. **Low Stock** — warning icon, count, yellow tint
4. **Categories** — grid icon, count, blue tint

**Search & Filter Bar:**
- Search input with search icon
- Category filter dropdown
- Auto-refresh toggle switch with "Auto-refresh" label + countdown text "Next refresh in {n}s"
- Last updated timestamp in grey small text

**Product List:** Vertical list of product cards
Each card:
- **Left:** Product image (60x60px, rounded), placeholder if none
- **Middle:**
  - Product name (bold, 15px)
  - Description (grey, 12px, 1 line ellipsis)
  - Category badge (small outlined pill)
  - "₹{price} / {unitQuantity} {unit}" (green, 14px)
- **Right:**
  - Stock count with status color
  - Stock status badge (In Stock / Low Stock / Out of Stock)
- **Swipe actions** or **trailing icon buttons:**
  - Edit (blue pencil icon)
  - Delete (red trash icon) — with confirmation dialog

**Floating Action Button:** "+" to add new product

**Empty State:**
- Package/inbox icon (large, grey)
- "No products found"
- "Start by adding your first product!"
- "Add Product" green button

---

### SCREEN 13: Vendor — Add/Edit Product (Full Screen or Bottom Sheet)

**App Bar:** "Add Product" or "Edit Product" with back arrow and save checkmark button

**Scrollable Form:**
- **Product Name:** Text input, required (2-100 chars)
- **Category:** Dropdown selector, required — options: Vegetables, Fruits, Dairy, Grains, Proteins, Beverages, Organic, Others
- **Description:** Multi-line text input (3-4 lines visible), required (10-500 chars)
- **Price (₹):** Number input with currency icon, required (min 0.01)
- **Quantity per Unit:** Number input, required (min 0.01), helper text: "e.g., 1, 250, 500"
- **Unit:** Dropdown, required — options: kg, g, litre, ml, piece, dozen, pack, unit
- **Stock Quantity:** Number input, required (min 0)
- **Delivery Schedule:** Dropdown, optional — options: No specific schedule, Saturday, Sunday
- **Image URL:** Text input, optional, URL validation, helper text: "Paste product image URL"
  - Image preview below input if URL is valid

**Actions:**
- "Save Product" full-width green button (loading state)
- "Cancel" outlined button or back navigation

---

### SCREEN 14: Vendor — Orders Tab

**App Bar:** "Order Management" on green background

**Tab Bar (scrollable tabs):**
1. **Issued** (yellow badge count) — orders awaiting vendor response
2. **Scheduled** (green badge count) — accepted orders ready for delivery
3. **Cancelled** (red badge count) — rejected/cancelled orders
4. **All History** (grey badge count) — complete order log

**Issued Orders Tab:**
- Yellow info banner: "Awaiting Your Response"
- Order cards with yellow left border (4px):
  - **ISSUED** yellow status badge + order timestamp
  - Product name (bold) + Order ID
  - Customer name + phone + pickup point
  - "Qty: {quantity}" + "₹{price}"
  - **Action buttons row:**
    - "Accept" green filled button (checkmark icon)
    - "Reject" red outlined button (X icon)
  - Confirmation dialog before accept/reject

**Scheduled Orders Tab:**
- Green info banner: "Ready for Delivery"
- **Download Delivery Sheet:** Dropdown button showing available delivery dates, tapping a date downloads PDF
- Order cards with green left border:
  - **SCHEDULED** green badge + timestamp
  - Same info layout, no action buttons

**Cancelled Orders Tab:**
- Red info banner: "Cancelled / Rejected Orders"
- Order cards with red left border:
  - **CANCELLED** or **CANCELLED BY VENDOR** red badge
  - Same info layout, read-only

**All History Tab:**
- Grey header
- Order cards with dynamic border color based on status
- All statuses shown with colored badges

**Empty States per tab:**
- Appropriate icon + "No {type} orders" + descriptive subtitle

---

### SCREEN 15: Vendor — Pickup Points Tab

**App Bar:** "My Pickup Points" on green background, "+" add button (right)

**Pickup Point Cards** (vertical list):
Each card:
- **Active/Inactive badge** (top-right): green "Active" or grey "Inactive"
- **Toggle switch** to activate/deactivate
- **Store/location icon** + Pickup point name (bold, 16px)
- **Map pin icon** + Address (grey, 14px)
- **City, State, ZIP** if available
- **"Remove" button** — red outlined, with confirmation dialog

**Add Pickup Point Bottom Sheet:**
- Dropdown to select from available pickup points (filtered to exclude already-added)
- Shows: Name — Address, City
- "Add" button + "Cancel" button
- Info message if all already added

**Empty State:**
- Map pin icon (large, grey)
- "No Pickup Points Added"
- "Add pickup locations where customers can collect orders"
- "Add Pickup Point" green button

---

### SCREEN 16: Vendor — Profile Tab

**Same structure as Customer Profile Tab (Screen 8) but with vendor-specific items:**

**Profile Header Card:**
- Vendor name, email, Vendor ID shown
- Role badge: "Vendor" green pill

**Menu Sections:**
- "Edit Profile" → Edit Profile screen (includes read-only Vendor ID field)
- "Pickup Points" → navigates to Pickup Points tab
- "Settings" → Change Password + Notification Preferences
- "Logout" → confirmation dialog + logout

---

### SCREEN 17: Admin — Vendor Management Tab

**App Bar:** "Vendor Management" on green background, "+" create button (right)

**Create Vendor Code Section** (expandable or FAB → bottom sheet):
- **Vendor Code:** Text input, required (5-20 chars), placeholder "e.g., VND001"
- **Vendor ID:** Text input, required (3-20 chars), placeholder "e.g., FRESH001"
- **Vendor Name:** Text input, required (3-100 chars)
- **Description:** Multi-line input, optional (max 255 chars)
- "Create" green button + "Cancel" text button

**Tab Bar or Segmented Control:**
1. **All Codes** — complete list
2. **Unused** — available codes
3. **Used** — redeemed codes

**All Codes — List View:**
Each card:
- Vendor code displayed as prominent badge/chip
- Vendor ID + Vendor Name
- Status pill: Yellow "Unused" or Green "Used"
- Created date (grey, 12px)
- If used: "Used by User #{id}" + used date
- **Action:** "Deactivate" red text button (only on unused codes), with confirmation

**Unused Codes — Card Grid (2 columns):**
- Yellow/golden border cards
- Code badge, Vendor details, Created date
- Deactivate button

**Used Codes — Card Grid (2 columns):**
- Green border cards
- Code badge, Vendor details, Used date, User ID

**Empty States per tab:**
- "No vendor codes found" / "No unused codes" / "No codes used yet"

---

### SCREEN 18: Admin — Pickup Point Management Tab

**App Bar:** "Pickup Points" on green background, "+" add button (right)

**Create/Edit Form** (bottom sheet or expandable):
- **Pickup Point Name:** Text input, required (3-100 chars)
- **Contact Number:** Phone input, optional
- **Address:** Multi-line input, required (10-255 chars)
- "Create" or "Update" green button + "Cancel"

**Pickup Points List:**
Each card:
- **Active/Inactive badge** (top-right): green or grey
- **Map pin icon** + Name (bold)
- **Address** (grey)
- **Contact number** if available
- **Created date** (grey, 12px)
- **Action buttons row:**
  - Edit (blue pencil icon) — opens form in edit mode
  - Toggle Active/Inactive (switch or icon button) — with confirmation
  - Delete (red trash icon) — with confirmation dialog

**Empty State:**
- Map pin icon (large, grey)
- "No pickup points found"
- "Create pickup locations for vendors and customers"
- "Add Pickup Point" green button

---

### SCREEN 19: Admin — Analytics Tab (Placeholder)

**App Bar:** "Analytics" on green background

**Coming Soon Card:**
- Large chart/analytics icon (centered, animated gentle floating motion)
- "Coming Soon" badge (golden pill)
- "Sales Analytics" title (bold, 20px)
- Description: "Advanced analytics and reporting features are being developed. Track sales, vendor performance, and customer trends."
- Placeholder illustration or icon

---

### SCREEN 20: Admin — Profile Tab

**Same structure as Customer/Vendor Profile Tab with admin-specific items:**

**Profile Header:**
- Admin name, email
- Role badge: "Admin" golden pill

**Menu Sections:**
- "Edit Profile" → Edit Profile screen
- "Settings" → Change Password + Notification Preferences
- "Logout"

---

## Common UI Components (Reusable Widgets)

### 1. Custom App Bar
- Green gradient background (`#6A994E` to `#5A8A3E`)
- White title text, white icon buttons
- Rounded bottom edge or straight

### 2. Product Card Widget
- Reused in customer browse and vendor stock management
- Image, name, description, price, stock badge, action buttons
- Elevation on tap/press

### 3. Order Card Widget
- Status-colored left border (4px)
- Status badge pill
- Product info, customer info, date, action buttons
- Reused across vendor order tabs

### 4. Stat Card Widget
- Icon, label, value
- Colored background tint
- Compact horizontal layout for scrolling

### 5. Status Badge Widget
- Pill-shaped container
- Color-coded: green (success), yellow (warning), red (danger), blue (info), grey (neutral)
- Small icon + text

### 6. Empty State Widget
- Large centered icon
- Title + subtitle
- Optional CTA button

### 7. Loading Indicator
- Centered circular progress (green color)
- Optional "Loading..." text below

### 8. Confirmation Dialog
- "Are you sure?" title
- Descriptive message
- "Cancel" grey button + "Confirm" colored button (red for delete, green for confirm)

### 9. Custom Text Input
- Rounded border (10px)
- Prefix icon
- Suffix icon (for password toggle, clear button)
- Focus border: green
- Error border: red with error text below
- Filled light grey background

### 10. Category Chip
- Horizontal scrollable chip list
- Selected: filled green with white text
- Unselected: outlined with grey text
- Tappable with ripple effect

### 11. Cart Item Widget
- Image + details + quantity controls + total + delete
- Swipe-to-delete supported

### 12. Snackbar/Toast Messages
- Success: green background, checkmark icon
- Error: red background, X icon
- Info: blue background, info icon
- Floating at bottom, auto-dismiss after 3 seconds

---

## Animations & Micro-interactions

1. **Page transitions:** Slide-in from right (forward navigation), slide-out to right (back)
2. **Card press effect:** Slight scale down (0.98) on press, elevation change
3. **Add to cart:** Brief green checkmark animation, cart badge bounce
4. **Pull to refresh:** Custom refresh indicator with leaf icon
5. **Empty state icon:** Gentle floating/bobbing animation (up and down)
6. **Bottom sheet:** Smooth slide-up with backdrop fade
7. **Tab switch:** Smooth crossfade between tab contents
8. **Quantity buttons:** Number increment/decrement with brief scale animation
9. **Loading buttons:** Text replaced with small circular spinner
10. **Snackbar:** Slide-up entrance, slide-down exit
11. **Delete confirmation:** Subtle shake animation on destructive action

---

## State Management

Use a state management solution (Provider, Riverpod, or BLoC) for:
- **Auth state:** Current user, JWT token, login status, role
- **Cart state:** Cart items, quantities, totals (persisted in SharedPreferences/local storage)
- **Product state:** Product list, filters, search, loading states
- **Order state:** Order lists by status, loading states
- **Pickup point state:** User's pickup points, active pickup point

---

## API Integration Structure

### Base URLs (configurable per environment)
- User Service: `http://localhost:9090`
- Product Service: `http://localhost:9091`
- Order Service: `http://localhost:9092`

### Auth Headers
- All authenticated requests include: `Authorization: Bearer {jwt_token}`
- Vendor/Customer requests include: `X-User-Id: {userId}`
- Customer order requests include: `X-Customer-Id: {customerId}`

### Key API Endpoints
**User Service (`/user`):**
- POST `/user/new?vendorCode={code}` — Register
- POST `/user/authenticate` — Login (returns JWT + user details)
- GET `/user/validate-vendor-code/{code}` — Validate vendor code
- PUT `/user/profile/{userId}` — Update profile
- PUT `/user/password/{userId}` — Change password

**Product Service (`/products`):**
- GET `/products` — All products
- GET `/products/vendor/{vendorId}` — Vendor's products
- GET `/products/by-pickup-point/{pickupPointId}` — Products by pickup point
- POST `/products` — Create product
- PUT `/products/{id}` — Update product
- DELETE `/products/{id}` — Delete product

**Order Service (`/order`):**
- POST `/order` — Create order
- GET `/order/customer/{customerId}` — Customer's orders
- GET `/order/vendor/{vendorId}` — Vendor's orders
- GET `/order/vendor/{vendorId}/issued` — Issued orders
- GET `/order/vendor/{vendorId}/scheduled` — Scheduled orders
- GET `/order/vendor/{vendorId}/cancelled` — Cancelled orders
- POST `/order/{id}/accept` — Accept order
- POST `/order/{id}/reject` — Reject order
- PUT `/order/{id}/status` — Update status
- GET `/order/vendor/{vendorId}/delivery-sheet?date={date}` — Download delivery PDF

**Pickup Points (`/pickup-points`):**
- GET `/pickup-points/active` — Active pickup points
- POST `/pickup-points` — Create
- PUT `/pickup-points/{id}` — Update
- DELETE `/pickup-points/{id}` — Delete
- PUT `/pickup-points/{id}/activate` — Activate
- PUT `/pickup-points/{id}/deactivate` — Deactivate

**Vendor Pickup Points (`/vendor-pickup-points`):**
- GET `/vendor-pickup-points/{vendorId}` — Vendor's points
- POST `/vendor-pickup-points/{vendorId}` — Add point
- DELETE `/vendor-pickup-points/{vendorId}/{pickupPointId}` — Remove

**Customer Pickup Points (`/customer-pickup-points`):**
- GET `/customer-pickup-points/{customerId}` — Customer's points
- POST `/customer-pickup-points/{customerId}` — Add point
- PUT `/customer-pickup-points/{customerId}/active/{pickupPointId}` — Set active
- DELETE `/customer-pickup-points/{customerId}/{pickupPointId}` — Remove

**Vendor Codes (`/user/admin/vendor-codes`):**
- GET `/user/admin/vendor-codes` — All codes
- GET `/user/admin/vendor-codes/unused` — Unused codes
- GET `/user/admin/vendor-codes/used` — Used codes
- POST `/user/admin/vendor-codes` — Create code
- DELETE `/user/admin/vendor-codes/{id}` — Deactivate code

---

## Data Models (Dart Classes)

```
User: id, firstName, lastName, email, phoneNumber, role (CUSTOMER/VENDOR/ADMIN), vendorId, userName, password, active, pickupPointId, createdDate, updatedDate

Product: id, productName, productPrice, productQuantity, productUnit, unitQuantity, category (VEGETABLES/FRUITS/DAIRY/GRAINS/PROTEINS/BEVERAGES/ORGANIC/OTHERS), description, vendorId, vendorName, stockQuantity, imageUrl, deliverySchedule (SATURDAY/SUNDAY/null), active

CartItem: product, quantity, totalPrice

Order: id, orderName, orderQuantity, orderUnit, orderPrice, orderPlacedDate, orderDeliveredDate, customerId, orderStatus (PENDING/PROCESSING/DELIVERED/CANCELLED/ISSUED/SCHEDULED/CANCELLED_BY_VENDOR), productId, vendorId, productName, customerName, customerPhone, customerPickupPoint

PickupPoint: id, name, address, city, state, zipCode, contactNumber, active, createdDate

VendorCode: id, vendorCode, vendorId, vendorName, description, active, used, usedBy, usedDate, createdDate
```

---

## Platform-Specific Considerations

### Android
- Material Design 3 components where applicable
- Back button handling for nested navigation
- Status bar color matches app bar (green)
- Edge-to-edge display support

### iOS
- Cupertino-style back swipe gesture support
- Safe area insets respected (notch, home indicator)
- iOS-style bottom sheet behavior
- Haptic feedback on important actions (add to cart, place order, delete)

### Both Platforms
- Responsive layout — works on phones and tablets
- Dark mode support (future enhancement) — design with theme-able colors
- Offline indicators — show banner when no internet connection
- Deep linking support structure
- Local storage for cart persistence (SharedPreferences)
- Secure storage for JWT tokens (flutter_secure_storage)

---

## Folder Structure (Recommended)

```
lib/
├── main.dart
├── app.dart (MaterialApp, theme, routes)
├── config/
│   ├── theme.dart (colors, text styles, component themes)
│   ├── routes.dart (named routes)
│   └── api_config.dart (base URLs, endpoints)
├── models/
│   ├── user.dart
│   ├── product.dart
│   ├── cart_item.dart
│   ├── order.dart
│   ├── pickup_point.dart
│   └── vendor_code.dart
├── services/
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── cart_service.dart
│   ├── order_service.dart
│   ├── pickup_point_service.dart
│   └── api_client.dart (HTTP client with auth interceptor)
├── providers/ (or blocs/)
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   └── order_provider.dart
├── screens/
│   ├── splash/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── customer/
│   │   ├── customer_shell.dart (bottom nav scaffold)
│   │   ├── browse_products_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_sheet.dart
│   │   ├── customer_orders_screen.dart
│   │   ├── customer_profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── customer_pickup_points_screen.dart
│   │   └── customer_settings_screen.dart
│   ├── vendor/
│   │   ├── vendor_shell.dart (bottom nav scaffold)
│   │   ├── stock_management_screen.dart
│   │   ├── add_edit_product_screen.dart
│   │   ├── vendor_orders_screen.dart
│   │   ├── vendor_pickup_points_screen.dart
│   │   ├── vendor_profile_screen.dart
│   │   └── vendor_settings_screen.dart
│   └── admin/
│       ├── admin_shell.dart (bottom nav scaffold)
│       ├── analytics_screen.dart
│       ├── vendor_management_screen.dart
│       ├── pickup_management_screen.dart
│       └── admin_profile_screen.dart
├── widgets/
│   ├── product_card.dart
│   ├── order_card.dart
│   ├── stat_card.dart
│   ├── status_badge.dart
│   ├── empty_state.dart
│   ├── custom_text_field.dart
│   ├── category_chips.dart
│   ├── confirmation_dialog.dart
│   ├── loading_indicator.dart
│   └── cart_item_widget.dart
└── utils/
    ├── validators.dart
    ├── date_helpers.dart (next delivery date calculation)
    ├── currency_formatter.dart
    └── constants.dart
```

---

## Summary of All Screens (20 screens total)

| # | Screen | Role | Description |
|---|--------|------|-------------|
| 1 | Splash | All | Green gradient, logo, auto-redirect |
| 2 | Login | All | Username/password form, demo accounts |
| 3 | Register | All | Multi-field form with role-based conditional fields |
| 4 | Browse Products | Customer | 2-col product grid, search, filters, add to cart |
| 5 | Cart | Customer | Cart items list, quantity controls, total |
| 6 | Checkout | Customer | Order summary, delivery form, place order |
| 7 | My Orders | Customer | Active/history tabs, order cards with status |
| 8 | Profile | Customer | Profile header, menu list (edit, settings, logout) |
| 9 | Edit Profile | Customer | First/last name, email, phone form |
| 10 | My Pickup Points | Customer | Pickup point cards, add/set active/delete |
| 11 | Settings | Customer | Change password, notification toggles |
| 12 | Stock Management | Vendor | Stats cards, product list, search, auto-refresh |
| 13 | Add/Edit Product | Vendor | Product form with all fields |
| 14 | Order Management | Vendor | 4 tabs: Issued/Scheduled/Cancelled/History |
| 15 | Vendor Pickup Points | Vendor | Pickup point cards, add/toggle/remove |
| 16 | Vendor Profile | Vendor | Profile header, menu list |
| 17 | Vendor Management | Admin | Create vendor codes, all/unused/used tabs |
| 18 | Pickup Management | Admin | Create/edit/delete/toggle pickup points |
| 19 | Analytics | Admin | Coming soon placeholder |
| 20 | Admin Profile | Admin | Profile header, menu list |

---

## Important Notes for Implementation

1. **Currency:** Use ₹ (Indian Rupee) symbol throughout the app
2. **Date Format:** Display dates as "DD MMM YYYY, HH:mm" (e.g., "28 Feb 2026, 15:30")
3. **Phone Validation:** Exactly 10 digits for Indian phone numbers
4. **Image Placeholders:** Use a food-themed placeholder icon/illustration when product has no image URL
5. **Delivery Schedule Calculation:** For Saturday delivery, calculate next Saturday from today; for Sunday, calculate next Sunday
6. **Cart Persistence:** Cart must survive app restarts using local storage
7. **Token Management:** Store JWT securely, auto-logout on 401 responses, redirect to login
8. **Role-based Routing:** After login, route to Customer/Vendor/Admin shell based on user role
9. **Pull-to-Refresh:** Support on all list/grid screens
10. **Internet Connectivity:** Show offline banner when no connection detected
11. **Form Validation:** Real-time validation with descriptive error messages below each field
12. **Confirmation Dialogs:** Required before all destructive actions (delete product, reject order, logout, clear cart)
13. **Loading States:** Every API call should show appropriate loading indicators
14. **Error Handling:** Graceful error messages for all API failures, never show raw error responses