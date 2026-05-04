

class Booking {
  final String id;
  final String studentId;
  final String lecturer;
  final DateTime dateTime;
  final String topic;
  final String notes;
  final String status; // pending / confirmed

  Booking({
    required this.id,
    required this.studentId,
    required this.lecturer,
    required this.dateTime,
    required this.topic,
    required this.notes,
    required this.status,
  });
}
