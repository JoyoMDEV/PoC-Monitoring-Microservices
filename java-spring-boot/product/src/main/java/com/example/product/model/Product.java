package com.example.product.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "products")
@Data // erzeugt Getter/Setter/ToString usw.
@NoArgsConstructor
@AllArgsConstructor
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private Double price;
}
