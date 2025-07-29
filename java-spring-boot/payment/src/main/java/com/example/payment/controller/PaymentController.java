package com.example.payment.controller;

import com.example.payment.dto.PaymentCreateDto;
import com.example.payment.dto.PaymentReadDto;
import com.example.payment.model.Payment;
import com.example.payment.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/payments")
@RequiredArgsConstructor
public class PaymentController {

    private static final Logger logger = LoggerFactory.getLogger(PaymentController.class);
    private final PaymentRepository paymentRepository;

    @PostMapping
    public ResponseEntity<PaymentReadDto> createPayment(@RequestBody PaymentCreateDto dto) {
        Payment payment = new Payment();
        payment.setOrderId(dto.getOrderId());
        payment.setAmount(dto.getAmount());
        payment.setMethod(dto.getMethod());
        payment.setStatus("pending");

        Payment saved = paymentRepository.save(payment);
        logger.info("payment_created: order_id={}, amount={}, method={}", 
            dto.getOrderId(), dto.getAmount(), dto.getMethod());

        PaymentReadDto readDto = new PaymentReadDto();
        readDto.setId(saved.getId());
        readDto.setOrderId(saved.getOrderId());
        readDto.setAmount(saved.getAmount());
        readDto.setMethod(saved.getMethod());
        readDto.setStatus(saved.getStatus());

        return ResponseEntity.ok(readDto);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentReadDto> getPayment(@PathVariable Long id) {
        Optional<Payment> paymentOpt = paymentRepository.findById(id);
        if (paymentOpt.isPresent()) {
            Payment payment = paymentOpt.get();
            logger.info("payment_retrieved: id={}", id);

            PaymentReadDto readDto = new PaymentReadDto();
            readDto.setId(payment.getId());
            readDto.setOrderId(payment.getOrderId());
            readDto.setAmount(payment.getAmount());
            readDto.setMethod(payment.getMethod());
            readDto.setStatus(payment.getStatus());

            return ResponseEntity.ok(readDto);
        } else {
            logger.warn("payment_not_found: id={}", id);
            return ResponseEntity.notFound().build();
        }
    }
}
