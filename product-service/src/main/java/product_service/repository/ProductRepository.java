package product_service.repository;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import product_service.entity.Product;
import product_service.enums.ProductCategory;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Integer> {

    List<Product> findByProductAddedBy(Long userId);

    List<Product> findByVendorId(String vendorId);

    List<Product> findByProductNameContainingIgnoreCase(String productName);

    List<Product> findByProductPriceBetween(Double minPrice, Double maxPrice);

    List<Product> findByCategory(ProductCategory category);

    /**
     * Find product by ID with pessimistic write lock for concurrent stock management.
     * This prevents race conditions when multiple orders try to purchase the same product simultaneously.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT p FROM Product p WHERE p.productId = :productId")
    Optional<Product> findByIdWithLock(@Param("productId") Integer productId);
}