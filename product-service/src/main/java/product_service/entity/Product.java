package product_service.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import product_service.enums.ProductCategory;

import java.time.LocalDateTime;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Product entity representing food items in the Healthy Food Bank catalog")
public class Product {

    @PrePersist
    protected void onCreate() {
        productAdditionDate = LocalDateTime.now();
        productUpdatedDate = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        productUpdatedDate = LocalDateTime.now();
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier for the product", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private int productId;
    
    @Schema(description = "Name of the product", example = "Organic Apples", required = true)
    private String productName;
    
    @Schema(description = "Price of the product", example = "2.99", required = true)
    private double productPrice;
    
    @Schema(description = "Available quantity of the product", example = "100.0", required = true)
    private double productQuantity;
    
    @Schema(description = "Unit of measurement for the product", example = "kg", required = true)
    private String productUnit;

    @Schema(description = "Quantity per unit (e.g., 1 for '1 kg', 250 for '250 ml')", example = "1.0", required = true)
    private double unitQuantity;

    @Schema(description = "Timestamp when the product was added", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime productAdditionDate;
    
    @Schema(description = "Timestamp when the product was last updated", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime productUpdatedDate;

    @Column(name = "product_added_by")
    @Schema(description = "ID of the user who added this product", example = "123")
    private Long productAddedBy;

    @Column(name = "vendor_id")
    @Schema(description = "Vendor ID who owns this product", example = "VENDOR001")
    private String vendorId;

    @Column(name = "vendor_name")
    @Schema(description = "Vendor name who owns this product", example = "John Doe")
    private String vendorName;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", length = 20)
    @Schema(description = "Product category", example = "VEGETABLES")
    private ProductCategory category = ProductCategory.OTHERS;

    @Column(name = "delivery_schedule", length = 20)
    @Schema(description = "Delivery schedule for the product", example = "SATURDAY")
    private String deliverySchedule;
}
