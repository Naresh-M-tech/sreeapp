package com.eventbridge.repository;

import com.eventbridge.model.Certificate;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CertificateRepository extends MongoRepository<Certificate, String> {
    List<Certificate> findByUserId(String userId);
    List<Certificate> findByEventId(String eventId);
    Optional<Certificate> findByVerificationCode(String verificationCode);
    Optional<Certificate> findByUserIdAndEventId(String userId, String eventId);
}
