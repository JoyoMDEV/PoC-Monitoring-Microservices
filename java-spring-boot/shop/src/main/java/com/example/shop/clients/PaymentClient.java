package com.example.shop.clients;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import com.example.shop.dto.PaymentCreateDto;
import com.example.shop.dto.PaymentDto;

@FeignClient(name = "payment", url = "${payment.service.url}")
public interface PaymentClient {
    @PostMapping("/payments")
    PaymentDto createPayment(@RequestBody PaymentCreateDto dto);
}