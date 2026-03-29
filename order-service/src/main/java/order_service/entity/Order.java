package order_service.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "`Order`")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Order entity representing customer orders in the Healthy Food Bank system")
public class Order {

    @PrePersist
    protected void onCreate() {
        orderPlacedDate = LocalDateTime.now();
        statusUpdatedAt = LocalDateTime.now();
        if (orderStatus == null) {
            orderStatus = "ISSUED";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        statusUpdatedAt = LocalDateTime.now();
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier for the order", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private int id;
    
    @Schema(description = "Name/description of the ordered item", example = "Organic Apples", required = true)
    private String orderName;
    
    @Schema(description = "Quantity of the ordered item", example = "5.0", required = true)
    private double orderQuantity;
    
    @Schema(description = "Unit of measurement for the order", example = "kg", required = true)
    private String orderUnit;
    
    @Schema(description = "Total price of the order", example = "14.95", required = true)
    private double orderPrice;
    
    @Schema(description = "Timestamp when the order was placed (ISSUED status)", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime orderPlacedDate;

    @Schema(description = "Timestamp when the order was scheduled by vendor (ISSUED → SCHEDULED)", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime scheduledDate;

    @Schema(description = "Timestamp when the order was marked ready for pickup (SCHEDULED → READY)", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime readyDate;

    @Schema(description = "Timestamp when the order was delivered to customer (READY → DELIVERED)", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime deliveredDate;

    @Deprecated
    @Schema(description = "Deprecated: Use deliveredDate instead", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime orderDeliveredDate;

    @Schema(description = "Timestamp when the order status was last updated (for polling notifications)", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime statusUpdatedAt;
    
    @Schema(description = "ID of the customer who placed this order", example = "123", required = true)
    private Long customerId;

    @Schema(description = "Current status of the order", example = "ISSUED",
            allowableValues = {"ISSUED", "SCHEDULED", "CANCELLED_BY_VENDOR"})
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
