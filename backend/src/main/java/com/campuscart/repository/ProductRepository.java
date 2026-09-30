package com.campuscart.repository;

import com.campuscart.entity.Product;
import com.campuscart.entity.ProductStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    @EntityGraph(attributePaths = {"seller", "category"})
    @Query(value = "SELECT p FROM Product p WHERE " +
           "(:status IS NULL OR p.status = :status) AND " +
           "(:categoryId IS NULL OR p.category.id = :categoryId) AND " +
           "(:query IS NULL OR :query = '' OR LOWER(p.title) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :query, '%'))) AND " +
           "(:campus IS NULL OR :campus = '' OR LOWER(p.campusLocation) LIKE LOWER(CONCAT('%', :campus, '%')) OR (p.seller.campusName IS NOT NULL AND LOWER(p.seller.campusName) LIKE LOWER(CONCAT('%', :campus, '%'))))",
           countQuery = "SELECT count(p) FROM Product p WHERE " +
           "(:status IS NULL OR p.status = :status) AND " +
           "(:categoryId IS NULL OR p.category.id = :categoryId) AND " +
           "(:query IS NULL OR :query = '' OR LOWER(p.title) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :query, '%'))) AND " +
           "(:campus IS NULL OR :campus = '' OR LOWER(p.campusLocation) LIKE LOWER(CONCAT('%', :campus, '%')) OR (p.seller.campusName IS NOT NULL AND LOWER(p.seller.campusName) LIKE LOWER(CONCAT('%', :campus, '%'))))")
    Page<Product> findFiltered(
            @Param("status") ProductStatus status,
            @Param("categoryId") Long categoryId,
            @Param("query") String query,
            @Param("campus") String campus,
            Pageable pageable
    );

    @EntityGraph(attributePaths = {"seller", "category"})
    @Query("SELECT p FROM Product p WHERE p.seller.id = :sellerId ORDER BY p.createdAt DESC")
    List<Product> findBySellerIdOrderByCreatedAtDesc(@Param("sellerId") Long sellerId);
}
