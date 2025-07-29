package com.example.shop.dto;

import lombok.Data;

@Data
public class PaymentDto {
    private Long id;
    private Long orderId;
    private Double amount;
    private String method;
    private String status;
}
