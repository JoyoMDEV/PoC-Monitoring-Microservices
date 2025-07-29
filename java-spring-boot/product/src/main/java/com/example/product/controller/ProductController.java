package com.example.product.controller;

import com.example.product.dto.ProductCreateDto;
import com.example.product.dto.ProductReadDto;
import com.example.product.model.Product;
import com.example.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequiredArgsConstructor
@RequestMapping("/products")
public class ProductController {

    private static final Logger logger = LoggerFactory.getLogger(ProductController.class);
    private final ProductRepository productRepository;

    @PostMapping
    public ResponseEntity<ProductReadDto> createProduct(@RequestBody ProductCreateDto dto) {
        Product product = new Product();
        product.setName(dto.getName());
        product.setPrice(dto.getPrice());

        Product saved = productRepository.save(product);
        logger.info("product_created: name={}, price={}", dto.getName(), dto.getPrice());

        ProductReadDto readDto = new ProductReadDto();
        readDto.setId(saved.getId());
        readDto.setName(saved.getName());
        readDto.setPrice(saved.getPrice());
        return ResponseEntity.ok(readDto);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductReadDto> getProduct(@PathVariable Long id) {
        Optional<Product> productOpt = productRepository.findById(id);
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            logger.info("product_retrieved: id={}", id);
            ProductReadDto readDto = new ProductReadDto();
            readDto.setId(product.getId());
            readDto.setName(product.getName());
            readDto.setPrice(product.getPrice());
            return ResponseEntity.ok(readDto);
        } else {
            logger.warn("product_not_found: id={}", id);
            return ResponseEntity.notFound().build();
        }
    }
}
