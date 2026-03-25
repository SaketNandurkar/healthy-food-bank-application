package order_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import order_service.entity.Order;

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
}