package user_service.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import user_service.entity.Customer;
import user_service.entity.VendorPickupPoint;
import user_service.repository.CustomerRepository;
import user_service.repository.VendorPickupPointRepository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/migration")
@CrossOrigin(origins = "http://localhost:4200")
public class MigrationController {

    @Autowired
    private VendorPickupPointRepository vendorPickupPointRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @PostMapping("/fix-vendor-ids")
    public ResponseEntity<Map<String, Object>> fixVendorIds() {
        List<VendorPickupPoint> allPoints = vendorPickupPointRepository.findAll();
        int updated = 0;
        int skipped = 0;

        for (VendorPickupPoint point : allPoints) {
            String currentVendorId = point.getVendorId();

            // Check if it's an email (contains @)
            if (currentVendorId != null && currentVendorId.contains("@")) {
                // Find the customer by username
                Optional<Customer> customer = customerRepository.findByUserName(currentVendorId);
                if (customer.isPresent() && customer.get().getVendorId() != null) {
                    String actualVendorId = customer.get().getVendorId();
                    point.setVendorId(actualVendorId);
                    vendorPickupPointRepository.save(point);
                    updated++;
                } else {
                    skipped++;
                }
            } else {
                skipped++;
            }
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("totalRecords", allPoints.size());
        response.put("updated", updated);
        response.put("skipped", skipped);
        response.put("message", "Migration completed successfully");

        return ResponseEntity.ok(response);
    }
}
