package order_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for aggregated product demand summary
 * Used to show total quantity needed per product for vendor inventory planning
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductDemandSummary {
    private String productName;
    private Long productId;
    private Integer totalQuantity;
    private String unit;

    // Constructor for SQL projection (without productId and unit)
    public ProductDemandSummary(String productName, Integer totalQuantity) {
        this.productName = productName;
        this.totalQuantity = totalQuantity;
    }

    // Constructor for SQL projection (with unit) - Integer version
    public ProductDemandSummary(String productName, Integer totalQuantity, String unit) {
        this.productName = productName;
        this.totalQuantity = totalQuantity;
        this.unit = unit;
    }

    // Constructor for SQL projection (with unit) - Double version
    // Used when SUM() returns Double from database
    public ProductDemandSummary(String productName, Double totalQuantity, String unit) {
        this.productName = productName;
        this.totalQuantity = totalQuantity != null ? totalQuantity.intValue() : 0;
        this.unit = unit;
    }
}
