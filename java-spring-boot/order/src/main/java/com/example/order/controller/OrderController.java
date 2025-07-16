package com.example.order.controller;

import com.example.order.dto.OrderCreateDto;
import com.example.order.dto.OrderReadDto;
import com.example.order.model.Order;
import com.example.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
public class OrderController {

    private static final Logger logger = LoggerFactory.getLogger(OrderController.class);
    private final OrderRepository orderRepository;

    @PostMapping
    public ResponseEntity<OrderReadDto> createOrder(@RequestBody OrderCreateDto dto) {
        Order order = new Order();
        order.setProductId(dto.getProductId());
        order.setQuantity(dto.getQuantity());
        order.setTotalPrice(dto.getTotalPrice());
        order.setStatus("pending");

        Order saved = orderRepository.save(order);
        logger.info("order_created: product_id={}, quantity={}, total_price={}", 
            dto.getProductId(), dto.getQuantity(), dto.getTotalPrice());

        OrderReadDto readDto = new OrderReadDto();
        readDto.setId(saved.getId());
        readDto.setProductId(saved.getProductId());
        readDto.setQuantity(saved.getQuantity());
        readDto.setTotalPrice(saved.getTotalPrice());
        readDto.setStatus(saved.getStatus());

        return ResponseEntity.ok(readDto);
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderReadDto> getOrder(@PathVariable Long id) {
        Optional<Order> orderOpt = orderRepository.findById(id);
        if (orderOpt.isPresent()) {
            Order order = orderOpt.get();
            logger.info("order_retrieved: id={}", id);

            OrderReadDto readDto = new OrderReadDto();
            readDto.setId(order.getId());
            readDto.setProductId(order.getProductId());
            readDto.setQuantity(order.getQuantity());
            readDto.setTotalPrice(order.getTotalPrice());
            readDto.setStatus(order.getStatus());

            return ResponseEntity.ok(readDto);
        } else {
            logger.warn("order_not_found: id={}", id);
            return ResponseEntity.notFound().build();
        }
    }
}
