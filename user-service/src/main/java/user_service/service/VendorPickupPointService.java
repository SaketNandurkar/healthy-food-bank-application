package user_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import user_service.entity.Customer;
import user_service.entity.PickupPoint;
import user_service.entity.VendorPickupPoint;
import user_service.repository.CustomerRepository;
import user_service.repository.PickupPointRepository;
import user_service.repository.VendorPickupPointRepository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class VendorPickupPointService {

    private static final Logger logger = LoggerFactory.getLogger(VendorPickupPointService.class);

    @Autowired
    private VendorPickupPointRepository vendorPickupPointRepository;

    @Autowired
    private PickupPointRepository pickupPointRepository;

    @Autowired
    private CustomerRepository customerRepository;

    /**
     * Helper method to get actual vendorId from username
     * If the input is already a vendorId, return it as is
     * If it's a username (email), look up the actual vendorId
     */
    private String getActualVendorId(String usernameOrVendorId) {
        // Try to find by username first
        Optional<Customer> customer = customerRepository.findByUserName(usernameOrVendorId);
        if (customer.isPresent() && customer.get().getVendorId() != null) {
            logger.info("Converted username {} to vendorId {}", usernameOrVendorId, customer.get().getVendorId());
            return customer.get().getVendorId();
        }
        // If not found, assume it's already a vendorId
        return usernameOrVendorId;
    }

    /**
     * Get all pickup points for a vendor
     */
    public List<VendorPickupPoint> getVendorPickupPoints(String vendorId) {
        String actualVendorId = getActualVendorId(vendorId);
        logger.info("Fetching all pickup points for vendor: {}", actualVendorId);
        return vendorPickupPointRepository.findByVendorId(actualVendorId);
    }

    /**
     * Get all active pickup points for a vendor
     */
    public List<VendorPickupPoint> getActiveVendorPickupPoints(String vendorId) {
        String actualVendorId = getActualVendorId(vendorId);
        logger.info("Fetching active pickup points for vendor: {}", actualVendorId);
        return vendorPickupPointRepository.findByVendorIdAndActiveTrue(actualVendorId);
    }

    /**
     * Get all vendor IDs that serve a specific pickup point
     */
    public List<String> getVendorsByPickupPoint(Long pickupPointId) {
        logger.info("Fetching vendors for pickup point: {}", pickupPointId);
        List<VendorPickupPoint> vendorPickupPoints = vendorPickupPointRepository
                .findByPickupPointIdAndActiveTrue(pickupPointId);
        return vendorPickupPoints.stream()
                .map(VendorPickupPoint::getVendorId)
                .collect(Collectors.toList());
    }

    /**
     * Add a new pickup point for a vendor
     */
    @Transactional
    public VendorPickupPoint addPickupPoint(String vendorId, Long pickupPointId) {
        String actualVendorId = getActualVendorId(vendorId);
        logger.info("Adding pickup point {} for vendor {}", pickupPointId, actualVendorId);

        // Check if pickup point exists
        Optional<PickupPoint> pickupPoint = pickupPointRepository.findById(pickupPointId);
        if (pickupPoint.isEmpty()) {
            throw new RuntimeException("Pickup point not found with id: " + pickupPointId);
        }

        // Check if this mapping already exists
        Optional<VendorPickupPoint> existing = vendorPickupPointRepository
                .findByVendorIdAndPickupPointId(actualVendorId, pickupPointId);
        if (existing.isPresent()) {
            throw new RuntimeException("Vendor already serves this pickup point");
        }

        VendorPickupPoint vendorPickupPoint = new VendorPickupPoint();
        vendorPickupPoint.setVendorId(actualVendorId);
        vendorPickupPoint.setPickupPointId(pickupPointId);
        vendorPickupPoint.setActive(true); // Active by default for vendors

        VendorPickupPoint saved = vendorPickupPointRepository.save(vendorPickupPoint);
        logger.info("Added pickup point {} for vendor {}", pickupPointId, actualVendorId);
        return saved;
    }

    /**
     * Toggle active status of a vendor pickup point
     */
    @Transactional
    public VendorPickupPoint toggleActiveStatus(String vendorId, Long pickupPointId) {
        String actualVendorId = getActualVendorId(vendorId);
        logger.info("Toggling active status for pickup point {} of vendor {}", pickupPointId, actualVendorId);

        Optional<VendorPickupPoint> pickupPointOpt = vendorPickupPointRepository
                .findByVendorIdAndPickupPointId(actualVendorId, pickupPointId);

        if (pickupPointOpt.isEmpty()) {
            throw new RuntimeException("Vendor does not serve this pickup point");
        }

        VendorPickupPoint pickupPoint = pickupPointOpt.get();
        pickupPoint.setActive(!pickupPoint.isActive());
        VendorPickupPoint saved = vendorPickupPointRepository.save(pickupPoint);

        logger.info("Toggled pickup point {} for vendor {} to active: {}",
                    pickupPointId, actualVendorId, saved.isActive());
        return saved;
    }

    /**
     * Delete a pickup point for a vendor
     */
    @Transactional
    public void deletePickupPoint(String vendorId, Long pickupPointId) {
        String actualVendorId = getActualVendorId(vendorId);
        logger.info("Deleting pickup point {} for vendor {}", pickupPointId, actualVendorId);

        Optional<VendorPickupPoint> pickupPointOpt = vendorPickupPointRepository
                .findByVendorIdAndPickupPointId(actualVendorId, pickupPointId);

        if (pickupPointOpt.isEmpty()) {
            throw new RuntimeException("Vendor does not serve this pickup point");
        }

        vendorPickupPointRepository.delete(pickupPointOpt.get());
        logger.info("Deleted pickup point {} for vendor {}", pickupPointId, actualVendorId);
    }
}
