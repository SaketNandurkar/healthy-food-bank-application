package order_service.dto;

import lombok.Data;

@Data
public class PickupPointDTO {
    private Long id;
    private String name;
    private String address;
}
