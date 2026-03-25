package user_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import user_service.entity.PickupPoint;

import java.util.List;
import java.util.Optional;

@Repository
public interface PickupPointRepository extends JpaRepository<PickupPoint, Long> {

    List<PickupPoint> findByActiveTrue();

    Optional<PickupPoint> findByName(String name);

    boolean existsByName(String name);
}
