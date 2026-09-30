package com.campuscart.controller;

import com.campuscart.dto.ContactDetailsDto;
import com.campuscart.dto.ProductCreateDto;
import com.campuscart.dto.ProductDto;
import com.campuscart.entity.ProductStatus;
import com.campuscart.entity.User;
import com.campuscart.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public ResponseEntity<Page<ProductDto>> getProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt,desc") String sort,
            @RequestParam(required = false) ProductStatus status,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String campus,
            @AuthenticationPrincipal User currentUser
    ) {
        String[] sortParts = sort.split(",");
        Sort.Direction direction = sortParts.length > 1 && sortParts[1].equalsIgnoreCase("asc") ?
                Sort.Direction.ASC : Sort.Direction.DESC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortParts[0]));

        Page<ProductDto> products = productService.getProducts(pageable, status, categoryId, query, campus, currentUser);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductDto> getProduct(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        ProductDto product = productService.getProductById(id, currentUser);
        return ResponseEntity.ok(product);
    }

    @PostMapping
    public ResponseEntity<ProductDto> createProduct(
            @Valid @RequestBody ProductCreateDto dto,
            @AuthenticationPrincipal User currentUser
    ) {
        ProductDto created = productService.createProduct(dto, currentUser);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductDto> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody ProductCreateDto dto,
            @AuthenticationPrincipal User currentUser
    ) {
        ProductDto updated = productService.updateProduct(id, dto, currentUser);
        return ResponseEntity.ok(updated);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<ProductDto> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> statusBody,
            @AuthenticationPrincipal User currentUser
    ) {
        String statusStr = statusBody.get("status");
        ProductStatus status = ProductStatus.valueOf(statusStr.toUpperCase());
        ProductDto updated = productService.updateStatus(id, status, currentUser);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        productService.deleteProduct(id, currentUser);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/my-listings")
    public ResponseEntity<List<ProductDto>> getMyListings(@AuthenticationPrincipal User currentUser) {
        List<ProductDto> listings = productService.getMyListings(currentUser);
        return ResponseEntity.ok(listings);
    }

    @PostMapping("/{id}/reveal-contact")
    public ResponseEntity<ContactDetailsDto> revealContact(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        ContactDetailsDto contactDetails = productService.revealContact(id, currentUser);
        return ResponseEntity.ok(contactDetails);
    }
}
