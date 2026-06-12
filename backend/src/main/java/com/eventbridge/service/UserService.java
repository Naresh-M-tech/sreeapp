package com.eventbridge.service;

import com.eventbridge.dto.AuthDto;
import com.eventbridge.exception.*;
import com.eventbridge.model.User;
import com.eventbridge.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public List<AuthDto.UserInfo> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::toUserInfo)
                .collect(Collectors.toList());
    }

    public AuthDto.UserInfo getUserById(String id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
        return toUserInfo(user);
    }

    public AuthDto.UserInfo getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
        return toUserInfo(user);
    }

    public List<AuthDto.UserInfo> getUsersByRole(String role) {
        User.Role userRole = User.Role.valueOf("ROLE_" + role.toUpperCase());
        return userRepository.findByRolesContaining(userRole).stream()
                .map(this::toUserInfo)
                .collect(Collectors.toList());
    }

    public AuthDto.UserInfo updateUser(String id, AuthDto.RegisterRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (request.getName() != null) user.setName(request.getName());
        if (request.getPhone() != null) user.setPhone(request.getPhone());
        if (request.getDepartment() != null) user.setDepartment(request.getDepartment());
        if (request.getCollege() != null) user.setCollege(request.getCollege());
        if (request.getRollNumber() != null) user.setRollNumber(request.getRollNumber());

        User saved = userRepository.save(user);
        return toUserInfo(saved);
    }

    public AuthDto.UserInfo updateProfile(String email, AuthDto.RegisterRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (request.getName() != null) user.setName(request.getName());
        if (request.getPhone() != null) user.setPhone(request.getPhone());
        if (request.getDepartment() != null) user.setDepartment(request.getDepartment());
        if (request.getCollege() != null) user.setCollege(request.getCollege());

        User saved = userRepository.save(user);
        return toUserInfo(saved);
    }

    public void updateProfileImage(String email, String imageUrl) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setProfileImageUrl(imageUrl);
        userRepository.save(user);
    }

    public void toggleUserStatus(String id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setEnabled(!user.isEnabled());
        userRepository.save(user);
    }

    public void updateUserRoles(String id, Set<String> roles) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        Set<User.Role> userRoles = roles.stream()
                .map(r -> User.Role.valueOf("ROLE_" + r.toUpperCase()))
                .collect(Collectors.toSet());
        user.setRoles(userRoles);
        userRepository.save(user);
    }

    public void deleteUser(String id) {
        if (!userRepository.existsById(id)) {
            throw new ResourceNotFoundException("User not found");
        }
        userRepository.deleteById(id);
    }

    public List<AuthDto.UserInfo> searchUsers(String query) {
        return userRepository.findByNameContainingIgnoreCase(query).stream()
                .map(this::toUserInfo)
                .collect(Collectors.toList());
    }

    private AuthDto.UserInfo toUserInfo(User user) {
        return AuthDto.UserInfo.builder()
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
    }
}
