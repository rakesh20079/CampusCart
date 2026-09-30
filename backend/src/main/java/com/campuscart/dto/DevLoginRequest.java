package com.campuscart.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class DevLoginRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Full name is required")
    private String fullName;

    private String campusName;

    public DevLoginRequest() {}

    public DevLoginRequest(String email, String fullName, String campusName) {
        this.email = email;
        this.fullName = fullName;
        this.campusName = campusName;
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getCampusName() { return campusName; }
    public void setCampusName(String campusName) { this.campusName = campusName; }
}
