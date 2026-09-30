package com.campuscart.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "contact_reveals", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"product_id", "buyer_id"})
})
public class ContactReveal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id", nullable = false)
    private User buyer;

    @Column(name = "revealed_at", nullable = false)
    private Instant revealedAt = Instant.now();

    public ContactReveal() {}

    public ContactReveal(Product product, User buyer) {
        this.product = product;
        this.buyer = buyer;
        this.revealedAt = Instant.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public User getBuyer() { return buyer; }
    public void setBuyer(User buyer) { this.buyer = buyer; }

    public Instant getRevealedAt() { return revealedAt; }
    public void setRevealedAt(Instant revealedAt) { this.revealedAt = revealedAt; }
}
