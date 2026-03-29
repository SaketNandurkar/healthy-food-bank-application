package order_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import order_service.dto.OrderDTO;
import order_service.dto.ProductDemandSummary;
import order_service.dto.VendorOrderSummaryResponse;
import order_service.entity.Order;
import order_service.exception.OrderNotFoundException;
import order_service.exception.OrderCutoffException;
import order_service.mapper.OrderMapper;
import order_service.repository.OrderRepository;
import order_service.util.OrderTimeValidator;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    private final OrderRepository orderRepository;

    @Autowired
    private OrderNotificationService orderNotificationService;

    @Autowired
    private VendorService vendorService;

    @Autowired
    private ProductServiceClient productServiceClient;

    @Autowired
    private org.springframework.web.client.RestTemplate restTemplate;

    @Autowired
    private OrderTimeValidator orderTimeValidator;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    public Order createOrder(Order order, Long customerId) {
        try {
            logger.info("Creating order for customer: {} with vendorId: {}", customerId, order.getVendorId());

            // ========== ORDER CUTOFF VALIDATION ==========
            // Validate if order placement is allowed based on business rules
            // Orders are only accepted Monday-Friday before 8:00 PM IST
            if (!orderTimeValidator.isOrderAllowed()) {
                logger.warn("Order creation blocked - outside allowed time window. Current time (IST): {}",
                        orderTimeValidator.getCurrentTimeIST());
                throw new OrderCutoffException(
                        "Order window closed. Please order before Friday 8 PM IST for weekend delivery."
                );
            }
            logger.info("Order time validation passed. Current time (IST): {}",
                    orderTimeValidator.getCurrentTimeIST());
            // ============================================

            order.setCustomerId(customerId);

            // Fetch and set customer details
            try {
                String url = "http://localhost:9090/customer/" + customerId;
                logger.info("Fetching customer details from: {}", url);
                order_service.dto.CustomerDTO customer = restTemplate.getForObject(url, order_service.dto.CustomerDTO.class);
                if (customer != null) {
                    String customerName = customer.getFirstName() + " " + customer.getLastName();
                    order.setCustomerName(customerName);
                    order.setCustomerPhone(String.valueOf(customer.getPhoneNumber()));

                    // Fetch pickup point name if pickupPointId exists
                    if (customer.getPickupPointId() != null) {
                        String pickupUrl = "http://localhost:9090/pickup-points/" + customer.getPickupPointId();
                        logger.info("Fetching pickup point details from: {}", pickupUrl);
                        order_service.dto.PickupPointDTO pickupPoint = restTemplate.getForObject(pickupUrl, order_service.dto.PickupPointDTO.class);
                        if (pickupPoint != null) {
                            order.setCustomerPickupPoint(pickupPoint.getName());
                            logger.info("Set customer pickup point: {} for customer: {}", pickupPoint.getName(), customerName);
                        }
                    }
                    logger.info("Set customer details - Name: {}, Phone: {}", customerName, order.getCustomerPhone());
                }
            } catch (Exception e) {
                logger.warn("Could not fetch customer details for customer ID: {}", customerId, e);
                // Continue without customer details rather than failing the order
            }

            // Fetch and set vendor name if vendorId is present
            if (order.getVendorId() != null && !order.getVendorId().trim().isEmpty()) {
                String vendorName = vendorService.getVendorNameByVendorId(order.getVendorId());
                if (vendorName != null) {
                    order.setVendorName(vendorName);
                    logger.info("Set vendor name: {} for vendorId: {}", vendorName, order.getVendorId());
                }
            }

            // Check if there's an existing ISSUED order for the same customer, product, and vendor
            if (order.getProductId() != null && order.getVendorId() != null) {
                var existingOrder = orderRepository.findByCustomerIdAndProductIdAndVendorIdAndOrderStatus(
                        customerId, order.getProductId(), order.getVendorId(), "ISSUED");

                if (existingOrder.isPresent()) {
                    // Merge quantities: add new quantity to existing order
                    Order orderToUpdate = existingOrder.get();
                    double newTotalQuantity = orderToUpdate.getOrderQuantity() + order.getOrderQuantity();
                    double newTotalPrice = orderToUpdate.getOrderPrice() + order.getOrderPrice();

                    logger.info("Merging order: existing order ID {} has quantity {}, adding {} more",
                            orderToUpdate.getId(), orderToUpdate.getOrderQuantity(), order.getOrderQuantity());

                    orderToUpdate.setOrderQuantity(newTotalQuantity);
                    orderToUpdate.setOrderPrice(newTotalPrice);

                    // Deduct stock for the NEW quantity being added
                    logger.info("Deducting stock for product ID: {}, quantity: {}, unit: {}",
                            order.getProductId(), order.getOrderQuantity(), order.getOrderUnit());
                    boolean stockDeducted = productServiceClient.deductStock(
                            order.getProductId(),
                            order.getOrderQuantity(),
                            order.getOrderUnit()
                    );
                    if (!stockDeducted) {
                        logger.error("Failed to deduct stock for product ID: {}. Insufficient stock available.",
                                order.getProductId());
                        throw new RuntimeException("Insufficient stock available for product ID: " + order.getProductId());
                    }
                    logger.info("Successfully deducted stock for product ID: {}", order.getProductId());

                    // Save updated order
                    Order savedOrder = orderRepository.save(orderToUpdate);
                    logger.info("Successfully merged order with ID: {} for vendor: {}. New quantity: {}",
                            savedOrder.getId(), savedOrder.getVendorId(), savedOrder.getOrderQuantity());

                    // Send notification about updated order
                    if (savedOrder.getVendorId() != null && !savedOrder.getVendorId().isEmpty()) {
                        orderNotificationService.notifyVendorAboutNewOrder(savedOrder);
                    }

                    return savedOrder;
                }
            }

            // No existing ISSUED order found, create new order
            // Deduct stock BEFORE creating order if productId is present
            if (order.getProductId() != null) {
                logger.info("Deducting stock for product ID: {}, quantity: {}, unit: {}",
                        order.getProductId(), order.getOrderQuantity(), order.getOrderUnit());
                boolean stockDeducted = productServiceClient.deductStock(
                        order.getProductId(),
                        order.getOrderQuantity(),
                        order.getOrderUnit()
                );
                if (!stockDeducted) {
                    logger.error("Failed to deduct stock for product ID: {}. Insufficient stock available.", order.getProductId());
                    throw new RuntimeException("Insufficient stock available for product ID: " + order.getProductId());
                }
                logger.info("Successfully deducted stock for product ID: {}", order.getProductId());
            }

            // Save order AFTER successful stock deduction
            Order savedOrder = orderRepository.save(order);
            logger.info("Successfully created order with ID: {} for vendor: {}", savedOrder.getId(), savedOrder.getVendorId());

            // Send real-time notification to vendor if vendorId is present
            if (savedOrder.getVendorId() != null && !savedOrder.getVendorId().isEmpty()) {
                orderNotificationService.notifyVendorAboutNewOrder(savedOrder);
            }

            return savedOrder;
        } catch (RuntimeException e) {
            logger.error("Error creating order for customer: {}", customerId, e);
            throw e;
        } catch (Exception e) {
            logger.error("Unexpected error creating order for customer: {}", customerId, e);
            throw new RuntimeException("Failed to create order: " + e.getMessage(), e);
        }
    }

    // Legacy method - kept for backward compatibility
    public Order updateOrderStatus(Integer orderId, String status) {
        try {
            logger.info("Updating order status for order ID: {} to {}", orderId, status);

            Order order = orderRepository.findById(orderId)
                    .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + orderId));

            String oldStatus = order.getOrderStatus();
            order.setOrderStatus(status);
            Order savedOrder = orderRepository.save(order);

            logger.info("Successfully updated order status for ID: {}", savedOrder.getId());

            // Send real-time notification to vendor about status update if vendorId is present
            if (savedOrder.getVendorId() != null && !savedOrder.getVendorId().isEmpty()) {
                orderNotificationService.notifyVendorAboutOrderUpdate(savedOrder, oldStatus);
            }

            return savedOrder;
        } catch (OrderNotFoundException e) {
            logger.warn("Order not found with ID: {}", orderId);
            throw e;
        } catch (Exception e) {
            logger.error("Error updating order status for ID: {}", orderId, e);
            throw new RuntimeException("Failed to update order status", e);
        }
    }

    /**
     * ========== VENDOR ORDER LIFECYCLE MANAGEMENT ==========
     * Update order status with validation (vendor ownership + valid transitions)
     *
     * Valid transitions:
     * - ISSUED → SCHEDULED (via acceptOrder)
     * - SCHEDULED → READY
     * - READY → DELIVERED
     *
     * @param orderId Order ID to update
     * @param vendorId Vendor ID making the update (for ownership check)
     * @param newStatus New status to set
     * @return Updated order
     * @throws IllegalArgumentException if transition is invalid or vendor doesn't own order
     */
    public Order updateOrderStatusWithValidation(Integer orderId, String vendorId, String newStatus) {
        try {
            logger.info("Vendor {} updating order {} status to {}", vendorId, orderId, newStatus);

            // Fetch order
            Order order = orderRepository.findById(orderId)
                    .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + orderId));

            // ===== VALIDATION 1: Vendor Ownership =====
            if (!vendorId.equals(order.getVendorId())) {
                logger.warn("Vendor {} attempted to update order {} owned by vendor {}",
                        vendorId, orderId, order.getVendorId());
                throw new IllegalArgumentException(
                        "Access denied: Vendor can only update their own orders");
            }

            String currentStatus = order.getOrderStatus();

            // ===== VALIDATION 2: Valid Status Transition =====
            if (!isValidStatusTransition(currentStatus, newStatus)) {
                logger.warn("Invalid status transition attempted: {} → {} for order {}",
                        currentStatus, newStatus, orderId);
                throw new IllegalArgumentException(
                        String.format("Invalid status transition: %s → %s. " +
                                "Valid transitions: ISSUED→SCHEDULED, SCHEDULED→READY, READY→DELIVERED",
                                currentStatus, newStatus));
            }

            // Update status and set timestamp based on transition
            order.setOrderStatus(newStatus);
            LocalDateTime now = LocalDateTime.now();
            order.setStatusUpdatedAt(now); // Track status update time for polling notifications

            // Set appropriate timestamp for each status transition
            switch (newStatus) {
                case "SCHEDULED":
                    order.setScheduledDate(now);
                    logger.info("Set scheduledDate for order {}", orderId);
                    break;
                case "READY":
                    order.setReadyDate(now);
                    logger.info("Set readyDate for order {}", orderId);
                    break;
                case "DELIVERED":
                    order.setDeliveredDate(now);
                    order.setOrderDeliveredDate(now); // Keep for backward compatibility
                    logger.info("Set deliveredDate for order {}", orderId);
                    break;
            }

            Order savedOrder = orderRepository.save(order);

            logger.info("Successfully updated order {} status: {} → {}",
                    orderId, currentStatus, newStatus);

            // Send notification
            if (savedOrder.getVendorId() != null && !savedOrder.getVendorId().isEmpty()) {
                orderNotificationService.notifyVendorAboutOrderUpdate(savedOrder, currentStatus);
            }

            return savedOrder;

        } catch (OrderNotFoundException | IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            logger.error("Error updating order status for ID: {}", orderId, e);
            throw new RuntimeException("Failed to update order status: " + e.getMessage(), e);
        }
    }

    /**
     * Validate if status transition is allowed
     *
     * @param currentStatus Current order status
     * @param newStatus Target status
     * @return true if transition is valid
     */
    private boolean isValidStatusTransition(String currentStatus, String newStatus) {
        // Define allowed transitions
        return switch (currentStatus) {
            case "ISSUED" -> "SCHEDULED".equals(newStatus);
            case "SCHEDULED" -> "READY".equals(newStatus);
            case "READY" -> "DELIVERED".equals(newStatus);
            default -> false;
        };
    }

    public Order updateOrderVendor(Integer orderId, String vendorId) {
        try {
            logger.info("Updating vendor for order ID: {} to {}", orderId, vendorId);

            Order order = orderRepository.findById(orderId)
                    .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + orderId));

            order.setVendorId(vendorId);
            Order savedOrder = orderRepository.save(order);

            logger.info("Successfully updated vendor for order ID: {}", savedOrder.getId());

            return savedOrder;
        } catch (OrderNotFoundException e) {
            logger.warn("Order not found with ID: {}", orderId);
            throw e;
        } catch (Exception e) {
            logger.error("Error updating vendor for order ID: {}", orderId, e);
            throw new RuntimeException("Failed to update order vendor", e);
        }
    }

    public ResponseEntity<String> deleteOrder(Integer orderId) {
        try {
            if (!orderRepository.existsById(orderId)) {
                logger.warn("Attempt to delete non-existent order with ID: {}", orderId);
                throw new OrderNotFoundException("Order not found with id: " + orderId);
            }
            
            orderRepository.deleteById(orderId);
            logger.info("Successfully deleted order with ID: {}", orderId);
            return ResponseEntity.ok("Order deleted successfully");
        } catch (OrderNotFoundException e) {
            throw e;
        } catch (Exception e) {
            logger.error("Error deleting order with ID: {}", orderId, e);
            throw new RuntimeException("Failed to delete order", e);
        }
    }

    public Order getOrderById(Integer orderId) {
        logger.info("Fetching order with ID: {}", orderId);
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + orderId));
    }

    public List<OrderDTO> getAllOrders() {
        logger.info("Fetching all orders");
        return orderRepository.findAll().stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<OrderDTO> getOrdersByCustomerId(Long customerId) {
        logger.info("Fetching orders for customer ID: {}", customerId);
        return orderRepository.findByCustomerId(customerId).stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<OrderDTO> getOrdersByStatus(String status) {
        logger.info("Fetching orders with status: {}", status);
        return orderRepository.findByOrderStatus(status).stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<OrderDTO> getOrdersByVendorId(String vendorId) {
        logger.info("Fetching orders for vendor ID: {}", vendorId);
        return orderRepository.findByVendorId(vendorId).stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<OrderDTO> getActiveOrdersByVendorId(String vendorId) {
        logger.info("Fetching active orders for vendor ID: {}", vendorId);
        return orderRepository.findByVendorIdAndOrderStatus(vendorId, "PENDING").stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<OrderDTO> getOrderHistoryByVendorId(String vendorId) {
        logger.info("Fetching order history for vendor ID: {}", vendorId);
        List<Order> completedOrders = orderRepository.findByVendorId(vendorId).stream()
                .filter(order -> "DELIVERED".equals(order.getOrderStatus()) ||
                               "CANCELLED".equals(order.getOrderStatus()) ||
                               "PROCESSING".equals(order.getOrderStatus()) ||
                               "SCHEDULED".equals(order.getOrderStatus()) ||
                               "CANCELLED_BY_VENDOR".equals(order.getOrderStatus()))
                .collect(Collectors.toList());

        return completedOrders.stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * ========== VENDOR ORDER AGGREGATION ==========
     * Get aggregated product demand summary for vendor inventory planning
     *
     * APPROACH 1: SQL GROUP BY (OPTIMAL - Database-level aggregation)
     * Performance: O(n) with single query, minimal memory footprint
     *
     * @param vendorId The vendor ID
     * @return VendorOrderSummaryResponse with aggregated product demand
     */
    public VendorOrderSummaryResponse getVendorOrderSummary(String vendorId) {
        logger.info("Fetching order summary for vendor ID: {}", vendorId);

        // Get aggregated data using SQL GROUP BY (OPTIMAL approach)
        List<ProductDemandSummary> productDemands = orderRepository.getProductDemandSummary(vendorId);

        // Calculate totals
        int totalProducts = productDemands.size();
        int totalOrders = productDemands.stream()
                .mapToInt(p -> p.getTotalQuantity() != null ? p.getTotalQuantity() : 0)
                .sum();

        logger.info("Order summary for vendor {}: {} products, {} total units",
                vendorId, totalProducts, totalOrders);

        return new VendorOrderSummaryResponse(productDemands, totalOrders, totalProducts);
    }

    /**
     * APPROACH 2: Java Streams (Alternative implementation)
     * Performance: O(n) but loads all orders into memory first
     * Use when you need additional filtering logic not easily expressed in SQL
     *
     * @param vendorId The vendor ID
     * @return VendorOrderSummaryResponse with aggregated product demand
     */
    public VendorOrderSummaryResponse getVendorOrderSummaryWithStreams(String vendorId) {
        logger.info("Fetching order summary (Streams approach) for vendor ID: {}", vendorId);

        // Fetch all ISSUED and SCHEDULED orders for vendor
        List<Order> orders = orderRepository.findByVendorId(vendorId).stream()
                .filter(order -> "ISSUED".equals(order.getOrderStatus()) ||
                               "SCHEDULED".equals(order.getOrderStatus()))
                .collect(Collectors.toList());

        // Group by product name and sum quantities using Java Streams
        Map<String, Double> productQuantityMap = orders.stream()
                .collect(Collectors.groupingBy(
                        Order::getOrderName,
                        Collectors.summingDouble(Order::getOrderQuantity)
                ));

        // Convert to ProductDemandSummary list
        List<ProductDemandSummary> productDemands = productQuantityMap.entrySet().stream()
                .map(entry -> {
                    // Get unit from first order with this product name
                    String unit = orders.stream()
                            .filter(o -> o.getOrderName().equals(entry.getKey()))
                            .findFirst()
                            .map(Order::getOrderUnit)
                            .orElse("unit");
                    return new ProductDemandSummary(entry.getKey(), entry.getValue().intValue(), unit);
                })
                .sorted((a, b) -> b.getTotalQuantity().compareTo(a.getTotalQuantity())) // Sort by quantity desc
                .collect(Collectors.toList());

        // Calculate totals
        int totalProducts = productDemands.size();
        int totalOrders = productDemands.stream()
                .mapToInt(p -> p.getTotalQuantity() != null ? p.getTotalQuantity() : 0)
                .sum();

        logger.info("Order summary (Streams) for vendor {}: {} products, {} total units",
                vendorId, totalProducts, totalOrders);

        return new VendorOrderSummaryResponse(productDemands, totalOrders, totalProducts);
    }

    public Order acceptOrder(Integer orderId) {
        try {
            logger.info("Accepting order with ID: {}", orderId);

            Order order = orderRepository.findById(orderId)
                    .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + orderId));

            if (!"ISSUED".equals(order.getOrderStatus())) {
                throw new RuntimeException("Only ISSUED orders can be accepted. Current status: " + order.getOrderStatus());
            }

            String oldStatus = order.getOrderStatus();
            LocalDateTime now = LocalDateTime.now();
            order.setOrderStatus("SCHEDULED");
            order.setScheduledDate(now); // Set timestamp when order is scheduled
            order.setStatusUpdatedAt(now); // Track status update time for polling notifications
            Order savedOrder = orderRepository.save(order);

            logger.info("Successfully accepted order ID: {}, status changed from {} to SCHEDULED",
                    orderId, oldStatus);

            // Send notification about order acceptance
            if (savedOrder.getVendorId() != null && !savedOrder.getVendorId().isEmpty()) {
                orderNotificationService.notifyVendorAboutOrderUpdate(savedOrder, oldStatus);
            }

            return savedOrder;
        } catch (OrderNotFoundException e) {
            logger.warn("Order not found with ID: {}", orderId);
            throw e;
        } catch (Exception e) {
            logger.error("Error accepting order with ID: {}", orderId, e);
            throw new RuntimeException("Failed to accept order: " + e.getMessage(), e);
        }
    }

    public Order rejectOrder(Integer orderId) {
        try {
            logger.info("Rejecting order with ID: {}", orderId);

            Order order = orderRepository.findById(orderId)
                    .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + orderId));

            if (!"ISSUED".equals(order.getOrderStatus())) {
                throw new RuntimeException("Only ISSUED orders can be rejected. Current status: " + order.getOrderStatus());
            }

            String oldStatus = order.getOrderStatus();
            order.setOrderStatus("CANCELLED_BY_VENDOR");
            order.setStatusUpdatedAt(LocalDateTime.now()); // Track status update time for polling notifications
            Order savedOrder = orderRepository.save(order);

            logger.info("Successfully rejected order ID: {}, status changed from {} to CANCELLED_BY_VENDOR",
                    orderId, oldStatus);

            // Restore stock when order is rejected
            if (savedOrder.getProductId() != null) {
                logger.info("Restoring stock for product ID: {}, quantity: {}, unit: {}",
                        savedOrder.getProductId(), savedOrder.getOrderQuantity(), savedOrder.getOrderUnit());
                try {
                    productServiceClient.restoreStock(
                            savedOrder.getProductId(),
                            savedOrder.getOrderQuantity(),
                            savedOrder.getOrderUnit()
                    );
                    logger.info("Successfully restored stock for product ID: {}", savedOrder.getProductId());
                } catch (Exception e) {
                    logger.error("Failed to restore stock for product ID: {}. Error: {}",
                            savedOrder.getProductId(), e.getMessage());
                    // Don't fail the rejection if stock restoration fails
                }
            }

            // Send notification about order rejection
            if (savedOrder.getVendorId() != null && !savedOrder.getVendorId().isEmpty()) {
                orderNotificationService.notifyVendorAboutOrderUpdate(savedOrder, oldStatus);
            }

            return savedOrder;
        } catch (OrderNotFoundException e) {
            logger.warn("Order not found with ID: {}", orderId);
            throw e;
        } catch (Exception e) {
            logger.error("Error rejecting order with ID: {}", orderId, e);
            throw new RuntimeException("Failed to reject order: " + e.getMessage(), e);
        }
    }

    public List<OrderDTO> getIssuedOrdersByVendorId(String vendorId) {
        logger.info("Fetching issued orders for vendor ID: {}", vendorId);
        return orderRepository.findByVendorIdAndOrderStatus(vendorId, "ISSUED").stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<OrderDTO> getScheduledOrdersByVendorId(String vendorId) {
        logger.info("Fetching scheduled orders for vendor ID: {}", vendorId);
        return orderRepository.findByVendorIdAndOrderStatus(vendorId, "SCHEDULED").stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get all READY orders for a vendor (orders ready for pickup)
     */
    public List<OrderDTO> getReadyOrdersByVendorId(String vendorId) {
        logger.info("Fetching ready orders for vendor ID: {}", vendorId);
        return orderRepository.findByVendorIdAndOrderStatus(vendorId, "READY").stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<OrderDTO> getCancelledOrdersByVendorId(String vendorId) {
        logger.info("Fetching cancelled orders for vendor ID: {}", vendorId);
        return orderRepository.findByVendorIdAndOrderStatus(vendorId, "CANCELLED_BY_VENDOR").stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public int migratePendingToIssued() {
        logger.info("Migrating all PENDING orders to ISSUED status");
        List<Order> pendingOrders = orderRepository.findByOrderStatus("PENDING");
        int count = 0;
        for (Order order : pendingOrders) {
            order.setOrderStatus("ISSUED");
            orderRepository.save(order);
            count++;
        }
        logger.info("Successfully migrated {} PENDING orders to ISSUED status", count);
        return count;
    }

    public int populateCustomerDetailsForExistingOrders() {
        logger.info("Populating customer details for all existing orders with NULL customer details");
        List<Order> allOrders = orderRepository.findAll();
        int count = 0;

        for (Order order : allOrders) {
            // Only update orders that have NULL customer details
            if (order.getCustomerName() == null && order.getCustomerId() != null) {
                try {
                    // Fetch customer details
                    String url = "http://localhost:9090/customer/" + order.getCustomerId();
                    logger.info("Fetching customer details from: {}", url);
                    order_service.dto.CustomerDTO customer = restTemplate.getForObject(url, order_service.dto.CustomerDTO.class);
                    if (customer != null) {
                        String customerName = customer.getFirstName() + " " + customer.getLastName();
                        order.setCustomerName(customerName);
                        order.setCustomerPhone(String.valueOf(customer.getPhoneNumber()));

                        // Fetch pickup point name if pickupPointId exists
                        if (customer.getPickupPointId() != null) {
                            String pickupUrl = "http://localhost:9090/pickup-points/" + customer.getPickupPointId();
                            logger.info("Fetching pickup point details from: {}", pickupUrl);
                            order_service.dto.PickupPointDTO pickupPoint = restTemplate.getForObject(pickupUrl, order_service.dto.PickupPointDTO.class);
                            if (pickupPoint != null) {
                                order.setCustomerPickupPoint(pickupPoint.getName());
                            }
                        }

                        orderRepository.save(order);
                        count++;
                        logger.info("Updated customer details for order ID: {} - Customer: {}", order.getId(), customerName);
                    }
                } catch (Exception e) {
                    logger.warn("Could not fetch customer details for order ID: {} with customerId: {}",
                              order.getId(), order.getCustomerId(), e);
                }
            }
        }

        logger.info("Successfully populated customer details for {} orders", count);
        return count;
    }

    /**
     * ========== SMART POLLING NOTIFICATIONS ==========
     * Get orders that were created or updated since a given timestamp
     * Used for polling-based real-time notifications
     *
     * @param vendorId The vendor ID
     * @param since Timestamp to check for new/updated orders
     * @return List of OrderDTOs for orders created or updated after the given timestamp
     */
    public List<OrderDTO> getOrdersUpdatedSince(String vendorId, LocalDateTime since) {
        logger.info("Fetching orders updated since {} for vendor {}", since, vendorId);
        return orderRepository.findOrdersUpdatedSince(vendorId, since).stream()
                .map(OrderMapper::toDTO)
                .collect(Collectors.toList());
    }
}