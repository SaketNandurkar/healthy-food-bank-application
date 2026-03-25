package user_service.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import user_service.entity.VendorCode;
import user_service.repository.VendorCodeRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class VendorCodeService {
    
    @Autowired
    private VendorCodeRepository vendorCodeRepository;
    
    /**
     * Create a new vendor code
     */
    public VendorCode createVendorCode(VendorCode vendorCode) {
        // Set default values
        vendorCode.setActive(true);
        vendorCode.setUsed(false);
        
        return vendorCodeRepository.save(vendorCode);
    }
    
    /**
     * Validate if a vendor code exists and can be used for registration
     */
    public boolean isValidVendorCode(String vendorCode) {
        Optional<VendorCode> code = vendorCodeRepository.findByVendorCodeAndActiveTrueAndUsedFalse(vendorCode);
        return code.isPresent();
    }
    
    /**
     * Get vendor code details for registration
     */
    public Optional<VendorCode> getVendorCodeForRegistration(String vendorCode) {
        return vendorCodeRepository.findByVendorCodeAndActiveTrueAndUsedFalse(vendorCode);
    }
    
    /**
     * Mark vendor code as used after successful registration
     */
    public void markVendorCodeAsUsed(String vendorCode, Long userId) {
        int updated = vendorCodeRepository.markCodeAsUsed(vendorCode, userId, LocalDateTime.now());
        if (updated == 0) {
            throw new RuntimeException("Failed to mark vendor code as used: " + vendorCode);
        }
    }
    
    /**
     * Get all vendor codes (admin function)
     */
    public List<VendorCode> getAllVendorCodes() {
        return vendorCodeRepository.findByActiveTrueOrderByCreatedDateDesc();
    }
    
    /**
     * Get unused vendor codes
     */
    public List<VendorCode> getUnusedVendorCodes() {
        return vendorCodeRepository.findByUsedFalseAndActiveTrueOrderByCreatedDateDesc();
    }
    
    /**
     * Get used vendor codes
     */
    public List<VendorCode> getUsedVendorCodes() {
        return vendorCodeRepository.findByUsedTrueOrderByUsedDateDesc();
    }
    
    /**
     * Update vendor code
     */
    public VendorCode updateVendorCode(Long id, VendorCode updatedVendorCode) {
        Optional<VendorCode> existingCode = vendorCodeRepository.findById(id);
        if (existingCode.isEmpty()) {
            throw new RuntimeException("Vendor code not found with ID: " + id);
        }
        
        VendorCode code = existingCode.get();
        
        // Check if trying to update to an existing vendor code/ID (excluding current record)
        if (!code.getVendorCode().equals(updatedVendorCode.getVendorCode())) {
            if (vendorCodeRepository.existsByVendorCode(updatedVendorCode.getVendorCode())) {
                throw new RuntimeException("Vendor code already exists: " + updatedVendorCode.getVendorCode());
            }
        }
        
        if (!code.getVendorId().equals(updatedVendorCode.getVendorId())) {
            if (vendorCodeRepository.existsByVendorId(updatedVendorCode.getVendorId())) {
                throw new RuntimeException("Vendor ID already exists: " + updatedVendorCode.getVendorId());
            }
        }
        
        // Update fields
        code.setVendorCode(updatedVendorCode.getVendorCode());
        code.setVendorId(updatedVendorCode.getVendorId());
        code.setVendorName(updatedVendorCode.getVendorName());
        code.setDescription(updatedVendorCode.getDescription());
        code.setActive(updatedVendorCode.getActive());
        
        return vendorCodeRepository.save(code);
    }
    
    /**
     * Deactivate vendor code (soft delete)
     */
    public void deactivateVendorCode(Long id) {
        Optional<VendorCode> vendorCode = vendorCodeRepository.findById(id);
        if (vendorCode.isEmpty()) {
            throw new RuntimeException("Vendor code not found with ID: " + id);
        }
        
        VendorCode code = vendorCode.get();
        code.setActive(false);
        vendorCodeRepository.save(code);
    }
    
    /**
     * Get vendor code by ID
     */
    public Optional<VendorCode> getVendorCodeById(Long id) {
        return vendorCodeRepository.findById(id);
    }
    
    /**
     * Get vendor code by vendor ID
     */
    public Optional<VendorCode> getVendorCodeByVendorId(String vendorId) {
        return vendorCodeRepository.findByVendorId(vendorId);
    }
}