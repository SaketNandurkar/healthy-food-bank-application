package user_service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import user_service.entity.Customer;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Login response containing JWT token and user details")
public class LoginResponse {
    
    @Schema(description = "JWT authentication token", example = "eyJhbGciOiJIUzI1NiJ9...", required = true)
    private String token;
    
    @Schema(description = "User details", required = true)
    private Customer user;
    
    @Schema(description = "Token expiration time in seconds", example = "3600")
    private Long expiresIn;
}