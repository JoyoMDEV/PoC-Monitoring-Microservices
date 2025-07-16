package com.example.shop.clients;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import com.example.shop.dto.ProductDto;

@FeignClient(name = "product", url = "${product.service.url}")
public interface ProductClient {
    @GetMapping("/products/{id}")
    ProductDto getProduct(@PathVariable("id") Long id);
}