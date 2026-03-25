package user_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class DataMigrationService {

    private static final Logger logger = LoggerFactory.getLogger(DataMigrationService.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Migrate existing customer pickupPointId data to customer_pickup_points table
     * This will be called once to migrate data from old schema to new schema
     */
    @Transactional
    public int migrateCustomerPickupPoints() {
        logger.info("Starting migration of customer pickup points...");

        try {
            // First, check if customer_pickup_points table exists
            String checkTableSql = "SELECT COUNT(*) FROM information_schema.tables " +
                                   "WHERE table_schema = DATABASE() AND table_name = 'customer_pickup_points'";
            Integer tableExists = jdbcTemplate.queryForObject(checkTableSql, Integer.class);

            if (tableExists == null || tableExists == 0) {
                logger.warn("customer_pickup_points table does not exist. Creating it now...");
                String createTableSql = "CREATE TABLE IF NOT EXISTS customer_pickup_points (" +
                                        "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                                        "customer_id BIGINT NOT NULL, " +
                                        "pickup_point_id BIGINT NOT NULL, " +
                                        "is_active BOOLEAN NOT NULL DEFAULT FALSE, " +
                                        "created_date DATETIME, " +
                                        "updated_date DATETIME, " +
                                        "UNIQUE KEY unique_customer_pickup (customer_id, pickup_point_id)" +
                                        ")";
                jdbcTemplate.execute(createTableSql);
                logger.info("customer_pickup_points table created successfully");
            }

            // Get all customers with a pickupPointId set
            String selectSql = "SELECT id, pickup_point_id FROM customer WHERE pickup_point_id IS NOT NULL";
            List<Map<String, Object>> customers = jdbcTemplate.queryForList(selectSql);

            logger.info("Found {} customers with pickup points to migrate", customers.size());

            int migratedCount = 0;
            for (Map<String, Object> customer : customers) {
                Long customerId = ((Number) customer.get("id")).longValue();
                Long pickupPointId = ((Number) customer.get("pickup_point_id")).longValue();

                // Check if this mapping already exists
                String checkSql = "SELECT COUNT(*) FROM customer_pickup_points " +
                                 "WHERE customer_id = ? AND pickup_point_id = ?";
                Integer exists = jdbcTemplate.queryForObject(checkSql, Integer.class, customerId, pickupPointId);

                if (exists == null || exists == 0) {
                    // Insert into customer_pickup_points with is_active = true (since it was their only/default one)
                    String insertSql = "INSERT INTO customer_pickup_points " +
                                      "(customer_id, pickup_point_id, is_active, created_date, updated_date) " +
                                      "VALUES (?, ?, true, NOW(), NOW())";
                    jdbcTemplate.update(insertSql, customerId, pickupPointId);
                    migratedCount++;
                    logger.debug("Migrated pickup point {} for customer {}", pickupPointId, customerId);
                } else {
                    logger.debug("Pickup point {} for customer {} already exists, skipping", pickupPointId, customerId);
                }
            }

            logger.info("Migration completed. Migrated {} customer pickup points", migratedCount);
            return migratedCount;

        } catch (Exception e) {
            logger.error("Error during customer pickup point migration", e);
            throw new RuntimeException("Migration failed: " + e.getMessage(), e);
        }
    }

    /**
     * Create vendor_pickup_points table if it doesn't exist
     * Vendors will manually add their pickup points through the UI
     */
    @Transactional
    public void createVendorPickupPointsTable() {
        logger.info("Checking/Creating vendor_pickup_points table...");

        try {
            String checkTableSql = "SELECT COUNT(*) FROM information_schema.tables " +
                                   "WHERE table_schema = DATABASE() AND table_name = 'vendor_pickup_points'";
            Integer tableExists = jdbcTemplate.queryForObject(checkTableSql, Integer.class);

            if (tableExists == null || tableExists == 0) {
                String createTableSql = "CREATE TABLE IF NOT EXISTS vendor_pickup_points (" +
                                        "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                                        "vendor_id VARCHAR(255) NOT NULL, " +
                                        "pickup_point_id BIGINT NOT NULL, " +
                                        "is_active BOOLEAN NOT NULL DEFAULT TRUE, " +
                                        "created_date DATETIME, " +
                                        "updated_date DATETIME, " +
                                        "UNIQUE KEY unique_vendor_pickup (vendor_id, pickup_point_id)" +
                                        ")";
                jdbcTemplate.execute(createTableSql);
                logger.info("vendor_pickup_points table created successfully");
            } else {
                logger.info("vendor_pickup_points table already exists");
            }
        } catch (Exception e) {
            logger.error("Error creating vendor_pickup_points table", e);
            throw new RuntimeException("Table creation failed: " + e.getMessage(), e);
        }
    }
}
