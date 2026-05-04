/*
N.R Mabunda   223037726
A.T Rantoa    222027706
M.C Munyai    223004579
N.T Ngcobo    222006273
T.A Mokaleng  223029362
K Mkhatshwa   222078465
L.W Rabothata 223062005

Question: booking model.dart
*/

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
