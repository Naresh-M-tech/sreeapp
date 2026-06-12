package com.eventbridge.dto;

import lombok.*;

import java.util.Map;

public class AnalyticsDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AdminAnalytics {
        private long totalUsers;
        private long totalEvents;
        private long totalRegistrations;
        private double totalRevenue;
        private long activeUsers;
        private long pendingApprovals;
        private Map<String, Long> usersByRole;
        private Map<String, Long> eventsByCategory;
        private Map<String, Long> registrationsByMonth;
        private Map<String, Double> revenueByMonth;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrganizerAnalytics {
        private long totalEvents;
        private long totalRegistrations;
        private long totalAttendees;
        private double totalRevenue;
        private Map<String, Long> registrationsByEvent;
        private Map<String, Long> registrationTrends;
        private Map<String, Double> attendanceRate;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EventAnalytics {
        private String eventId;
        private String eventTitle;
        private long totalRegistrations;
        private long confirmedRegistrations;
        private long attendees;
        private double attendanceRate;
        private double revenue;
        private Map<String, Long> registrationsByDay;
        private Map<String, Long> registrationsByDepartment;
    }
}
