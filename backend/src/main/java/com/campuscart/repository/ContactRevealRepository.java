package com.campuscart.repository;

import com.campuscart.entity.ContactReveal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ContactRevealRepository extends JpaRepository<ContactReveal, Long> {
    Optional<ContactReveal> findByProductIdAndBuyerId(Long productId, Long buyerId);
    boolean existsByProductIdAndBuyerId(Long productId, Long buyerId);
    long countByProductId(Long productId);
}
