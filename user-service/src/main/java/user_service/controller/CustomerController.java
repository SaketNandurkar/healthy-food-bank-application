package user_service.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import user_service.entity.Customer;
import user_service.service.UserService;

@RestController
@RequestMapping("/customer")
@Tag(name = "Customer Data", description = "API for retrieving customer data (used by other services)")
public class CustomerController {

    @Autowired
    private UserService userService;

    @Operation(summary = "Get customer by ID",
               description = "Returns customer details for the given customer ID (Used by order-service)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Customer retrieved successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Customer.class))),
        @ApiResponse(responseCode = "404", description = "Customer not found")
    })
    @GetMapping("/{customerId}")
    public ResponseEntity<Customer> getCustomerById(
            @Parameter(description = "Customer ID", required = true, example = "1")
            @PathVariable Long customerId) {
        try {
            Customer customer = userService.getCustomerById(customerId);
            if (customer != null) {
                // Clear sensitive data before returning
                customer.setPassword(null);
                return ResponseEntity.ok(customer);
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }
}
