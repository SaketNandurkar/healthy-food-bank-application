package user_service.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import user_service.dto.CustomerPickupPointDTO;
import user_service.entity.CustomerPickupPoint;
import user_service.service.CustomerPickupPointService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/customer-pickup-points")
@CrossOrigin(origins = "http://localhost:4200")
@Tag(name = "Customer Pickup Points", description = "APIs for managing customer pickup points")
public class CustomerPickupPointController {

    @Autowired
    private CustomerPickupPointService customerPickupPointService;

    @Operation(summary = "Get all pickup points for a customer",
               description = "Returns all pickup points associated with a customer")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pickup points retrieved successfully"),
        @ApiResponse(responseCode = "404", description = "Customer not found")
    })
    @GetMapping("/{customerId}")
    public ResponseEntity<List<CustomerPickupPoint>> getCustomerPickupPoints(
            @Parameter(description = "Customer ID", required = true, example = "1")
            @PathVariable Long customerId) {
        try {
            List<CustomerPickupPoint> pickupPoints = customerPickupPointService.getCustomerPickupPoints(customerId);
            return ResponseEntity.ok(pickupPoints);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(summary = "Get active pickup point for a customer",
               description = "Returns the currently active pickup point for a customer")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Active pickup point retrieved successfully"),
        @ApiResponse(responseCode = "404", description = "No active pickup point found")
    })
    @GetMapping("/{customerId}/active")
    public ResponseEntity<CustomerPickupPoint> getActivePickupPoint(
            @Parameter(description = "Customer ID", required = true, example = "1")
            @PathVariable Long customerId) {
        try {
            Optional<CustomerPickupPoint> activePoint = customerPickupPointService.getActivePickupPoint(customerId);
            return activePoint.map(ResponseEntity::ok)
                    .orElseGet(() -> ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(summary = "Add a new pickup point for a customer",
               description = "Adds a new pickup point to the customer's list. If it's the first one, it becomes active automatically.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Pickup point added successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid request or pickup point already exists"),
        @ApiResponse(responseCode = "404", description = "Pickup point not found")
    })
    @PostMapping("/{customerId}")
    public ResponseEntity<Map<String, Object>> addPickupPoint(
            @Parameter(description = "Customer ID", required = true, example = "1")
            @PathVariable Long customerId,
            @RequestBody CustomerPickupPointDTO dto) {
        try {
            CustomerPickupPoint added = customerPickupPointService.addPickupPoint(
                    customerId, dto.getPickupPointId(), dto.isMakeActive());

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Pickup point added successfully");
            response.put("data", added);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", "Internal server error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @Operation(summary = "Set a pickup point as active",
               description = "Sets the specified pickup point as active and deactivates all others")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pickup point set as active successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid request"),
        @ApiResponse(responseCode = "404", description = "Pickup point not found for this customer")
    })
    @PutMapping("/{customerId}/active/{pickupPointId}")
    public ResponseEntity<Map<String, Object>> setActivePickupPoint(
            @Parameter(description = "Customer ID", required = true, example = "1")
            @PathVariable Long customerId,
            @Parameter(description = "Pickup Point ID", required = true, example = "1")
            @PathVariable Long pickupPointId) {
        try {
            CustomerPickupPoint updated = customerPickupPointService.setActivePickupPoint(customerId, pickupPointId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Pickup point set as active successfully");
            response.put("data", updated);

            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", "Internal server error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @Operation(summary = "Delete a pickup point",
               description = "Deletes the specified pickup point from the customer's list. Cannot delete if it's the only one.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pickup point deleted successfully"),
        @ApiResponse(responseCode = "400", description = "Cannot delete the only pickup point"),
        @ApiResponse(responseCode = "404", description = "Pickup point not found for this customer")
    })
    @DeleteMapping("/{customerId}/{pickupPointId}")
    public ResponseEntity<Map<String, Object>> deletePickupPoint(
            @Parameter(description = "Customer ID", required = true, example = "1")
            @PathVariable Long customerId,
            @Parameter(description = "Pickup Point ID", required = true, example = "1")
            @PathVariable Long pickupPointId) {
        try {
            customerPickupPointService.deletePickupPoint(customerId, pickupPointId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Pickup point deleted successfully");

            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", "Internal server error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
