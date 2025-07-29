package com.example.shop.dto;

import lombok.Data;

@Data
public class OrderDto {
    private Long id;
    private Long productId;
    private Integer quantity;
    private Double totalPrice;
    private String status;
}
