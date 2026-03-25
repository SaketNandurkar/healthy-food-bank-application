package user_service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Registration response containing success status and message")
public class RegistrationResponse {
    
    @Schema(description = "Registration success status", example = "true", required = true)
    private boolean success;
    
    @Schema(description = "Registration response message", example = "User added to system successfully", required = true)
    private String message;
    
    @Schema(description = "Error details if registration failed", example = "Username already exists")
    private String error;
    
    // Convenience constructors
    public static RegistrationResponse success(String message) {
        return new RegistrationResponse(true, message, null);
    }
    
    public static RegistrationResponse error(String error) {
        return new RegistrationResponse(false, null, error);
    }
}