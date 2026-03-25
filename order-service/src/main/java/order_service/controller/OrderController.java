package order_service.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import order_service.dto.OrderDTO;
import order_service.entity.Order;
import order_service.service.DeliverySheetService;
import order_service.service.OrderService;

import java.util.List;

@RestController
@RequestMapping("/order")
@CrossOrigin(origins = "*")
@Tag(name = "Order Management", description = "APIs for managing orders, order processing, and order history")
public class OrderController {

    private static final Logger logger = LoggerFactory.getLogger(OrderController.class);
    private final OrderService orderService;

    @Autowired
    private DeliverySheetService deliverySheetService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @Operation(summary = "Health check endpoint", 
               description = "Returns the health status of the Order Service")
    @ApiResponse(responseCode = "200", description = "Service is running", 
                content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "Order Service is running")))
    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("Order Service is running");
    }

    @Operation(summary = "Create new order", 
               description = "Creates a new order in the system. Requires Customer ID header for order association.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Order created successfully", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Order.class))),
        @ApiResponse(responseCode = "400", description = "Invalid order data"),
        @ApiResponse(responseCode = "401", description = "Missing or invalid Customer ID header")
    })
    @SecurityRequirement(name = "Customer ID Header")
    @PostMapping
    public ResponseEntity<?> createOrder(
            @Parameter(description = "Order details to create", required = true)
            @RequestBody Order order,
            @Parameter(description = "ID of the customer placing the order", required = true, example = "123")
            @RequestHeader("X-Customer-Id") Long customerId) {
        try {
            Order savedOrder = orderService.createOrder(order, customerId);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedOrder);
        } catch (RuntimeException e) {
            logger.error("Error creating order: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            logger.error("Unexpected error creating order: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to create order");
        }
    }

    @Operation(summary = "Update order status", 
               description = "Updates the status of an existing order (e.g., PENDING, PROCESSING, DELIVERED, CANCELLED)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Order status updated successfully", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Order.class))),
        @ApiResponse(responseCode = "404", description = "Order not found"),
        @ApiResponse(responseCode = "400", description = "Invalid status value")
    })
    @PutMapping("/{id}/status")
    public ResponseEntity<Order> updateOrderStatus(
            @Parameter(description = "ID of the order to update", required = true, example = "1")
            @PathVariable Integer id, 
            @Parameter(description = "New order status", required = true, 
                      schema = @Schema(type = "string", allowableValues = {"PENDING", "PROCESSING", "DELIVERED", "CANCELLED"}, 
                                     example = "PROCESSING"))
            @RequestBody String status) {
        try {
            Order updatedOrder = orderService.updateOrderStatus(id, status);
            return ResponseEntity.ok(updatedOrder);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @Operation(summary = "Update order vendor",
               description = "Updates the vendor ID of an existing order")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Order vendor updated successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Order.class))),
        @ApiResponse(responseCode = "404", description = "Order not found")
    })
    @PutMapping("/{id}/vendor")
    public ResponseEntity<Order> updateOrderVendor(
            @Parameter(description = "ID of the order to update", required = true, example = "1")
            @PathVariable Integer id,
            @Parameter(description = "New vendor ID", required = true, example = "VENDOR001")
            @RequestBody String vendorId) {
        try {
            Order updatedOrder = orderService.updateOrderVendor(id, vendorId);
            return ResponseEntity.ok(updatedOrder);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @Operation(summary = "Delete order",
               description = "Removes an order from the system by ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Order deleted successfully",
                    content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "Order deleted successfully"))),
        @ApiResponse(responseCode = "404", description = "Order not found")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteOrder(
            @Parameter(description = "ID of the order to delete", required = true, example = "1")
            @PathVariable Integer id) {
        return orderService.deleteOrder(id);
    }

    @Operation(summary = "Get order by ID", 
               description = "Retrieves detailed information about a specific order")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Order found and returned", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Order.class))),
        @ApiResponse(responseCode = "404", description = "Order not found")
    })
    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(
            @Parameter(description = "ID of the order to retrieve", required = true, example = "1")
            @PathVariable Integer id) {
        try {
            Order order = orderService.getOrderById(id);
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @Operation(summary = "Get all orders", 
               description = "Retrieves a list of all orders in the system")
    @ApiResponse(responseCode = "200", description = "List of orders returned successfully", 
                content = @Content(mediaType = "application/json", 
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping
    public ResponseEntity<List<OrderDTO>> getAllOrders() {
        List<OrderDTO> orders = orderService.getAllOrders();
        return ResponseEntity.ok(orders);
    }
    
    @Operation(summary = "Get orders (Legacy endpoint)", 
               description = "Legacy endpoint that returns a simple string response - used for service communication")
    @ApiResponse(responseCode = "200", description = "Orders string returned", 
                content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "Orders from Order Service")))
    @GetMapping("/getOrders")
    public ResponseEntity<String> getOrders() {
        return ResponseEntity.ok("Orders from Order Service");
    }

    @Operation(summary = "Get orders by customer ID", 
               description = "Retrieves all orders placed by a specific customer")
    @ApiResponse(responseCode = "200", description = "Customer's orders returned successfully", 
                content = @Content(mediaType = "application/json", 
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<OrderDTO>> getOrdersByCustomerId(
            @Parameter(description = "ID of the customer whose orders to retrieve", required = true, example = "123")
            @PathVariable Long customerId) {
        List<OrderDTO> orders = orderService.getOrdersByCustomerId(customerId);
        return ResponseEntity.ok(orders);
    }

    @Operation(summary = "Get orders by status", 
               description = "Retrieves all orders with a specific status")
    @ApiResponse(responseCode = "200", description = "Orders with specified status returned successfully", 
                content = @Content(mediaType = "application/json", 
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping("/status/{status}")
    public ResponseEntity<List<OrderDTO>> getOrdersByStatus(
            @Parameter(description = "Status of orders to retrieve", required = true,
                      schema = @Schema(type = "string", allowableValues = {"PENDING", "PROCESSING", "DELIVERED", "CANCELLED"},
                                     example = "PENDING"))
            @PathVariable String status) {
        List<OrderDTO> orders = orderService.getOrdersByStatus(status);
        return ResponseEntity.ok(orders);
    }

    @Operation(summary = "Get all orders for a vendor",
               description = "Retrieves all orders assigned to a specific vendor")
    @ApiResponse(responseCode = "200", description = "Vendor's orders returned successfully",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping("/vendor/{vendorId}")
    public ResponseEntity<List<OrderDTO>> getOrdersByVendorId(
            @Parameter(description = "ID of the vendor whose orders to retrieve", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        List<OrderDTO> orders = orderService.getOrdersByVendorId(vendorId);
        return ResponseEntity.ok(orders);
    }

    @Operation(summary = "Get active orders for a vendor",
               description = "Retrieves all pending orders that the vendor needs to fulfill")
    @ApiResponse(responseCode = "200", description = "Vendor's active orders returned successfully",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping("/vendor/{vendorId}/active")
    public ResponseEntity<List<OrderDTO>> getActiveOrdersByVendorId(
            @Parameter(description = "ID of the vendor whose active orders to retrieve", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        List<OrderDTO> orders = orderService.getActiveOrdersByVendorId(vendorId);
        return ResponseEntity.ok(orders);
    }

    @Operation(summary = "Get order history for a vendor",
               description = "Retrieves all completed orders (delivered, completed, or cancelled) for the vendor")
    @ApiResponse(responseCode = "200", description = "Vendor's order history returned successfully",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping("/vendor/{vendorId}/history")
    public ResponseEntity<List<OrderDTO>> getOrderHistoryByVendorId(
            @Parameter(description = "ID of the vendor whose order history to retrieve", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        List<OrderDTO> orders = orderService.getOrderHistoryByVendorId(vendorId);
        return ResponseEntity.ok(orders);
    }

    @Operation(summary = "Accept an order",
               description = "Vendor accepts an ISSUED order, changing status to SCHEDULED")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Order accepted successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Order.class))),
        @ApiResponse(responseCode = "404", description = "Order not found"),
        @ApiResponse(responseCode = "400", description = "Order cannot be accepted (not in ISSUED status)")
    })
    @PostMapping("/{id}/accept")
    public ResponseEntity<?> acceptOrder(
            @Parameter(description = "ID of the order to accept", required = true, example = "1")
            @PathVariable Integer id) {
        try {
            Order acceptedOrder = orderService.acceptOrder(id);
            return ResponseEntity.ok(acceptedOrder);
        } catch (Exception e) {
            logger.error("Error accepting order: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    @Operation(summary = "Reject an order",
               description = "Vendor rejects an ISSUED order, changing status to CANCELLED_BY_VENDOR and restoring stock")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Order rejected successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Order.class))),
        @ApiResponse(responseCode = "404", description = "Order not found"),
        @ApiResponse(responseCode = "400", description = "Order cannot be rejected (not in ISSUED status)")
    })
    @PostMapping("/{id}/reject")
    public ResponseEntity<?> rejectOrder(
            @Parameter(description = "ID of the order to reject", required = true, example = "1")
            @PathVariable Integer id) {
        try {
            Order rejectedOrder = orderService.rejectOrder(id);
            return ResponseEntity.ok(rejectedOrder);
        } catch (Exception e) {
            logger.error("Error rejecting order: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    @Operation(summary = "Get issued orders for a vendor",
               description = "Retrieves all orders with ISSUED status for the vendor")
    @ApiResponse(responseCode = "200", description = "Vendor's issued orders returned successfully",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping("/vendor/{vendorId}/issued")
    public ResponseEntity<List<OrderDTO>> getIssuedOrdersByVendorId(
            @Parameter(description = "ID of the vendor whose issued orders to retrieve", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        List<OrderDTO> orders = orderService.getIssuedOrdersByVendorId(vendorId);
        return ResponseEntity.ok(orders);
    }

    @Operation(summary = "Get scheduled orders for a vendor",
               description = "Retrieves all orders with SCHEDULED status for the vendor")
    @ApiResponse(responseCode = "200", description = "Vendor's scheduled orders returned successfully",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping("/vendor/{vendorId}/scheduled")
    public ResponseEntity<List<OrderDTO>> getScheduledOrdersByVendorId(
            @Parameter(description = "ID of the vendor whose scheduled orders to retrieve", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        List<OrderDTO> orders = orderService.getScheduledOrdersByVendorId(vendorId);
        return ResponseEntity.ok(orders);
    }

    @Operation(summary = "Get cancelled/rejected orders for a vendor",
               description = "Retrieves all orders with CANCELLED_BY_VENDOR status for the vendor")
    @ApiResponse(responseCode = "200", description = "Vendor's cancelled orders returned successfully",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = OrderDTO.class))))
    @GetMapping("/vendor/{vendorId}/cancelled")
    public ResponseEntity<List<OrderDTO>> getCancelledOrdersByVendorId(
            @Parameter(description = "ID of the vendor whose cancelled orders to retrieve", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        List<OrderDTO> orders = orderService.getCancelledOrdersByVendorId(vendorId);
        return ResponseEntity.ok(orders);
    }

    @Operation(summary = "Generate delivery sheet PDF",
               description = "Generates a PDF delivery sheet for a vendor's scheduled orders on a specific delivery date")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "PDF generated successfully",
                    content = @Content(mediaType = "application/pdf")),
        @ApiResponse(responseCode = "400", description = "Invalid parameters or no orders found"),
        @ApiResponse(responseCode = "500", description = "Error generating PDF")
    })
    @GetMapping("/vendor/{vendorId}/delivery-sheet")
    public ResponseEntity<byte[]> generateDeliverySheet(
            @Parameter(description = "ID of the vendor", required = true, example = "VENDOR001")
            @PathVariable String vendorId,
            @Parameter(description = "Delivery date in YYYY-MM-DD format", required = true, example = "2025-01-25")
            @RequestParam String date) {
        try {
            byte[] pdfBytes = deliverySheetService.generateDeliverySheet(vendorId, date);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment", "delivery-sheet-" + vendorId + "-" + date + ".pdf");
            headers.setContentLength(pdfBytes.length);

            return new ResponseEntity<>(pdfBytes, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("Error generating delivery sheet: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @Operation(summary = "Get delivery dates for vendor",
               description = "Retrieves list of delivery dates for a vendor's scheduled orders")
    @ApiResponse(responseCode = "200", description = "Delivery dates returned successfully",
                content = @Content(mediaType = "application/json"))
    @GetMapping("/vendor/{vendorId}/delivery-dates")
    public ResponseEntity<List<String>> getDeliveryDates(
            @Parameter(description = "ID of the vendor", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        try {
            List<String> dates = deliverySheetService.getDeliveryDates(vendorId);
            return ResponseEntity.ok(dates);
        } catch (Exception e) {
            logger.error("Error getting delivery dates: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @Operation(summary = "Migrate PENDING orders to ISSUED (Admin only)",
               description = "Updates all PENDING orders to ISSUED status for migration purposes")
    @ApiResponse(responseCode = "200", description = "Orders migrated successfully")
    @PostMapping("/admin/migrate-pending-to-issued")
    public ResponseEntity<String> migratePendingToIssued() {
        try {
            int updated = orderService.migratePendingToIssued();
            return ResponseEntity.ok("Successfully migrated " + updated + " PENDING orders to ISSUED status");
        } catch (Exception e) {
            logger.error("Error migrating orders: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to migrate orders");
        }
    }

    @PostMapping("/admin/populate-customer-details")
    public ResponseEntity<String> populateCustomerDetails() {
        try {
            int updated = orderService.populateCustomerDetailsForExistingOrders();
            return ResponseEntity.ok("Successfully populated customer details for " + updated + " orders");
        } catch (Exception e) {
            logger.error("Error populating customer details: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to populate customer details: " + e.getMessage());
        }
    }
}