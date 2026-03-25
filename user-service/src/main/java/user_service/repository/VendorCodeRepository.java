package user_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import user_service.entity.VendorCode;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface VendorCodeRepository extends JpaRepository<VendorCode, Long> {
    
    /**
     * Find vendor code by the actual code string
     */
    Optional<VendorCode> findByVendorCode(String vendorCode);
    
    /**
     * Find vendor code by vendor ID
     */
    Optional<VendorCode> findByVendorId(String vendorId);
    
    /**
     * Check if a vendor code exists and is active
     */
    Optional<VendorCode> findByVendorCodeAndActiveTrue(String vendorCode);
    
    /**
     * Check if a vendor code exists, is active, and not used
     */
    Optional<VendorCode> findByVendorCodeAndActiveTrueAndUsedFalse(String vendorCode);
    
    /**
     * Find all active vendor codes
     */
    List<VendorCode> findByActiveTrueOrderByCreatedDateDesc();
    
    /**
     * Find all used vendor codes
     */
    List<VendorCode> findByUsedTrueOrderByUsedDateDesc();
    
    /**
     * Find all unused vendor codes
     */
    List<VendorCode> findByUsedFalseAndActiveTrueOrderByCreatedDateDesc();
    
    /**
     * Check if vendor code exists
     */
    boolean existsByVendorCode(String vendorCode);
    
    /**
     * Check if vendor ID exists
     */
    boolean existsByVendorId(String vendorId);
    
    /**
     * Mark vendor code as used
     */
    @Modifying
    @Query("UPDATE VendorCode vc SET vc.used = true, vc.usedBy = :userId, vc.usedDate = :usedDate WHERE vc.vendorCode = :vendorCode")
    int markCodeAsUsed(@Param("vendorCode") String vendorCode, @Param("userId") Long userId, @Param("usedDate") LocalDateTime usedDate);
    
    /**
     * Find vendor codes created by specific admin
     */
    List<VendorCode> findByCreatedByOrderByCreatedDateDesc(Long createdBy);
}