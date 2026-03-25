package product_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class VendorService {

    private static final Logger logger = LoggerFactory.getLogger(VendorService.class);

    @Autowired
    private RestTemplate restTemplate;

    @Value("${user.service.url:http://localhost:9090}")
    private String userServiceUrl;

    public String getVendorNameByVendorId(String vendorId) {
        if (vendorId == null || vendorId.trim().isEmpty()) {
            return null;
        }

        try {
            String url = userServiceUrl + "/user/vendor/" + vendorId + "/name";
            logger.info("Fetching vendor name from: {}", url);

            String vendorName = restTemplate.getForObject(url, String.class);
            logger.info("Successfully fetched vendor name for vendorId: {}", vendorId);

            return vendorName;
        } catch (Exception e) {
            logger.warn("Failed to fetch vendor name for vendorId: {}. Error: {}", vendorId, e.getMessage());
            return null;
        }
    }

    /**
     * Get all vendor IDs that serve a specific pickup point
     */
    public java.util.List<String> getVendorsByPickupPoint(Long pickupPointId) {
        if (pickupPointId == null) {
            return java.util.Collections.emptyList();
        }

        try {
            String url = userServiceUrl + "/vendor-pickup-points/by-pickup-point/" + pickupPointId;
            logger.info("Fetching vendors for pickup point from: {}", url);

            String[] vendorIds = restTemplate.getForObject(url, String[].class);
            if (vendorIds != null) {
                logger.info("Successfully fetched {} vendors for pickup point: {}", vendorIds.length, pickupPointId);
                return java.util.Arrays.asList(vendorIds);
            }
            return java.util.Collections.emptyList();
        } catch (Exception e) {
            logger.warn("Failed to fetch vendors for pickup point: {}. Error: {}", pickupPointId, e.getMessage());
            return java.util.Collections.emptyList();
        }
    }
}
