package com.eventbridge.security;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
class JwtTokenProviderTest {
    @Autowired
    private JwtTokenProvider tokenProvider;

    @Test
    void generateAndValidateToken() {
        String token = tokenProvider.generateAccessToken("test@test.com");
        assertNotNull(token);
        assertTrue(tokenProvider.validateToken(token));
        assertEquals("test@test.com", tokenProvider.getEmailFromToken(token));
    }

    @Test
    void invalidToken() {
        assertFalse(tokenProvider.validateToken("invalid.token.here"));
    }

    @Test
    void generateRefreshToken() {
        String token = tokenProvider.generateRefreshToken();
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
}
