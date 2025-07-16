package com.example.shop.clients;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import com.example.shop.dto.OrderCreateDto;
import com.example.shop.dto.OrderDto;

@FeignClient(name = "order", url = "${order.service.url}")
public interface OrderClient {
    @PostMapping("/orders")
    OrderDto createOrder(@RequestBody OrderCreateDto dto);
}