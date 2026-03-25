package product_service.enums;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Product categories available in the Healthy Food Bank")
public enum ProductCategory {
    @Schema(description = "Fresh vegetables")
    VEGETABLES,
    
    @Schema(description = "Fresh fruits") 
    FRUITS,
    
    @Schema(description = "Dairy products")
    DAIRY,
    
    @Schema(description = "Grains and cereals")
    GRAINS,
    
    @Schema(description = "Protein sources")
    PROTEINS,
    
    @Schema(description = "Beverages and drinks")
    BEVERAGES,
    
    @Schema(description = "Organic products")
    ORGANIC,
    
    @Schema(description = "Other food items")
    OTHERS
}