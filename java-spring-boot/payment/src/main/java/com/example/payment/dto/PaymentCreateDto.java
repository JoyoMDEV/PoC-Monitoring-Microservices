package com.example.payment.dto;

import lombok.Data;

@Data
public class PaymentCreateDto {
    private Long orderId;
    private Double amount;
    private String method;
}