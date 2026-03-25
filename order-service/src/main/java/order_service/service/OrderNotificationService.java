package order_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import order_service.entity.Order;

import java.util.HashMap;
import java.util.Map;

@Service
public class OrderNotificationService {

    private static final Logger logger = LoggerFactory.getLogger(OrderNotificationService.class);
    private static final String USER_SERVICE_URL = "http://localhost:9090";

    @Autowired
    private RestTemplate restTemplate;

    public void notifyVendorAboutNewOrder(Order order) {
        try {
            logger.info("Sending order notification to vendor: {} for order: {}", order.getVendorId(), order.getId());

            Map<String, Object> notification = new HashMap<>();
            notification.put("orderId", order.getId());
            notification.put("orderName", order.getOrderName());
            notification.put("orderQuantity", order.getOrderQuantity());
            notification.put("orderUnit", order.getOrderUnit());
            notification.put("orderPrice", order.getOrderPrice());
            notification.put("customerId", order.getCustomerId());
            notification.put("productId", order.getProductId());
            notification.put("productName", order.getProductName());
            notification.put("vendorId", order.getVendorId());
            notification.put("orderStatus", order.getOrderStatus());
            notification.put("orderPlacedDate", order.getOrderPlacedDate());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(notification, headers);

            String url = USER_SERVICE_URL + "/api/notify/order-placed";
            restTemplate.postForEntity(url, request, String.class);

            logger.info("Successfully notified user service about new order for vendor: {}", order.getVendorId());
        } catch (Exception e) {
            logger.warn("Failed to notify user service about new order for vendor: {}", order.getVendorId(), e);
        }
    }

    public void notifyVendorAboutOrderUpdate(Order order, String oldStatus) {
        try {
            logger.info("Sending order update notification to vendor: {} for order: {}", order.getVendorId(), order.getId());

            Map<String, Object> notification = new HashMap<>();
            notification.put("orderId", order.getId());
            notification.put("orderName", order.getOrderName());
            notification.put("oldStatus", oldStatus);
            notification.put("newStatus", order.getOrderStatus());
            notification.put("vendorId", order.getVendorId());
            notification.put("customerId", order.getCustomerId());
            notification.put("productName", order.getProductName());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(notification, headers);

            String url = USER_SERVICE_URL + "/api/notify/order-updated";
            restTemplate.postForEntity(url, request, String.class);

            logger.info("Successfully notified user service about order update for vendor: {}", order.getVendorId());
        } catch (Exception e) {
            logger.warn("Failed to notify user service about order update for vendor: {}", order.getVendorId(), e);
        }
    }
}