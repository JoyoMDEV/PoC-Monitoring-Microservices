package com.example.shop.dto;

import lombok.Data;

@Data
public class OrderCreateDto {
    private Long productId;
    private Integer quantity;
    private Double totalPrice;
}
