package order_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import order_service.dto.ProductDemandSummary;
import order_service.dto.OrdersByPickupPointDTO;
import order_service.dto.TopProductDTO;
import order_service.dto.TopVendorDTO;
import order_service.entity.Order;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Integer> {

    List<Order> findByCustomerId(Long customerId);

    List<Order> findByOrderStatus(String orderStatus);

    List<Order> findByOrderNameContainingIgnoreCase(String orderName);

    List<Order> findByVendorId(String vendorId);

    List<Order> findByVendorIdAndOrderStatus(String vendorId, String orderStatus);

    Optional<Order> findByCustomerIdAndProductIdAndVendorIdAndOrderStatus(
            Long customerId, Integer productId, String vendorId, String orderStatus);

    /**
     * Aggregate product demand for a vendor using SQL GROUP BY
     * Sums quantities for ISSUED and SCHEDULED orders only
     * (ISSUED = New orders, SCHEDULED = Accepted orders)
     *
     * Performance: O(n) with database-level aggregation - OPTIMAL
     *
     * @param vendorId The vendor ID
     * @return List of ProductDemandSummary with aggregated quantities
     */
    @Query("SELECT new order_service.dto.ProductDemandSummary(o.orderName, SUM(o.orderQuantity), o.orderUnit) " +
           "FROM Order o " +
           "WHERE o.vendorId = :vendorId " +
           "AND (o.orderStatus = 'ISSUED' OR o.orderStatus = 'SCHEDULED') " +
           "GROUP BY o.orderName, o.orderUnit " +
           "ORDER BY SUM(o.orderQuantity) DESC")
    List<ProductDemandSummary> getProductDemandSummary(@Param("vendorId") String vendorId);

    /**
     * Get orders for a vendor that were created or updated since a given timestamp
     * Used for polling-based real-time notifications
     *
     * @param vendorId The vendor ID
     * @param since Timestamp to check for new/updated orders
     * @return List of orders created or status-updated after the given timestamp
     */
    @Query("SELECT o FROM Order o " +
           "WHERE o.vendorId = :vendorId " +
           "AND (o.orderPlacedDate > :since OR o.statusUpdatedAt > :since) " +
           "ORDER BY o.orderPlacedDate DESC")
    List<Order> findOrdersUpdatedSince(@Param("vendorId") String vendorId,
                                       @Param("since") LocalDateTime since);

    // ============ ADMIN ANALYTICS QUERIES ============

    /**
     * Get total revenue from all orders
     * @return Sum of all order prices
     */
    @Query("SELECT COALESCE(SUM(o.orderPrice), 0.0) FROM Order o")
    Double getTotalRevenue();

    /**
     * Get orders grouped by pickup point
     * @return List of pickup points with order counts
     */
    @Query("SELECT new order_service.dto.OrdersByPickupPointDTO(o.customerPickupPoint, COUNT(o)) " +
           "FROM Order o " +
           "GROUP BY o.customerPickupPoint " +
           "ORDER BY COUNT(o) DESC")
    List<OrdersByPickupPointDTO> getOrdersByPickupPoint();

    /**
     * Get top products by total quantity ordered
     * @return List of products with total quantities
     */
    @Query("SELECT new order_service.dto.TopProductDTO(o.productName, CAST(SUM(o.orderQuantity) AS long)) " +
           "FROM Order o " +
           "GROUP BY o.productName " +
           "ORDER BY SUM(o.orderQuantity) DESC")
    List<TopProductDTO> getTopProducts();

    /**
     * Get top vendors by order count
     * @return List of vendors with order counts
     */
    @Query("SELECT new order_service.dto.TopVendorDTO(o.vendorName, COUNT(o)) " +
           "FROM Order o " +
           "WHERE o.vendorName IS NOT NULL " +
           "GROUP BY o.vendorName " +
           "ORDER BY COUNT(o) DESC")
    List<TopVendorDTO> getTopVendors();
}