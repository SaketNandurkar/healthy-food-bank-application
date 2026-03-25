package product_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import product_service.entity.Product;

@Service
public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);
    private static final String USER_SERVICE_URL = "http://localhost:9090";

    @Autowired
    private RestTemplate restTemplate;

    public void notifyProductAdded(Product product) {
        try {
            String url = USER_SERVICE_URL + "/api/notify/product-added";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Product> request = new HttpEntity<>(product, headers);

            restTemplate.postForEntity(url, request, String.class);
            logger.info("Successfully notified user service about new product: {}", product.getProductName());
        } catch (Exception e) {
            logger.warn("Failed to notify user service about new product: {}", e.getMessage());
            // Don't throw exception - notification failure shouldn't break product creation
        }
    }

    public void notifyProductUpdated(Product product) {
        try {
            String url = USER_SERVICE_URL + "/api/notify/product-updated";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Product> request = new HttpEntity<>(product, headers);

            restTemplate.postForEntity(url, request, String.class);
            logger.info("Successfully notified user service about updated product: {}", product.getProductName());
        } catch (Exception e) {
            logger.warn("Failed to notify user service about updated product: {}", e.getMessage());
        }
    }

    public void notifyProductDeleted(Product product) {
        try {
            String url = USER_SERVICE_URL + "/api/notify/product-deleted";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Product> request = new HttpEntity<>(product, headers);

            restTemplate.postForEntity(url, request, String.class);
            logger.info("Successfully notified user service about deleted product: {}", product.getProductName());
        } catch (Exception e) {
            logger.warn("Failed to notify user service about deleted product: {}", e.getMessage());
        }
    }
}