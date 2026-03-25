package user_service.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "customer_pickup_points")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Customer Pickup Point entity - manages multiple pickup points per customer with one active at a time")
public class CustomerPickupPoint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier for customer pickup point", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;

    @Column(name = "customer_id", nullable = false)
    @Schema(description = "Customer ID who owns this pickup point", example = "1", required = true)
    private Long customerId;

    @Column(name = "pickup_point_id", nullable = false)
    @Schema(description = "Pickup point ID from pickup_points table", example = "1", required = true)
    private Long pickupPointId;

    @Column(name = "is_active", nullable = false)
    @Schema(description = "Whether this is the currently active pickup point for the customer", example = "true", defaultValue = "false")
    private boolean active = false;

    @Column(name = "created_date")
    @Schema(description = "Timestamp when this pickup point was added", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    @Schema(description = "Timestamp when this pickup point was last updated", accessMode = Schema.AccessMode.READ_ONLY)
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
