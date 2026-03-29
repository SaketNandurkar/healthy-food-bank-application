-- V3: Create delivery_slots table for flexible delivery scheduling
-- Replaces hardcoded Friday 8 PM cutoff with admin-managed delivery slots

CREATE TABLE IF NOT EXISTS delivery_slots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    delivery_date DATE NOT NULL,
    cutoff_date_time DATETIME(6) NOT NULL,
    active BIT(1) NOT NULL DEFAULT 1
);

CREATE INDEX idx_delivery_slots_active_cutoff ON delivery_slots (active, cutoff_date_time);
CREATE INDEX idx_delivery_slots_delivery_date ON delivery_slots (delivery_date);
