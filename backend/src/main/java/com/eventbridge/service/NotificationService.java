package com.eventbridge.service;

import com.eventbridge.model.Notification;
import com.eventbridge.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final NotificationRepository notificationRepository;

    public Notification createNotification(String userId, String title, String message, Notification.NotificationType type, String refId, String refType) {
        Notification notification = Notification.builder().userId(userId).title(title).message(message).type(type).referenceId(refId).referenceType(refType).read(false).build();
        return notificationRepository.save(notification);
    }

    public List<Notification> getUserNotifications(String userId) { return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId); }
    public List<Notification> getUnreadNotifications(String userId) { return notificationRepository.findByUserIdAndReadFalse(userId); }
    public long getUnreadCount(String userId) { return notificationRepository.countByUserIdAndReadFalse(userId); }

    public void markAsRead(String notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> { n.setRead(true); notificationRepository.save(n); });
    }

    public void markAllAsRead(String userId) {
        notificationRepository.findByUserIdAndReadFalse(userId).forEach(n -> { n.setRead(true); notificationRepository.save(n); });
    }
}
