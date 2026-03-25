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
import user_service.dto.VendorPickupPointDTO;
import user_service.entity.VendorPickupPoint;
import user_service.service.VendorPickupPointService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/vendor-pickup-points")
@CrossOrigin(origins = "http://localhost:4200")
@Tag(name = "Vendor Pickup Points", description = "APIs for managing vendor pickup points (many-to-many relationship)")
public class VendorPickupPointController {

    @Autowired
    private VendorPickupPointService vendorPickupPointService;

    @Operation(summary = "Get all pickup points for a vendor",
               description = "Returns all pickup points associated with a vendor")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pickup points retrieved successfully"),
        @ApiResponse(responseCode = "404", description = "Vendor not found")
    })
    @GetMapping("/{vendorId}")
    public ResponseEntity<List<VendorPickupPoint>> getVendorPickupPoints(
            @Parameter(description = "Vendor ID", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        try {
            List<VendorPickupPoint> pickupPoints = vendorPickupPointService.getVendorPickupPoints(vendorId);
            return ResponseEntity.ok(pickupPoints);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(summary = "Get all active pickup points for a vendor",
               description = "Returns all active pickup points for a vendor")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Active pickup points retrieved successfully")
    })
    @GetMapping("/{vendorId}/active")
    public ResponseEntity<List<VendorPickupPoint>> getActiveVendorPickupPoints(
            @Parameter(description = "Vendor ID", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        try {
            List<VendorPickupPoint> pickupPoints = vendorPickupPointService.getActiveVendorPickupPoints(vendorId);
            return ResponseEntity.ok(pickupPoints);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(summary = "Get all vendors serving a pickup point",
               description = "Returns list of vendor IDs that serve the specified pickup point")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vendors retrieved successfully")
    })
    @GetMapping("/by-pickup-point/{pickupPointId}")
    public ResponseEntity<List<String>> getVendorsByPickupPoint(
            @Parameter(description = "Pickup Point ID", required = true, example = "1")
            @PathVariable Long pickupPointId) {
        try {
            List<String> vendorIds = vendorPickupPointService.getVendorsByPickupPoint(pickupPointId);
            return ResponseEntity.ok(vendorIds);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(summary = "Add a new pickup point for a vendor",
               description = "Adds a new pickup point to the vendor's service area")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Pickup point added successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid request or pickup point already exists"),
        @ApiResponse(responseCode = "404", description = "Pickup point not found")
    })
    @PostMapping("/{vendorId}")
    public ResponseEntity<Map<String, Object>> addPickupPoint(
            @Parameter(description = "Vendor ID", required = true, example = "VENDOR001")
            @PathVariable String vendorId,
            @RequestBody VendorPickupPointDTO dto) {
        try {
            VendorPickupPoint added = vendorPickupPointService.addPickupPoint(vendorId, dto.getPickupPointId());

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

    @Operation(summary = "Toggle active status of a vendor pickup point",
               description = "Toggles the active status of a vendor's pickup point")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status toggled successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid request"),
        @ApiResponse(responseCode = "404", description = "Pickup point not found for this vendor")
    })
    @PutMapping("/{vendorId}/toggle/{pickupPointId}")
    public ResponseEntity<Map<String, Object>> toggleActiveStatus(
            @Parameter(description = "Vendor ID", required = true, example = "VENDOR001")
            @PathVariable String vendorId,
            @Parameter(description = "Pickup Point ID", required = true, example = "1")
            @PathVariable Long pickupPointId) {
        try {
            VendorPickupPoint updated = vendorPickupPointService.toggleActiveStatus(vendorId, pickupPointId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Active status toggled successfully");
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

    @Operation(summary = "Delete a pickup point from vendor's service area",
               description = "Removes the specified pickup point from the vendor's service area")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pickup point deleted successfully"),
        @ApiResponse(responseCode = "404", description = "Pickup point not found for this vendor")
    })
    @DeleteMapping("/{vendorId}/{pickupPointId}")
    public ResponseEntity<Map<String, Object>> deletePickupPoint(
            @Parameter(description = "Vendor ID", required = true, example = "VENDOR001")
            @PathVariable String vendorId,
            @Parameter(description = "Pickup Point ID", required = true, example = "1")
            @PathVariable Long pickupPointId) {
        try {
            vendorPickupPointService.deletePickupPoint(vendorId, pickupPointId);

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
