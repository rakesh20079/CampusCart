package com.campuscart.service;

import com.campuscart.dto.ContactDetailsDto;
import com.campuscart.dto.ProductCreateDto;
import com.campuscart.dto.ProductDto;
import com.campuscart.entity.*;
import com.campuscart.repository.CategoryRepository;
import com.campuscart.repository.ContactRevealRepository;
import com.campuscart.repository.ProductRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ContactRevealRepository contactRevealRepository;

    public ProductService(
            ProductRepository productRepository,
            CategoryRepository categoryRepository,
            ContactRevealRepository contactRevealRepository) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.contactRevealRepository = contactRevealRepository;
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getProducts(
            Pageable pageable,
            ProductStatus status,
            Long categoryId,
            String query,
            String campus,
            User currentUser) {
        Page<Product> page = productRepository.findFiltered(status, categoryId, query, campus, pageable);
        return page.map(p -> {
            boolean isRevealed = false;
            if (currentUser != null) {
                isRevealed = p.getSeller().getId().equals(currentUser.getId()) ||
                        contactRevealRepository.existsByProductIdAndBuyerId(p.getId(), currentUser.getId());
            }
            return ProductDto.fromEntity(p, isRevealed);
        });
    }

    @Transactional(readOnly = true)
    public ProductDto getProductById(Long id, User currentUser) {
        Product product = productRepository.findById(id)
                .orElseThrow(
                        () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found with id: " + id));

        boolean isRevealed = false;
        if (currentUser != null) {
            isRevealed = product.getSeller().getId().equals(currentUser.getId()) ||
                    contactRevealRepository.existsByProductIdAndBuyerId(product.getId(), currentUser.getId());
        }
        return ProductDto.fromEntity(product, isRevealed);
    }

    @Transactional
    public ProductDto createProduct(ProductCreateDto dto, User seller) {
        Category category = categoryRepository.findById(dto.getCategoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "Invalid category ID: " + dto.getCategoryId()));

        Product product = new Product();
        product.setTitle(dto.getTitle());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setOriginalPrice(dto.getOriginalPrice());
        product.setConditionGrade(dto.getConditionGrade());
        product.setStatus(ProductStatus.AVAILABLE);
        product.setCampusLocation(dto.getCampusLocation());
        // Default to seller's profile phone/whatsapp if not explicitly specified
        product.setContactPhone(
                dto.getContactPhone() != null && !dto.getContactPhone().isBlank() ? dto.getContactPhone()
                        : seller.getPhoneNumber());
        product.setContactWhatsapp(
                dto.getContactWhatsapp() != null && !dto.getContactWhatsapp().isBlank() ? dto.getContactWhatsapp()
                        : seller.getWhatsappNumber());
        product.setImageUrl(dto.getImageUrl());
        product.setCategory(category);
        product.setSeller(seller);

        Product saved = productRepository.save(product);
        return ProductDto.fromEntity(saved, true);
    }

    @Transactional
    public ProductDto updateProduct(Long id, ProductCreateDto dto, User currentUser) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));

        if (!product.getSeller().getId().equals(currentUser.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not authorized to update this listing");
        }

        Category category = categoryRepository.findById(dto.getCategoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid category ID"));

        product.setTitle(dto.getTitle());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setOriginalPrice(dto.getOriginalPrice());
        product.setConditionGrade(dto.getConditionGrade());
        product.setCampusLocation(dto.getCampusLocation());
        product.setContactPhone(dto.getContactPhone());
        product.setContactWhatsapp(dto.getContactWhatsapp());
        product.setImageUrl(dto.getImageUrl());
        product.setCategory(category);

        Product updated = productRepository.save(product);
        return ProductDto.fromEntity(updated, true);
    }

    @Transactional
    public ProductDto updateStatus(Long id, ProductStatus newStatus, User currentUser) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));

        if (!product.getSeller().getId().equals(currentUser.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "You are not authorized to change status of this listing");
        }

        product.setStatus(newStatus);
        Product updated = productRepository.save(product);
        return ProductDto.fromEntity(updated, true);
    }

    @Transactional
    public void deleteProduct(Long id, User currentUser) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));

        if (!product.getSeller().getId().equals(currentUser.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not authorized to delete this listing");
        }

        productRepository.delete(product);
    }

    public List<ProductDto> getMyListings(User currentUser) {
        List<Product> products = productRepository.findBySellerIdOrderByCreatedAtDesc(currentUser.getId());
        return products.stream()
                .map(p -> ProductDto.fromEntity(p, true))
                .collect(Collectors.toList());
    }

    @Transactional
    public ContactDetailsDto revealContact(Long productId, User buyer) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));

        // If the buyer is not the seller and hasn't revealed yet, record the reveal
        // interest
        if (!product.getSeller().getId().equals(buyer.getId())) {
            if (!contactRevealRepository.existsByProductIdAndBuyerId(productId, buyer.getId())) {
                ContactReveal reveal = new ContactReveal(product, buyer);
                contactRevealRepository.save(reveal);
            }
        }

        User seller = product.getSeller();
        ContactDetailsDto dto = new ContactDetailsDto();
        dto.setProductId(product.getId());
        dto.setProductTitle(product.getTitle());
        dto.setSellerName(seller.getFullName());
        dto.setSellerEmail(seller.getEmail());
        dto.setSellerPhone(null);
        dto.setSellerWhatsapp(null);
        dto.setCampusLocation(null);
        dto.setSafetyTip(
                "Contact the seller directly via email to coordinate the purchase and agree on a campus meetup spot.");
        dto.setRevealedAt(Instant.now());

        return dto;
    }
}
