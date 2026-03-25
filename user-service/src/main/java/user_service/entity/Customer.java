package user_service.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Customer entity representing a user in the Healthy Food Bank system")
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier for the customer", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;
    
    @Schema(description = "Customer's first name", example = "John", required = true)
    private String firstName;
    
    @Schema(description = "Customer's last name", example = "Doe", required = true)
    private String lastName;
    
    @Schema(description = "Unique username for login", example = "johndoe123", required = true)
    private String userName;
    
    @Schema(description = "Customer's password (encrypted)", example = "password123", required = true, accessMode = Schema.AccessMode.WRITE_ONLY)
    private String password;
    
    @Schema(description = "Customer's role in the system", example = "CUSTOMER", allowableValues = {"CUSTOMER", "VENDOR", "ADMIN"})
    private String roles;
    
    @Schema(description = "Customer's email address", example = "john.doe@email.com")
    private String email;
    
    @Schema(description = "Customer's phone number", example = "1234567890")
    private long phoneNumber;
    
    @Schema(description = "Vendor ID for vendor accounts", example = "VENDOR001")
    private String vendorId;

    @Schema(description = "Preferred pickup point ID for orders", example = "1")
    private Long pickupPointId;
    
    @Schema(description = "Whether the customer account is active", example = "true", defaultValue = "true")
    private boolean active = true;
    
    @Column(name = "created_date")
    @Schema(description = "Timestamp when the customer account was created", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime createdDate;
    
    @Column(name = "updated_date")
    @Schema(description = "Timestamp when the customer account was last updated", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime updatedDate;

    @PrePersist
    protected void onCreate() {
        createdDate = LocalDateTime.now();
        updatedDate = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedDate = LocalDateTime.now();
    }
}
