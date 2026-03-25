package user_service.service;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import user_service.entity.Customer;
import user_service.entity.VendorCode;
import user_service.repository.CustomerRepository;

import java.time.LocalDateTime;

@Service
public class AdminInitializationService {

    private static final Logger logger = LoggerFactory.getLogger(AdminInitializationService.class);
    
    private static final String ADMIN_USERNAME = "admin";
    private static final String ADMIN_PASSWORD = "Test@1234"; // Change this in production
    private static final String ADMIN_FIRST_NAME = "System";
    private static final String ADMIN_LAST_NAME = "Administrator";
    private static final String ADMIN_EMAIL = "admin@healthyfoodbank.com";
    private static final long ADMIN_PHONE = 9999999999L;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private VendorCodeService vendorCodeService;

    @PostConstruct
    public void initializeAdmin() {
        try {
            // Check if admin already exists
            if (customerRepository.findByUserName(ADMIN_USERNAME).isPresent()) {
                Customer existingAdmin = customerRepository.findByUserName(ADMIN_USERNAME).get();
                logger.info("Admin account already exists with username: {} and role: '{}'", ADMIN_USERNAME, existingAdmin.getRoles());
                
                // Test authority generation
                org.springframework.security.core.userdetails.UserDetails userDetails = 
                    new user_service.mapper.CustomerUserDetails(existingAdmin);
                logger.info("Generated authorities: {}", userDetails.getAuthorities());
                
                // Verify admin can be retrieved and test password
                logger.info("Admin verification - ID: {}, Active: {}, Password set: {}", 
                    existingAdmin.getId(), existingAdmin.isActive(), existingAdmin.getPassword() != null);
                
                // Test password encoding
                boolean passwordMatches = passwordEncoder.matches(ADMIN_PASSWORD, existingAdmin.getPassword());
                logger.info("Password verification test - Raw password '{}' matches encoded: {}", 
                    ADMIN_PASSWORD, passwordMatches);
                return;
            }

            // Create admin account
            Customer admin = new Customer();
            admin.setFirstName(ADMIN_FIRST_NAME);
            admin.setLastName(ADMIN_LAST_NAME);
            admin.setUserName(ADMIN_USERNAME);
            admin.setPassword(passwordEncoder.encode(ADMIN_PASSWORD));
            admin.setRoles("ADMIN");
            admin.setEmail(ADMIN_EMAIL);
            admin.setPhoneNumber(ADMIN_PHONE);
            admin.setActive(true);

            Customer savedAdmin = customerRepository.save(admin);
            
            logger.info("=================================================================");
            logger.info("ADMIN ACCOUNT CREATED SUCCESSFULLY!");
            logger.info("Username: {}", ADMIN_USERNAME);
            logger.info("Password: {}", ADMIN_PASSWORD);
            logger.info("Role: '{}'", savedAdmin.getRoles());
            logger.info("ID: {}", savedAdmin.getId());
            logger.info("Active: {}", savedAdmin.isActive());
            
            // Test authority generation for new admin
            org.springframework.security.core.userdetails.UserDetails newUserDetails = 
                new user_service.mapper.CustomerUserDetails(savedAdmin);
            logger.info("Generated authorities for new admin: {}", newUserDetails.getAuthorities());
            logger.info("=================================================================");
            logger.warn("SECURITY WARNING: Change the default admin password in production!");
            logger.info("=================================================================");
            
            // Initialize sample vendor codes for testing (delay to ensure service is ready)
            try {
                Thread.sleep(1000);
                initializeSampleVendorCodes();
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                logger.warn("Interrupted while waiting to initialize vendor codes");
            }
            
        } catch (Exception e) {
            logger.error("Failed to initialize admin account", e);
        }
    }

    private void initializeSampleVendorCodes() {
        try {
            // Create sample vendor codes for testing if none exist
            if (vendorCodeService.getAllVendorCodes().isEmpty()) {
                
                VendorCode[] sampleCodes = {
                    createVendorCode("FRESH001", "VENDOR001", "Fresh Foods Market", "Organic produce and fresh groceries"),
                    createVendorCode("BAKERY01", "VENDOR002", "Golden Bakery", "Fresh baked goods and pastries"),
                    createVendorCode("MEAT001", "VENDOR003", "Premium Meats Co", "Quality meat and poultry products"),
                    createVendorCode("DAIRY01", "VENDOR004", "Farm Fresh Dairy", "Dairy products and organic milk"),
                    createVendorCode("SPICES01", "VENDOR005", "Spice Kingdom", "Exotic spices and seasonings")
                };

                for (VendorCode code : sampleCodes) {
                    vendorCodeService.createVendorCode(code);
                }
                
                logger.info("=================================================================");
                logger.info("SAMPLE VENDOR CODES CREATED FOR TESTING:");
                for (VendorCode code : sampleCodes) {
                    logger.info("Code: {} | Vendor ID: {} | Name: {}", 
                        code.getVendorCode(), code.getVendorId(), code.getVendorName());
                }
                logger.info("=================================================================");
                logger.info("Use these codes to test vendor registration functionality");
                logger.info("=================================================================");
            }
            
        } catch (Exception e) {
            logger.error("Failed to initialize sample vendor codes", e);
        }
    }

    private VendorCode createVendorCode(String code, String vendorId, String vendorName, String description) {
        VendorCode vendorCode = new VendorCode();
        vendorCode.setVendorCode(code);
        vendorCode.setVendorId(vendorId);
        vendorCode.setVendorName(vendorName);
        vendorCode.setDescription(description);
        vendorCode.setActive(true);
        vendorCode.setUsed(false);
        vendorCode.setCreatedBy(1L); // Admin user ID
        return vendorCode;
    }
}