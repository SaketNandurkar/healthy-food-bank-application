package user_service.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import user_service.repository.CustomerPickupPointRepository;
import user_service.repository.VendorPickupPointRepository;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/debug")
@CrossOrigin(origins = "http://localhost:4200")
public class DebugController {

    @Autowired
    private CustomerPickupPointRepository customerPickupPointRepository;

    @Autowired
    private VendorPickupPointRepository vendorPickupPointRepository;

    @GetMapping("/customer-pickup-points/{customerId}")
    public ResponseEntity<Map<String, Object>> getCustomerPickupPointsDebug(@PathVariable Long customerId) {
        Map<String, Object> response = new HashMap<>();
        response.put("all", customerPickupPointRepository.findByCustomerId(customerId));
        response.put("active", customerPickupPointRepository.findByCustomerIdAndActiveTrue(customerId));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/vendor-pickup-points/{vendorId}")
    public ResponseEntity<Map<String, Object>> getVendorPickupPointsDebug(@PathVariable String vendorId) {
        Map<String, Object> response = new HashMap<>();
        response.put("all", vendorPickupPointRepository.findByVendorId(vendorId));
        response.put("active", vendorPickupPointRepository.findByVendorIdAndActiveTrue(vendorId));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/vendor-pickup-points/by-point/{pickupPointId}")
    public ResponseEntity<Map<String, Object>> getVendorsByPickupPointDebug(@PathVariable Long pickupPointId) {
        Map<String, Object> response = new HashMap<>();
        response.put("vendors", vendorPickupPointRepository.findByPickupPointIdAndActiveTrue(pickupPointId));
        return ResponseEntity.ok(response);
    }
}
