package com.example.order.dto;

import lombok.Data;

@Data
public class OrderReadDto {
    private Long id;
    private Long productId;
    private Integer quantity;
    private Double totalPrice;
    private String status;
}