import 'package:flutter_test/flutter_test.dart';
import 'package:event_bridge/models/user_model.dart';
import 'package:event_bridge/models/event_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates valid user', () {
      final json = {'id': '1', 'name': 'Test', 'email': 'test@test.com', 'roles': ['ROLE_PARTICIPANT'], 'emailVerified': true};
      final user = UserModel.fromJson(json);
      expect(user.name, 'Test');
      expect(user.email, 'test@test.com');
      expect(user.isParticipant, true);
      expect(user.isAdmin, false);
      expect(user.primaryRole, 'Participant');
    });

    test('admin role detected correctly', () {
      final user = UserModel.fromJson({'id': '1', 'name': 'Admin', 'email': 'a@a.com', 'roles': ['ROLE_ADMIN']});
      expect(user.isAdmin, true);
      expect(user.primaryRole, 'Admin');
    });
  });

  group('EventModel', () {
    test('fromJson creates valid event', () {
      final json = {'id': '1', 'title': 'Test Event', 'description': 'Desc', 'category': 'TECHNICAL', 'capacity': 100, 'registeredCount': 50, 'registrationFee': 0, 'status': 'PUBLISHED', 'teamEvent': false};
      final event = EventModel.fromJson(json);
      expect(event.title, 'Test Event');
      expect(event.isFull, false);
      expect(event.spotsLeft, 50);
      expect(event.categoryDisplay, 'TECHNICAL');
    });

    test('full event detected correctly', () {
      final event = EventModel.fromJson({'id': '1', 'title': 'Full', 'description': 'D', 'category': 'WORKSHOP', 'capacity': 10, 'registeredCount': 10});
      expect(event.isFull, true);
      expect(event.spotsLeft, 0);
    });
  });
}
