package user_service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import user_service.entity.Customer;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Profile update response containing updated user details and optionally a new JWT token")
public class ProfileUpdateResponse {

    @Schema(description = "Updated user details", required = true)
    private Customer user;

    @Schema(description = "New JWT token (only provided if username/email was changed)", required = false)
    private String newToken;

    @Schema(description = "Indicates if a new token was issued", required = true)
    private boolean tokenRefreshed;
}