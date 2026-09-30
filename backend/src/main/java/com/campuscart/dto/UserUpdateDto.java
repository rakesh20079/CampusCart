package com.campuscart.dto;

public class UserUpdateDto {
    private String fullName;
    private String phoneNumber;
    private String whatsappNumber;
    private String campusName;
    private String dormOrHostel;

    public UserUpdateDto() {}

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getWhatsappNumber() { return whatsappNumber; }
    public void setWhatsappNumber(String whatsappNumber) { this.whatsappNumber = whatsappNumber; }

    public String getCampusName() { return campusName; }
    public void setCampusName(String campusName) { this.campusName = campusName; }

    public String getDormOrHostel() { return dormOrHostel; }
    public void setDormOrHostel(String dormOrHostel) { this.dormOrHostel = dormOrHostel; }
}
