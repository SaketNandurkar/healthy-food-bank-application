package order_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

@Service
public class ProductServiceClient {

    private static final Logger logger = LoggerFactory.getLogger(ProductServiceClient.class);

    private final RestTemplate restTemplate;

    @Value("${product.service.url:http://localhost:9091}")
    private String productServiceUrl;

    public ProductServiceClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Deduct stock from a product in the product service
     * @param productId The ID of the product
     * @param quantity The quantity to deduct
     * @param unit The unit of measurement
     * @return true if successful, false otherwise
     */
    public boolean deductStock(Integer productId, double quantity, String unit) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(productServiceUrl + "/products/" + productId + "/deduct-stock")
                    .queryParam("quantity", quantity)
                    .queryParam("unit", unit)
                    .toUriString();

            logger.info("Calling product service to deduct stock: URL={}, productId={}, quantity={}, unit={}",
                    url, productId, quantity, unit);

            ResponseEntity<Object> response = restTemplate.postForEntity(url, null, Object.class);

            logger.info("Product service response: status={}, body={}", response.getStatusCode(), response.getBody());

            if (response.getStatusCode() == HttpStatus.OK || response.getStatusCode().is2xxSuccessful()) {
                logger.info("Successfully deducted stock for product ID: {}", productId);
                return true;
            } else {
                logger.warn("Failed to deduct stock. Status code: {}", response.getStatusCode());
                return false;
            }
        } catch (org.springframework.web.client.HttpClientErrorException e) {
            logger.error("HTTP error deducting stock for product ID: {}. Status: {}, Response: {}",
                    productId, e.getStatusCode(), e.getResponseBodyAsString(), e);
            return false;
        } catch (Exception e) {
            logger.error("Error deducting stock for product ID: {}, quantity: {}, unit: {}",
                    productId, quantity, unit, e);
            return false;
        }
    }

    /**
     * Restore stock to a product in the product service (when order is cancelled/rejected)
     * @param productId The ID of the product
     * @param quantity The quantity to restore
     * @param unit The unit of measurement
     * @return true if successful, false otherwise
     */
    public boolean restoreStock(Integer productId, double quantity, String unit) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(productServiceUrl + "/products/" + productId + "/restore-stock")
                    .queryParam("quantity", quantity)
                    .queryParam("unit", unit)
                    .toUriString();

            logger.info("Calling product service to restore stock: URL={}, productId={}, quantity={}, unit={}",
                    url, productId, quantity, unit);

            ResponseEntity<Object> response = restTemplate.postForEntity(url, null, Object.class);

            logger.info("Product service response: status={}, body={}", response.getStatusCode(), response.getBody());

            if (response.getStatusCode() == HttpStatus.OK || response.getStatusCode().is2xxSuccessful()) {
                logger.info("Successfully restored stock for product ID: {}", productId);
                return true;
            } else {
                logger.warn("Failed to restore stock. Status code: {}", response.getStatusCode());
                return false;
            }
        } catch (org.springframework.web.client.HttpClientErrorException e) {
            logger.error("HTTP error restoring stock for product ID: {}. Status: {}, Response: {}",
                    productId, e.getStatusCode(), e.getResponseBodyAsString(), e);
            return false;
        } catch (Exception e) {
            logger.error("Error restoring stock for product ID: {}, quantity: {}, unit: {}",
                    productId, quantity, unit, e);
            return false;
        }
    }
}
