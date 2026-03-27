package user_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import user_service.entity.Customer;
import user_service.entity.VendorCode;
import user_service.exception.UserNotFoundException;
import user_service.repository.CustomerRepository;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    @Autowired
    private CustomerRepository repository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private VendorCodeService vendorCodeService;

    public String addUser(Customer customer) {
        return addUser(customer, null);
    }

    public String addUser(Customer customer, String vendorCode) {
        try {
            // Check if user already exists
            if (repository.findByUserName(customer.getUserName()).isPresent()) {
                logger.warn("Attempt to create user with existing username: {}", customer.getUserName());
                return "User already exists with username: " + customer.getUserName();
            }
            
            // For vendor registration, validate vendor code
            if ("VENDOR".equals(customer.getRoles()) && vendorCode != null) {
                if (!vendorCodeService.isValidVendorCode(vendorCode)) {
                    logger.warn("Invalid vendor code provided: {}", vendorCode);
                    return "Invalid or already used vendor code: " + vendorCode;
                }
                
                // Get vendor details from code
                VendorCode validVendorCode = vendorCodeService.getVendorCodeForRegistration(vendorCode)
                    .orElseThrow(() -> new RuntimeException("Vendor code validation failed"));
                
                // Set vendor ID from the code
                customer.setVendorId(validVendorCode.getVendorId());
            }
            
            customer.setPassword(passwordEncoder.encode(customer.getPassword()));
            Customer savedCustomer = repository.save(customer);
            
            // Mark vendor code as used if it's a vendor registration
            if ("VENDOR".equals(customer.getRoles()) && vendorCode != null) {
                vendorCodeService.markVendorCodeAsUsed(vendorCode, savedCustomer.getId());
            }
            
            logger.info("Successfully created user: {}", customer.getUserName());
            return "User added to system successfully";
        } catch (Exception e) {
            logger.error("Error adding user: {}", customer.getUserName(), e);
            throw new RuntimeException("Failed to add user", e);
        }
    }

    public Customer getUserByUsername(String username) {
        return repository.findByUserName(username)
                .orElseThrow(() -> new UserNotFoundException("User not found with username: " + username));
    }

    public String getUserRoleFromToken(String token) {
        if (token == null || !token.startsWith("Bearer ")) {
            logger.warn("Invalid token format");
            throw new IllegalArgumentException("Invalid token format");
        }

        try {
            String jwt = token.substring(7); // Remove "Bearer " prefix
            String role = jwtService.extractClaim(jwt, claims -> claims.get("role", String.class));
            if (role == null) {
                logger.warn("Role not found in token");
                throw new IllegalArgumentException("Role not found in token");
            }
            return role;
        } catch (Exception e) {
            logger.error("Error extracting role from token", e);
            throw new IllegalArgumentException("Invalid token", e);
        }
    }

    public Map<String, Object> updateProfile(Long userId, String firstName, String lastName, String email, String phoneNumber, String vendorId) {
        try {
            Customer user = repository.findById(userId.intValue())
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + userId));

            // Update email field (separate from userName)
            if (email != null && !email.trim().isEmpty()) {
                user.setEmail(email.trim());
            }

            if (firstName != null && !firstName.trim().isEmpty()) {
                user.setFirstName(firstName.trim());
            }
            if (lastName != null && !lastName.trim().isEmpty()) {
                user.setLastName(lastName.trim());
            }
            if (phoneNumber != null && !phoneNumber.trim().isEmpty()) {
                try {
                    user.setPhoneNumber(Long.parseLong(phoneNumber.trim()));
                } catch (NumberFormatException e) {
                    throw new RuntimeException("Invalid phone number format: " + phoneNumber);
                }
            }
            if (vendorId != null && !vendorId.trim().isEmpty()) {
                user.setVendorId(vendorId.trim());
            }

            Customer updatedUser = repository.save(user);
            logger.info("Successfully updated profile for user: {}", user.getUserName());

            // Clear password before returning
            updatedUser.setPassword(null);

            Map<String, Object> result = new HashMap<>();
            result.put("user", updatedUser);
            result.put("usernameChanged", false); // Username never changes now
            return result;
        } catch (Exception e) {
            logger.error("Error updating profile for user ID: {}", userId, e);
            throw new RuntimeException("Failed to update profile: " + e.getMessage(), e);
        }
    }

    public boolean changePassword(Long userId, String currentPassword, String newPassword) {
        try {
            Customer user = repository.findById(userId.intValue())
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + userId));

            // Verify current password
            if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
                logger.warn("Invalid current password provided for user: {}", user.getUserName());
                return false;
            }

            // Encode and set new password
            user.setPassword(passwordEncoder.encode(newPassword));
            repository.save(user);

            logger.info("Successfully changed password for user: {}", user.getUserName());
            return true;
        } catch (Exception e) {
            logger.error("Error changing password for user ID: {}", userId, e);
            throw new RuntimeException("Failed to change password: " + e.getMessage(), e);
        }
    }

    public Customer getCustomerById(Long customerId) {
        try {
            return repository.findById(customerId.intValue())
                .orElseThrow(() -> new UserNotFoundException("Customer not found with id: " + customerId));
        } catch (Exception e) {
            logger.error("Error fetching customer by id: {}", customerId, e);
            throw new UserNotFoundException("Customer not found with id: " + customerId);
        }
    }

    public String getVendorNameByVendorId(String vendorId) {
        try {
            Customer vendor = repository.findByVendorId(vendorId)
                .orElse(null);

            if (vendor != null) {
                return vendor.getFirstName() + " " + vendor.getLastName();
            }
            return null;
        } catch (Exception e) {
            logger.error("Error fetching vendor name for vendorId: {}", vendorId, e);
            return null;
        }
    }

    public boolean isUserAuthorizedForAction(String token, Long targetUserId) {
        try {
            System.out.println("=== AUTHORIZATION DEBUG ===");
            System.out.println("Token: " + token);
            System.out.println("Target User ID: " + targetUserId);

            if (token == null || !token.startsWith("Bearer ")) {
                System.out.println("Invalid token format");
                logger.warn("Invalid token format for authorization check");
                return false;
            }

            String jwt = token.substring(7); // Remove "Bearer " prefix
            System.out.println("JWT after Bearer removal: " + jwt);
            String username = jwtService.extractUsername(jwt);
            System.out.println("Extracted username: " + username);

            if (username == null) {
                System.out.println("Username is null");
                logger.warn("Username not found in token for authorization check");
                return false;
            }

            // Get the authenticated user
            Customer authenticatedUser = repository.findByUserName(username)
                .orElseThrow(() -> new UserNotFoundException("Authenticated user not found: " + username));

            System.out.println("Authenticated user ID: " + authenticatedUser.getId());
            System.out.println("Authenticated username: " + authenticatedUser.getUserName());

            // Check if the authenticated user is trying to access their own data
            boolean isAuthorized = authenticatedUser.getId().equals(targetUserId);
            System.out.println("Authorization result: " + isAuthorized);

            if (!isAuthorized) {
                System.out.println("Authorization FAILED - User " + username + " (ID: " + authenticatedUser.getId() + ") attempted to access user ID: " + targetUserId);
                logger.warn("User {} attempted to access data for user ID {}", username, targetUserId);
            }

            System.out.println("=== AUTHORIZATION DEBUG END ===");
            return isAuthorized;
        } catch (Exception e) {
            System.out.println("Exception in authorization: " + e.getMessage());
            e.printStackTrace();
            logger.error("Error during authorization check for user ID: {}", targetUserId, e);
            return false;
        }
    }

    // ============ ADMIN USER MANAGEMENT METHODS ============

    public List<Customer> getAllUsers(String role) {
        try {
            List<Customer> users;
            if (role != null && !role.isEmpty()) {
                users = repository.findAll().stream()
                    .filter(user -> role.equalsIgnoreCase(user.getRoles()))
                    .toList();
                logger.info("Retrieved {} users with role: {}", users.size(), role);
            } else {
                users = repository.findAll();
                logger.info("Retrieved all {} users", users.size());
            }
            return users;
        } catch (Exception e) {
            logger.error("Error retrieving users with role: {}", role, e);
            throw new RuntimeException("Failed to retrieve users", e);
        }
    }

    public Map<String, Long> getUserStats() {
        try {
            List<Customer> allUsers = repository.findAll();

            long totalUsers = allUsers.size();
            long customers = allUsers.stream().filter(u -> "CUSTOMER".equals(u.getRoles())).count();
            long vendors = allUsers.stream().filter(u -> "VENDOR".equals(u.getRoles())).count();
            long admins = allUsers.stream().filter(u -> "ADMIN".equals(u.getRoles())).count();
            long activeUsers = allUsers.stream().filter(Customer::isActive).count();

            Map<String, Long> stats = new HashMap<>();
            stats.put("totalUsers", totalUsers);
            stats.put("customers", customers);
            stats.put("vendors", vendors);
            stats.put("admins", admins);
            stats.put("activeUsers", activeUsers);

            logger.info("User stats - Total: {}, Customers: {}, Vendors: {}, Admins: {}, Active: {}",
                totalUsers, customers, vendors, admins, activeUsers);

            return stats;
        } catch (Exception e) {
            logger.error("Error calculating user stats", e);
            throw new RuntimeException("Failed to calculate user stats", e);
        }
    }

    public Customer setUserActiveStatus(Integer userId, boolean active) {
        try {
            Customer user = repository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found with ID: " + userId));

            user.setActive(active);
            Customer updated = repository.save(user);

            logger.info("User {} (ID: {}) has been {}",
                user.getUserName(), userId, active ? "activated" : "deactivated");

            return updated;
        } catch (UserNotFoundException e) {
            throw e;
        } catch (Exception e) {
            logger.error("Error updating user status for ID: {}", userId, e);
            throw new RuntimeException("Failed to update user status", e);
        }
    }

}
