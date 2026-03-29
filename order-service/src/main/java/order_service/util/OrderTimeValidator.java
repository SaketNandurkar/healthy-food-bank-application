package order_service.util;

import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;

/**
 * Utility class to validate order placement timing based on business rules.
 *
 * Business Rule: Orders are only allowed before Friday 8:00 PM IST.
 * - Monday to Thursday: Orders allowed anytime
 * - Friday: Orders allowed only before 8:00 PM IST
 * - Saturday to Sunday: Orders blocked (weekend)
 *
 * @author Senior Technical Architect
 * @version 1.0
 */
@Component
public class OrderTimeValidator {

    // Timezone for India (IST)
    private static final ZoneId IST_ZONE = ZoneId.of("Asia/Kolkata");

    // Friday cutoff time (8:00 PM)
    private static final LocalTime FRIDAY_CUTOFF_TIME = LocalTime.of(20, 0);

    /**
     * Checks if order placement is allowed based on current time in IST.
     *
     * @return true if orders are allowed, false otherwise
     */
    public boolean isOrderAllowed() {
        LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);
        DayOfWeek currentDay = nowIST.getDayOfWeek();
        LocalTime currentTime = nowIST.toLocalTime();

        // Monday to Thursday: Always allowed
        if (currentDay.getValue() >= DayOfWeek.MONDAY.getValue()
                && currentDay.getValue() <= DayOfWeek.THURSDAY.getValue()) {
            return true;
        }

        // Friday: Allowed only before 8:00 PM
        if (currentDay == DayOfWeek.FRIDAY) {
            return currentTime.isBefore(FRIDAY_CUTOFF_TIME);
        }

        // Saturday and Sunday: Not allowed (weekend)
        return false;
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
     * @return Cutoff message
     */
    public String getCutoffMessage() {
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
     * Gets the remaining time until Friday 8 PM cutoff (in hours).
     * Returns null if not Friday or already past cutoff.
     *
     * @return Hours remaining until cutoff, or null
     */
    public Long getHoursUntilCutoff() {
        LocalDateTime nowIST = LocalDateTime.now(IST_ZONE);

        if (nowIST.getDayOfWeek() != DayOfWeek.FRIDAY) {
            return null;
        }

        LocalDateTime cutoffDateTime = nowIST.toLocalDate().atTime(FRIDAY_CUTOFF_TIME);

        if (nowIST.isAfter(cutoffDateTime)) {
            return null; // Already past cutoff
        }

        return java.time.Duration.between(nowIST, cutoffDateTime).toHours();
    }
}
