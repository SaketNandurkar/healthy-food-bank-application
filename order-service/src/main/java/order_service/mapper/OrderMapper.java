package order_service.mapper;

import order_service.dto.OrderDTO;
import order_service.entity.Order;

public class OrderMapper {

    public static OrderDTO toDTO(Order order) {
        if (order == null) {
            return null;
        }

        return new OrderDTO(
                order.getId(),
                order.getOrderName(),
                order.getOrderQuantity(),
                order.getOrderUnit(),
                order.getOrderPrice(),
                order.getOrderPlacedDate(),
                order.getOrderDeliveredDate(),
                order.getCustomerId(),
                order.getOrderStatus(),
                order.getProductId(),
                order.getVendorId(),
                order.getVendorName(),
                order.getProductName(),
                order.getCustomerName(),
                order.getCustomerPhone(),
                order.getCustomerPickupPoint()
        );
    }

    public static Order toEntity(OrderDTO orderDTO) {
        if (orderDTO == null) {
            return null;
        }

        Order order = new Order();
        order.setId(orderDTO.getId());
        order.setOrderName(orderDTO.getOrderName());
        order.setOrderQuantity(orderDTO.getOrderQuantity());
        order.setOrderUnit(orderDTO.getOrderUnit());
        order.setOrderPrice(orderDTO.getOrderPrice());
        order.setOrderPlacedDate(orderDTO.getOrderPlacedDate());
        order.setOrderDeliveredDate(orderDTO.getOrderDeliveredDate());
        order.setCustomerId(orderDTO.getCustomerId());
        order.setOrderStatus(orderDTO.getOrderStatus());
        order.setProductId(orderDTO.getProductId());
        order.setVendorId(orderDTO.getVendorId());
        order.setVendorName(orderDTO.getVendorName());
        order.setProductName(orderDTO.getProductName());
        order.setCustomerName(orderDTO.getCustomerName());
        order.setCustomerPhone(orderDTO.getCustomerPhone());
        order.setCustomerPickupPoint(orderDTO.getCustomerPickupPoint());
        return order;
    }
}