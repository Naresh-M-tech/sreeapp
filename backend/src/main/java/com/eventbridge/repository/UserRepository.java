package com.eventbridge.repository;

import com.eventbridge.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends MongoRepository<User, String> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    Optional<User> findByEmailVerificationToken(String token);
    Optional<User> findByPasswordResetToken(String token);
    Optional<User> findByRefreshToken(String refreshToken);
    List<User> findByRolesContaining(User.Role role);
    List<User> findByDepartment(String department);
    long countByRolesContaining(User.Role role);
    long countByOnlineTrue();
    List<User> findByNameContainingIgnoreCase(String name);
}
