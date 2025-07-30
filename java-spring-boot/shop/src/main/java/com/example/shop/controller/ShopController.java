package com.example.shop.controller;

import com.example.shop.clients.ProductClient;
import com.example.shop.clients.OrderClient;
import com.example.shop.clients.PaymentClient;
import com.example.shop.dto.*;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/shop")
@RequiredArgsConstructor
public class ShopController {

    private final ProductClient productClient;
    private final OrderClient orderClient;
    private final PaymentClient paymentClient;
    private static final Logger logger = LoggerFactory.getLogger(ShopController.class);

    @PostMapping("/products")
    public ResponseEntity<?> create_product(@RequestBody ProductCreateRequest req) {
        try {
            ProductDto product = productClient.createProduct(req.getName(), req.getPrice());
            if (product == null) {
                logger.error("Product Creation failed");
                return ResponseEntity.status(404).body(Map.of("error", "Product Creation failed"));
            }
            Long product_id = product.getId();
            logger.info("Created Product", product);
            return ResponseEntity.ok(Map.of(
                    "id", product_id));
        } catch (Exception e) {
            logger.error("shop_purchase_failed", e);
            return ResponseEntity.status(500).body(Map.of("error", "Shop purchase failed"));
        }
    }

    @PostMapping("/purchase")
    public ResponseEntity<?> purchase(@RequestBody ShopPurchaseRequest req) {
        try {
            // 0. Validierung
            try {
                if (req.getProductId() == null) {
                    return ResponseEntity.badRequest().body(Map.of("error", "Product ID is required"));
                }
                if (req.getQuantity() <= 0) {
                    return ResponseEntity.badRequest().body(Map.of("error", "Quantity must be greater than 0"));
                }
            } finally {
            }
            // 1. Produktdaten holen
            ProductDto product = productClient.getProduct(req.getProductId());
            if (product == null) {
                return ResponseEntity.status(404).body(Map.of("error", "Prddduct not found"));
            }
            double totalPrice = product.getPrice() * req.getQuantity();

            // 2. Order anlegen
            OrderCreateDto orderReq = new OrderCreateDto();
            orderReq.setProductId(req.getProductId());
            orderReq.setQuantity(req.getQuantity());
            orderReq.setTotalPrice(totalPrice);
            OrderDto order = orderClient.createOrder(orderReq);

            // 3. Payment auslösen
            PaymentCreateDto paymentReq = new PaymentCreateDto();
            paymentReq.setOrderId(order.getId());
            paymentReq.setAmount(totalPrice);
            paymentReq.setMethod(req.getPaymentMethod());
            PaymentDto payment = paymentClient.createPayment(paymentReq);

            logger.info("purchase_success: orderId={}, paymentId={}", order.getId(), payment.getId());

            return ResponseEntity.ok(Map.of(
                    "order", order,
                    "payment", payment,
                    "product", product));
        } catch (Exception e) {
            logger.error("shop_purchase_failed", e);
            return ResponseEntity.status(500).body(Map.of("error", "Shop purchase failed"));
        }
    }
}
