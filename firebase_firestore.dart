import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addBooking(Booking booking) async {
    await _firestore.collection('bookings').doc(booking.id).set({
      'studentId': booking.studentId,
      'lecturer': booking.lecturer,
      'dateTime': booking.dateTime,
      'topic': booking.topic,
      'notes': booking.notes,
      'status': booking.status,
    });
  }

  Future<List<Booking>> getBookingsForStudent(String studentId) async {
    final snapshot =
        await _firestore
            .collection('bookings')
            .where('studentId', isEqualTo: studentId)
            .orderBy('dateTime')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Booking(
        id: doc.id,
        studentId: data['studentId'],
        lecturer: data['lecturer'],
        dateTime: (data['dateTime'] as Timestamp).toDate(),
        topic: data['topic'],
        notes: data['notes'],
        status: data['status'],
      );
    }).toList();
  }

  // Optionally, implement updateBooking and deleteBooking with Firebase too
}
