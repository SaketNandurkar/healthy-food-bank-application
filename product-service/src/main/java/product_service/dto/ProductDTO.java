package product_service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import product_service.enums.ProductCategory;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Product data transfer object for API responses")
public class ProductDTO {
    @Schema(description = "Unique identifier for the product", example = "1")
    private int productId;
    
    @Schema(description = "Name of the product", example = "Organic Apples")
    private String productName;
    
    @Schema(description = "Price of the product", example = "2.99")
    private double productPrice;
    
    @Schema(description = "Available quantity of the product", example = "100.0")
    private double productQuantity;
    
    @Schema(description = "Unit of measurement for the product", example = "kg")
    private String productUnit;
    
    @Schema(description = "Timestamp when the product was added")
    private LocalDateTime productAdditionDate;
    
    @Schema(description = "Timestamp when the product was last updated")
    private LocalDateTime productUpdatedDate;
    
    @Schema(description = "ID of the user who added this product", example = "123")
    private Long productAddedBy;
    
    @Schema(description = "Vendor ID who owns this product", example = "VENDOR001")
    private String vendorId;

    @Schema(description = "Vendor name who owns this product", example = "John Doe")
    private String vendorName;

    @Schema(description = "Product category", example = "VEGETABLES")
    private ProductCategory category;

    @Schema(description = "Quantity per unit (e.g., 1 for '1 kg', 250 for '250 ml')", example = "1.0")
    private double unitQuantity;

    @Schema(description = "Delivery schedule for the product", example = "SATURDAY")
    private String deliverySchedule;
}

