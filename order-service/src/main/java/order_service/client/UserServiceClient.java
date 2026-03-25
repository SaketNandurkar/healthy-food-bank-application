package order_service.client;

import order_service.dto.CustomerDTO;
import order_service.dto.PickupPointDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class UserServiceClient {

    private static final Logger logger = LoggerFactory.getLogger(UserServiceClient.class);
    private static final String USER_SERVICE_URL = "http://localhost:9090";

    private final RestTemplate restTemplate;

    public UserServiceClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public CustomerDTO getCustomerById(Long customerId) {
        try {
            String url = USER_SERVICE_URL + "/customer/" + customerId;
            logger.info("Fetching customer details from: {}", url);
            return restTemplate.getForObject(url, CustomerDTO.class);
        } catch (Exception e) {
            logger.error("Error fetching customer with ID: {}", customerId, e);
            return null;
        }
    }

    public PickupPointDTO getPickupPointById(Long pickupPointId) {
        try {
            String url = USER_SERVICE_URL + "/pickup-points/" + pickupPointId;
            logger.info("Fetching pickup point details from: {}", url);
            return restTemplate.getForObject(url, PickupPointDTO.class);
        } catch (Exception e) {
            logger.error("Error fetching pickup point with ID: {}", pickupPointId, e);
            return null;
        }
    }
}
