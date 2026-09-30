package com.campuscart.service;

import com.campuscart.dto.*;
import com.campuscart.entity.RefreshToken;
import com.campuscart.entity.Role;
import com.campuscart.entity.User;
import com.campuscart.repository.RefreshTokenRepository;
import com.campuscart.repository.UserRepository;
import com.campuscart.security.GoogleTokenVerifierService;
import com.campuscart.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtTokenProvider tokenProvider;
    private final GoogleTokenVerifierService googleTokenVerifierService;

    @Value("${app.security.allow-dev-login:true}")
    private boolean allowDevLogin;

    public AuthService(
            UserRepository userRepository,
            RefreshTokenRepository refreshTokenRepository,
            JwtTokenProvider tokenProvider,
            GoogleTokenVerifierService googleTokenVerifierService
    ) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.tokenProvider = tokenProvider;
        this.googleTokenVerifierService = googleTokenVerifierService;
    }

    @Transactional
    public AuthResponse processGoogleLogin(GoogleAuthRequest request) {
        GoogleTokenVerifierService.GoogleStudentInfo studentInfo =
                googleTokenVerifierService.verifyToken(request.getIdToken());

        if (studentInfo == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid Google ID token");
        }

        User user = userRepository.findByEmail(studentInfo.getEmail())
                .orElseGet(() -> {
                    User newUser = new User(
                            studentInfo.getEmail(),
                            studentInfo.getName(),
                            studentInfo.getPictureUrl(),
                            studentInfo.getRole(),
                            studentInfo.isVerifiedStudent()
                    );
                    return userRepository.save(newUser);
                });

        // Update verification status & role if student domain newly matched
        if (studentInfo.isVerifiedStudent() && !user.isVerified()) {
            user.setRole(Role.ROLE_VERIFIED_STUDENT);
            user.setVerified(true);
            user = userRepository.save(user);
        }

        return generateAuthResponse(user);
    }

    @Transactional
    public AuthResponse processDevLogin(DevLoginRequest request) {
        if (!allowDevLogin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Dev login is disabled in this environment");
        }

        Role role = Role.ROLE_VERIFIED_STUDENT;
        boolean isVerified = true;

        User user = userRepository.findByEmail(request.getEmail())
                .orElseGet(() -> {
                    User newUser = new User(
                            request.getEmail(),
                            request.getFullName(),
                            null,
                            role,
                            isVerified
                    );
                    if (request.getCampusName() != null) {
                        newUser.setCampusName(request.getCampusName());
                    }
                    return userRepository.save(newUser);
                });

        return generateAuthResponse(user);
    }

    @Transactional
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(request.getRefreshToken())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token not found"));

        if (refreshToken.getExpiryDate().isBefore(Instant.now())) {
            refreshTokenRepository.delete(refreshToken);
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token has expired. Please log in again");
        }

        User user = refreshToken.getUser();
        String newAccessToken = tokenProvider.generateAccessToken(user);

        return new AuthResponse(
                newAccessToken,
                refreshToken.getToken(),
                tokenProvider.getAccessTokenExpirationMs() / 1000,
                UserDto.fromEntity(user)
        );
    }

    private AuthResponse generateAuthResponse(User user) {
        String accessToken = tokenProvider.generateAccessToken(user);
        String refreshTokenString = UUID.randomUUID().toString();

        Instant expiryDate = Instant.now().plusMillis(tokenProvider.getRefreshTokenExpirationMs());

        RefreshToken refreshToken = new RefreshToken(user, refreshTokenString, expiryDate);
        refreshTokenRepository.save(refreshToken);

        return new AuthResponse(
                accessToken,
                refreshTokenString,
                tokenProvider.getAccessTokenExpirationMs() / 1000,
                UserDto.fromEntity(user)
        );
    }
}
