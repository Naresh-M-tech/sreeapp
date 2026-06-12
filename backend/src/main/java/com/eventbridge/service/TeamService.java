package com.eventbridge.service;

import com.eventbridge.exception.*;
import com.eventbridge.model.*;
import com.eventbridge.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
@RequiredArgsConstructor
public class TeamService {
    private final TeamRepository teamRepository;
    private final EventRepository eventRepository;
    private final UserRepository userRepository;

    public Team createTeam(String eventId, String teamName, String leaderEmail) {
        Event event = eventRepository.findById(eventId).orElseThrow(() -> new ResourceNotFoundException("Event not found"));
        if (!event.isTeamEvent()) throw new BadRequestException("Not a team event");
        User leader = userRepository.findByEmail(leaderEmail).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        teamRepository.findByEventIdAndLeaderId(eventId, leader.getId()).ifPresent(t -> { throw new DuplicateResourceException("You already have a team"); });

        Team.TeamMember leaderMember = Team.TeamMember.builder().userId(leader.getId()).name(leader.getName()).email(leader.getEmail()).role(Team.TeamMember.MemberRole.LEADER).build();
        Team team = Team.builder().name(teamName).eventId(eventId).leaderId(leader.getId()).leaderName(leader.getName())
                .members(new ArrayList<>(List.of(leaderMember))).inviteCodes(List.of(UUID.randomUUID().toString().substring(0, 8))).status(Team.TeamStatus.FORMING).build();
        return teamRepository.save(team);
    }

    public Team joinTeam(String teamId, String email) {
        Team team = teamRepository.findById(teamId).orElseThrow(() -> new ResourceNotFoundException("Team not found"));
        User user = userRepository.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        Event event = eventRepository.findById(team.getEventId()).orElseThrow(() -> new ResourceNotFoundException("Event not found"));
        if (team.getMembers().size() >= event.getMaxTeamSize()) throw new BadRequestException("Team is full");
        if (team.getMembers().stream().anyMatch(m -> m.getUserId().equals(user.getId()))) throw new DuplicateResourceException("Already in team");

        team.getMembers().add(Team.TeamMember.builder().userId(user.getId()).name(user.getName()).email(user.getEmail()).role(Team.TeamMember.MemberRole.MEMBER).build());
        if (team.getMembers().size() >= event.getMinTeamSize()) team.setStatus(Team.TeamStatus.COMPLETE);
        return teamRepository.save(team);
    }

    public Team removeMember(String teamId, String memberId, String leaderEmail) {
        Team team = teamRepository.findById(teamId).orElseThrow(() -> new ResourceNotFoundException("Team not found"));
        User leader = userRepository.findByEmail(leaderEmail).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (!team.getLeaderId().equals(leader.getId())) throw new BadRequestException("Only leader can remove members");
        team.getMembers().removeIf(m -> m.getUserId().equals(memberId));
        return teamRepository.save(team);
    }

    public List<Team> getTeamsByEvent(String eventId) { return teamRepository.findByEventId(eventId); }
    public List<Team> getMyTeams(String email) {
        User user = userRepository.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return teamRepository.findByMembersUserId(user.getId());
    }
    public Team getTeamById(String id) { return teamRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Team not found")); }
}
