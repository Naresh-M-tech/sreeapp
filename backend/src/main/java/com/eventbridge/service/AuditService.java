package com.eventbridge.service;

import com.eventbridge.model.AuditLog;
import com.eventbridge.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AuditService {
    private final AuditLogRepository auditLogRepository;

    @Async
    public void log(String userId, String userName, String action, String entityType, String entityId, String details) {
        AuditLog log = AuditLog.builder().userId(userId).userName(userName).action(action).entityType(entityType).entityId(entityId).details(details).build();
        auditLogRepository.save(log);
    }

    public List<AuditLog> getRecentLogs() { return auditLogRepository.findTop100ByOrderByCreatedAtDesc(); }
    public List<AuditLog> getLogsByUser(String userId) { return auditLogRepository.findByUserIdOrderByCreatedAtDesc(userId); }
}
