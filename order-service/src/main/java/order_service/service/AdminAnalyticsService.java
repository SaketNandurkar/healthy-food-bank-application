package order_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import order_service.dto.AdminAnalyticsOverviewDTO;
import order_service.dto.OrdersByPickupPointDTO;
import order_service.dto.TopProductDTO;
import order_service.dto.TopVendorDTO;
import order_service.repository.OrderRepository;

import java.util.List;
import java.util.Map;

/**
 * Service for Admin Analytics Dashboard
 * Aggregates data from orders and user-service for comprehensive analytics
 */
@Service
public class AdminAnalyticsService {

    private static final Logger logger = LoggerFactory.getLogger(AdminAnalyticsService.class);

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${user.service.url:http://localhost:9090}")
    private String userServiceUrl;

    /**
     * Get overview analytics combining data from orders and user-service
     * @return AdminAnalyticsOverviewDTO with total users, vendors, orders, and revenue
     */
    public AdminAnalyticsOverviewDTO getOverview() {
        logger.info("Fetching admin analytics overview");

        AdminAnalyticsOverviewDTO overview = new AdminAnalyticsOverviewDTO();

        // Get order-related statistics
        Long totalOrders = orderRepository.count();
        Double totalRevenue = orderRepository.getTotalRevenue();

        overview.setTotalOrders(totalOrders);
        overview.setTotalRevenue(totalRevenue != null ? totalRevenue : 0.0);

        // Get user statistics from user-service
        try {
            String url = userServiceUrl + "/user/admin/users/stats";
            logger.info("Calling user-service at: {}", url);

            @SuppressWarnings("unchecked")
            Map<String, Long> userStats = restTemplate.getForObject(url, Map.class);

            if (userStats != null) {
                Long totalUsers = userStats.get("total");
                Long totalVendors = userStats.get("vendors");

                overview.setTotalUsers(totalUsers != null ? totalUsers : 0L);
                overview.setTotalVendors(totalVendors != null ? totalVendors : 0L);

                logger.info("User statistics retrieved: {} users, {} vendors", totalUsers, totalVendors);
            }
        } catch (Exception e) {
            logger.error("Failed to fetch user statistics from user-service: {}", e.getMessage());
            // Set defaults if user-service is unavailable
            overview.setTotalUsers(0L);
            overview.setTotalVendors(0L);
        }

        logger.info("Overview compiled: {} users, {} vendors, {} orders, ${}",
                   overview.getTotalUsers(), overview.getTotalVendors(),
                   overview.getTotalOrders(), overview.getTotalRevenue());

        return overview;
    }

    /**
     * Get orders grouped by pickup point
     * @return List of OrdersByPickupPointDTO
     */
    public List<OrdersByPickupPointDTO> getOrdersByPickupPoint() {
        logger.info("Fetching orders by pickup point");
        List<OrdersByPickupPointDTO> result = orderRepository.getOrdersByPickupPoint();
        logger.info("Found {} pickup points", result.size());
        return result;
    }

    /**
     * Get top products by quantity ordered
     * @return List of TopProductDTO
     */
    public List<TopProductDTO> getTopProducts() {
        logger.info("Fetching top products");
        List<TopProductDTO> result = orderRepository.getTopProducts();
        logger.info("Found {} products", result.size());
        return result;
    }

    /**
     * Get top vendors by order count
     * @return List of TopVendorDTO
     */
    public List<TopVendorDTO> getTopVendors() {
        logger.info("Fetching top vendors");
        List<TopVendorDTO> result = orderRepository.getTopVendors();
        logger.info("Found {} vendors", result.size());
        return result;
    }
}
