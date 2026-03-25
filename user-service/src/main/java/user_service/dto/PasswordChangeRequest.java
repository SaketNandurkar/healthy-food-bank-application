package user_service.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request to change user password")
public class PasswordChangeRequest {
    
    @Schema(description = "User's current password", example = "oldPassword123")
    private String currentPassword;
    
    @Schema(description = "User's new password", example = "newPassword123")
    private String newPassword;
    
    // Default constructor
    public PasswordChangeRequest() {}
    
    // Constructor with parameters
    public PasswordChangeRequest(String currentPassword, String newPassword) {
        this.currentPassword = currentPassword;
        this.newPassword = newPassword;
    }
    
    // Getters and Setters
    public String getCurrentPassword() {
        return currentPassword;
    }
    
    public void setCurrentPassword(String currentPassword) {
        this.currentPassword = currentPassword;
    }
    
    public String getNewPassword() {
        return newPassword;
    }
    
    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }
}