package user_service.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "vendor_pickup_points")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Vendor Pickup Point junction table - manages many-to-many relationship between vendors and pickup points")
public class VendorPickupPoint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier for vendor pickup point mapping", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;

    @Column(name = "vendor_id", nullable = false)
    @Schema(description = "Vendor ID from customer table (vendorId field)", example = "VENDOR001", required = true)
    private String vendorId;

    @Column(name = "pickup_point_id", nullable = false)
    @Schema(description = "Pickup point ID from pickup_points table", example = "1", required = true)
    private Long pickupPointId;

    @Column(name = "is_active", nullable = false)
    @Schema(description = "Whether this pickup point is active for the vendor", example = "true", defaultValue = "true")
    private boolean active = true;

    @Column(name = "created_date")
    @Schema(description = "Timestamp when this mapping was created", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    @Schema(description = "Timestamp when this mapping was last updated", accessMode = Schema.AccessMode.READ_ONLY)
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
