package user_service.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import user_service.service.DataMigrationService;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/migration")
@CrossOrigin(origins = "http://localhost:4200")
@Tag(name = "Data Migration", description = "Endpoints for migrating data to new schema")
public class DataMigrationController {

    @Autowired
    private DataMigrationService dataMigrationService;

    @Operation(summary = "Migrate customer pickup points",
               description = "Migrates existing customer pickupPointId data to customer_pickup_points table")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Migration completed successfully"),
        @ApiResponse(responseCode = "500", description = "Migration failed")
    })
    @PostMapping("/customer-pickup-points")
    public ResponseEntity<Map<String, Object>> migrateCustomerPickupPoints() {
        try {
            dataMigrationService.createVendorPickupPointsTable();
            int migratedCount = dataMigrationService.migrateCustomerPickupPoints();

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("migratedCount", migratedCount);
            response.put("message", "Successfully migrated " + migratedCount + " customer pickup points");

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
}
