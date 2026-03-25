# Microservice Separation Guide

## Architecture Issues Fixed

This user-service currently contains entities and logic that should be separated into different microservices:

### Current Structure (Problematic):
- User Service contains: Customer, Product, Order entities
- Mixed responsibilities in a single service
- Tight coupling between domains

### Recommended Structure:

#### 1. User Service (Current)
- **Entities**: Customer only
- **Responsibilities**: User management, authentication, authorization
- **Port**: 9090

#### 2. Product Service (To be created)
- **Entities**: Product
- **Responsibilities**: Product management, inventory
- **Port**: 9091
- **Database**: product_service_db

#### 3. Order Service (To be created)  
- **Entities**: Order
- **Responsibilities**: Order processing, order history
- **Port**: 9092
- **Database**: order_service_db

### Files to Move/Remove from User Service:

#### Move to Product Service:
- `entity/Product.java`
- `controller/ProductController.java`
- `controller/ProductWebSocketController.java`
- `service/ProductService.java`
- `repository/ProductRepository.java`
- `dto/ProductDTO.java`
- `mapper/ProductMapper.java`
- `handler/ProductWebSocketHandler.java`

#### Move to Order Service:
- `entity/Order.java`
- `service/OrderService.java`
- `repository/OrderRepository.java`
- `dto/OrderDTO.java`
- `mapper/OrderMapper.java`

#### Remove from Customer Entity:
- Remove `@OneToMany` relationship with Product
- Products should be linked via customer ID, not direct entity relationship

### Communication Between Services:
- Use REST API calls with service discovery
- Implement circuit breakers for fault tolerance
- Use event-driven architecture for data consistency

### Database Changes:
- Separate databases for each service
- Remove cross-service foreign key constraints
- Use customer_id as reference instead of entity relationships

## Next Steps:
1. Create separate Spring Boot applications for Product and Order services
2. Move the respective files to new services
3. Update database schemas
4. Test inter-service communication
5. Remove circular dependencies