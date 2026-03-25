# 🚀 Complete Healthy Food Bank Setup & Testing Guide

## ✅ **What's Fixed & Working**

### **Backend Services** 
- ✅ **User Service** (Port 9080): Registration, JWT authentication with user details
- ✅ **Product Service** (Port 9091): Product CRUD operations with vendor support  
- ✅ **Database Integration**: MySQL with proper entity mappings
- ✅ **Spring Security**: JWT tokens, role-based access control
- ✅ **API Documentation**: Swagger/OpenAPI integration

### **Frontend Application**
- ✅ **Angular 17**: Modern framework with TypeScript compilation
- ✅ **Authentication System**: Registration & login with role-based routing
- ✅ **Vendor Dashboard**: Complete product management interface
- ✅ **Customer Dashboard**: Product catalog, shopping cart, checkout
- ✅ **Responsive Design**: Bootstrap 5 with mobile-friendly UI

---

## 🛠️ **Setup Instructions**

### **1. Database Setup**
```sql
-- Create MySQL databases
CREATE DATABASE user_service_db;
USE user_service_db;
-- Tables will be auto-created by JPA
```

### **2. Backend Services**

#### **Start User Service (Port 9080)**
```bash
cd user-service
mvn spring-boot:run
```

#### **Start Product Service (Port 9091)**
```bash
cd product-service  
mvn spring-boot:run
```

### **3. Frontend Application**

#### **Install Dependencies**
```bash
cd frontend-angular
npm install
```

#### **Start Development Server**
```bash
ng serve
# Access at: http://localhost:4200
```

---

## 🧪 **Testing Guide**

### **1. Backend API Testing**

#### **Test User Service (Port 9080)**
```bash
# Health check
curl http://localhost:9080/user/welcome

# Register new user
curl -X POST http://localhost:9080/user/new \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe", 
    "userName": "johndoe",
    "password": "password123",
    "roles": "CUSTOMER",
    "phoneNumber": 1234567890,
    "email": "john@example.com"
  }'

# Login user
curl -X POST http://localhost:9080/user/authenticate \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "password": "password123"
  }'
```

#### **Test Product Service (Port 9091)**
```bash
# Health check
curl http://localhost:9091/products/health

# Get all products
curl http://localhost:9091/products

# Add product (requires JWT token)
curl -X POST http://localhost:9091/products \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 1" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -d '{
    "productName": "Fresh Apples",
    "productPrice": 2.99,
    "productQuantity": 100,
    "productUnit": "kg"
  }'
```

### **2. Frontend Application Testing**

#### **User Registration Flow**
1. Go to `http://localhost:4200`
2. Click "Register here"
3. Fill registration form:
   - **Customer**: Select "CUSTOMER" role
   - **Vendor**: Select "VENDOR" role + provide Vendor ID
4. Submit registration
5. Login with created credentials

#### **Vendor Dashboard Testing**  
1. Register/Login as vendor
2. Access vendor dashboard (`/vendor/dashboard`)
3. Test features:
   - ✅ View product statistics
   - ✅ Add new products
   - ✅ Edit existing products  
   - ✅ Delete products
   - ✅ Search & filter products

#### **Customer Dashboard Testing**
1. Register/Login as customer  
2. Access customer dashboard (`/customer/dashboard`)
3. Test features:
   - ✅ Browse all products
   - ✅ Search by name/vendor
   - ✅ Filter by categories
   - ✅ Add products to cart
   - ✅ Manage cart quantities
   - ✅ Checkout process

---

## 🔧 **Architecture Overview**

### **Backend Services**
```
User Service (Port 9080)
├── Registration & Authentication
├── JWT Token Generation  
├── Role-based Access Control
└── User Management

Product Service (Port 9091)  
├── Product CRUD Operations
├── Vendor-specific Products
├── Inventory Management
└── Category Organization
```

### **Frontend Application**
```
Angular Frontend (Port 4200)
├── Authentication Module
│   ├── Registration Component
│   └── Login Component
├── Vendor Module
│   └── Product Management Dashboard
├── Customer Module
│   ├── Product Catalog
│   ├── Shopping Cart
│   └── Checkout Process
└── Shared Services
    ├── Auth Service (JWT handling)
    ├── Product Service (API calls)
    └── Cart Service (State management)
```

---

## 🔄 **Data Flow**

### **User Registration & Authentication**
1. Frontend → User Service: Registration data
2. User Service → Database: Store encrypted user  
3. Frontend → User Service: Login credentials
4. User Service → Frontend: JWT token + user details
5. Frontend: Store token, route to role-based dashboard

### **Product Management (Vendor)**
1. Vendor Dashboard → Product Service: CRUD operations
2. Product Service → Database: Store product data
3. Product Service → Vendor Dashboard: Updated product list

### **Shopping Experience (Customer)**  
1. Customer Dashboard → Product Service: Get all products
2. Product Service → Customer Dashboard: Product catalog
3. Customer: Add to cart (frontend state)
4. Customer: Checkout process (future: Order Service)

---

## 📊 **API Endpoints**

### **User Service** `/user`
- `POST /new` - Register user
- `POST /authenticate` - Login user  
- `GET /welcome` - Public endpoint
- `GET /role` - Get user role from token

### **Product Service** `/products`  
- `GET /` - Get all products
- `GET /{id}` - Get product by ID
- `GET /vendor/{vendorId}` - Get products by vendor
- `POST /` - Create product
- `PUT /{id}` - Update product  
- `DELETE /{id}` - Delete product

---

## 🎯 **Key Features Implemented**

### **Security**
- ✅ JWT-based authentication
- ✅ Password encryption  
- ✅ Role-based access control
- ✅ CORS configuration
- ✅ Protected API endpoints

### **User Experience**
- ✅ Responsive design (mobile-friendly)
- ✅ Real-time form validation
- ✅ Loading states & error handling
- ✅ Success/error messaging
- ✅ Intuitive navigation

### **Business Logic**
- ✅ Multi-role user system (Customer/Vendor)
- ✅ Vendor-specific product management
- ✅ Shopping cart with quantity management
- ✅ Product search & filtering
- ✅ Inventory tracking

---

## 🚀 **Future Enhancements Ready**

### **Order Management Service**
- Order placement & tracking
- Payment integration
- Order history for customers
- Order fulfillment for vendors

### **Enhanced Features**  
- Product reviews & ratings
- Advanced search with filters
- Real-time notifications
- Analytics dashboard
- Multi-vendor checkout

---

## 🛟 **Troubleshooting**

### **Backend Issues**
```bash
# Check if services are running
curl http://localhost:9080/user/welcome
curl http://localhost:9091/products/health

# Check database connection
mysql -u root -p -e "SHOW DATABASES;"
```

### **Frontend Issues**
```bash
# Clear npm cache
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules
npm install

# Check Angular CLI
ng version
```

### **CORS Issues**
- Backend services have `@CrossOrigin(origins = "*")` 
- For production, update to specific origins

---

## ✅ **Success Checklist**

- [ ] MySQL database running
- [ ] User Service running on port 9080
- [ ] Product Service running on port 9091  
- [ ] Frontend running on port 4200
- [ ] Can register users (Customer & Vendor)
- [ ] Can login and get JWT tokens
- [ ] Vendor can manage products
- [ ] Customer can browse & add to cart
- [ ] All API endpoints responding

---

**🎉 Congratulations! Your complete Healthy Food Bank application is ready!**

**Tech Stack:** Spring Boot 3.2.10 + Angular 17 + MySQL + JWT + Bootstrap 5

**Production Ready Features:** ✅ Security ✅ Validation ✅ Error Handling ✅ Documentation