package product_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import product_service.dto.ProductDTO;
import product_service.entity.Product;
import product_service.enums.ProductCategory;
import product_service.exception.ProductNotFoundException;
import product_service.mapper.ProductMapper;
import product_service.repository.ProductRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductService {

    private static final Logger logger = LoggerFactory.getLogger(ProductService.class);

    private final ProductRepository productRepository;
    private final NotificationService notificationService;

    @Autowired
    private VendorService vendorService;

    public ProductService(ProductRepository productRepository, NotificationService notificationService) {
        this.productRepository = productRepository;
        this.notificationService = notificationService;
    }

    public Product addNewProduct(Product newProduct, Long userId) {
        try {
            logger.info("Adding new product: {} for user: {}", newProduct.getProductName(), userId);
            logger.info("Product creation - Vendor ID from request: {}", newProduct.getVendorId());

            Product product = new Product();
            product.setProductName(newProduct.getProductName());
            product.setProductPrice(newProduct.getProductPrice());
            product.setProductQuantity(newProduct.getProductQuantity());
            product.setProductUnit(newProduct.getProductUnit());
            product.setProductAddedBy(userId);
            product.setVendorId(newProduct.getVendorId());
            product.setCategory(newProduct.getCategory() != null ? newProduct.getCategory() : ProductCategory.OTHERS);

            // Fetch and set vendor name if vendorId is present
            if (product.getVendorId() != null && !product.getVendorId().trim().isEmpty()) {
                String vendorName = vendorService.getVendorNameByVendorId(product.getVendorId());
                if (vendorName != null) {
                    product.setVendorName(vendorName);
                    logger.info("Set vendor name: {} for vendorId: {}", vendorName, product.getVendorId());
                }
            }
            // DateTime is handled by @PrePersist

            logger.info("Product creation - Final vendor ID being saved: {}", product.getVendorId());

            Product savedProduct = productRepository.save(product);
            logger.info("Successfully added product with ID: {} and vendor ID: {}",
                savedProduct.getProductId(), savedProduct.getVendorId());

            // Notify all users about the new product via WebSocket
            notificationService.notifyProductAdded(savedProduct);

            return savedProduct;
        } catch (Exception e) {
            logger.error("Error adding product: {}", newProduct.getProductName(), e);
            throw new RuntimeException("Failed to add product", e);
        }
    }

    public Product editProduct(Integer id, Product updatedProduct, Long userId) {
        try {
            logger.info("Editing product with ID: {} for user: {}", id, userId);

            Product existingProduct = productRepository.findById(id)
                    .orElseThrow(() -> new ProductNotFoundException("Product not found with id: " + id));

            existingProduct.setProductName(updatedProduct.getProductName());
            existingProduct.setProductPrice(updatedProduct.getProductPrice());
            existingProduct.setProductQuantity(updatedProduct.getProductQuantity());
            existingProduct.setProductUnit(updatedProduct.getProductUnit());
            existingProduct.setUnitQuantity(updatedProduct.getUnitQuantity());
            existingProduct.setDeliverySchedule(updatedProduct.getDeliverySchedule());
            existingProduct.setProductAddedBy(userId);
            if (updatedProduct.getVendorId() != null) {
                existingProduct.setVendorId(updatedProduct.getVendorId());

                // Fetch and set vendor name when vendorId is updated
                String vendorName = vendorService.getVendorNameByVendorId(updatedProduct.getVendorId());
                if (vendorName != null) {
                    existingProduct.setVendorName(vendorName);
                    logger.info("Updated vendor name: {} for vendorId: {}", vendorName, updatedProduct.getVendorId());
                }
            }
            if (updatedProduct.getCategory() != null) {
                existingProduct.setCategory(updatedProduct.getCategory());
            }
            // DateTime is handled by @PreUpdate

            Product savedProduct = productRepository.save(existingProduct);
            logger.info("Successfully updated product with ID: {}", savedProduct.getProductId());

            // Notify all users about the updated product via WebSocket
            notificationService.notifyProductUpdated(savedProduct);

            return savedProduct;
        } catch (ProductNotFoundException e) {
            logger.warn("Product not found with ID: {}", id);
            throw e;
        } catch (Exception e) {
            logger.error("Error editing product with ID: {}", id, e);
            throw new RuntimeException("Failed to edit product", e);
        }
    }

    public ResponseEntity<String> deleteProduct(Integer id) {
        try {
            if (!productRepository.existsById(id)) {
                logger.warn("Attempt to delete non-existent product with ID: {}", id);
                throw new ProductNotFoundException("Product not found with id: " + id);
            }

            // Get product before deletion for notification
            Product productToDelete = productRepository.findById(id).orElse(null);

            productRepository.deleteById(id);
            logger.info("Successfully deleted product with ID: {}", id);

            // Notify all users about the deleted product via WebSocket
            if (productToDelete != null) {
                notificationService.notifyProductDeleted(productToDelete);
            }

            return ResponseEntity.ok("Product deleted successfully");
        } catch (ProductNotFoundException e) {
            throw e;
        } catch (Exception e) {
            logger.error("Error deleting product with ID: {}", id, e);
            throw new RuntimeException("Failed to delete product", e);
        }
    }

    public Product getProductById(Integer id) {
        logger.info("Fetching product with ID: {}", id);
        return productRepository.findById(id)
                .orElseThrow(() -> new ProductNotFoundException("Product not found with id: " + id));
    }

    public List<ProductDTO> getAllProducts() {
        logger.info("Fetching all products");
        return productRepository.findAll().stream()
                .map(this::toDTOWithVendorName)
                .collect(Collectors.toList());
    }

    public List<ProductDTO> getProductsByUserId(Long userId) {
        logger.info("Fetching products for user ID: {}", userId);
        return productRepository.findByProductAddedBy(userId).stream()
                .map(this::toDTOWithVendorName)
                .collect(Collectors.toList());
    }

    public List<ProductDTO> getProductsByVendorId(String vendorId) {
        logger.info("Fetching products for vendor ID: {}", vendorId);
        return productRepository.findByVendorId(vendorId).stream()
                .map(this::toDTOWithVendorName)
                .collect(Collectors.toList());
    }

    public List<ProductDTO> getProductsByCategory(ProductCategory category) {
        logger.info("Fetching products for category: {}", category);
        return productRepository.findByCategory(category).stream()
                .map(this::toDTOWithVendorName)
                .collect(Collectors.toList());
    }

    /**
     * Get products filtered by pickup point
     * Only returns products from vendors who serve the specified pickup point
     */
    public List<ProductDTO> getProductsByPickupPoint(Long pickupPointId) {
        logger.info("Fetching products for pickup point: {}", pickupPointId);

        // Get list of vendor IDs serving this pickup point
        List<String> vendorIds = vendorService.getVendorsByPickupPoint(pickupPointId);

        if (vendorIds.isEmpty()) {
            logger.info("No vendors found for pickup point: {}", pickupPointId);
            return List.of();
        }

        logger.info("Found {} vendors for pickup point: {}", vendorIds.size(), pickupPointId);

        // Fetch all products and filter by vendor IDs
        return productRepository.findAll().stream()
                .filter(product -> product.getVendorId() != null && vendorIds.contains(product.getVendorId()))
                .map(this::toDTOWithVendorName)
                .collect(Collectors.toList());
    }

    /**
     * Maps Product to DTO, enriching vendorName from User Service if missing in DB.
     * Also persists the vendorName back to the product so future fetches skip the lookup.
     */
    private ProductDTO toDTOWithVendorName(Product product) {
        if ((product.getVendorName() == null || product.getVendorName().trim().isEmpty())
                && product.getVendorId() != null && !product.getVendorId().trim().isEmpty()) {
            String vendorName = vendorService.getVendorNameByVendorId(product.getVendorId());
            if (vendorName != null) {
                product.setVendorName(vendorName);
                productRepository.save(product);
                logger.info("Enriched vendor name '{}' for product ID: {}", vendorName, product.getProductId());
            }
        }
        return ProductMapper.toDTO(product);
    }

    /**
     * Deduct stock from a product when an order is placed with pessimistic locking.
     * Uses database row-level lock to prevent race conditions when multiple customers
     * try to purchase the same product simultaneously.
     * Handles unit conversion (e.g., g to kg, ml to litre)
     */
    @Transactional
    public Product deductStock(Integer productId, double orderQuantity, String orderUnit) {
        try {
            logger.info("Deducting stock for product ID: {}, quantity: {} {} (with pessimistic lock)",
                    productId, orderQuantity, orderUnit);

            // Use pessimistic write lock to prevent concurrent modifications
            // This ensures only ONE transaction can modify this product's stock at a time
            Product product = productRepository.findByIdWithLock(productId)
                    .orElseThrow(() -> new ProductNotFoundException("Product not found with id: " + productId));

            // Convert order quantity to product's base unit
            double quantityToDeduct = convertToBaseUnit(orderQuantity, orderUnit, product.getProductUnit());

            // Check if sufficient stock is available
            if (product.getProductQuantity() < quantityToDeduct) {
                logger.warn("Insufficient stock for product ID: {}. Available: {} {}, Required: {} {}",
                        productId, product.getProductQuantity(), product.getProductUnit(),
                        quantityToDeduct, product.getProductUnit());
                throw new RuntimeException("Insufficient stock. Available: " + product.getProductQuantity() +
                        " " + product.getProductUnit() + ", Required: " + quantityToDeduct + " " + product.getProductUnit());
            }

            // Deduct the stock
            double newQuantity = product.getProductQuantity() - quantityToDeduct;
            product.setProductQuantity(newQuantity);

            Product savedProduct = productRepository.save(product);
            logger.info("Successfully deducted stock. New quantity: {} {}", newQuantity, product.getProductUnit());

            // Notify about stock update
            notificationService.notifyProductUpdated(savedProduct);

            return savedProduct;
        } catch (ProductNotFoundException e) {
            logger.warn("Product not found with ID: {}", productId);
            throw e;
        } catch (Exception e) {
            logger.error("Error deducting stock for product ID: {}", productId, e);
            throw new RuntimeException("Failed to deduct stock: " + e.getMessage(), e);
        }
    }

    /**
     * Convert quantity from one unit to another
     * Supports: kg <-> g, litre <-> ml
     */
    private double convertToBaseUnit(double quantity, String fromUnit, String toUnit) {
        // Normalize unit names
        fromUnit = fromUnit.toLowerCase().trim();
        toUnit = toUnit.toLowerCase().trim();

        // If units are the same, no conversion needed
        if (fromUnit.equals(toUnit)) {
            return quantity;
        }

        // Weight conversions
        if (fromUnit.equals("g") && toUnit.equals("kg")) {
            return quantity / 1000.0;
        }
        if (fromUnit.equals("kg") && toUnit.equals("g")) {
            return quantity * 1000.0;
        }

        // Volume conversions
        if (fromUnit.equals("ml") && (toUnit.equals("litre") || toUnit.equals("l"))) {
            return quantity / 1000.0;
        }
        if ((fromUnit.equals("litre") || fromUnit.equals("l")) && toUnit.equals("ml")) {
            return quantity * 1000.0;
        }

        // If units don't match and no conversion is available, throw error
        throw new RuntimeException("Cannot convert from " + fromUnit + " to " + toUnit + ". Please ensure order unit matches product unit.");
    }
}