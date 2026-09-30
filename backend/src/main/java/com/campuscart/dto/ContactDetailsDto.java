package com.campuscart.dto;

import java.time.Instant;

public class ContactDetailsDto {
    private Long productId;
    private String productTitle;
    private String sellerName;
    private String sellerEmail;
    private String sellerPhone;
    private String sellerWhatsapp;
    private String campusLocation;
    private String safetyTip;
    private Instant revealedAt;

    public ContactDetailsDto() {}

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getProductTitle() { return productTitle; }
    public void setProductTitle(String productTitle) { this.productTitle = productTitle; }

    public String getSellerName() { return sellerName; }
    public void setSellerName(String sellerName) { this.sellerName = sellerName; }

    public String getSellerEmail() { return sellerEmail; }
    public void setSellerEmail(String sellerEmail) { this.sellerEmail = sellerEmail; }

    public String getSellerPhone() { return sellerPhone; }
    public void setSellerPhone(String sellerPhone) { this.sellerPhone = sellerPhone; }

    public String getSellerWhatsapp() { return sellerWhatsapp; }
    public void setSellerWhatsapp(String sellerWhatsapp) { this.sellerWhatsapp = sellerWhatsapp; }

    public String getCampusLocation() { return campusLocation; }
    public void setCampusLocation(String campusLocation) { this.campusLocation = campusLocation; }

    public String getSafetyTip() { return safetyTip; }
    public void setSafetyTip(String safetyTip) { this.safetyTip = safetyTip; }

    public Instant getRevealedAt() { return revealedAt; }
    public void setRevealedAt(Instant revealedAt) { this.revealedAt = revealedAt; }
}
