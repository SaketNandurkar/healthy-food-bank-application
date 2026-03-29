package order_service.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Order data transfer object for API responses")
public class OrderDTO {

    @Schema(description = "Unique identifier for the order", example = "1")
    private int id;
    
    @Schema(description = "Name/description of the ordered item", example = "Organic Apples")
    private String orderName;
    
    @Schema(description = "Quantity of the ordered item", example = "5.0")
    private double orderQuantity;
    
    @Schema(description = "Unit of measurement for the order", example = "kg")
    private String orderUnit;
    
    @Schema(description = "Total price of the order", example = "14.95")
    private double orderPrice;

    @Schema(description = "Timestamp when the order was placed (ISSUED status)")
    private LocalDateTime orderPlacedDate;

    @Schema(description = "Timestamp when the order was scheduled by vendor (ISSUED → SCHEDULED)")
    private LocalDateTime scheduledDate;

    @Schema(description = "Timestamp when the order was marked ready for pickup (SCHEDULED → READY)")
    private LocalDateTime readyDate;

    @Schema(description = "Timestamp when the order was delivered to customer (READY → DELIVERED)")
    private LocalDateTime deliveredDate;

    @Deprecated
    @Schema(description = "Deprecated: Use deliveredDate instead")
    private LocalDateTime orderDeliveredDate;

    @Schema(description = "Timestamp when the order status was last updated (for polling notifications)")
    private LocalDateTime statusUpdatedAt;

    @Schema(description = "ID of the customer who placed this order", example = "123")
    private Long customerId;
    
    @Schema(description = "Current status of the order", example = "PENDING", allowableValues = {"PENDING", "PROCESSING", "DELIVERED", "CANCELLED"})
    private String orderStatus;

    @Schema(description = "ID of the product being ordered", example = "1")
    private Integer productId;

    @Schema(description = "ID of the vendor who owns the product", example = "VENDOR001")
    private String vendorId;

    @Schema(description = "Name of the vendor who owns the product", example = "John Doe")
    private String vendorName;

    @Schema(description = "Name of the product being ordered", example = "Organic Apples")
    private String productName;

    @Schema(description = "Name of the customer who placed the order", example = "Jane Smith")
    private String customerName;

    @Schema(description = "Phone number of the customer", example = "+91 9876543210")
    private String customerPhone;

    @Schema(description = "Pickup point selected by the customer", example = "Main Street Hub")
    private String customerPickupPoint;
}