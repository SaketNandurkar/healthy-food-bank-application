# Healthy Food Bank Application - Technical & Functional Specification

**Version:** 1.0
**Date:** March 27, 2026
**Document Type:** Technical Architecture & Product Specification

---

## Executive Summary

The Healthy Food Bank Application is a comprehensive multi-tenant food distribution platform connecting vendors, customers, and administrators through a centralized marketplace with location-based pickup points. The system enables efficient management of fresh food products while providing role-based access control and real-time inventory management.

---

## 1. Technology Stack

### 1.1 Backend Architecture

#### Core Framework
- **Spring Boot 3.x** - Enterprise Java framework for microservices
- **Java 17** - LTS version for production stability
- **Maven** - Dependency management and build automation

#### Microservices
- **user-service** (Port 9090) - User management, authentication, vendor codes
- **product-service** (Port 9091) - Product catalog, inventory, image storage
- **order-service** (Port 9092) - Order processing, transaction management

#### Database
- **MySQL 8.0** - Relational database for transactional data
- **JPA/Hibernate** - Object-relational mapping
- **Spring Data JPA** - Repository abstraction layer

#### Security
- **JWT (JSON Web Tokens)** - Stateless authentication
- **Spring Security** - Authorization and role-based access control
- **BCrypt** - Password hashing algorithm

#### API Documentation
- **Swagger/OpenAPI 3.0** - Interactive API documentation
- **SpringDoc OpenAPI** - Automated API specification generation

#### Additional Technologies
- **Feign Client** - Inter-service communication
- **Lombok** - Boilerplate code reduction
- **Spring Boot DevTools** - Hot reload during development

### 1.2 Frontend Architecture

#### Core Framework
- **Flutter 3.x** - Cross-platform UI framework
- **Dart 3.x** - Programming language
- **Flutter Web** - Web compilation target (Chrome optimized)

#### State Management
- **Riverpod 2.x** - Type-safe state management
- **StateNotifier** - Immutable state updates
- **Provider Pattern** - Dependency injection

#### UI/UX
- **Material Design 3** - Modern design system
- **Custom Premium Theme** - Gradient-based design system
- **Responsive Layout** - Adaptive UI components
- **Staggered Animations** - Smooth transitions and entrance effects

#### Networking
- **http package** - REST API communication
- **flutter_secure_storage** - Secure token storage
- **MultipartRequest** - File upload support

#### Additional Packages
- **intl** - Date/time formatting and internationalization
- **image_picker** - Cross-platform image selection
- **file_picker** - File selection support

---

## 2. System Architecture

### 2.1 Architecture Pattern
**Microservices Architecture** with the following characteristics:
- Independent deployment of services
- Service-to-service communication via REST APIs
- Centralized authentication through user-service
- Decoupled business logic per domain

### 2.2 Data Flow
```
Client (Flutter Web)
    ↓ HTTPS/REST
API Gateway Pattern (Direct service calls)
    ↓
┌─────────────────┬──────────────────┬─────────────────┐
│  User Service   │  Product Service │  Order Service  │
│  (Port 9090)    │   (Port 9091)    │  (Port 9092)    │
└────────┬────────┴─────────┬────────┴────────┬────────┘
         ↓                  ↓                  ↓
    MySQL 8.0          MySQL 8.0          MySQL 8.0
  user_service_db   product_service_db  order_service_db
```

### 2.3 Security Architecture
- **JWT-based authentication** with Bearer tokens
- **Role-based authorization** (CUSTOMER, VENDOR, ADMIN)
- **Password encryption** using BCrypt
- **CORS configuration** for web client security
- **Secure file storage** with access control

---

## 3. Functional Specification

### 3.1 User Roles & Capabilities

#### 3.1.1 Customer Role
**Authentication & Profile**
- Register with email and password
- Login with JWT token generation
- Update profile information (name, email, phone)
- Change password with current password verification
- View and manage active pickup points

**Product Discovery**
- Browse products filtered by active pickup point
- Search products by name or category
- View product details (name, price, image, vendor)
- Real-time product availability status

**Shopping & Orders**
- Add products to cart with quantity selection
- View cart summary with total calculation
- Place orders for specific pickup points
- Track order status (PENDING, CONFIRMED, DELIVERED, CANCELLED)
- View order history with detailed breakdowns

**Pickup Point Management**
- Select active pickup point for browsing
- View available pickup points
- Associate with multiple pickup points

#### 3.1.2 Vendor Role
**Authentication & Onboarding**
- Register using valid vendor code
- Vendor code validation system
- Profile management with vendor-specific fields

**Product Management**
- Create products with details (name, price, description, category)
- Upload product images (JPG, PNG formats)
- Edit product information
- Manage product availability status
- Set stock quantities

**Pickup Point Association**
- Add/remove pickup points for product distribution
- Products visible only to customers in associated pickup points
- Many-to-many relationship between vendors and pickup points

**Order Management**
- View incoming orders by pickup point
- Update order status (confirm, mark as ready, deliver)
- Track order history and revenue
- Manage multiple concurrent orders

**Inventory Tracking**
- Monitor product stock levels
- Update availability in real-time
- Bulk product operations

#### 3.1.3 Admin Role
**User Management**
- View all users (customers, vendors, admins)
- Filter users by role
- Activate/deactivate user accounts
- View user statistics and analytics
- Monitor user activity

**Vendor Code Management**
- Generate vendor registration codes
- Auto-generate unique codes or custom codes
- Mark codes as active/inactive
- Track code usage (used/unused status)
- View which vendor used which code
- Deactivate or delete unused codes

**Pickup Point Administration**
- Create pickup points with location details
- Edit pickup point information
- Activate/deactivate pickup points
- View vendor associations
- Manage pickup point capacity

**System Oversight**
- Dashboard with key metrics (users, orders, revenue)
- Recent activity feed
- Quick actions for common tasks
- System-wide configuration

### 3.2 Core Workflows

#### 3.2.1 Vendor Onboarding Workflow
```
1. Admin creates vendor code (e.g., SPICES01)
   ↓
2. Vendor registers with email + vendor code
   ↓
3. System validates code (active + unused)
   ↓
4. System marks code as "used" and assigns to vendor
   ↓
5. Vendor account created with VENDOR role
   ↓
6. Vendor logs in and accesses vendor dashboard
```

#### 3.2.2 Product Discovery Workflow
```
1. Customer selects active pickup point
   ↓
2. System loads products from vendors associated with pickup point
   ↓
3. Customer browses filtered product list
   ↓
4. Products show vendor name, price, availability
   ↓
5. Customer can search/filter further
   ↓
6. Click product for detailed view
```

#### 3.2.3 Order Processing Workflow
```
1. Customer adds products to cart
   ↓
2. Cart validates against active pickup point
   ↓
3. Customer reviews cart and places order
   ↓
4. Order created with PENDING status
   ↓
5. Vendor receives order notification
   ↓
6. Vendor confirms order (CONFIRMED status)
   ↓
7. Vendor prepares order (READY status)
   ↓
8. Customer picks up order
   ↓
9. Vendor marks as DELIVERED
```

#### 3.2.4 Pickup Point System Workflow
```
1. Admin creates pickup point (location, timings)
   ↓
2. Admin activates pickup point
   ↓
3. Vendor adds pickup point to their service areas
   ↓
4. Vendor's products become visible at that pickup point
   ↓
5. Customers select pickup point to browse
   ↓
6. System filters products by pickup point association
```

---

## 4. Technical Implementation Details

### 4.1 Backend Design Patterns

#### Repository Pattern
```java
@Repository
public interface UserRepository extends JpaRepository<Customer, Integer> {
    Optional<Customer> findByUserName(String username);
    List<Customer> findByRoles(String role);
}
```

#### Service Layer Pattern
```java
@Service
@Transactional
public class UserService {
    // Business logic encapsulation
    // Transaction management
    // Error handling
}
```

#### DTO Pattern
- Request/Response DTOs for API contracts
- Entity-DTO mapping for data transfer
- Separation of persistence and presentation layers

### 4.2 Database Schema Highlights

#### Key Tables
- **customers** - User accounts with roles and authentication
- **vendor_codes** - Registration codes with usage tracking
- **pickup_points** - Delivery locations with active status
- **vendor_pickup_points** - Many-to-many association table
- **products** - Product catalog with vendor references
- **orders** - Order transactions with status tracking

#### Relationships
- One vendor → Many products
- Many vendors ↔ Many pickup points
- One customer → Many orders
- One order → Many products (via order_items)

### 4.3 API Design

#### RESTful Conventions
- **GET** - Retrieve resources
- **POST** - Create resources
- **PUT** - Update resources
- **DELETE** - Delete/deactivate resources

#### Authentication Headers
```
Authorization: Bearer <JWT_TOKEN>
X-User-Id: <USER_ID>
X-Customer-Id: <CUSTOMER_ID>
```

#### Response Format
```json
{
  "success": true,
  "data": { /* resource */ },
  "error": null,
  "statusCode": 200
}
```

### 4.4 Frontend Architecture Patterns

#### State Management Pattern
```dart
// State class with immutability
class VendorCodesState {
  final List<VendorCode> codes;
  final bool isLoading;
  final String? error;

  VendorCodesState copyWith({...}) { /* immutable update */ }
}

// StateNotifier for business logic
class VendorCodesNotifier extends StateNotifier<VendorCodesState> {
  Future<void> createCode() async { /* API call */ }
}

// Provider for dependency injection
final vendorCodesProvider = StateNotifierProvider<...>((ref) {
  return VendorCodesNotifier(ref.watch(adminServiceProvider));
});
```

#### Service Layer Pattern
```dart
class AdminService {
  final ApiClient _api = ApiClient();

  Future<VendorCode> createVendorCode({String? customCode}) async {
    final response = await _api.post(url, body: body);
    return VendorCode.fromJson(response.data);
  }
}
```

#### Navigation Architecture
- **Provider-based navigation** for tab switching
- **Named routes** for screen navigation
- **Role-based routing** after authentication

---

## 5. Key Features Implemented

### 5.1 Authentication & Authorization
✅ JWT token generation and validation
✅ Role-based access control (RBAC)
✅ Secure password storage with BCrypt
✅ Token expiration and refresh
✅ Protected routes and endpoints

### 5.2 User Management
✅ Multi-role user registration
✅ Profile management with validation
✅ Password change functionality
✅ User activation/deactivation (Admin)
✅ User statistics dashboard

### 5.3 Vendor Code System
✅ Custom and auto-generated codes
✅ Code validation during registration
✅ Usage tracking (used/unused status)
✅ Code lifecycle management (create, activate, deactivate)
✅ Vendor assignment tracking

### 5.4 Pickup Point System
✅ Location-based product filtering
✅ Many-to-many vendor-pickup point associations
✅ Active/inactive status management
✅ Vendor service area management
✅ Customer pickup point selection

### 5.5 Product Management
✅ CRUD operations for products
✅ Image upload and storage
✅ Category-based organization
✅ Vendor-specific product catalogs
✅ Stock availability tracking

### 5.6 Order Management
✅ Shopping cart functionality
✅ Order placement with validation
✅ Status tracking (PENDING → DELIVERED)
✅ Order history for customers and vendors
✅ Pickup point-specific orders

### 5.7 UI/UX Features
✅ Material Design 3 implementation
✅ Premium gradient design system
✅ Staggered animations
✅ Pull-to-refresh functionality
✅ Auto-refresh on app resume
✅ Loading states and error handling
✅ Empty states with illustrations
✅ Responsive layouts

---

## 6. Technical Achievements

### 6.1 Backend Excellence
- **Microservices architecture** with independent scalability
- **RESTful API design** with OpenAPI documentation
- **Transaction management** with JPA
- **Error handling** with proper HTTP status codes
- **Inter-service communication** using Feign clients
- **CORS configuration** for web client support

### 6.2 Frontend Excellence
- **Type-safe state management** with Riverpod
- **Immutable state updates** for predictability
- **Separation of concerns** (UI, Business Logic, Data)
- **Reusable component library** (PremiumHeader, PremiumCard)
- **Custom animation system** (StaggeredListItem, PressableScale)
- **Cross-platform compatibility** (Web, Mobile ready)

### 6.3 Security Best Practices
- Password hashing (never stored in plain text)
- JWT stateless authentication
- Role-based authorization at API and UI levels
- Input validation on both client and server
- Secure file storage with access control
- HTTPS-ready infrastructure

### 6.4 Developer Experience
- Hot reload for rapid development
- Comprehensive API documentation with Swagger
- Type safety with Dart and Java
- Dependency injection for testability
- Modular code organization
- Clear separation of layers

---

## 7. Database Configuration

### MySQL Connection Details
```properties
# User Service
spring.datasource.url=jdbc:mysql://localhost:3306/user_service_db
spring.datasource.username=root
spring.datasource.password=password

# Product Service
spring.datasource.url=jdbc:mysql://localhost:3306/product_service_db
spring.datasource.username=root
spring.datasource.password=password

# Order Service
spring.datasource.url=jdbc:mysql://localhost:3306/order_service_db
spring.datasource.username=root
spring.datasource.password=password
```

---

## 8. API Endpoints Summary

### User Service (Port 9090)
- `POST /user/new` - Register user
- `POST /user/authenticate` - Login
- `GET /user/role` - Get user role from token
- `PUT /user/profile/{userId}` - Update profile
- `PUT /user/password/{userId}` - Change password
- `GET /user/admin/users` - Get all users (Admin)
- `PUT /user/admin/users/{id}/activate` - Activate user (Admin)
- `PUT /user/admin/users/{id}/deactivate` - Deactivate user (Admin)
- `GET /user/admin/vendor-codes` - Get vendor codes (Admin)
- `POST /user/admin/vendor-codes` - Create vendor code (Admin)
- `PUT /user/admin/vendor-codes/{id}` - Update vendor code (Admin)
- `DELETE /user/admin/vendor-codes/{id}` - Delete vendor code (Admin)
- `GET /user/validate-vendor-code/{code}` - Validate vendor code

### Product Service (Port 9091)
- `GET /products` - Get all products
- `GET /products/{id}` - Get product by ID
- `POST /products` - Create product
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Delete product
- `POST /products/upload-image` - Upload product image
- `GET /products/by-user/{userId}` - Get products by vendor
- `GET /products/by-pickup-point/{pickupPointId}` - Get products by pickup point

### Order Service (Port 9092)
- `GET /orders` - Get all orders
- `GET /orders/{id}` - Get order by ID
- `POST /orders` - Create order
- `PUT /orders/{id}/status` - Update order status
- `GET /orders/customer/{customerId}` - Get customer orders
- `GET /orders/vendor/{vendorId}` - Get vendor orders

---

## 9. Future Enhancements

### 9.1 Planned Features
- Real-time notifications (WebSocket/Firebase)
- Payment gateway integration
- Order tracking with GPS
- Review and rating system
- Advanced analytics dashboard
- Multi-language support
- Push notifications
- In-app messaging between customers and vendors
- Loyalty program and rewards
- Promotional campaigns and coupons

### 9.2 Technical Improvements
- API Gateway (Spring Cloud Gateway)
- Service discovery (Eureka)
- Load balancing
- Centralized configuration (Spring Cloud Config)
- Circuit breaker pattern (Resilience4j)
- Distributed tracing (Sleuth + Zipkin)
- Caching layer (Redis)
- Message queue (RabbitMQ/Kafka)
- Docker containerization
- Kubernetes orchestration
- CI/CD pipeline
- Automated testing (unit, integration, e2e)

---

## 10. Development Guidelines

### 10.1 Code Standards
- Follow SOLID principles
- Write self-documenting code
- Use meaningful variable names
- Keep methods small and focused
- Write comprehensive comments for complex logic
- Follow consistent naming conventions

### 10.2 Git Workflow
- Feature branch workflow
- Meaningful commit messages
- Pull request reviews
- Co-authored commits with Claude Code

### 10.3 Testing Strategy
- Unit tests for business logic
- Integration tests for APIs
- Widget tests for Flutter UI
- End-to-end tests for critical workflows

---

## 11. Deployment Architecture

### 11.1 Current Setup
- **Backend**: Local development servers (ports 9090-9092)
- **Database**: Local MySQL 8.0 instances
- **Frontend**: Flutter Web (Chrome)
- **File Storage**: Local filesystem (uploads/products/)

### 11.2 Production Recommendations
- **Backend**: AWS EC2 or Azure VMs for microservices
- **Database**: AWS RDS MySQL or Azure Database for MySQL
- **Frontend**: AWS S3 + CloudFront or Azure Static Web Apps
- **File Storage**: AWS S3 or Azure Blob Storage
- **Load Balancer**: AWS ALB or Azure Load Balancer
- **SSL/TLS**: AWS Certificate Manager or Let's Encrypt

---

## 12. Performance Considerations

### 12.1 Backend Optimization
- Database connection pooling (HikariCP)
- JPA query optimization
- Proper indexing on frequently queried columns
- Lazy loading for associations
- Pagination for large datasets

### 12.2 Frontend Optimization
- Image compression and lazy loading
- Widget caching with const constructors
- Efficient state management
- Debounced search
- Pagination for long lists
- Virtual scrolling for large datasets

---

## 13. Monitoring & Logging

### 13.1 Backend Logging
- SLF4J with Logback
- Structured logging (JSON format)
- Log levels: INFO, WARN, ERROR
- Request/response logging
- Error stack traces

### 13.2 Frontend Logging
- Print statements for debugging
- Error boundary for crash reporting
- Analytics integration ready

---

## 14. Conclusion

The Healthy Food Bank Application represents a robust, scalable, and maintainable solution for food distribution management. Built on modern technologies and following industry best practices, the system provides a solid foundation for future growth and feature expansion.

### Key Strengths
✅ **Microservices Architecture** - Independent, scalable services
✅ **Type-Safe Development** - Java + Dart for reliability
✅ **Modern UI/UX** - Material Design 3 with premium animations
✅ **Secure Authentication** - JWT-based with role management
✅ **Comprehensive Features** - Complete user journeys for all roles
✅ **Developer-Friendly** - Clean code, good documentation
✅ **Production-Ready** - Security, error handling, validation

### Project Status
**Phase 1: Core Features** ✅ Complete
- User authentication and authorization
- Product management with images
- Order processing
- Pickup point system
- Admin panel with vendor code management

**Phase 2: Advanced Features** 🚧 In Progress
- Real-time notifications
- Advanced analytics
- Payment integration

---

**Document Prepared By:** Senior Technical Architect & Product Owner
**Experience:** 25+ Years in Enterprise Architecture & Product Management
**Specialization:** Microservices, Cloud Architecture, Full-Stack Development

**Last Updated:** March 27, 2026
**Project:** Healthy Food Bank Application v1.0
