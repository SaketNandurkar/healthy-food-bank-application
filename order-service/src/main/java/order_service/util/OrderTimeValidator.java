package order_service.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import order_service.entity.DeliverySlot;
import order_service.service.DeliverySlotService;

import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.Optional;

/**
 * Utility class to validate order placement timing based on business rules.
 *
 * Primary: Uses database-driven DeliverySlot system (admin-managed).
 * Fallback: If no delivery slots exist in DB, falls back to hardcoded
 *           Friday 8:00 PM IST cutoff logic for backward compatibility.
 *
 * @author Senior Technical Architect
 * @version 2.0
 */
@Component
public class OrderTimeValidator {

    private static final Logger logger = LoggerFactory.getLogger(OrderTimeValidator.class);

    // Timezone for India (IST)
    private static final ZoneId IST_ZONE = ZoneId.of("Asia/Kolkata");

    // Legacy Friday cutoff time (8:00 PM) - used as fallback
    private static final LocalTime FRIDAY_CUTOFF_TIME = LocalTime.of(20, 0);

    @Autowired
    private DeliverySlotService deliverySlotService;

    /**
     * Checks if order placement is allowed.
     * Uses delivery slot system first; falls back to legacy logic if no slots exist.
     *
     * @return true if orders are allowed, false otherwise
     */
    public boolean isOrderAllowed() {
        try {
            if (deliverySlotService.hasAnySlots()) {
                // Slot-based: check if there's an active upcoming slot
                boolean allowed = deliverySlotService.isOrderAllowedBySlot();
                logger.debug("Slot-based order validation: allowed={}", allowed);
                return allowed;
            }
        } catch (Exception e) {
            logger.warn("Error checking delivery slots, falling back to legacy logic: {}", e.getMessage());
        }

        // Fallback: legacy hardcoded Friday 8 PM IST logic
        return isOrderAllowedLegacy();
    }

    /**
     * Legacy order validation: hardcoded Friday 8 PM IST cutoff.
     * Monday-Thursday: allowed. Friday before 8 PM: allowed. Otherwise: blocked.
     */
    private boolean isOrderAllowedLegacy() {
        LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);
        DayOfWeek currentDay = nowIST.getDayOfWeek();
        LocalTime currentTime = nowIST.toLocalTime();

        if (currentDay.getValue() >= DayOfWeek.MONDAY.getValue()
                && currentDay.getValue() <= DayOfWeek.THURSDAY.getValue()) {
            return true;
        }

        if (currentDay == DayOfWeek.FRIDAY) {
            return currentTime.isBefore(FRIDAY_CUTOFF_TIME);
        }

        return false;
    }

    /**
     * Gets the current active delivery slot, if any.
     *
     * @return Optional containing the active slot, or empty
     */
    public Optional<DeliverySlot> getCurrentActiveSlot() {
        try {
            if (deliverySlotService.hasAnySlots()) {
                return deliverySlotService.getCurrentActiveSlot();
            }
        } catch (Exception e) {
            logger.warn("Error fetching active delivery slot: {}", e.getMessage());
        }
        return Optional.empty();
    }

    /**
     * Gets the current time in IST timezone.
     *
     * @return Current LocalDateTime in IST
     */
    public LocalDateTime getCurrentTimeIST() {
        return LocalDateTime.now(IST_ZONE);
    }

    /**
     * Gets a user-friendly message about the order cutoff.
     *
     * @return Cutoff message based on active slot or legacy logic
     */
    public String getCutoffMessage() {
        Optional<DeliverySlot> activeSlot = getCurrentActiveSlot();
        if (activeSlot.isPresent()) {
            DeliverySlot slot = activeSlot.get();
            return String.format("Orders are accepted until %s for %s delivery.",
                    slot.getCutoffDateTime().toString(),
                    slot.getDeliveryDate().toString());
        }

        return "Orders are accepted Monday to Friday before 8:00 PM IST only. " +
               "Please place your order before Friday 8:00 PM for weekend delivery.";
    }

    /**
     * Checks if today is Friday.
     *
     * @return true if today is Friday in IST timezone
     */
    public boolean isFriday() {
        LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);
        return nowIST.getDayOfWeek() == DayOfWeek.FRIDAY;
    }

    /**
     * Gets the remaining time until cutoff (in hours).
     * Uses delivery slot cutoff if available, otherwise Friday 8 PM.
     *
     * @return Hours remaining until cutoff, or null if not applicable
     */
    public Long getHoursUntilCutoff() {
        // Try slot-based cutoff first
        Optional<DeliverySlot> activeSlot = getCurrentActiveSlot();
        if (activeSlot.isPresent()) {
            LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);
            Duration remaining = Duration.between(nowIST, activeSlot.get().getCutoffDateTime());
            return remaining.isNegative() ? null : remaining.toHours();
        }

        // Legacy: Friday-only cutoff
        LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);
        if (nowIST.getDayOfWeek() != DayOfWeek.FRIDAY) {
            return null;
        }

        LocalDateTime cutoffDateTime = nowIST.toLocalDate().atTime(FRIDAY_CUTOFF_TIME);
        if (nowIST.isAfter(cutoffDateTime)) {
            return null;
        }

        return Duration.between(nowIST, cutoffDateTime).toHours();
    }

    /**
     * Gets the delivery date from active slot, or next Saturday/Sunday for legacy.
     *
     * @return Delivery date, or null if not available
     */
    public LocalDate getDeliveryDate() {
        Optional<DeliverySlot> activeSlot = getCurrentActiveSlot();
        if (activeSlot.isPresent()) {
            return activeSlot.get().getDeliveryDate();
        }
        return null;
    }

    /**
     * Gets the cutoff date/time from active slot, or Friday 8 PM for legacy.
     *
     * @return Cutoff datetime, or null if not available
     */
    public LocalDateTime getCutoffDateTime() {
        Optional<DeliverySlot> activeSlot = getCurrentActiveSlot();
        if (activeSlot.isPresent()) {
            return activeSlot.get().getCutoffDateTime();
        }

        // Legacy: return this Friday's 8 PM if we're in the order window
        LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);
        DayOfWeek day = nowIST.getDayOfWeek();
        if (day.getValue() >= DayOfWeek.MONDAY.getValue()
                && day.getValue() <= DayOfWeek.FRIDAY.getValue()) {
            // Calculate this coming Friday 8 PM
            int daysUntilFriday = DayOfWeek.FRIDAY.getValue() - day.getValue();
            return nowIST.toLocalDate().plusDays(daysUntilFriday).atTime(FRIDAY_CUTOFF_TIME);
        }
        return null;
    }
}
