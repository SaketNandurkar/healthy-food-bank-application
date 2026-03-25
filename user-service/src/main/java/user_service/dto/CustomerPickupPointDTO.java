package user_service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "DTO for Customer Pickup Point requests")
public class CustomerPickupPointDTO {

    @Schema(description = "Pickup point ID", example = "1", required = true)
    private Long pickupPointId;

    @Schema(description = "Whether to make this the active pickup point", example = "true", defaultValue = "false")
    private boolean makeActive = false;
}
