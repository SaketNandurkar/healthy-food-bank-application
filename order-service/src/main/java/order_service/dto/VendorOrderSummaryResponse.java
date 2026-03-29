package order_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for vendor order summary endpoint
 * Contains aggregated product demand data
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VendorOrderSummaryResponse {
    private List<ProductDemandSummary> products;
    private Integer totalOrders;
    private Integer totalProducts;
}
