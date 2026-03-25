package product_service.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import product_service.dto.ProductDTO;
import product_service.entity.Product;
import product_service.enums.ProductCategory;
import product_service.service.ProductService;

import java.util.List;

@RestController
@RequestMapping("/products")
@CrossOrigin(origins = "*")
@Tag(name = "Product Management", description = "APIs for managing products, inventory, and product catalog")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @Operation(summary = "Health check endpoint", 
               description = "Returns the health status of the Product Service")
    @ApiResponse(responseCode = "200", description = "Service is running", 
                content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "Product Service is running")))
    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("Product Service is running");
    }

    @Operation(summary = "Add new product", 
               description = "Creates a new product in the catalog. Requires User ID header for tracking.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Product created successfully", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Product.class))),
        @ApiResponse(responseCode = "400", description = "Invalid product data"),
        @ApiResponse(responseCode = "401", description = "Missing or invalid User ID header")
    })
    @SecurityRequirement(name = "User ID Header")
    @PostMapping
    public ResponseEntity<Product> addProduct(
            @Parameter(description = "Product details to create", required = true)
            @RequestBody Product product, 
            @Parameter(description = "ID of the user creating the product", required = true, example = "123")
            @RequestHeader("X-User-Id") Long userId) {
        try {
            Product savedProduct = productService.addNewProduct(product, userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedProduct);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @Operation(summary = "Update existing product", 
               description = "Updates an existing product by ID. Requires User ID header for tracking.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Product updated successfully", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Product.class))),
        @ApiResponse(responseCode = "404", description = "Product not found"),
        @ApiResponse(responseCode = "400", description = "Invalid product data"),
        @ApiResponse(responseCode = "401", description = "Missing or invalid User ID header")
    })
    @SecurityRequirement(name = "User ID Header")
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
            @Parameter(description = "ID of the product to update", required = true, example = "1")
            @PathVariable Integer id, 
            @Parameter(description = "Updated product details", required = true)
            @RequestBody Product product, 
            @Parameter(description = "ID of the user updating the product", required = true, example = "123")
            @RequestHeader("X-User-Id") Long userId) {
        try {
            Product updatedProduct = productService.editProduct(id, product, userId);
            return ResponseEntity.ok(updatedProduct);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @Operation(summary = "Delete product", 
               description = "Removes a product from the catalog by ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Product deleted successfully", 
                    content = @Content(mediaType = "text/plain", schema = @Schema(type = "string", example = "Product deleted successfully"))),
        @ApiResponse(responseCode = "404", description = "Product not found")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteProduct(
            @Parameter(description = "ID of the product to delete", required = true, example = "1")
            @PathVariable Integer id) {
        return productService.deleteProduct(id);
    }

    @Operation(summary = "Get product by ID", 
               description = "Retrieves detailed information about a specific product")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Product found and returned", 
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Product.class))),
        @ApiResponse(responseCode = "404", description = "Product not found")
    })
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(
            @Parameter(description = "ID of the product to retrieve", required = true, example = "1")
            @PathVariable Integer id) {
        try {
            Product product = productService.getProductById(id);
            return ResponseEntity.ok(product);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @Operation(summary = "Get all products", 
               description = "Retrieves a list of all products in the catalog")
    @ApiResponse(responseCode = "200", description = "List of products returned successfully", 
                content = @Content(mediaType = "application/json", 
                array = @ArraySchema(schema = @Schema(implementation = ProductDTO.class))))
    @GetMapping
    public ResponseEntity<List<ProductDTO>> getAllProducts() {
        List<ProductDTO> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }

    @Operation(summary = "Get products by user ID", 
               description = "Retrieves all products created/managed by a specific user")
    @ApiResponse(responseCode = "200", description = "User's products returned successfully", 
                content = @Content(mediaType = "application/json", 
                array = @ArraySchema(schema = @Schema(implementation = ProductDTO.class))))
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ProductDTO>> getProductsByUserId(
            @Parameter(description = "ID of the user whose products to retrieve", required = true, example = "123")
            @PathVariable Long userId) {
        List<ProductDTO> products = productService.getProductsByUserId(userId);
        return ResponseEntity.ok(products);
    }

    @Operation(summary = "Get products by vendor ID", 
               description = "Retrieves all products from a specific vendor")
    @ApiResponse(responseCode = "200", description = "Vendor's products returned successfully", 
                content = @Content(mediaType = "application/json", 
                array = @ArraySchema(schema = @Schema(implementation = ProductDTO.class))))
    @GetMapping("/vendor/{vendorId}")
    public ResponseEntity<List<ProductDTO>> getProductsByVendorId(
            @Parameter(description = "Vendor ID whose products to retrieve", required = true, example = "VENDOR001")
            @PathVariable String vendorId) {
        List<ProductDTO> products = productService.getProductsByVendorId(vendorId);
        return ResponseEntity.ok(products);
    }

    @Operation(summary = "Get products by category",
               description = "Retrieves all products from a specific category")
    @ApiResponse(responseCode = "200", description = "Category products returned successfully",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = ProductDTO.class))))
    @GetMapping("/category/{category}")
    public ResponseEntity<List<ProductDTO>> getProductsByCategory(
            @Parameter(description = "Product category to filter by", required = true, example = "VEGETABLES")
            @PathVariable ProductCategory category) {
        List<ProductDTO> products = productService.getProductsByCategory(category);
        return ResponseEntity.ok(products);
    }

    @Operation(summary = "Get products by pickup point",
               description = "Retrieves products from vendors serving the specified pickup point")
    @ApiResponse(responseCode = "200", description = "Products retrieved successfully",
                content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = ProductDTO.class))))
    @GetMapping("/by-pickup-point/{pickupPointId}")
    public ResponseEntity<List<ProductDTO>> getProductsByPickupPoint(
            @Parameter(description = "Pickup point ID to filter products by", required = true, example = "1")
            @PathVariable Long pickupPointId) {
        List<ProductDTO> products = productService.getProductsByPickupPoint(pickupPointId);
        return ResponseEntity.ok(products);
    }

    @Operation(summary = "Deduct stock from product",
               description = "Deducts stock quantity from a product when an order is placed. Supports unit conversion.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Stock deducted successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Product.class))),
        @ApiResponse(responseCode = "404", description = "Product not found"),
        @ApiResponse(responseCode = "400", description = "Insufficient stock or invalid units")
    })
    @PostMapping("/{id}/deduct-stock")
    public ResponseEntity<?> deductStock(
            @Parameter(description = "ID of the product to deduct stock from", required = true, example = "1")
            @PathVariable Integer id,
            @Parameter(description = "Quantity to deduct", required = true, example = "0.5")
            @RequestParam double quantity,
            @Parameter(description = "Unit of the quantity", required = true, example = "kg")
            @RequestParam String unit) {
        try {
            Product updatedProduct = productService.deductStock(id, quantity, unit);
            return ResponseEntity.ok(updatedProduct);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}