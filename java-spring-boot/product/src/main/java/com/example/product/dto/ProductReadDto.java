package com.example.product.dto;

import lombok.Data;

@Data
public class ProductReadDto {
    private Long id;
    private String name;
    private Double price;
}
