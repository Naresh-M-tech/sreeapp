class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? college;
  final String? rollNumber;
  final String? profileImageUrl;
  final Set<String> roles;
  final bool emailVerified;

  UserModel({required this.id, required this.name, required this.email, this.phone, this.department, this.college, this.rollNumber, this.profileImageUrl, required this.roles, this.emailVerified = false});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '', name: json['name'] ?? '', email: json['email'] ?? '',
      phone: json['phone'], department: json['department'], college: json['college'],
      rollNumber: json['rollNumber'], profileImageUrl: json['profileImageUrl'],
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toSet() ?? {},
      emailVerified: json['emailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'phone': phone, 'department': department, 'college': college, 'rollNumber': rollNumber, 'profileImageUrl': profileImageUrl, 'roles': roles.toList(), 'emailVerified': emailVerified};

  bool get isAdmin => roles.contains('ROLE_ADMIN');
  bool get isOrganizer => roles.contains('ROLE_ORGANIZER');
  bool get isFaculty => roles.contains('ROLE_FACULTY');
  bool get isParticipant => roles.contains('ROLE_PARTICIPANT');

  String get primaryRole {
    if (isAdmin) return 'Admin';
    if (isOrganizer) return 'Organizer';
    if (isFaculty) return 'Faculty';
    return 'Participant';
  }
}
