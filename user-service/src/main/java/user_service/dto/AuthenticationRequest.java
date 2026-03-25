package user_service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Authentication request containing user credentials for login")
public class AuthenticationRequest {

    @JsonProperty("userName")
    @Schema(description = "Username for authentication", example = "johndoe123", required = true)
    private String username;

    @Schema(description = "Password for authentication", example = "password123", required = true, format = "password")
    private String password;

}
