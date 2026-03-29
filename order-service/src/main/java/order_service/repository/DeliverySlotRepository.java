package order_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import order_service.entity.DeliverySlot;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface DeliverySlotRepository extends JpaRepository<DeliverySlot, Long> {

    List<DeliverySlot> findByActiveTrueOrderByCutoffDateTimeAsc();

    Optional<DeliverySlot> findByDeliveryDate(LocalDate deliveryDate);

    /**
     * Find active delivery slots whose cutoff is still in the future.
     * Ordered by cutoff ascending so the first result is the nearest upcoming slot.
     */
    @Query("SELECT d FROM DeliverySlot d WHERE d.active = true AND d.cutoffDateTime > :now ORDER BY d.cutoffDateTime ASC")
    List<DeliverySlot> findActiveUpcomingSlots(@Param("now") LocalDateTime now);

    List<DeliverySlot> findAllByOrderByDeliveryDateDesc();
}
