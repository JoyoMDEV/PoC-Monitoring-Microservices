package com.example.shop.dto;

import lombok.Data;

@Data
public class ShopPurchaseRequest {
    private Long productId;
    private Integer quantity;
    private String paymentMethod = "credit_card";
}
