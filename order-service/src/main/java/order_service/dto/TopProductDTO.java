package order_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for top-selling products analytics
 * Aggregates product quantities across all orders
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TopProductDTO {
    private String productName;
    private Long totalQuantity;
}
