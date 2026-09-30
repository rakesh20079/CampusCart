package com.campuscart.service;

import com.campuscart.dto.UserDto;
import com.campuscart.dto.UserUpdateDto;
import com.campuscart.entity.User;
import com.campuscart.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserDto getCurrentUser(User currentUser) {
        return UserDto.fromEntity(currentUser);
    }

    @Transactional
    public UserDto updateProfile(User currentUser, UserUpdateDto dto) {
        if (dto.getFullName() != null && !dto.getFullName().isBlank()) {
            currentUser.setFullName(dto.getFullName());
        }
        if (dto.getPhoneNumber() != null) {
            currentUser.setPhoneNumber(dto.getPhoneNumber());
        }
        if (dto.getWhatsappNumber() != null) {
            currentUser.setWhatsappNumber(dto.getWhatsappNumber());
        }
        if (dto.getCampusName() != null) {
            currentUser.setCampusName(dto.getCampusName());
        }
        if (dto.getDormOrHostel() != null) {
            currentUser.setDormOrHostel(dto.getDormOrHostel());
        }

        User saved = userRepository.save(currentUser);
        return UserDto.fromEntity(saved);
    }
}
