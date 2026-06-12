class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? venue;
  final String? startDate;
  final String? endDate;
  final String? registrationDeadline;
  final String? organizerId;
  final String? organizerName;
  final int capacity;
  final int registeredCount;
  final String? bannerImageUrl;
  final List<String> rules;
  final String? eligibility;
  final double registrationFee;
  final bool teamEvent;
  final int minTeamSize;
  final int maxTeamSize;
  final String status;
  final List<String> tags;
  final bool isRegistered;
  final String? createdAt;

  EventModel({required this.id, required this.title, required this.description, required this.category,
    this.venue, this.startDate, this.endDate, this.registrationDeadline, this.organizerId, this.organizerName,
    this.capacity = 0, this.registeredCount = 0, this.bannerImageUrl, this.rules = const [],
    this.eligibility, this.registrationFee = 0, this.teamEvent = false, this.minTeamSize = 1,
    this.maxTeamSize = 1, this.status = 'DRAFT', this.tags = const [], this.isRegistered = false, this.createdAt});

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '', title: json['title'] ?? '', description: json['description'] ?? '',
      category: json['category'] ?? '', venue: json['venue'], startDate: json['startDate'],
      endDate: json['endDate'], registrationDeadline: json['registrationDeadline'],
      organizerId: json['organizerId'], organizerName: json['organizerName'],
      capacity: json['capacity'] ?? 0, registeredCount: json['registeredCount'] ?? 0,
      bannerImageUrl: json['bannerImageUrl'], rules: List<String>.from(json['rules'] ?? []),
      eligibility: json['eligibility'], registrationFee: (json['registrationFee'] ?? 0).toDouble(),
      teamEvent: json['teamEvent'] ?? false, minTeamSize: json['minTeamSize'] ?? 1,
      maxTeamSize: json['maxTeamSize'] ?? 1, status: json['status'] ?? 'DRAFT',
      tags: List<String>.from(json['tags'] ?? []), isRegistered: json['isRegistered'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  bool get isFull => capacity > 0 && registeredCount >= capacity;
  String get categoryDisplay => category.replaceAll('_', ' ');
  int get spotsLeft => capacity > 0 ? capacity - registeredCount : -1;
}
