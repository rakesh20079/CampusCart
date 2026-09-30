package com.campuscart.security;

import com.campuscart.entity.Role;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.List;

@Service
public class GoogleTokenVerifierService {

    private static final Logger logger = LoggerFactory.getLogger(GoogleTokenVerifierService.class);

    private final GoogleIdTokenVerifier verifier;
    private final boolean allowDevLogin;
    private final String configuredClientId;

    public GoogleTokenVerifierService(
            @Value("${app.google.client-id:campus-cart-google-client-id}") String clientId,
            @Value("${app.security.allow-dev-login:true}") boolean allowDevLogin
    ) {
        this.configuredClientId = clientId;
        this.allowDevLogin = allowDevLogin;
        this.verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance())
                .setAudience(Collections.singletonList(clientId))
                .build();
    }

    public GoogleStudentInfo verifyToken(String idTokenString) {
        // 1. Dual-mode check: If testing with mock token in dev environment
        if (allowDevLogin && isMockToken(idTokenString)) {
            return parseMockToken(idTokenString);
        }

        // 2. Production cryptographic verification against Google API public certs
        try {
            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();
                String email = payload.getEmail();
                String name = (String) payload.get("name");
                String pictureUrl = (String) payload.get("picture");
                String hostedDomain = (String) payload.get("hd");

                // No domain constraint: Any authenticated student account is verified
                boolean isVerifiedStudent = true;
                Role role = Role.ROLE_VERIFIED_STUDENT;

                return new GoogleStudentInfo(email, name, pictureUrl, hostedDomain, role, isVerifiedStudent);
            } else {
                logger.warn("Google ID Token verification failed: token signature or audience mismatch with client ID '{}'", configuredClientId);
                return null;
            }
        } catch (GeneralSecurityException | IOException e) {
            logger.error("Error verifying Google ID token: {}", e.getMessage());
            return null;
        }
    }

    private boolean isMockToken(String token) {
        return token != null && (
                token.startsWith("mock_") ||
                token.startsWith("test_") ||
                token.contains("@")
        );
    }

    private GoogleStudentInfo parseMockToken(String token) {
        String cleanEmail = token.replace("mock_", "").replace("test_", "").trim();
        if (!cleanEmail.contains("@")) {
            cleanEmail = cleanEmail + "@gmail.com";
        }
        String name = cleanEmail.split("@")[0].replace(".", " ");
        name = Character.toUpperCase(name.charAt(0)) + name.substring(1);

        String hostedDomain = cleanEmail.substring(cleanEmail.indexOf("@") + 1);
        boolean isVerifiedStudent = true;
        Role role = Role.ROLE_VERIFIED_STUDENT;

        logger.info("[LOGIN] Authenticated verified student account for: {}", cleanEmail);
        return new GoogleStudentInfo(cleanEmail, name, null, hostedDomain, role, isVerifiedStudent);
    }

    public boolean checkCampusDomain(String email, String hostedDomain) {
        // Domain constraint removed: all valid student emails are accepted
        return email != null && email.contains("@");
    }

    public static class GoogleStudentInfo {
        private final String email;
        private final String name;
        private final String pictureUrl;
        private final String hostedDomain;
        private final Role role;
        private final boolean verifiedStudent;

        public GoogleStudentInfo(String email, String name, String pictureUrl, String hostedDomain, Role role, boolean verifiedStudent) {
            this.email = email;
            this.name = name != null ? name : email.split("@")[0];
            this.pictureUrl = pictureUrl;
            this.hostedDomain = hostedDomain;
            this.role = role;
            this.verifiedStudent = verifiedStudent;
        }

        public String getEmail() { return email; }
        public String getName() { return name; }
        public String getPictureUrl() { return pictureUrl; }
        public String getHostedDomain() { return hostedDomain; }
        public Role getRole() { return role; }
        public boolean isVerifiedStudent() { return verifiedStudent; }
    }
}
