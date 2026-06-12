package com.eventbridge.repository;

import com.eventbridge.model.OdRequest;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OdRequestRepository extends MongoRepository<OdRequest, String> {
    List<OdRequest> findByStudentId(String studentId);
    List<OdRequest> findByFacultyId(String facultyId);
    List<OdRequest> findByFacultyIdAndStatus(String facultyId, OdRequest.OdStatus status);
    List<OdRequest> findByStudentIdAndEventId(String studentId, String eventId);
    long countByFacultyIdAndStatus(String facultyId, OdRequest.OdStatus status);
    long countByStatus(OdRequest.OdStatus status);
}
