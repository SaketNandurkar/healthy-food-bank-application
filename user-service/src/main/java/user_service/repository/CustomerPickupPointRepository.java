package user_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import user_service.entity.CustomerPickupPoint;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerPickupPointRepository extends JpaRepository<CustomerPickupPoint, Long> {

    List<CustomerPickupPoint> findByCustomerId(Long customerId);

    Optional<CustomerPickupPoint> findByCustomerIdAndActiveTrue(Long customerId);

    Optional<CustomerPickupPoint> findByCustomerIdAndPickupPointId(Long customerId, Long pickupPointId);
}
