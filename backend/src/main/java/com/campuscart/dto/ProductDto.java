package com.campuscart.dto;

import com.campuscart.entity.ConditionGrade;
import com.campuscart.entity.Product;
import com.campuscart.entity.ProductStatus;

import java.math.BigDecimal;
import java.time.Instant;

public class ProductDto {
    private Long id;
    private String title;
    private String description;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private ConditionGrade conditionGrade;
    private ProductStatus status;
    private String campusLocation;
    private String imageUrl;
    private CategoryDto category;
    private UserDto seller;
    private Instant createdAt;
    private Instant updatedAt;
    private boolean isContactRevealed;

    public ProductDto() {}

    public static ProductDto fromEntity(Product product, boolean isContactRevealed) {
        ProductDto dto = new ProductDto();
        dto.setId(product.getId());
        dto.setTitle(product.getTitle());
        dto.setDescription(product.getDescription());
        dto.setPrice(product.getPrice());
        dto.setOriginalPrice(product.getOriginalPrice());
        dto.setConditionGrade(product.getConditionGrade());
        dto.setStatus(product.getStatus());
        dto.setCampusLocation(product.getCampusLocation());
        dto.setImageUrl(product.getImageUrl());
        dto.setCategory(CategoryDto.fromEntity(product.getCategory()));
        dto.setSeller(UserDto.toPublicSeller(product.getSeller()));
        dto.setCreatedAt(product.getCreatedAt());
        dto.setUpdatedAt(product.getUpdatedAt());
        dto.setContactRevealed(isContactRevealed);
        return dto;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public BigDecimal getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(BigDecimal originalPrice) { this.originalPrice = originalPrice; }

    public ConditionGrade getConditionGrade() { return conditionGrade; }
    public void setConditionGrade(ConditionGrade conditionGrade) { this.conditionGrade = conditionGrade; }

    public ProductStatus getStatus() { return status; }
    public void setStatus(ProductStatus status) { this.status = status; }

    public String getCampusLocation() { return campusLocation; }
    public void setCampusLocation(String campusLocation) { this.campusLocation = campusLocation; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public CategoryDto getCategory() { return category; }
    public void setCategory(CategoryDto category) { this.category = category; }

    public UserDto getSeller() { return seller; }
    public void setSeller(UserDto seller) { this.seller = seller; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    public boolean isContactRevealed() { return isContactRevealed; }
    public void setContactRevealed(boolean contactRevealed) { isContactRevealed = contactRevealed; }
}
