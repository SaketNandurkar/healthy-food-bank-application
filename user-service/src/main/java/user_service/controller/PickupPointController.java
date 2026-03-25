package user_service.controller;

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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import user_service.entity.PickupPoint;
import user_service.service.PickupPointService;

import java.util.List;

@RestController
@RequestMapping("/pickup-points")
@Tag(name = "Pickup Point Management", description = "APIs for managing pickup points where customers can collect their orders")
public class PickupPointController {

    private static final Logger logger = LoggerFactory.getLogger(PickupPointController.class);
    private final PickupPointService pickupPointService;

    public PickupPointController(PickupPointService pickupPointService) {
        this.pickupPointService = pickupPointService;
    }

    @Operation(summary = "Get all pickup points",
            description = "Retrieves a list of all pickup points including active and inactive ones")
    @ApiResponse(responseCode = "200", description = "Pickup points retrieved successfully",
            content = @Content(mediaType = "application/json",
                    array = @ArraySchema(schema = @Schema(implementation = PickupPoint.class))))
    @GetMapping
    public ResponseEntity<List<PickupPoint>> getAllPickupPoints() {
        logger.info("GET /pickup-points - Fetching all pickup points");
        List<PickupPoint> pickupPoints = pickupPointService.getAllPickupPoints();
        return ResponseEntity.ok(pickupPoints);
    }

    @Operation(summary = "Get active pickup points",
            description = "Retrieves only active pickup points available for customer selection")
    @ApiResponse(responseCode = "200", description = "Active pickup points retrieved successfully",
            content = @Content(mediaType = "application/json",
                    array = @ArraySchema(schema = @Schema(implementation = PickupPoint.class))))
    @GetMapping("/active")
    public ResponseEntity<List<PickupPoint>> getActivePickupPoints() {
        logger.info("GET /pickup-points/active - Fetching active pickup points");
        List<PickupPoint> pickupPoints = pickupPointService.getActivePickupPoints();
        return ResponseEntity.ok(pickupPoints);
    }

    @Operation(summary = "Get pickup point by ID",
            description = "Retrieves a specific pickup point by its ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Pickup point found",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = PickupPoint.class))),
            @ApiResponse(responseCode = "404", description = "Pickup point not found")
    })
    @GetMapping("/{id}")
    public ResponseEntity<?> getPickupPointById(
            @Parameter(description = "ID of the pickup point to retrieve", required = true, example = "1")
            @PathVariable Long id) {
        logger.info("GET /pickup-points/{} - Fetching pickup point by ID", id);
        return pickupPointService.getPickupPointById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND).body(null));
    }

    @Operation(summary = "Create new pickup point",
            description = "Creates a new pickup point in the system (Admin only)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Pickup point created successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = PickupPoint.class))),
            @ApiResponse(responseCode = "400", description = "Invalid data or duplicate pickup point name")
    })
    @PostMapping
    public ResponseEntity<?> createPickupPoint(
            @Parameter(description = "Pickup point details to create", required = true)
            @RequestBody PickupPoint pickupPoint) {
        logger.info("POST /pickup-points - Creating new pickup point: {}", pickupPoint.getName());
        try {
            PickupPoint created = pickupPointService.createPickupPoint(pickupPoint);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (RuntimeException e) {
            logger.error("Error creating pickup point: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    @Operation(summary = "Update pickup point",
            description = "Updates an existing pickup point (Admin only)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Pickup point updated successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = PickupPoint.class))),
            @ApiResponse(responseCode = "404", description = "Pickup point not found"),
            @ApiResponse(responseCode = "400", description = "Invalid data or duplicate pickup point name")
    })
    @PutMapping("/{id}")
    public ResponseEntity<?> updatePickupPoint(
            @Parameter(description = "ID of the pickup point to update", required = true, example = "1")
            @PathVariable Long id,
            @Parameter(description = "Updated pickup point details", required = true)
            @RequestBody PickupPoint pickupPoint) {
        logger.info("PUT /pickup-points/{} - Updating pickup point", id);
        try {
            PickupPoint updated = pickupPointService.updatePickupPoint(id, pickupPoint);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            logger.error("Error updating pickup point: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    @Operation(summary = "Delete pickup point",
            description = "Permanently deletes a pickup point (Admin only)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Pickup point deleted successfully"),
            @ApiResponse(responseCode = "404", description = "Pickup point not found")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePickupPoint(
            @Parameter(description = "ID of the pickup point to delete", required = true, example = "1")
            @PathVariable Long id) {
        logger.info("DELETE /pickup-points/{} - Deleting pickup point", id);
        try {
            pickupPointService.deletePickupPoint(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            logger.error("Error deleting pickup point: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @Operation(summary = "Deactivate pickup point",
            description = "Soft deletes a pickup point by setting it as inactive (Admin only)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Pickup point deactivated successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = PickupPoint.class))),
            @ApiResponse(responseCode = "404", description = "Pickup point not found")
    })
    @PutMapping("/{id}/deactivate")
    public ResponseEntity<?> deactivatePickupPoint(
            @Parameter(description = "ID of the pickup point to deactivate", required = true, example = "1")
            @PathVariable Long id) {
        logger.info("PUT /pickup-points/{}/deactivate - Deactivating pickup point", id);
        try {
            PickupPoint deactivated = pickupPointService.deactivatePickupPoint(id);
            return ResponseEntity.ok(deactivated);
        } catch (RuntimeException e) {
            logger.error("Error deactivating pickup point: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @Operation(summary = "Activate pickup point",
            description = "Reactivates a previously deactivated pickup point (Admin only)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Pickup point activated successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = PickupPoint.class))),
            @ApiResponse(responseCode = "404", description = "Pickup point not found")
    })
    @PutMapping("/{id}/activate")
    public ResponseEntity<?> activatePickupPoint(
            @Parameter(description = "ID of the pickup point to activate", required = true, example = "1")
            @PathVariable Long id) {
        logger.info("PUT /pickup-points/{}/activate - Activating pickup point", id);
        try {
            PickupPoint activated = pickupPointService.activatePickupPoint(id);
            return ResponseEntity.ok(activated);
        } catch (RuntimeException e) {
            logger.error("Error activating pickup point: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}
