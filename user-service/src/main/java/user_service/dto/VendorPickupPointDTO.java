package user_service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "DTO for Vendor Pickup Point requests")
public class VendorPickupPointDTO {

    @Schema(description = "Pickup point ID", example = "1", required = true)
    private Long pickupPointId;
}
