package order_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for orders grouped by pickup point
 * Used in admin analytics to show order distribution across locations
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrdersByPickupPointDTO {
    private String pickupPointName;
    private Long totalOrders;
}
