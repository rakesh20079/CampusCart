package com.campuscart.controller;

import com.campuscart.dto.AuthResponse;
import com.campuscart.dto.DevLoginRequest;
import com.campuscart.dto.GoogleAuthRequest;
import com.campuscart.dto.RefreshTokenRequest;
import com.campuscart.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@Valid @RequestBody GoogleAuthRequest request) {
        AuthResponse response = authService.processGoogleLogin(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/dev-login")
    public ResponseEntity<AuthResponse> devLogin(@Valid @RequestBody DevLoginRequest request) {
        AuthResponse response = authService.processDevLogin(request);
        return ResponseEntity.ok(response);
    }
}
