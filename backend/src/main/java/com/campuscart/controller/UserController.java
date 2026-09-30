package com.campuscart.controller;

import com.campuscart.dto.UserDto;
import com.campuscart.dto.UserUpdateDto;
import com.campuscart.entity.User;
import com.campuscart.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public ResponseEntity<UserDto> getCurrentUser(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(userService.getCurrentUser(currentUser));
    }

    @PutMapping("/me")
    public ResponseEntity<UserDto> updateProfile(
            @RequestBody UserUpdateDto dto,
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(userService.updateProfile(currentUser, dto));
    }
}
