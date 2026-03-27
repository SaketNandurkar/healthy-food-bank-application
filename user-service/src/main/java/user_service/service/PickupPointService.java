package user_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import user_service.entity.PickupPoint;
import user_service.repository.PickupPointRepository;

import java.util.List;
import java.util.Optional;

@Service
public class PickupPointService {

    private static final Logger logger = LoggerFactory.getLogger(PickupPointService.class);
    private final PickupPointRepository pickupPointRepository;

    public PickupPointService(PickupPointRepository pickupPointRepository) {
        this.pickupPointRepository = pickupPointRepository;
    }

    /**
     * Get all pickup points
     */
    public List<PickupPoint> getAllPickupPoints() {
        logger.info("Fetching all pickup points");
        return pickupPointRepository.findAll();
    }

    /**
     * Get all active pickup points
     */
    public List<PickupPoint> getActivePickupPoints() {
        logger.info("Fetching active pickup points");
        return pickupPointRepository.findByActiveTrue();
    }

    /**
     * Get pickup point by ID
     */
    public Optional<PickupPoint> getPickupPointById(Long id) {
        logger.info("Fetching pickup point by ID: {}", id);
        return pickupPointRepository.findById(id);
    }

    /**
     * Create new pickup point
     */
    @Transactional
    public PickupPoint createPickupPoint(PickupPoint pickupPoint) {
        logger.info("Creating new pickup point: {}", pickupPoint.getName());

        // Check if pickup point with same name already exists
        if (pickupPointRepository.existsByName(pickupPoint.getName())) {
            logger.error("Pickup point with name '{}' already exists", pickupPoint.getName());
            throw new RuntimeException("Pickup point with name '" + pickupPoint.getName() + "' already exists");
        }

        PickupPoint saved = pickupPointRepository.save(pickupPoint);
        logger.info("Successfully created pickup point with ID: {}", saved.getId());
        return saved;
    }

    /**
     * Update existing pickup point
     */
    @Transactional
    public PickupPoint updatePickupPoint(Long id, PickupPoint pickupPoint) {
        logger.info("Updating pickup point with ID: {}", id);

        PickupPoint existing = pickupPointRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pickup point not found with ID: " + id));

        // Check if updating name and new name already exists
        if (!existing.getName().equals(pickupPoint.getName())
                && pickupPointRepository.existsByName(pickupPoint.getName())) {
            logger.error("Pickup point with name '{}' already exists", pickupPoint.getName());
            throw new RuntimeException("Pickup point with name '" + pickupPoint.getName() + "' already exists");
        }

        existing.setName(pickupPoint.getName());
        existing.setAddress(pickupPoint.getAddress());
        existing.setContactNumber(pickupPoint.getContactNumber());
        existing.setActive(pickupPoint.isActive());

        PickupPoint updated = pickupPointRepository.save(existing);
        logger.info("Successfully updated pickup point with ID: {}", id);
        return updated;
    }

    /**
     * Delete pickup point
     */
    @Transactional
    public void deletePickupPoint(Long id) {
        logger.info("Deleting pickup point with ID: {}", id);

        if (!pickupPointRepository.existsById(id)) {
            logger.error("Pickup point not found with ID: {}", id);
            throw new RuntimeException("Pickup point not found with ID: " + id);
        }

        pickupPointRepository.deleteById(id);
        logger.info("Successfully deleted pickup point with ID: {}", id);
    }

    /**
     * Deactivate pickup point (soft delete)
     */
    @Transactional
    public PickupPoint deactivatePickupPoint(Long id) {
        logger.info("Deactivating pickup point with ID: {}", id);

        PickupPoint pickupPoint = pickupPointRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pickup point not found with ID: " + id));

        pickupPoint.setActive(false);
        PickupPoint updated = pickupPointRepository.save(pickupPoint);

        logger.info("Successfully deactivated pickup point with ID: {}", id);
        return updated;
    }

    /**
     * Activate pickup point
     */
    @Transactional
    public PickupPoint activatePickupPoint(Long id) {
        logger.info("Activating pickup point with ID: {}", id);

        PickupPoint pickupPoint = pickupPointRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pickup point not found with ID: " + id));

        pickupPoint.setActive(true);
        PickupPoint updated = pickupPointRepository.save(pickupPoint);

        logger.info("Successfully activated pickup point with ID: {}", id);
        return updated;
    }
}
