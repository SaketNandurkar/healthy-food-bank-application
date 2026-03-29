-- Migration script to add statusUpdatedAt column to Order table
-- This script handles both new and existing orders

-- Add the statusUpdatedAt column
ALTER TABLE `Order` ADD COLUMN statusUpdatedAt DATETIME(6) DEFAULT NULL;

-- Initialize statusUpdatedAt for existing orders
-- Use orderPlacedDate as the initial value
UPDATE `Order`
SET statusUpdatedAt = orderPlacedDate
WHERE statusUpdatedAt IS NULL AND orderPlacedDate IS NOT NULL;

-- For orders without orderPlacedDate (edge case), use current timestamp
UPDATE `Order`
SET statusUpdatedAt = NOW()
WHERE statusUpdatedAt IS NULL;

-- Add index for performance (optional but recommended)
CREATE INDEX idx_order_status_updated_at ON `Order` (statusUpdatedAt);
CREATE INDEX idx_order_vendor_status_updated ON `Order` (vendorId, statusUpdatedAt);
