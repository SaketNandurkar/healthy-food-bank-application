package product_service.mapper;

import product_service.dto.ProductDTO;
import product_service.entity.Product;

public class ProductMapper {

    public static ProductDTO toDTO(Product product) {
        ProductDTO dto = new ProductDTO();
        dto.setProductId(product.getProductId());
        dto.setProductName(product.getProductName());
        dto.setProductPrice(product.getProductPrice());
        dto.setProductQuantity(product.getProductQuantity());
        dto.setProductUnit(product.getProductUnit());
        dto.setProductAdditionDate(product.getProductAdditionDate());
        dto.setProductUpdatedDate(product.getProductUpdatedDate());
        dto.setProductAddedBy(product.getProductAddedBy());
        dto.setVendorId(product.getVendorId());
        dto.setVendorName(product.getVendorName());
        dto.setCategory(product.getCategory());
        dto.setUnitQuantity(product.getUnitQuantity());
        dto.setDeliverySchedule(product.getDeliverySchedule());
        return dto;
    }
}

