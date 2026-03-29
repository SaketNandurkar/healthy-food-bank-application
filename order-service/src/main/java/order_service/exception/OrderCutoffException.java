package order_service.exception;

/**
 * Exception thrown when an order is attempted outside the allowed time window.
 *
 * This exception is thrown when:
 * - Orders are attempted after Friday 8:00 PM IST
 * - Orders are attempted on Saturday or Sunday
 *
 * @author Senior Technical Architect
 * @version 1.0
 */
public class OrderCutoffException extends RuntimeException {

    /**
     * Constructs a new OrderCutoffException with a default message.
     */
    public OrderCutoffException() {
        super("Order window closed. Please order before Friday 8 PM IST for weekend delivery.");
    }

    /**
     * Constructs a new OrderCutoffException with a custom message.
     *
     * @param message the detail message
     */
    public OrderCutoffException(String message) {
        super(message);
    }

    /**
     * Constructs a new OrderCutoffException with a custom message and cause.
     *
     * @param message the detail message
     * @param cause   the cause
     */
    public OrderCutoffException(String message, Throwable cause) {
        super(message, cause);
    }
}
