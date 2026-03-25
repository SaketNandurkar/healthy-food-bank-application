package user_service.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import user_service.repository.CustomerRepository;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/health")
public class HealthController {

    @Autowired
    private CustomerRepository customerRepository;

    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getHealthStatus() {
        Map<String, Object> healthStatus = new HashMap<>();
        
        try {
            // Check database connectivity
            long userCount = customerRepository.count();
            healthStatus.put("status", "UP");
            healthStatus.put("database", "UP");
            healthStatus.put("userCount", userCount);
            healthStatus.put("timestamp", LocalDateTime.now());
            healthStatus.put("service", "user-service");
            
            return ResponseEntity.ok(healthStatus);
        } catch (Exception e) {
            healthStatus.put("status", "DOWN");
            healthStatus.put("database", "DOWN");
            healthStatus.put("error", e.getMessage());
            healthStatus.put("timestamp", LocalDateTime.now());
            healthStatus.put("service", "user-service");
            
            return ResponseEntity.status(503).body(healthStatus);
        }
    }

    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> getReadinessStatus() {
        Map<String, Object> readinessStatus = new HashMap<>();
        
        try {
            // Check if service is ready to handle requests
            customerRepository.count();
            readinessStatus.put("ready", true);
            readinessStatus.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(readinessStatus);
        } catch (Exception e) {
            readinessStatus.put("ready", false);
            readinessStatus.put("error", e.getMessage());
            readinessStatus.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.status(503).body(readinessStatus);
        }
    }
}