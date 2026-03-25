# 🚀 Frontend Setup Guide

## Quick Start Instructions

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn package manager
- Angular CLI

### 1. Install Node.js and npm
```bash
# Download and install Node.js from https://nodejs.org
# Verify installation
node --version
npm --version
```

### 2. Install Angular CLI globally
```bash
npm install -g @angular/cli@17
```

### 3. Navigate to the frontend directory
```bash
cd frontend-angular
```

### 4. Install dependencies
```bash
npm install
```

### 5. Start the development server
```bash
ng serve
```

### 6. Open your browser
Navigate to `http://localhost:4200`

## 🔧 Backend Integration Setup

### Required Backend Services
Make sure these microservices are running:

1. **User Service** - Port 9080
2. **Product Service** - Port 9091  
3. **Order Service** - Port 9092 (optional for future)

### Environment Configuration
The frontend is pre-configured to work with your local backend services. If you need to change the URLs, update:

`src/environments/environment.ts`

## 📱 User Testing Guide

### Test User Registration
1. Go to `http://localhost:4200`
2. Click "Register here"
3. Fill in the form:
   - **Customer Registration**: Select "CUSTOMER" role
   - **Vendor Registration**: Select "VENDOR" role and provide Vendor ID

### Test Vendor Features
1. Register as a vendor or login with vendor credentials
2. Access vendor dashboard at `/vendor/dashboard`
3. Add/Edit/Delete products
4. View inventory statistics

### Test Customer Features  
1. Register as a customer or login with customer credentials
2. Access customer dashboard at `/customer/dashboard`
3. Browse products from all vendors
4. Add products to cart
5. Complete checkout process

## 🛠️ Development Commands

```bash
# Start development server
ng serve

# Start with custom port
ng serve --port 4201

# Build for production
ng build --configuration production

# Run unit tests
ng test

# Generate new component
ng generate component components/new-component

# Generate new service
ng generate service services/new-service
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Port already in use
```bash
# Use different port
ng serve --port 4201
```

#### 2. Node modules not found
```bash
# Delete node_modules and reinstall
rm -rf node_modules
npm install
```

#### 3. Angular CLI not found
```bash
# Install globally
npm install -g @angular/cli@17
```

#### 4. Backend connection issues
- Check if backend services are running
- Verify URLs in `environment.ts`
- Check browser console for CORS errors

### Browser Console Errors
- Open Developer Tools (F12)
- Check Console tab for error messages
- Verify Network tab for failed API calls

## 🎨 Customization

### Styling
- Global styles: `src/styles.css`
- Component styles: `*.component.css` files
- Bootstrap classes available throughout

### Adding New Features
1. Create new components: `ng generate component`
2. Create new services: `ng generate service`  
3. Update routing: `app-routing.module.ts`
4. Add to module: `app.module.ts`

## 📦 Production Build

```bash
# Build for production
ng build --configuration production

# Files will be in dist/ folder
# Deploy these files to your web server
```

## 🔐 Security Notes

- JWT tokens stored in localStorage
- Route guards protect authenticated pages
- CORS configured for backend communication
- Form validation prevents invalid submissions

## 📞 Support

If you encounter issues:
1. Check this guide first
2. Verify backend services are running
3. Check browser console for errors
4. Ensure all dependencies are installed

---

**Happy Coding! 🚀**