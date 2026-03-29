package order_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for top vendors by order count
 * Shows which vendors are most active
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TopVendorDTO {
    private String vendorName;
    private Long totalOrders;
}
