package com.vithey.auth.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.vithey.auth.dto.request.GoogleLoginRequest;
import com.vithey.auth.dto.response.AuthResponse;
import com.vithey.auth.dto.response.TokenResponse;
import com.vithey.auth.dto.response.UserAuthResponse;
import com.vithey.auth.entity.Role;
import com.vithey.auth.exception.ApiException;
import com.vithey.auth.exception.ErrorCode;
import com.vithey.auth.exception.GlobalExceptionHandler;
import com.vithey.auth.security.CurrentUserProvider;
import com.vithey.auth.service.AuthService;
import com.vithey.auth.service.GoogleAuthService;
import com.vithey.auth.service.PasswordResetService;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class AuthControllerGoogleTest {

  private static final String ENDPOINT = "/api/v1/auth/google";

  private GoogleAuthService googleAuthService;
  private MockMvc mockMvc;

  @BeforeEach
  void setUp() {
    googleAuthService = Mockito.mock(GoogleAuthService.class);
    AuthController controller = new AuthController(
        Mockito.mock(AuthService.class),
        googleAuthService,
        Mockito.mock(PasswordResetService.class),
        Mockito.mock(CurrentUserProvider.class)
    );
    mockMvc = MockMvcBuilders.standaloneSetup(controller)
        .setControllerAdvice(new GlobalExceptionHandler())
        .setMessageConverters(new MappingJackson2HttpMessageConverter(
            JsonMapper.builder().propertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE).build()
        ))
        .build();
  }

  @Test
  void returnsVitheyTokensForValidGoogleToken() throws Exception {
    when(googleAuthService.authenticate(any(GoogleLoginRequest.class))).thenReturn(authResponse());

    mockMvc.perform(post(ENDPOINT)
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"id_token\":\"google-id-token\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.data.tokens.access_token").value("access"))
        .andExpect(jsonPath("$.data.tokens.refresh_token").value("refresh"))
        .andExpect(jsonPath("$.data.user.role").value("USER"));
  }

  @Test
  void returnsUnauthorizedForInvalidGoogleToken() throws Exception {
    when(googleAuthService.authenticate(any(GoogleLoginRequest.class)))
        .thenThrow(new ApiException(ErrorCode.INVALID_TOKEN, "Google token is invalid or expired"));

    mockMvc.perform(post(ENDPOINT)
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"id_token\":\"bad\"}"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error.code").value("INVALID_TOKEN"));
  }

  @Test
  void rejectsMissingIdTokenWithValidationError() throws Exception {
    mockMvc.perform(post(ENDPOINT)
            .contentType(MediaType.APPLICATION_JSON)
            .content("{}"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.error.code").value("VALIDATION_ERROR"));
  }

  private AuthResponse authResponse() {
    return new AuthResponse(
        new UserAuthResponse(UUID.randomUUID(), "student@aub.edu.kh", null, "Test User", Role.USER, false, true),
        new TokenResponse("access", "refresh", 900)
    );
  }
}
