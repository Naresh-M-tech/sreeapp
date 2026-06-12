package com.eventbridge.service;

import com.eventbridge.exception.*;
import com.eventbridge.model.*;
import com.eventbridge.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OdRequestService {
    private final OdRequestRepository odRequestRepository;
    private final UserRepository userRepository;
    private final EventRepository eventRepository;
    private final NotificationService notificationService;
    private final PdfService pdfService;

    public OdRequest createOdRequest(OdRequest request, String studentEmail) {
        User student = userRepository.findByEmail(studentEmail).orElseThrow(() -> new ResourceNotFoundException("Student not found"));
        Event event = eventRepository.findById(request.getEventId()).orElseThrow(() -> new ResourceNotFoundException("Event not found"));

        request.setStudentId(student.getId());
        request.setStudentName(student.getName());
        request.setStudentEmail(student.getEmail());
        request.setStudentRollNumber(student.getRollNumber());
        request.setDepartment(student.getDepartment());
        request.setEventTitle(event.getTitle());
        request.setStatus(OdRequest.OdStatus.PENDING);

        OdRequest saved = odRequestRepository.save(request);
        if (request.getFacultyId() != null) {
            notificationService.createNotification(request.getFacultyId(), "New OD Request",
                    student.getName() + " has requested OD for " + event.getTitle(),
                    Notification.NotificationType.OD_REQUEST, saved.getId(), "OdRequest");
        }
        return saved;
    }

    public OdRequest approveOdRequest(String id, String facultyEmail, String remarks) {
        OdRequest od = odRequestRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("OD Request not found"));
        User faculty = userRepository.findByEmail(facultyEmail).orElseThrow(() -> new ResourceNotFoundException("Faculty not found"));
        od.setStatus(OdRequest.OdStatus.APPROVED);
        od.setRemarks(remarks);
        od.setFacultyName(faculty.getName());
        OdRequest saved = odRequestRepository.save(od);
        notificationService.createNotification(od.getStudentId(), "OD Approved", "Your OD for " + od.getEventTitle() + " has been approved.", Notification.NotificationType.OD_REQUEST, id, "OdRequest");
        return saved;
    }

    public OdRequest rejectOdRequest(String id, String facultyEmail, String remarks) {
        OdRequest od = odRequestRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("OD Request not found"));
        od.setStatus(OdRequest.OdStatus.REJECTED);
        od.setRemarks(remarks);
        OdRequest saved = odRequestRepository.save(od);
        notificationService.createNotification(od.getStudentId(), "OD Rejected", "Your OD for " + od.getEventTitle() + " was rejected. Reason: " + remarks, Notification.NotificationType.OD_REQUEST, id, "OdRequest");
        return saved;
    }

    public List<OdRequest> getStudentOdRequests(String email) {
        User student = userRepository.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("Not found"));
        return odRequestRepository.findByStudentId(student.getId());
    }

    public List<OdRequest> getFacultyOdRequests(String email) {
        User faculty = userRepository.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("Not found"));
        return odRequestRepository.findByFacultyId(faculty.getId());
    }

    public List<OdRequest> getPendingOdRequests(String facultyEmail) {
        User faculty = userRepository.findByEmail(facultyEmail).orElseThrow(() -> new ResourceNotFoundException("Not found"));
        return odRequestRepository.findByFacultyIdAndStatus(faculty.getId(), OdRequest.OdStatus.PENDING);
    }

    public byte[] generateOdPdf(String id) {
        OdRequest od = odRequestRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Not found"));
        return pdfService.generateOdLetter(od);
    }
}
