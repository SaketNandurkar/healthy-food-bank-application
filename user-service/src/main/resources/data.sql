-- Create vendor_codes table if not exists
CREATE TABLE IF NOT EXISTS vendor_codes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vendor_code VARCHAR(20) UNIQUE NOT NULL,
    vendor_id VARCHAR(20) UNIQUE NOT NULL,
    vendor_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    active BOOLEAN DEFAULT TRUE,
    used BOOLEAN DEFAULT FALSE,
    used_by BIGINT,
    used_date TIMESTAMP NULL,
    created_by BIGINT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);