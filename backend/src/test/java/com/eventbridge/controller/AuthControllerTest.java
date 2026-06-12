package com.eventbridge.controller;

import com.eventbridge.dto.AuthDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthControllerTest {
    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;

    @Test
    void registerAndLogin() throws Exception {
        AuthDto.RegisterRequest reg = AuthDto.RegisterRequest.builder()
                .name("Test User").email("testuser" + System.currentTimeMillis() + "@test.com")
                .password("Test@1234").role("PARTICIPANT").build();

        mockMvc.perform(post("/auth/register").contentType(MediaType.APPLICATION_JSON).content(objectMapper.writeValueAsString(reg)))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.success").value(true)).andExpect(jsonPath("$.data.accessToken").exists());
    }

    @Test
    void loginWithInvalidCredentials() throws Exception {
        AuthDto.LoginRequest req = AuthDto.LoginRequest.builder().email("nonexistent@test.com").password("wrong").build();
        mockMvc.perform(post("/auth/login").contentType(MediaType.APPLICATION_JSON).content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isUnauthorized());
    }
}
