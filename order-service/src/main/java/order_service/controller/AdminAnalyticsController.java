package order_service.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import order_service.dto.AdminAnalyticsOverviewDTO;
import order_service.dto.OrdersByPickupPointDTO;
import order_service.dto.TopProductDTO;
import order_service.dto.TopVendorDTO;
import order_service.service.AdminAnalyticsService;

import java.util.List;

/**
 * REST Controller for Admin Analytics Dashboard
 * Provides aggregated business insights for administrators
 *
 * @author Healthy Food Bank Team
 */
@RestController
@RequestMapping("/admin/analytics")
@CrossOrigin(origins = "*")
@Tag(name = "Admin Analytics", description = "Analytics APIs for admin dashboard - business insights and metrics")
public class AdminAnalyticsController {

    private static final Logger logger = LoggerFactory.getLogger(AdminAnalyticsController.class);

    @Autowired
    private AdminAnalyticsService analyticsService;

    @Operation(summary = "Get analytics overview",
               description = "Returns high-level metrics including total users, vendors, orders, and revenue. " +
                           "Combines data from order-service and user-service for comprehensive dashboard overview.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Analytics overview retrieved successfully",
                    content = @Content(mediaType = "application/json",
                                      schema = @Schema(implementation = AdminAnalyticsOverviewDTO.class))),
        @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/overview")
    public ResponseEntity<AdminAnalyticsOverviewDTO> getOverview() {
        logger.info("GET /admin/analytics/overview - Fetching analytics overview");
        try {
            AdminAnalyticsOverviewDTO overview = analyticsService.getOverview();
            return ResponseEntity.ok(overview);
        } catch (Exception e) {
            logger.error("Error fetching analytics overview: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @Operation(summary = "Get orders by pickup point",
               description = "Returns order count grouped by pickup point location. " +
                           "Helps identify most active locations for logistics planning.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Orders by pickup point retrieved successfully",
                    content = @Content(mediaType = "application/json",
                                      array = @ArraySchema(schema = @Schema(implementation = OrdersByPickupPointDTO.class)))),
        @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/orders-by-pickup-point")
    public ResponseEntity<List<OrdersByPickupPointDTO>> getOrdersByPickupPoint() {
        logger.info("GET /admin/analytics/orders-by-pickup-point - Fetching orders by pickup point");
        try {
            List<OrdersByPickupPointDTO> result = analyticsService.getOrdersByPickupPoint();
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Error fetching orders by pickup point: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @Operation(summary = "Get top products",
               description = "Returns products ranked by total quantity ordered. " +
                           "Useful for inventory planning and identifying popular items.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Top products retrieved successfully",
                    content = @Content(mediaType = "application/json",
                                      array = @ArraySchema(schema = @Schema(implementation = TopProductDTO.class)))),
        @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/top-products")
    public ResponseEntity<List<TopProductDTO>> getTopProducts() {
        logger.info("GET /admin/analytics/top-products - Fetching top products");
        try {
            List<TopProductDTO> result = analyticsService.getTopProducts();
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Error fetching top products: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @Operation(summary = "Get top vendors",
               description = "Returns vendors ranked by order count. " +
                           "Helps identify most active vendors for partnership and support decisions.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Top vendors retrieved successfully",
                    content = @Content(mediaType = "application/json",
                                      array = @ArraySchema(schema = @Schema(implementation = TopVendorDTO.class)))),
        @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @SecurityRequirement(name = "Bearer Authentication")
    @GetMapping("/top-vendors")
    public ResponseEntity<List<TopVendorDTO>> getTopVendors() {
        logger.info("GET /admin/analytics/top-vendors - Fetching top vendors");
        try {
            List<TopVendorDTO> result = analyticsService.getTopVendors();
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Error fetching top vendors: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
