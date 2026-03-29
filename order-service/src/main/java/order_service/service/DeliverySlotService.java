package order_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import order_service.entity.DeliverySlot;
import order_service.repository.DeliverySlotRepository;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;

@Service
public class DeliverySlotService {

    private static final Logger logger = LoggerFactory.getLogger(DeliverySlotService.class);
    private static final ZoneId IST_ZONE = ZoneId.of("Asia/Kolkata");

    @Autowired
    private DeliverySlotRepository deliverySlotRepository;

    /**
     * Get the current active delivery slot (nearest upcoming slot where now < cutoff).
     * Returns empty if no active slot is available.
     */
    public Optional<DeliverySlot> getCurrentActiveSlot() {
        LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);
        List<DeliverySlot> upcomingSlots = deliverySlotRepository.findActiveUpcomingSlots(nowIST);

        if (upcomingSlots.isEmpty()) {
            logger.debug("No active upcoming delivery slots found");
            return Optional.empty();
        }

        DeliverySlot nearest = upcomingSlots.get(0);
        logger.debug("Current active slot: delivery={}, cutoff={}", nearest.getDeliveryDate(), nearest.getCutoffDateTime());
        return Optional.of(nearest);
    }

    /**
     * Check if ordering is allowed based on delivery slots.
     * Returns true if there is at least one active slot with cutoff in the future.
     */
    public boolean isOrderAllowedBySlot() {
        return getCurrentActiveSlot().isPresent();
    }

    public List<DeliverySlot> getAllSlots() {
        return deliverySlotRepository.findAllByOrderByDeliveryDateDesc();
    }

    public DeliverySlot createSlot(DeliverySlot slot) {
        logger.info("Creating delivery slot: delivery={}, cutoff={}", slot.getDeliveryDate(), slot.getCutoffDateTime());
        return deliverySlotRepository.save(slot);
    }

    public DeliverySlot updateSlot(Long id, DeliverySlot updated) {
        DeliverySlot existing = deliverySlotRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Delivery slot not found with id: " + id));

        existing.setDeliveryDate(updated.getDeliveryDate());
        existing.setCutoffDateTime(updated.getCutoffDateTime());
        existing.setActive(updated.isActive());

        logger.info("Updating delivery slot {}: delivery={}, cutoff={}", id, updated.getDeliveryDate(), updated.getCutoffDateTime());
        return deliverySlotRepository.save(existing);
    }

    public DeliverySlot toggleSlotActive(Long id) {
        DeliverySlot slot = deliverySlotRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Delivery slot not found with id: " + id));

        slot.setActive(!slot.isActive());
        logger.info("Toggling delivery slot {} active status to {}", id, slot.isActive());
        return deliverySlotRepository.save(slot);
    }

    public void deleteSlot(Long id) {
        if (!deliverySlotRepository.existsById(id)) {
            throw new RuntimeException("Delivery slot not found with id: " + id);
        }
        logger.info("Deleting delivery slot {}", id);
        deliverySlotRepository.deleteById(id);
    }

    /**
     * Check if any delivery slots exist in the database.
     * Used to determine whether to use slot-based or legacy cutoff logic.
     */
    public boolean hasAnySlots() {
        return deliverySlotRepository.count() > 0;
    }
}
