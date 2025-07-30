package com.example.shop.dto;

import lombok.Data;

@Data
public class ProductCreateRequest {
    private String name;
    private Double price;
}
