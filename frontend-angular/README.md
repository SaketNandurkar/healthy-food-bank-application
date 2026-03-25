# Healthy Food Bank - Angular Frontend

A comprehensive Angular frontend application for the Healthy Food Bank microservices platform.

## 🚀 Features

### Authentication System
- **User Registration**: Complete registration with role-based access (Customer/Vendor)
- **User Login**: Secure JWT-based authentication
- **Role-based Routing**: Different dashboards for different user roles

### Vendor Features
- **Product Management**: Add, edit, delete, and view products
- **Inventory Tracking**: Monitor stock levels and product performance
- **Dashboard Analytics**: View statistics about products, sales, and inventory
- **Category Management**: Organize products by categories (Vegetables, Fruits, Dairy, etc.)

### Customer Features
- **Product Catalog**: Browse all available products from all vendors
- **Search & Filter**: Find products by name, category, or vendor
- **Shopping Cart**: Add/remove products, manage quantities
- **Checkout Process**: Place orders with delivery information

### Shared Features
- **Responsive Design**: Mobile-first design using Bootstrap 5
- **Real-time Updates**: Live cart updates and product availability
- **Security**: JWT-based authentication with role-based access control
- **User Experience**: Intuitive UI/UX with loading states and error handling

## 🛠️ Technology Stack

- **Framework**: Angular 17
- **Styling**: Bootstrap 5 + Custom CSS
- **Icons**: Font Awesome 6
- **HTTP Client**: Angular HttpClient
- **Forms**: Reactive Forms
- **Routing**: Angular Router with Guards
- **State Management**: RxJS Observables + Services

## 📁 Project Structure

```
frontend-angular/
├── src/
│   ├── app/
│   │   ├── components/
│   │   │   ├── auth/
│   │   │   │   ├── login/
│   │   │   │   └── register/
│   │   │   ├── customer/
│   │   │   │   └── customer-dashboard/
│   │   │   ├── vendor/
│   │   │   │   └── vendor-dashboard/
│   │   │   └── shared/
│   │   ├── services/
│   │   │   ├── auth.service.ts
│   │   │   ├── product.service.ts
│   │   │   └── cart.service.ts
│   │   ├── models/
│   │   │   ├── user.model.ts
│   │   │   ├── product.model.ts
│   │   │   └── cart.model.ts
│   │   ├── guards/
│   │   │   ├── auth.guard.ts
│   │   │   ├── vendor.guard.ts
│   │   │   └── customer.guard.ts
│   │   └── app-routing.module.ts
│   ├── environments/
│   ├── assets/
│   └── styles.css
├── package.json
├── angular.json
└── README.md
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn
- Angular CLI (`npm install -g @angular/cli`)

### Installation

1. **Clone and navigate to the frontend directory**
   ```bash
   cd frontend-angular
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   Update `src/environments/environment.ts` with your backend service URLs:
   ```typescript
   export const environment = {
     production: false,
     apiUrl: 'http://localhost:8080',
     userServiceUrl: 'http://localhost:9080',
     productServiceUrl: 'http://localhost:9091',
     orderServiceUrl: 'http://localhost:9092'
   };
   ```

4. **Start the development server**
   ```bash
   ng serve
   ```

5. **Open your browser**
   Navigate to `http://localhost:4200`

## 🔧 Backend Integration

### Required Backend Endpoints

#### User Service (Port 9080)
- `POST /user/new` - User registration
- `POST /user/authenticate` - User login
- `GET /user/{id}` - Get user details

#### Product Service (Port 9091)
- `GET /products` - Get all products
- `GET /products/vendor/{vendorId}` - Get products by vendor
- `GET /products/{id}` - Get product by ID
- `POST /products` - Create new product
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Delete product

#### Order Service (Port 9092) - Future Implementation
- `POST /orders` - Create new order
- `GET /orders/customer/{customerId}` - Get customer orders
- `GET /orders/vendor/{vendorId}` - Get vendor orders

## 👥 User Roles & Access

### Customer Role
- Browse all products
- Search and filter products
- Add products to cart
- Place orders
- View order history

### Vendor Role
- Manage own products (CRUD operations)
- View product analytics
- Monitor inventory
- Process orders

### Registration Fields
- **All Users**: First Name, Last Name, Email, Phone, Username, Password
- **Vendors Only**: Vendor ID (unique identifier)

## 🎨 UI/UX Features

### Design System
- **Color Scheme**: Green-based theme representing fresh, healthy food
- **Typography**: Inter font family for modern readability
- **Components**: Bootstrap 5 components with custom styling
- **Icons**: Font Awesome icons for consistent visual language

### Responsive Design
- Mobile-first approach
- Responsive grid layouts
- Touch-friendly interfaces
- Progressive enhancement

### User Experience
- Loading states for async operations
- Form validation with real-time feedback
- Success/error message handling
- Intuitive navigation flows

## 🔐 Security Features

### Authentication
- JWT token-based authentication
- Secure token storage in localStorage
- Automatic token expiration handling
- Route protection with guards

### Authorization
- Role-based access control
- Route guards for different user types
- API endpoint protection
- Secure form submissions

## 🚀 Development Commands

```bash
# Start development server
ng serve

# Build for production
ng build --prod

# Run unit tests
ng test

# Run e2e tests
ng e2e

# Generate component
ng generate component component-name

# Generate service
ng generate service service-name

# Lint code
ng lint
```

## 🔄 API Integration

### Service Architecture
Each service encapsulates specific business logic:
- **AuthService**: Handles user authentication and session management
- **ProductService**: Manages product-related API calls
- **CartService**: Handles shopping cart state and operations

### HTTP Interceptors
- JWT token attachment to authenticated requests
- Error handling and user-friendly error messages
- Request/response logging for debugging

### Error Handling
- Global error handling with user-friendly messages
- Network error recovery
- Validation error display

## 📱 Future Enhancements

### Planned Features
1. **Order Management System**
   - Order tracking
   - Order status updates
   - Order history

2. **Payment Integration**
   - Multiple payment gateways
   - Secure payment processing
   - Payment history

3. **Real-time Features**
   - WebSocket integration
   - Real-time inventory updates
   - Live order tracking

4. **Advanced Features**
   - Product reviews and ratings
   - Vendor profiles
   - Advanced search filters
   - Recommendation engine

### Technical Improvements
- Progressive Web App (PWA) capabilities
- Offline functionality
- Push notifications
- Advanced caching strategies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Happy Coding! 🚀**