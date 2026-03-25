package order_service.service;

import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import order_service.entity.Order;
import order_service.repository.OrderRepository;

import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class DeliverySheetService {

    private static final Logger logger = LoggerFactory.getLogger(DeliverySheetService.class);

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private VendorService vendorService;

    /**
     * Generate a PDF delivery sheet for a vendor's scheduled orders on a specific date
     * @param vendorId The vendor ID
     * @param deliveryDate The delivery date (format: YYYY-MM-DD)
     * @return PDF as byte array
     */
    public byte[] generateDeliverySheet(String vendorId, String deliveryDate) throws Exception {
        try {
            logger.info("Generating delivery sheet for vendor: {} on date: {}", vendorId, deliveryDate);

            // Get all scheduled orders for this vendor
            List<Order> scheduledOrders = orderRepository.findByVendorIdAndOrderStatus(vendorId, "SCHEDULED");

            if (scheduledOrders.isEmpty()) {
                logger.warn("No scheduled orders found for vendor: {}", vendorId);
                throw new RuntimeException("No scheduled orders found for this vendor");
            }

            // Get vendor name
            String vendorName = vendorService.getVendorNameByVendorId(vendorId);
            if (vendorName == null) {
                vendorName = "Vendor " + vendorId;
            }

            // Filter orders by delivery date if provided
            // Note: For MVP, we're showing all scheduled orders
            // In production, you'd filter by the product's deliverySchedule matching the date

            // Create PDF in memory
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            PdfWriter writer = new PdfWriter(baos);
            PdfDocument pdfDoc = new PdfDocument(writer);
            Document document = new Document(pdfDoc);

            // Add title
            Paragraph title = new Paragraph("DELIVERY SHEET")
                    .setFontSize(20)
                    .setBold()
                    .setTextAlignment(TextAlignment.CENTER)
                    .setMarginBottom(10);
            document.add(title);

            // Add vendor info
            Paragraph vendorInfo = new Paragraph("Vendor: " + vendorName)
                    .setFontSize(14)
                    .setBold()
                    .setMarginBottom(5);
            document.add(vendorInfo);

            // Add delivery date
            Paragraph dateInfo = new Paragraph("Delivery Date: " + deliveryDate)
                    .setFontSize(12)
                    .setMarginBottom(15);
            document.add(dateInfo);

            // Create table with customer details and orders
            float[] columnWidths = {1, 2, 2, 3, 2, 2, 2};
            Table table = new Table(UnitValue.createPercentArray(columnWidths));
            table.setWidth(UnitValue.createPercentValue(100));

            // Add table headers
            addTableHeader(table, "Order ID");
            addTableHeader(table, "Customer Name");
            addTableHeader(table, "Phone");
            addTableHeader(table, "Pickup Point");
            addTableHeader(table, "Product");
            addTableHeader(table, "Quantity");
            addTableHeader(table, "Price");

            // Add order data
            double totalAmount = 0;
            for (Order order : scheduledOrders) {
                table.addCell(new Cell().add(new Paragraph(String.valueOf(order.getId()))));
                table.addCell(new Cell().add(new Paragraph(order.getCustomerName() != null ? order.getCustomerName() : "N/A")));
                table.addCell(new Cell().add(new Paragraph(order.getCustomerPhone() != null ? order.getCustomerPhone() : "N/A")));
                table.addCell(new Cell().add(new Paragraph(order.getCustomerPickupPoint() != null ? order.getCustomerPickupPoint() : "N/A")));
                table.addCell(new Cell().add(new Paragraph(order.getProductName() != null ? order.getProductName() : order.getOrderName())));
                table.addCell(new Cell().add(new Paragraph(order.getOrderQuantity() + " " + order.getOrderUnit())));
                table.addCell(new Cell().add(new Paragraph("₹" + String.format("%.2f", order.getOrderPrice()))));
                totalAmount += order.getOrderPrice();
            }

            // Add total row
            Cell totalLabelCell = new Cell(1, 6)
                    .add(new Paragraph("TOTAL"))
                    .setBold()
                    .setBackgroundColor(ColorConstants.LIGHT_GRAY)
                    .setTextAlignment(TextAlignment.RIGHT);
            table.addCell(totalLabelCell);

            Cell totalAmountCell = new Cell()
                    .add(new Paragraph("₹" + String.format("%.2f", totalAmount)))
                    .setBold()
                    .setBackgroundColor(ColorConstants.LIGHT_GRAY);
            table.addCell(totalAmountCell);

            document.add(table);

            // Add footer
            Paragraph footer = new Paragraph("\nTotal Orders: " + scheduledOrders.size())
                    .setFontSize(12)
                    .setBold()
                    .setMarginTop(15);
            document.add(footer);

            Paragraph generatedDate = new Paragraph("Generated on: " + LocalDate.now().format(DateTimeFormatter.ofPattern("dd-MM-yyyy")))
                    .setFontSize(10)
                    .setMarginTop(10)
                    .setItalic();
            document.add(generatedDate);

            // Close document
            document.close();

            logger.info("Successfully generated delivery sheet for vendor: {} with {} orders", vendorId, scheduledOrders.size());

            return baos.toByteArray();
        } catch (Exception e) {
            logger.error("Error generating delivery sheet for vendor: {}, date: {}", vendorId, deliveryDate, e);
            throw new Exception("Failed to generate delivery sheet: " + e.getMessage(), e);
        }
    }

    private void addTableHeader(Table table, String headerText) {
        Cell headerCell = new Cell()
                .add(new Paragraph(headerText))
                .setBold()
                .setBackgroundColor(ColorConstants.LIGHT_GRAY)
                .setTextAlignment(TextAlignment.CENTER);
        table.addHeaderCell(headerCell);
    }

    /**
     * Get unique delivery dates from scheduled orders for a vendor
     * @param vendorId The vendor ID
     * @return List of delivery dates
     */
    public List<String> getDeliveryDates(String vendorId) {
        try {
            List<Order> scheduledOrders = orderRepository.findByVendorIdAndOrderStatus(vendorId, "SCHEDULED");

            // For MVP, we'll return the next Saturday and Sunday
            // In production, this would be based on product delivery schedules
            Set<String> dates = new HashSet<>();
            LocalDate today = LocalDate.now();

            // Find next Saturday
            LocalDate nextSaturday = today;
            while (nextSaturday.getDayOfWeek().getValue() != 6) { // 6 = Saturday
                nextSaturday = nextSaturday.plusDays(1);
            }
            dates.add(nextSaturday.format(DateTimeFormatter.ISO_LOCAL_DATE));

            // Find next Sunday
            LocalDate nextSunday = today;
            while (nextSunday.getDayOfWeek().getValue() != 7) { // 7 = Sunday
                nextSunday = nextSunday.plusDays(1);
            }
            dates.add(nextSunday.format(DateTimeFormatter.ISO_LOCAL_DATE));

            return new ArrayList<>(dates).stream().sorted().collect(Collectors.toList());
        } catch (Exception e) {
            logger.error("Error getting delivery dates for vendor: {}", vendorId, e);
            return new ArrayList<>();
        }
    }
}
