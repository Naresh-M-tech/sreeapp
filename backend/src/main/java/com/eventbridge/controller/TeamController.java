package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.model.Team;
import com.eventbridge.service.TeamService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/teams")
@RequiredArgsConstructor
@Tag(name = "Teams")
public class TeamController {
    private final TeamService teamService;

    @PostMapping
    public ResponseEntity<ApiResponse<Team>> create(@RequestParam String eventId, @RequestParam String teamName, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Team created", teamService.createTeam(eventId, teamName, user.getUsername())));
    }

    @PostMapping("/{teamId}/join")
    public ResponseEntity<ApiResponse<Team>> join(@PathVariable String teamId, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(teamService.joinTeam(teamId, user.getUsername())));
    }

    @DeleteMapping("/{teamId}/members/{memberId}")
    public ResponseEntity<ApiResponse<Team>> removeMember(@PathVariable String teamId, @PathVariable String memberId, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(teamService.removeMember(teamId, memberId, user.getUsername())));
    }

    @GetMapping("/event/{eventId}")
    public ResponseEntity<ApiResponse<List<Team>>> getByEvent(@PathVariable String eventId) {
        return ResponseEntity.ok(ApiResponse.success(teamService.getTeamsByEvent(eventId)));
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Team>>> myTeams(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(teamService.getMyTeams(user.getUsername())));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Team>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(teamService.getTeamById(id)));
    }
}
