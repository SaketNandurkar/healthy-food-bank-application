package user_service.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "vendor_codes")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Vendor registration code entity for validating vendor registrations")
public class VendorCode {

    @PrePersist
    protected void onCreate() {
        createdDate = LocalDateTime.now();
        updatedDate = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedDate = LocalDateTime.now();
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier for the vendor code", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    @Schema(description = "Unique vendor code used for registration", example = "VENDOR001", required = true)
    private String vendorCode;
    
    @Column(nullable = false)
    @Schema(description = "Vendor ID associated with this code", example = "VND001", required = true)
    private String vendorId;
    
    @Column(nullable = false)
    @Schema(description = "Name of the vendor", example = "Fresh Foods Market", required = true)
    private String vendorName;
    
    @Schema(description = "Description of the vendor business", example = "Organic produce supplier")
    private String description;
    
    @Column(nullable = false)
    @Schema(description = "Whether this vendor code is active", example = "true")
    private Boolean active = true;
    
    @Schema(description = "Whether this code has been used for registration", example = "false")
    private Boolean used = false;
    
    @Schema(description = "User ID who used this code (null if unused)")
    private Long usedBy;
    
    @Schema(description = "Date when the code was used (null if unused)")
    private LocalDateTime usedDate;
    
    @Schema(description = "ID of the admin who created this code", example = "1")
    private Long createdBy;
    
    @Schema(description = "Timestamp when the code was created", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime createdDate;
    
    @Schema(description = "Timestamp when the code was last updated", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime updatedDate;
}