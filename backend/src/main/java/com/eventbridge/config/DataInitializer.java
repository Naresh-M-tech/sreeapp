package com.eventbridge.config;

import com.eventbridge.model.Event;
import com.eventbridge.model.User;
import com.eventbridge.repository.EventRepository;
import com.eventbridge.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Slf4j
@Configuration
@RequiredArgsConstructor
public class DataInitializer {

    private final UserRepository userRepository;
    private final EventRepository eventRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner initData() {
        return args -> {
            if (!userRepository.existsByEmail("admin@eventbridge.com")) {
                User admin = User.builder()
                        .name("System Admin")
                        .email("admin@eventbridge.com")
                        .password(passwordEncoder.encode("Admin@123"))
                        .roles(Set.of(User.Role.ROLE_ADMIN))
                        .enabled(true)
                        .emailVerified(true)
                        .department("Administration")
                        .college("Event Bridge University")
                        .build();
                userRepository.save(admin);
                log.info("Default admin user created");
            }
            
            if (!userRepository.existsByEmail("organizer@eventbridge.com")) {
                User organizer = User.builder()
                        .name("College Events Club")
                        .email("organizer@eventbridge.com")
                        .password(passwordEncoder.encode("Org@123"))
                        .roles(Set.of(User.Role.ROLE_ORGANIZER))
                        .enabled(true)
                        .emailVerified(true)
                        .department("Student Affairs")
                        .college("Event Bridge University")
                        .build();
                userRepository.save(organizer);
                log.info("Default organizer user created");
            }
            
            if (!userRepository.existsByEmail("faculty@eventbridge.com")) {
                User faculty = User.builder()
                        .name("Dr. Smith")
                        .email("faculty@eventbridge.com")
                        .password(passwordEncoder.encode("Faculty@123"))
                        .roles(Set.of(User.Role.ROLE_FACULTY))
                        .enabled(true)
                        .emailVerified(true)
                        .department("Computer Science")
                        .college("Event Bridge University")
                        .build();
                userRepository.save(faculty);
                log.info("Default faculty user created");
            }

            if (eventRepository.count() == 0) {
                User org = userRepository.findByEmail("organizer@eventbridge.com").orElse(null);
                if (org != null) {
                    Event event1 = Event.builder()
                            .title("Annual Tech Symposium 2026")
                            .description("A massive gathering of tech enthusiasts featuring coding challenges, guest lectures, and more.")
                            .category(Event.EventCategory.TECHNICAL)
                            .venue("Main Auditorium")
                            .startDate(LocalDateTime.now().plusDays(10).withHour(9).withMinute(0))
                            .endDate(LocalDateTime.now().plusDays(12).withHour(17).withMinute(0))
                            .registrationDeadline(LocalDateTime.now().plusDays(8).withHour(23).withMinute(59))
                            .organizerId(org.getId())
                            .organizerName(org.getName())
                            .capacity(500)
                            .registeredCount(120)
                            .bannerImageUrl("https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80")
                            .rules(List.of("Bring your college ID", "Laptops are required for hackathon events"))
                            .eligibility("All tech students")
                            .registrationFee(250.0)
                            .status(Event.EventStatus.PUBLISHED)
                            .tags(List.of("Tech", "Hackathon", "Symposium"))
                            .build();

                    Event event2 = Event.builder()
                            .title("Cultural Fest Night")
                            .description("Join us for an evening of music, dance, and cultural celebrations.")
                            .category(Event.EventCategory.CULTURAL)
                            .venue("Open Air Theatre")
                            .startDate(LocalDateTime.now().plusDays(15).withHour(18).withMinute(0))
                            .endDate(LocalDateTime.now().plusDays(15).withHour(23).withMinute(0))
                            .registrationDeadline(LocalDateTime.now().plusDays(14).withHour(23).withMinute(59))
                            .organizerId(org.getId())
                            .organizerName(org.getName())
                            .capacity(1000)
                            .registeredCount(450)
                            .bannerImageUrl("https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=80")
                            .rules(List.of("No outside food allowed", "Must carry valid entry pass"))
                            .eligibility("Open to all")
                            .registrationFee(0.0)
                            .status(Event.EventStatus.PUBLISHED)
                            .tags(List.of("Cultural", "Music", "Dance"))
                            .build();
                            
                    Event event3 = Event.builder()
                            .title("AI & Machine Learning Workshop")
                            .description("A hands-on workshop on building your first neural network using PyTorch.")
                            .category(Event.EventCategory.WORKSHOP)
                            .venue("Computer Lab 3")
                            .startDate(LocalDateTime.now().plusDays(5).withHour(10).withMinute(0))
                            .endDate(LocalDateTime.now().plusDays(5).withHour(16).withMinute(0))
                            .registrationDeadline(LocalDateTime.now().plusDays(3).withHour(23).withMinute(59))
                            .organizerId(org.getId())
                            .organizerName(org.getName())
                            .capacity(60)
                            .registeredCount(55)
                            .bannerImageUrl("https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=800&q=80")
                            .rules(List.of("Basic Python knowledge required", "Install PyTorch before coming"))
                            .eligibility("CS/IT Students")
                            .registrationFee(100.0)
                            .status(Event.EventStatus.PUBLISHED)
                            .tags(List.of("AI", "ML", "Workshop", "Python"))
                            .build();

                    eventRepository.saveAll(List.of(event1, event2, event3));
                    log.info("Mock events initialized");
                }
            }
        };
    }
}
