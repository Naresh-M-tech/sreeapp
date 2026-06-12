package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.model.OdRequest;
import com.eventbridge.service.OdRequestService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/od")
@RequiredArgsConstructor
@Tag(name = "OD Requests")
public class OdRequestController {
    private final OdRequestService odRequestService;

    @PostMapping
    public ResponseEntity<ApiResponse<OdRequest>> create(@RequestBody OdRequest request, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("OD Request submitted", odRequestService.createOdRequest(request, user.getUsername())));
    }

    @PutMapping("/{id}/approve")
    public ResponseEntity<ApiResponse<OdRequest>> approve(@PathVariable String id, @RequestParam(required = false) String remarks, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(odRequestService.approveOdRequest(id, user.getUsername(), remarks)));
    }

    @PutMapping("/{id}/reject")
    public ResponseEntity<ApiResponse<OdRequest>> reject(@PathVariable String id, @RequestParam String remarks, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(odRequestService.rejectOdRequest(id, user.getUsername(), remarks)));
    }

    @GetMapping("/student")
    public ResponseEntity<ApiResponse<List<OdRequest>>> getStudentOds(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(odRequestService.getStudentOdRequests(user.getUsername())));
    }

    @GetMapping("/faculty")
    public ResponseEntity<ApiResponse<List<OdRequest>>> getFacultyOds(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(odRequestService.getFacultyOdRequests(user.getUsername())));
    }

    @GetMapping("/faculty/pending")
    public ResponseEntity<ApiResponse<List<OdRequest>>> getPending(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(odRequestService.getPendingOdRequests(user.getUsername())));
    }

    @GetMapping("/{id}/pdf")
    public ResponseEntity<byte[]> downloadPdf(@PathVariable String id) {
        byte[] pdf = odRequestService.generateOdPdf(id);
        return ResponseEntity.ok().header(HttpHeaders.CONTENT_TYPE, "application/pdf")
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=od_letter.pdf").body(pdf);
    }
}
