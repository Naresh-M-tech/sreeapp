class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? referenceId;
  final bool read;
  final String? createdAt;

  NotificationModel({required this.id, required this.title, required this.message, this.type = 'GENERAL', this.referenceId, this.read = false, this.createdAt});

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id'] ?? '', title: json['title'] ?? '', message: json['message'] ?? '',
    type: json['type'] ?? 'GENERAL', referenceId: json['referenceId'], read: json['read'] ?? false, createdAt: json['createdAt']);
}

class RegistrationModel {
  final String id;
  final String userId;
  final String eventId;
  final String eventTitle;
  final String status;
  final bool attended;
  final String? createdAt;

  RegistrationModel({required this.id, required this.userId, required this.eventId, required this.eventTitle, this.status = 'REGISTERED', this.attended = false, this.createdAt});

  factory RegistrationModel.fromJson(Map<String, dynamic> json) => RegistrationModel(
    id: json['id'] ?? '', userId: json['userId'] ?? '', eventId: json['eventId'] ?? '',
    eventTitle: json['eventTitle'] ?? '', status: json['status'] ?? 'REGISTERED', attended: json['attended'] ?? false, createdAt: json['createdAt']);
}

class OdRequestModel {
  final String id;
  final String studentName;
  final String eventTitle;
  final String status;
  final String? remarks;
  final String? fromDate;
  final String? toDate;
  final String? createdAt;

  OdRequestModel({required this.id, required this.studentName, required this.eventTitle, this.status = 'PENDING', this.remarks, this.fromDate, this.toDate, this.createdAt});

  factory OdRequestModel.fromJson(Map<String, dynamic> json) => OdRequestModel(
    id: json['id'] ?? '', studentName: json['studentName'] ?? '', eventTitle: json['eventTitle'] ?? '',
    status: json['status'] ?? 'PENDING', remarks: json['remarks'], fromDate: json['fromDate'], toDate: json['toDate'], createdAt: json['createdAt']);
}
