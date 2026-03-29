package order_service.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import order_service.entity.DeliverySlot;
import order_service.service.DeliverySlotService;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/delivery-slots")
@CrossOrigin(origins = "*")
@Tag(name = "Delivery Slots", description = "APIs for managing delivery slots and cutoff times")
public class DeliverySlotController {

    private static final Logger logger = LoggerFactory.getLogger(DeliverySlotController.class);
    private static final ZoneId IST_ZONE = ZoneId.of("Asia/Kolkata");

    @Autowired
    private DeliverySlotService deliverySlotService;

    @Operation(summary = "Get current active delivery slot",
               description = "Returns the nearest upcoming active delivery slot with ordering status")
    @ApiResponse(responseCode = "200", description = "Active slot info returned")
    @GetMapping("/active")
    public ResponseEntity<Map<String, Object>> getActiveSlot() {
        Map<String, Object> response = new HashMap<>();
        Optional<DeliverySlot> activeSlot = deliverySlotService.getCurrentActiveSlot();

        if (activeSlot.isPresent()) {
            DeliverySlot slot = activeSlot.get();
            LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);
            Duration timeUntilCutoff = Duration.between(nowIST, slot.getCutoffDateTime());

            response.put("id", slot.getId());
            response.put("deliveryDate", slot.getDeliveryDate().toString());
            response.put("cutoffDateTime", slot.getCutoffDateTime().toString());
            response.put("active", slot.isActive());
            response.put("orderAllowed", true);
            response.put("timeUntilCutoff", timeUntilCutoff.toString());
            response.put("hoursUntilCutoff", timeUntilCutoff.toHours());
            response.put("message", "Orders are currently being accepted");
        } else {
            response.put("orderAllowed", false);
            response.put("message", "No active delivery slot available. Order window is closed.");
        }

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Get all delivery slots",
               description = "Returns all delivery slots ordered by delivery date descending (Admin)")
    @ApiResponse(responseCode = "200", description = "List of all delivery slots",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = DeliverySlot.class))))
    @GetMapping
    public ResponseEntity<List<DeliverySlot>> getAllSlots() {
        List<DeliverySlot> slots = deliverySlotService.getAllSlots();
        return ResponseEntity.ok(slots);
    }

    @Operation(summary = "Create delivery slot",
               description = "Creates a new delivery slot with delivery date and cutoff time (Admin)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Delivery slot created",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = DeliverySlot.class))),
        @ApiResponse(responseCode = "400", description = "Invalid slot data")
    })
    @PostMapping
    public ResponseEntity<?> createSlot(
            @Parameter(description = "Delivery slot to create", required = true)
            @RequestBody DeliverySlot slot) {
        try {
            if (slot.getDeliveryDate() == null || slot.getCutoffDateTime() == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "deliveryDate and cutoffDateTime are required");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
            }

            DeliverySlot created = deliverySlotService.createSlot(slot);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (Exception e) {
            logger.error("Error creating delivery slot: {}", e.getMessage(), e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }

    @Operation(summary = "Update delivery slot",
               description = "Updates an existing delivery slot (Admin)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Delivery slot updated",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = DeliverySlot.class))),
        @ApiResponse(responseCode = "404", description = "Delivery slot not found")
    })
    @PutMapping("/{id}")
    public ResponseEntity<?> updateSlot(
            @Parameter(description = "Slot ID", required = true) @PathVariable Long id,
            @Parameter(description = "Updated slot data", required = true) @RequestBody DeliverySlot slot) {
        try {
            DeliverySlot updated = deliverySlotService.updateSlot(id, slot);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            logger.error("Error updating delivery slot: {}", e.getMessage(), e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    @Operation(summary = "Toggle delivery slot active status",
               description = "Activates or deactivates a delivery slot (Admin)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Slot toggled",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = DeliverySlot.class))),
        @ApiResponse(responseCode = "404", description = "Delivery slot not found")
    })
    @PutMapping("/{id}/toggle")
    public ResponseEntity<?> toggleSlot(
            @Parameter(description = "Slot ID", required = true) @PathVariable Long id) {
        try {
            DeliverySlot toggled = deliverySlotService.toggleSlotActive(id);
            return ResponseEntity.ok(toggled);
        } catch (RuntimeException e) {
            logger.error("Error toggling delivery slot: {}", e.getMessage(), e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    @Operation(summary = "Delete delivery slot",
               description = "Permanently removes a delivery slot (Admin)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Delivery slot deleted"),
        @ApiResponse(responseCode = "404", description = "Delivery slot not found")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSlot(
            @Parameter(description = "Slot ID", required = true) @PathVariable Long id) {
        try {
            deliverySlotService.deleteSlot(id);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Delivery slot deleted successfully");
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            logger.error("Error deleting delivery slot: {}", e.getMessage(), e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }
}
