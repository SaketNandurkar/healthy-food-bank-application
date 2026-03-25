-- Create product table if not exists
CREATE TABLE IF NOT EXISTS product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    product_price DECIMAL(10,2) NOT NULL,
    product_quantity DOUBLE NOT NULL,
    product_unit VARCHAR(20) NOT NULL DEFAULT 'unit',
    product_addition_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    product_added_by BIGINT,
    vendor_id VARCHAR(50),
    INDEX idx_product_added_by (product_added_by),
    INDEX idx_product_name (product_name),
    INDEX idx_vendor_id (vendor_id)
);