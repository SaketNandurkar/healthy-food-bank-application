package order_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import order_service.dto.OrderDTO;
import order_service.entity.Order;
import order_service.exception.OrderNotFoundException;
import order_service.mapper.OrderMapper;
import order_service.repository.OrderRepository;

import java.util.List;
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

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    public Order createOrder(Order order, Long customerId) {
        try {
            logger.info("Creating order for customer: {} with vendorId: {}", customerId, order.getVendorId());

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

    public Order acceptOrder(Integer orderId) {
        try {
            logger.info("Accepting order with ID: {}", orderId);

            Order order = orderRepository.findById(orderId)
                    .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + orderId));

            if (!"ISSUED".equals(order.getOrderStatus())) {
                throw new RuntimeException("Only ISSUED orders can be accepted. Current status: " + order.getOrderStatus());
            }

            String oldStatus = order.getOrderStatus();
            order.setOrderStatus("SCHEDULED");
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
}