package user_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import user_service.entity.CustomerPickupPoint;
import user_service.entity.PickupPoint;
import user_service.repository.CustomerPickupPointRepository;
import user_service.repository.PickupPointRepository;

import java.util.List;
import java.util.Optional;

@Service
public class CustomerPickupPointService {

    private static final Logger logger = LoggerFactory.getLogger(CustomerPickupPointService.class);

    @Autowired
    private CustomerPickupPointRepository customerPickupPointRepository;

    @Autowired
    private PickupPointRepository pickupPointRepository;

    /**
     * Get all pickup points for a customer
     */
    public List<CustomerPickupPoint> getCustomerPickupPoints(Long customerId) {
        logger.info("Fetching all pickup points for customer: {}", customerId);
        return customerPickupPointRepository.findByCustomerId(customerId);
    }

    /**
     * Get the active pickup point for a customer
     */
    public Optional<CustomerPickupPoint> getActivePickupPoint(Long customerId) {
        logger.info("Fetching active pickup point for customer: {}", customerId);
        return customerPickupPointRepository.findByCustomerIdAndActiveTrue(customerId);
    }

    /**
     * Add a new pickup point for a customer
     * If it's the first one, make it active automatically
     */
    @Transactional
    public CustomerPickupPoint addPickupPoint(Long customerId, Long pickupPointId, boolean makeActive) {
        logger.info("Adding pickup point {} for customer {}", pickupPointId, customerId);

        // Check if pickup point exists
        Optional<PickupPoint> pickupPoint = pickupPointRepository.findById(pickupPointId);
        if (pickupPoint.isEmpty()) {
            throw new RuntimeException("Pickup point not found with id: " + pickupPointId);
        }

        // Check if this mapping already exists
        Optional<CustomerPickupPoint> existing = customerPickupPointRepository
                .findByCustomerIdAndPickupPointId(customerId, pickupPointId);
        if (existing.isPresent()) {
            throw new RuntimeException("Customer already has this pickup point");
        }

        // Check if customer has any pickup points
        List<CustomerPickupPoint> existingPoints = customerPickupPointRepository.findByCustomerId(customerId);
        boolean isFirstPoint = existingPoints.isEmpty();

        CustomerPickupPoint customerPickupPoint = new CustomerPickupPoint();
        customerPickupPoint.setCustomerId(customerId);
        customerPickupPoint.setPickupPointId(pickupPointId);
        // Make active if it's the first point OR explicitly requested
        customerPickupPoint.setActive(isFirstPoint || makeActive);

        // If making this active, deactivate all others
        if (customerPickupPoint.isActive()) {
            deactivateAllPickupPoints(customerId);
        }

        CustomerPickupPoint saved = customerPickupPointRepository.save(customerPickupPoint);
        logger.info("Added pickup point {} for customer {} with active status: {}",
                    pickupPointId, customerId, saved.isActive());
        return saved;
    }

    /**
     * Set a pickup point as active (deactivates all others)
     */
    @Transactional
    public CustomerPickupPoint setActivePickupPoint(Long customerId, Long pickupPointId) {
        logger.info("Setting pickup point {} as active for customer {}", pickupPointId, customerId);

        // Find the pickup point mapping
        Optional<CustomerPickupPoint> pickupPointOpt = customerPickupPointRepository
                .findByCustomerIdAndPickupPointId(customerId, pickupPointId);

        if (pickupPointOpt.isEmpty()) {
            throw new RuntimeException("Customer does not have this pickup point");
        }

        // Deactivate all other pickup points
        deactivateAllPickupPoints(customerId);

        // Activate this one
        CustomerPickupPoint pickupPoint = pickupPointOpt.get();
        pickupPoint.setActive(true);
        CustomerPickupPoint saved = customerPickupPointRepository.save(pickupPoint);

        logger.info("Set pickup point {} as active for customer {}", pickupPointId, customerId);
        return saved;
    }

    /**
     * Delete a pickup point for a customer
     * Cannot delete if it's the only/active one
     */
    @Transactional
    public void deletePickupPoint(Long customerId, Long pickupPointId) {
        logger.info("Deleting pickup point {} for customer {}", pickupPointId, customerId);

        Optional<CustomerPickupPoint> pickupPointOpt = customerPickupPointRepository
                .findByCustomerIdAndPickupPointId(customerId, pickupPointId);

        if (pickupPointOpt.isEmpty()) {
            throw new RuntimeException("Customer does not have this pickup point");
        }

        CustomerPickupPoint pickupPoint = pickupPointOpt.get();

        // Check if this is the active pickup point
        if (pickupPoint.isActive()) {
            List<CustomerPickupPoint> allPoints = customerPickupPointRepository.findByCustomerId(customerId);
            if (allPoints.size() == 1) {
                throw new RuntimeException("Cannot delete the only pickup point. Please add another one first.");
            }
            // If there are other points, we'll delete this and activate another one
            customerPickupPointRepository.delete(pickupPoint);

            // Activate the first remaining pickup point
            List<CustomerPickupPoint> remaining = customerPickupPointRepository.findByCustomerId(customerId);
            if (!remaining.isEmpty()) {
                CustomerPickupPoint firstRemaining = remaining.get(0);
                firstRemaining.setActive(true);
                customerPickupPointRepository.save(firstRemaining);
                logger.info("Activated pickup point {} after deleting active point", firstRemaining.getPickupPointId());
            }
        } else {
            customerPickupPointRepository.delete(pickupPoint);
        }

        logger.info("Deleted pickup point {} for customer {}", pickupPointId, customerId);
    }

    /**
     * Helper method to deactivate all pickup points for a customer
     */
    private void deactivateAllPickupPoints(Long customerId) {
        List<CustomerPickupPoint> allPoints = customerPickupPointRepository.findByCustomerId(customerId);
        for (CustomerPickupPoint point : allPoints) {
            if (point.isActive()) {
                point.setActive(false);
                customerPickupPointRepository.save(point);
            }
        }
        logger.debug("Deactivated all pickup points for customer {}", customerId);
    }
}
