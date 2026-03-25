package user_service.client;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class OrderServiceClient {

    private static final Logger logger = LoggerFactory.getLogger(OrderServiceClient.class);

    private final RestTemplate restTemplate;

    @Value("${order.service.url}")
    private String orderServiceUrl;

    public OrderServiceClient(@LoadBalanced RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @CircuitBreaker(name = "order-service", fallbackMethod = "getOrdersFallback")
    public ResponseEntity<String> getOrders() {
        try {
            logger.info("Calling order service at: {}", orderServiceUrl + "/order/getOrders");
            String response = restTemplate.getForObject(orderServiceUrl + "/order/getOrders", String.class);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error calling order service", e);
            throw e;
        }
    }

    public ResponseEntity<String> getOrdersFallback(Exception e) {
        logger.warn("Order service is unavailable, returning fallback response", e);
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body("Order service is currently unavailable. Please try again later.");
    }

    @CircuitBreaker(name = "order-service", fallbackMethod = "createOrderFallback")
    public ResponseEntity<String> createOrder(Object orderRequest) {
        try {
            logger.info("Creating order via order service");
            return restTemplate.postForEntity(orderServiceUrl + "/order", orderRequest, String.class);
        } catch (Exception e) {
            logger.error("Error creating order", e);
            throw e;
        }
    }

    public ResponseEntity<String> createOrderFallback(Object orderRequest, Exception e) {
        logger.warn("Order service unavailable for order creation", e);
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body("Unable to create order at this time. Please try again later.");
    }
}