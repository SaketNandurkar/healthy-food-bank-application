package order_service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for order status update requests
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Request to update order status")
public class UpdateOrderStatusRequest {

    @Schema(description = "New order status",
            example = "READY",
            allowableValues = {"SCHEDULED", "READY", "DELIVERED"},
            required = true)
    private String status;
}
