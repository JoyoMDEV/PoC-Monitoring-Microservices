package com.example.shop.dto;

import lombok.Data;
import com.fasterxml.jackson.annotation.JsonProperty;;

@Data
public class ShopPurchaseRequest {
    @JsonProperty("product_id")
    private Long productId;
    private Integer quantity;
    @JsonProperty("payment_method")
    private String paymentMethod = "credit_card";
}
