package user_service.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import user_service.client.OrderServiceClient;
import user_service.dto.AuthenticationRequest;
import user_service.dto.LoginResponse;
import user_service.dto.RegistrationResponse;
import user_service.dto.ProfileUpdateRequest;
import user_service.dto.ProfileUpdateResponse;
import user_service.dto.PasswordChangeRequest;
import user_service.entity.Customer;
import user_service.entity.VendorCode;
import user_service.repository.CustomerRepository;
import user_service.service.JwtService;
import user_service.service.UserService;
import user_service.service.VendorCodeService;

import java.util.Map;

import java.util.List;

@RestController
@RequestMapping("/user")
@CrossOrigin(origins = {"http://localhost:4200", "http://127.0.0.1:4200"}, allowCredentials = "true")
@Tag(name = "User Management", description = "APIs for user registration, authentication, and user management")
public class UserController {

    @Autowired
    UserService userService;

    @Autowired
    JwtService jwtService;

    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    VendorCodeService vendorCodeService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired 
    private CustomerRepository repository;

    private final OrderServiceClient orderServiceClient;

    public UserController(OrderServiceClient orderServiceClient) {
        this.orderServiceClient = orderServiceClient;
    }

    @Operation(summary = "Get user role from JWT token", 
               description = "Extracts and returns the user role from a JWT Bearer token")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Successfully retrieved user role", 
                    content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "ROLE_CUSTOMER"))),
        @ApiResponse(responseCode = "401", description = "Invalid or missing token", 
                    content = @Content(mediaType = "text/plain"))
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/role")
    public ResponseEntity<String> getUserRole(
            @Parameter(description = "JWT Bearer token", required = true, example = "Bearer eyJhbGciOiJIUzI1NiJ9...")
            @RequestHeader("Authorization") String token) {
        try {
            String role = userService.getUserRoleFromToken(token);
            return ResponseEntity.ok(role);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid or missing token");
        }
    }

    @Operation(summary = "Welcome message", 
               description = "Returns a welcome message for authenticated users")
    @ApiResponse(responseCode = "200", description = "Welcome message returned successfully", 
                content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "<h2>Welcome User!</h2>")))
    @GetMapping("/welcome")
    public ResponseEntity<String> getWelcomeMessage(){
        return ResponseEntity.ok("<h2>Welcome User!</h2>");
    }

    @Operation(summary = "Health check", description = "Simple health check endpoint")
    @GetMapping("/health")
    public ResponseEntity<String> healthCheck(){
        return ResponseEntity.ok("User Service is running on port 9080");
    }

    @GetMapping("/test-db")
    public ResponseEntity<String> testDatabase(){
        try {
            long customerCount = repository.count();
            return ResponseEntity.ok("Database connected. Customer count: " + customerCount);
        } catch (Exception e) {
            return ResponseEntity.ok("Database error: " + e.getMessage());
        }
    }

    @Operation(summary = "Get orders from Order Service", 
               description = "Proxies the request to Order Service to retrieve orders")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Orders retrieved successfully"),
        @ApiResponse(responseCode = "503", description = "Order Service unavailable")
    })
    @GetMapping("/orders")
    public ResponseEntity<String> getOrders() {
        return orderServiceClient.getOrders();
    }

    @Operation(summary = "Get customer data (Admin only)", 
               description = "Retrieves customer data - restricted to admin users only")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Customer data retrieved successfully", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Customer.class))),
        @ApiResponse(responseCode = "403", description = "Access denied - Admin role required")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/customer-data")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Customer getCustomerData(){
        Customer customer1 = new Customer();
        return customer1;
    }

    @Operation(summary = "Validate user token", 
               description = "Validates if the user token is valid and user has customer role")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "User is valid", 
                    content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "<h2>User is Valid</h2>"))),
        @ApiResponse(responseCode = "403", description = "Access denied - Customer role required")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/valid")
    @PreAuthorize("hasAuthority('ROLE_CUSTOMER')")
    public ResponseEntity<String> checkUserIsValid(){
        return ResponseEntity.ok("<h2>User is Valid</h2>");
    }

    @Operation(summary = "Register new customer", 
               description = "Creates a new customer account in the system")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Customer registered successfully", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = RegistrationResponse.class))),
        @ApiResponse(responseCode = "400", description = "Invalid customer data or user already exists",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = RegistrationResponse.class)))
    })
    @PostMapping("/new")
    public ResponseEntity<RegistrationResponse> addNewCustomer(
            @Parameter(description = "Customer registration details", required = true)
            @RequestBody Customer customer,
            @Parameter(description = "Vendor code (required for vendor registration)", required = false)
            @RequestParam(required = false) String vendorCode){
        try {
            String result = userService.addUser(customer, vendorCode);
            if (result.contains("successfully")) {
                return ResponseEntity.ok(RegistrationResponse.success(result));
            } else {
                return ResponseEntity.badRequest().body(RegistrationResponse.error(result));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(RegistrationResponse.error("Registration failed: " + e.getMessage()));
        }
    }

    @Operation(summary = "Authenticate user and get JWT token", 
               description = "Authenticates user credentials and returns JWT token with user details")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Authentication successful - JWT token and user details returned", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = LoginResponse.class))),
        @ApiResponse(responseCode = "401", description = "Authentication failed - Invalid credentials")
    })
    @PostMapping("/authenticate")
    public ResponseEntity<LoginResponse> authenticateAndGetToken(
            @Parameter(description = "User login credentials", required = true)
            @RequestBody AuthenticationRequest authenticationRequest) {
        try {
            System.out.println("=== AUTHENTICATION DEBUG ===");
            System.out.println("Attempting login for username: " + authenticationRequest.getUsername());
            System.out.println("Password provided: " + authenticationRequest.getPassword());
            
            // Check if user exists
            try {
                Customer user = userService.getUserByUsername(authenticationRequest.getUsername());
                System.out.println("User found in database - Role: " + user.getRoles() + ", Active: " + user.isActive());
            } catch (Exception e) {
                System.out.println("User NOT found in database: " + e.getMessage());
            }
            
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            authenticationRequest.getUsername(), 
                            authenticationRequest.getPassword()));
            
            System.out.println("Authentication successful: " + authentication.isAuthenticated());
            System.out.println("Authorities: " + authentication.getAuthorities());
            
            if(authentication.isAuthenticated()){
                Customer user = userService.getUserByUsername(authenticationRequest.getUsername());
                String token = jwtService.generateToken(user.getUserName(), authentication);
                
                System.out.println("User found - Role: " + user.getRoles());
                System.out.println("JWT Token generated: " + token.substring(0, 20) + "...");
                
                // Clear password before sending to client
                user.setPassword(null);
                
                LoginResponse response = new LoginResponse(token, user, 3600L);
                System.out.println("Response created - User role in response: " + response.getUser().getRoles());
                System.out.println("=== AUTHENTICATION DEBUG END ===");
                
                return ResponseEntity.ok(response);
            } else {
                throw new AuthenticationCredentialsNotFoundException("Not Authenticated");
            }
        } catch (Exception e) {
            System.out.println("Authentication failed: " + e.getMessage());
            e.printStackTrace();
            throw new AuthenticationCredentialsNotFoundException("Authentication failed: " + e.getMessage());
        }
    }

    // === ADMIN VENDOR CODE MANAGEMENT ENDPOINTS ===

    @Operation(summary = "Create new vendor code (Admin only)", 
               description = "Creates a new vendor code for vendor registration")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Vendor code created successfully", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = VendorCode.class))),
        @ApiResponse(responseCode = "400", description = "Invalid vendor code data or code already exists"),
        @ApiResponse(responseCode = "403", description = "Access denied - Admin role required")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @PostMapping("/admin/vendor-codes")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<?> createVendorCode(
            @Parameter(description = "Vendor code details", required = true)
            @RequestBody VendorCode vendorCode) {
        try {
            // Check current authentication
            org.springframework.security.core.Authentication auth = 
                org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            System.out.println("Current user authorities: " + (auth != null ? auth.getAuthorities() : "No auth"));
            System.out.println("Current user: " + (auth != null ? auth.getName() : "No user"));
            
            System.out.println("Creating vendor code: " + vendorCode.getVendorCode());
            System.out.println("Vendor ID: " + vendorCode.getVendorId());
            System.out.println("Vendor Name: " + vendorCode.getVendorName());
            
            VendorCode createdCode = vendorCodeService.createVendorCode(vendorCode);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdCode);
        } catch (Exception e) {
            System.out.println("Error creating vendor code: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }

    @Operation(summary = "Get all vendor codes (Admin only)", 
               description = "Retrieves all vendor codes in the system")
    @ApiResponse(responseCode = "200", description = "Vendor codes retrieved successfully", 
                content = @Content(mediaType = "application/json"))
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/admin/vendor-codes")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<List<VendorCode>> getAllVendorCodes() {
        List<VendorCode> codes = vendorCodeService.getAllVendorCodes();
        return ResponseEntity.ok(codes);
    }

    @Operation(summary = "Get unused vendor codes (Admin only)", 
               description = "Retrieves all unused vendor codes")
    @ApiResponse(responseCode = "200", description = "Unused vendor codes retrieved successfully", 
                content = @Content(mediaType = "application/json"))
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/admin/vendor-codes/unused")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<List<VendorCode>> getUnusedVendorCodes() {
        List<VendorCode> codes = vendorCodeService.getUnusedVendorCodes();
        return ResponseEntity.ok(codes);
    }

    @Operation(summary = "Get used vendor codes (Admin only)", 
               description = "Retrieves all used vendor codes")
    @ApiResponse(responseCode = "200", description = "Used vendor codes retrieved successfully", 
                content = @Content(mediaType = "application/json"))
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/admin/vendor-codes/used")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<List<VendorCode>> getUsedVendorCodes() {
        List<VendorCode> codes = vendorCodeService.getUsedVendorCodes();
        return ResponseEntity.ok(codes);
    }

    @Operation(summary = "Update vendor code (Admin only)", 
               description = "Updates an existing vendor code")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vendor code updated successfully", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = VendorCode.class))),
        @ApiResponse(responseCode = "404", description = "Vendor code not found"),
        @ApiResponse(responseCode = "400", description = "Invalid vendor code data")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @PutMapping("/admin/vendor-codes/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<VendorCode> updateVendorCode(
            @Parameter(description = "Vendor code ID", required = true)
            @PathVariable Long id,
            @Parameter(description = "Updated vendor code details", required = true)
            @RequestBody VendorCode vendorCode) {
        try {
            VendorCode updatedCode = vendorCodeService.updateVendorCode(id, vendorCode);
            return ResponseEntity.ok(updatedCode);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @Operation(summary = "Deactivate vendor code (Admin only)", 
               description = "Deactivates a vendor code (soft delete)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vendor code deactivated successfully"),
        @ApiResponse(responseCode = "404", description = "Vendor code not found")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @DeleteMapping("/admin/vendor-codes/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<String> deactivateVendorCode(
            @Parameter(description = "Vendor code ID", required = true)
            @PathVariable Long id) {
        try {
            vendorCodeService.deactivateVendorCode(id);
            return ResponseEntity.ok("Vendor code deactivated successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Vendor code not found");
        }
    }

    @Operation(summary = "Validate vendor code", 
               description = "Validates if a vendor code exists and can be used for registration")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vendor code validation result", 
                    content = @Content(mediaType = "application/json")),
        @ApiResponse(responseCode = "400", description = "Invalid vendor code")
    })
    @GetMapping("/validate-vendor-code/{code}")
    public ResponseEntity<Boolean> validateVendorCode(
            @Parameter(description = "Vendor code to validate", required = true)
            @PathVariable String code) {
        boolean isValid = vendorCodeService.isValidVendorCode(code);
        return ResponseEntity.ok(isValid);
    }

    @Operation(summary = "Debug admin account", description = "Debug endpoint to verify admin account exists")
    @GetMapping("/debug/admin")
    public ResponseEntity<String> debugAdmin() {
        try {
            Customer admin = userService.getUserByUsername("admin");
            return ResponseEntity.ok("Admin found: " + admin.getUserName() + ", Role: " + admin.getRoles() + ", Active: " + admin.isActive());
        } catch (Exception e) {
            return ResponseEntity.ok("Admin not found: " + e.getMessage());
        }
    }

    @PostMapping("/debug/reset-admin-password")
    public ResponseEntity<String> resetAdminPassword() {
        try {
            Customer admin = userService.getUserByUsername("admin");
            admin.setPassword(passwordEncoder.encode("admin123"));
            repository.save(admin);
            return ResponseEntity.ok("Admin password reset to 'admin123' successfully");
        } catch (Exception e) {
            return ResponseEntity.ok("Failed to reset admin password: " + e.getMessage());
        }
    }

    @PostMapping("/debug/reset-piyush-password")
    public ResponseEntity<String> resetPiyushPassword() {
        try {
            Customer piyush = userService.getUserByUsername("Piyush");
            piyush.setPassword(passwordEncoder.encode("Test@1234"));
            repository.save(piyush);
            return ResponseEntity.ok("Piyush password reset to 'Test@1234' successfully");
        } catch (Exception e) {
            return ResponseEntity.ok("Failed to reset Piyush password: " + e.getMessage());
        }
    }

    @PostMapping("/debug/fix-piyush-user")
    public ResponseEntity<String> fixPiyushUser() {
        try {
            // Try to find user by current username (email)
            Customer piyush = null;
            try {
                piyush = userService.getUserByUsername("piyush@example.com");
            } catch (Exception e1) {
                try {
                    piyush = userService.getUserByUsername("piyush");
                } catch (Exception e2) {
                    try {
                        piyush = userService.getUserByUsername("Piyush");
                    } catch (Exception e3) {
                        return ResponseEntity.ok("Could not find Piyush user with any username variant");
                    }
                }
            }

            // Reset username and password to original values
            piyush.setUserName("piyush");  // Original lowercase username
            piyush.setPassword(passwordEncoder.encode("Test@1234"));  // Original password
            piyush.setFirstName("Piyush");  // Reset name
            piyush.setLastName("Piyush");   // Reset name
            repository.save(piyush);

            return ResponseEntity.ok("Piyush user fixed: username=piyush, password=Test@1234");
        } catch (Exception e) {
            return ResponseEntity.ok("Failed to fix Piyush user: " + e.getMessage());
        }
    }

    @PostMapping("/debug/test-vendor-code")
    public ResponseEntity<String> testVendorCodeCreation() {
        try {
            VendorCode testCode = new VendorCode();
            testCode.setVendorCode("TEST001");
            testCode.setVendorId("TESTVENDOR001");
            testCode.setVendorName("Test Vendor");
            testCode.setDescription("Test Description");
            testCode.setActive(true);
            testCode.setUsed(false);
            testCode.setCreatedBy(1L);
            
            VendorCode saved = vendorCodeService.createVendorCode(testCode);
            return ResponseEntity.ok("Test vendor code created successfully with ID: " + saved.getId());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok("Failed to create test vendor code: " + e.getMessage());
        }
    }

    @Operation(summary = "Get vendor name by vendor ID",
               description = "Returns the vendor's full name for the given vendor ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vendor name retrieved successfully",
                    content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "John Doe"))),
        @ApiResponse(responseCode = "404", description = "Vendor not found")
    })
    @GetMapping("/vendor/{vendorId}/name")
    public ResponseEntity<String> getVendorName(
            @Parameter(description = "Vendor ID", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        String vendorName = userService.getVendorNameByVendorId(vendorId);
        if (vendorName != null) {
            return ResponseEntity.ok(vendorName);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Vendor not found");
        }
    }

    // === USER PROFILE AND SETTINGS ENDPOINTS ===

    @Operation(summary = "Update user profile",
               description = "Updates the authenticated user's profile information")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Profile updated successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Customer.class))),
        @ApiResponse(responseCode = "400", description = "Invalid profile data"),
        @ApiResponse(responseCode = "401", description = "User not authenticated"),
        @ApiResponse(responseCode = "403", description = "Access denied - Can only update own profile"),
        @ApiResponse(responseCode = "404", description = "User not found")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @PutMapping("/profile/{userId}")
    public ResponseEntity<?> updateProfile(
            @Parameter(description = "User ID", required = true)
            @PathVariable Long userId,
            @Parameter(description = "Profile update details", required = true)
            @RequestBody ProfileUpdateRequest request,
            @Parameter(description = "JWT Bearer token", required = true, example = "Bearer eyJhbGciOiJIUzI1NiJ9...")
            @RequestHeader("Authorization") String token) {
        try {
            // DEBUG: Log the authorization check
            System.out.println("=== PROFILE UPDATE DEBUG ===");
            System.out.println("Target userId: " + userId);
            System.out.println("Token: " + token);

            boolean isAuthorized = userService.isUserAuthorizedForAction(token, userId);
            System.out.println("Is authorized: " + isAuthorized);

            if (!isAuthorized) {
                System.out.println("Authorization failed for profile update");
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Access denied - You can only update your own profile");
            }
            System.out.println("Authorization passed for profile update");

            Map<String, Object> updateResult = userService.updateProfile(
                userId,
                request.getFirstName(),
                request.getLastName(),
                request.getEmail(),
                request.getPhoneNumber(),
                request.getVendorId()
            );

            Customer updatedUser = (Customer) updateResult.get("user");

            // Since username never changes, no need for JWT refresh
            ProfileUpdateResponse response = new ProfileUpdateResponse();
            response.setUser(updatedUser);
            response.setTokenRefreshed(false);
            response.setNewToken(null);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("Error updating profile: " + e.getMessage());
            return ResponseEntity.badRequest().body("Failed to update profile: " + e.getMessage());
        }
    }

    @Operation(summary = "Change user password",
               description = "Changes the authenticated user's password")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Password changed successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid password data or current password incorrect"),
        @ApiResponse(responseCode = "401", description = "User not authenticated"),
        @ApiResponse(responseCode = "403", description = "Access denied - Can only change own password"),
        @ApiResponse(responseCode = "404", description = "User not found")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @PutMapping("/password/{userId}")
    public ResponseEntity<String> changePassword(
            @Parameter(description = "User ID", required = true)
            @PathVariable Long userId,
            @Parameter(description = "Password change details", required = true)
            @RequestBody PasswordChangeRequest request,
            @Parameter(description = "JWT Bearer token", required = true, example = "Bearer eyJhbGciOiJIUzI1NiJ9...")
            @RequestHeader("Authorization") String token) {
        try {
            // DEBUG: Log the authorization check
            System.out.println("=== PASSWORD UPDATE DEBUG ===");
            System.out.println("Target userId: " + userId);
            System.out.println("Token: " + token);

            boolean isAuthorized = userService.isUserAuthorizedForAction(token, userId);
            System.out.println("Is authorized: " + isAuthorized);

            if (!isAuthorized) {
                System.out.println("Authorization failed for password update");
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Access denied - You can only change your own password");
            }
            System.out.println("Authorization passed for password update");

            boolean success = userService.changePassword(
                userId,
                request.getCurrentPassword(),
                request.getNewPassword()
            );

            if (success) {
                return ResponseEntity.ok("Password changed successfully");
            } else {
                return ResponseEntity.badRequest().body("Current password is incorrect");
            }
        } catch (Exception e) {
            System.out.println("Error changing password: " + e.getMessage());
            return ResponseEntity.badRequest().body("Failed to change password: " + e.getMessage());
        }
    }

    // ============ ADMIN USER MANAGEMENT APIs ============

    @Operation(summary = "Get all users (Admin only)",
            description = "Retrieve list of all users with optional role filter")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Users retrieved successfully"),
            @ApiResponse(responseCode = "403", description = "Access denied - Admin only")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @GetMapping("/admin/users")
    public ResponseEntity<List<Customer>> getAllUsers(
            @Parameter(description = "Filter by role (CUSTOMER, VENDOR, ADMIN)")
            @RequestParam(required = false) String role) {
        try {
            List<Customer> users = userService.getAllUsers(role);
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            System.out.println("Error getting users: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(summary = "Get user statistics (Admin only)",
            description = "Get counts of users by role for dashboard")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Statistics retrieved successfully"),
            @ApiResponse(responseCode = "403", description = "Access denied - Admin only")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @GetMapping("/admin/users/stats")
    public ResponseEntity<Map<String, Long>> getUserStats() {
        try {
            Map<String, Long> stats = userService.getUserStats();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            System.out.println("Error getting user stats: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @Operation(summary = "Activate user (Admin only)",
            description = "Activate a deactivated user account")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User activated successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "403", description = "Access denied - Admin only")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @PutMapping("/admin/users/{id}/activate")
    public ResponseEntity<Customer> activateUser(
            @Parameter(description = "ID of the user to activate", required = true)
            @PathVariable Integer id) {
        try {
            Customer user = userService.setUserActiveStatus(id, true);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            System.out.println("Error activating user: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @Operation(summary = "Deactivate user (Admin only)",
            description = "Deactivate a user account (prevents login and orders)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User deactivated successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "403", description = "Access denied - Admin only")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @PutMapping("/admin/users/{id}/deactivate")
    public ResponseEntity<Customer> deactivateUser(
            @Parameter(description = "ID of the user to deactivate", required = true)
            @PathVariable Integer id) {
        try {
            Customer user = userService.setUserActiveStatus(id, false);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            System.out.println("Error deactivating user: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }
}