package com.example.payment.dto;

import lombok.Data;

@Data
public class PaymentReadDto {
    private Long id;
    private Long orderId;
    private Double amount;
    private String method;
    private String status;
}