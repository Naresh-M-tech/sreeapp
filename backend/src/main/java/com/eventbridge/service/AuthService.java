package com.eventbridge.service;

import com.eventbridge.dto.AuthDto;
import com.eventbridge.exception.*;
import com.eventbridge.model.User;
import com.eventbridge.repository.UserRepository;
import com.eventbridge.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuthenticationManager authenticationManager;
    private final EmailService emailService;
    private final AuditService auditService;

    public AuthDto.AuthResponse register(AuthDto.RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Email already registered");
        }

        User.Role role = parseRole(request.getRole());

        String verificationToken = UUID.randomUUID().toString();

        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .department(request.getDepartment())
                .college(request.getCollege())
                .rollNumber(request.getRollNumber())
                .roles(Set.of(role))
                .enabled(true)
                .emailVerified(false)
                .emailVerificationToken(verificationToken)
                .emailVerificationExpiry(Instant.now().plusSeconds(86400))
                .build();

        User savedUser = userRepository.save(user);

        emailService.sendVerificationEmail(savedUser.getEmail(), savedUser.getName(), verificationToken);
        auditService.log(savedUser.getId(), savedUser.getName(), "USER_REGISTERED", "User", savedUser.getId(), "New user registration");

        String accessToken = tokenProvider.generateAccessToken(savedUser.getEmail());
        String refreshToken = tokenProvider.generateRefreshToken();

        savedUser.setRefreshToken(refreshToken);
        savedUser.setRefreshTokenExpiry(Instant.now().plusMillis(tokenProvider.getRefreshTokenExpirationMs()));
        userRepository.save(savedUser);

        return buildAuthResponse(savedUser, accessToken, refreshToken);
    }

    public AuthDto.AuthResponse login(AuthDto.LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        String accessToken = tokenProvider.generateAccessToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken();

        user.setRefreshToken(refreshToken);
        user.setRefreshTokenExpiry(Instant.now().plusMillis(tokenProvider.getRefreshTokenExpirationMs()));
        user.setOnline(true);
        user.setLastSeen(Instant.now());
        userRepository.save(user);

        auditService.log(user.getId(), user.getName(), "USER_LOGIN", "User", user.getId(), "User logged in");

        return buildAuthResponse(user, accessToken, refreshToken);
    }

    public AuthDto.AuthResponse refreshToken(String refreshToken) {
        User user = userRepository.findByRefreshToken(refreshToken)
                .orElseThrow(() -> new BadRequestException("Invalid refresh token"));

        if (user.getRefreshTokenExpiry().isBefore(Instant.now())) {
            throw new BadRequestException("Refresh token expired");
        }

        String newAccessToken = tokenProvider.generateAccessToken(user.getEmail());
        String newRefreshToken = tokenProvider.generateRefreshToken();

        user.setRefreshToken(newRefreshToken);
        user.setRefreshTokenExpiry(Instant.now().plusMillis(tokenProvider.getRefreshTokenExpirationMs()));
        userRepository.save(user);

        return buildAuthResponse(user, newAccessToken, newRefreshToken);
    }

    public void logout(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setRefreshToken(null);
        user.setRefreshTokenExpiry(null);
        user.setOnline(false);
        user.setLastSeen(Instant.now());
        userRepository.save(user);
    }

    public void forgotPassword(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("No account found with this email"));

        String resetToken = UUID.randomUUID().toString();
        user.setPasswordResetToken(resetToken);
        user.setPasswordResetExpiry(Instant.now().plusSeconds(3600));
        userRepository.save(user);

        emailService.sendPasswordResetEmail(user.getEmail(), user.getName(), resetToken);
    }

    public void resetPassword(AuthDto.ResetPasswordRequest request) {
        User user = userRepository.findByPasswordResetToken(request.getToken())
                .orElseThrow(() -> new BadRequestException("Invalid reset token"));

        if (user.getPasswordResetExpiry().isBefore(Instant.now())) {
            throw new BadRequestException("Reset token has expired");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordResetToken(null);
        user.setPasswordResetExpiry(null);
        userRepository.save(user);
    }

    public void verifyEmail(String token) {
        User user = userRepository.findByEmailVerificationToken(token)
                .orElseThrow(() -> new BadRequestException("Invalid verification token"));

        if (user.getEmailVerificationExpiry().isBefore(Instant.now())) {
            throw new BadRequestException("Verification token has expired");
        }

        user.setEmailVerified(true);
        user.setEmailVerificationToken(null);
        user.setEmailVerificationExpiry(null);
        userRepository.save(user);
    }

    public void changePassword(String email, AuthDto.ChangePasswordRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new BadRequestException("Current password is incorrect");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    private User.Role parseRole(String role) {
        try {
            return User.Role.valueOf("ROLE_" + role.toUpperCase());
        } catch (IllegalArgumentException e) {
            return User.Role.ROLE_PARTICIPANT;
        }
    }

    private AuthDto.AuthResponse buildAuthResponse(User user, String accessToken, String refreshToken) {
        AuthDto.UserInfo userInfo = AuthDto.UserInfo.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .department(user.getDepartment())
                .college(user.getCollege())
                .rollNumber(user.getRollNumber())
                .profileImageUrl(user.getProfileImageUrl())
                .roles(user.getRoles().stream().map(Enum::name).collect(Collectors.toSet()))
                .emailVerified(user.isEmailVerified())
                .build();

        return AuthDto.AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(tokenProvider.getAccessTokenExpirationMs())
                .user(userInfo)
                .build();
    }
}
