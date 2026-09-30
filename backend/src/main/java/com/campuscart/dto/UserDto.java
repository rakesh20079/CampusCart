package com.campuscart.dto;

import com.campuscart.entity.Role;
import com.campuscart.entity.User;

public class UserDto {
    private Long id;
    private String email;
    private String fullName;
    private String avatarUrl;
    private String phoneNumber;
    private String whatsappNumber;
    private String campusName;
    private String dormOrHostel;
    private Role role;
    private boolean verified;

    public UserDto() {}

    public static UserDto fromEntity(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setFullName(user.getFullName());
        dto.setAvatarUrl(user.getAvatarUrl());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setWhatsappNumber(user.getWhatsappNumber());
        dto.setCampusName(user.getCampusName());
        dto.setDormOrHostel(user.getDormOrHostel());
        dto.setRole(user.getRole());
        dto.setVerified(user.isVerified());
        return dto;
    }

    public static UserDto toPublicSeller(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setFullName(user.getFullName());
        dto.setAvatarUrl(user.getAvatarUrl());
        dto.setCampusName(user.getCampusName());
        dto.setRole(user.getRole());
        dto.setVerified(user.isVerified());
        return dto;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getWhatsappNumber() { return whatsappNumber; }
    public void setWhatsappNumber(String whatsappNumber) { this.whatsappNumber = whatsappNumber; }

    public String getCampusName() { return campusName; }
    public void setCampusName(String campusName) { this.campusName = campusName; }

    public String getDormOrHostel() { return dormOrHostel; }
    public void setDormOrHostel(String dormOrHostel) { this.dormOrHostel = dormOrHostel; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }
}
