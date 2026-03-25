package user_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import user_service.entity.VendorPickupPoint;

import java.util.List;
import java.util.Optional;

@Repository
public interface VendorPickupPointRepository extends JpaRepository<VendorPickupPoint, Long> {

    List<VendorPickupPoint> findByVendorId(String vendorId);

    List<VendorPickupPoint> findByVendorIdAndActiveTrue(String vendorId);

    List<VendorPickupPoint> findByPickupPointIdAndActiveTrue(Long pickupPointId);

    Optional<VendorPickupPoint> findByVendorIdAndPickupPointId(String vendorId, Long pickupPointId);
}
