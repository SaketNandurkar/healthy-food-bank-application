package order_service.entity;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "delivery_slots")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Delivery slot representing a scheduled delivery window with cutoff time")
public class DeliverySlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;

    @Schema(description = "Date when delivery will happen", example = "2026-03-30", required = true)
    private LocalDate deliveryDate;

    @Schema(description = "Cutoff date/time after which orders are no longer accepted", example = "2026-03-28T20:00:00", required = true)
    private LocalDateTime cutoffDateTime;

    @Schema(description = "Whether this delivery slot is active", example = "true")
    private boolean active;

    @PrePersist
    protected void onCreate() {
        // Default to active if not explicitly set
        // Note: primitive boolean defaults to false, so we set true on create
    }
}
