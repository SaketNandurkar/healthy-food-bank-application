package order_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for Admin Analytics Dashboard Overview
 * Returns high-level metrics for admin dashboard
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AdminAnalyticsOverviewDTO {
    private Long totalUsers;
    private Long totalVendors;
    private Long totalOrders;
    private Double totalRevenue;
}
