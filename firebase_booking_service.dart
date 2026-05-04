import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class FirebaseBookingService {
  final _firestore = FirebaseFirestore.instance;
  final _bookings = 'bookings';

  // Add booking with improved error handling and debugging
  Future<void> addBooking(Booking booking) async {
    try {
      print("FirebaseBookingService: Adding booking with ID: ${booking.id}");
      print("FirebaseBookingService: Student ID: ${booking.studentId}");
      print("FirebaseBookingService: Topic: ${booking.topic}");
      print("FirebaseBookingService: DateTime: ${booking.dateTime}");
      print("FirebaseBookingService: Lecturer: ${booking.lecturer}");

      // Check if studentId is not empty
      if (booking.studentId.isEmpty) {
        throw Exception("Student ID cannot be empty");
      }

      // Create a document with a generated ID if not provided
      final docRef =
          booking.id.isNotEmpty
              ? _firestore.collection(_bookings).doc(booking.id)
              : _firestore.collection(_bookings).doc();

      final bookingId = booking.id.isNotEmpty ? booking.id : docRef.id;

      await docRef.set({
        'id': bookingId, // Store the ID in the document as well
        'studentId': booking.studentId,
        'lecturer': booking.lecturer,
        'dateTime': Timestamp.fromDate(booking.dateTime),
        'topic': booking.topic,
        'notes': booking.notes,
        'status': booking.status,
      });

      print(
        "FirebaseBookingService: Booking added successfully with ID: ${docRef.id}",
      );
    } catch (e, stack) {
      print("FirebaseBookingService: Error adding booking: $e");
      print(stack);
      throw e; // Re-throw to be handled by the ViewModel
    }
  }

  // Update booking with improved error handling
  Future<void> updateBooking(Booking booking) async {
    try {
      print("FirebaseBookingService: Updating booking with ID: ${booking.id}");

      await _firestore.collection(_bookings).doc(booking.id).update({
        'lecturer': booking.lecturer,
        'dateTime': Timestamp.fromDate(booking.dateTime),
        'topic': booking.topic,
        'notes': booking.notes,
        'status': booking.status,
      });

      print("FirebaseBookingService: Booking updated successfully");
    } catch (e, stack) {
      print("FirebaseBookingService: Error updating booking: $e");
      print(stack);
      throw e;
    }
  }

  // Delete booking with improved error handling
  Future<void> deleteBooking(String id) async {
    try {
      print("FirebaseBookingService: Deleting booking with ID: $id");

      await _firestore.collection(_bookings).doc(id).delete();

      print("FirebaseBookingService: Booking deleted successfully");
    } catch (e, stack) {
      print("FirebaseBookingService: Error deleting booking: $e");
      print(stack);
      throw e;
    }
  }

  // Get bookings for a student with improved debugging
  Future<List<Booking>> getBookingsForStudent(String studentId) async {
    print(
      "FirebaseBookingService: Querying Firestore for studentId: '$studentId'",
    );

    try {
      // Check if studentId is valid
      if (studentId.isEmpty) {
        print("FirebaseBookingService: Empty studentId provided");
        return [];
      }

      final snapshot =
          await _firestore
              .collection(_bookings)
              .where('studentId', isEqualTo: studentId)
              .get();

      print("FirebaseBookingService: Found ${snapshot.docs.length} bookings");

      if (snapshot.docs.isEmpty) {
        // Check if there are ANY bookings in the collection
        final allBookings = await _firestore.collection(_bookings).get();
        print(
          "FirebaseBookingService: Total bookings in collection: ${allBookings.docs.length}",
        );

        if (allBookings.docs.isNotEmpty) {
          print("FirebaseBookingService: Sample booking data for debugging:");
          print(
            "First booking studentId: ${allBookings.docs.first.data()['studentId']}",
          );
        }
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        print("FirebaseBookingService: Booking data: $data");

        return Booking(
          id: doc.id,
          studentId: data['studentId'],
          lecturer: data['lecturer'],
          dateTime: (data['dateTime'] as Timestamp).toDate(),
          topic: data['topic'],
          notes: data['notes'] ?? '',
          status: data['status'],
        );
      }).toList();
    } catch (e, stack) {
      print("FirebaseBookingService: Error fetching bookings: $e");
      print(stack);
      throw e;
    }
  }

  Future<List<Booking>> getAllBookings() async {
    try {
      final snapshot =
          await _firestore.collection('bookings').orderBy('dateTime').get();

      print(
        "FirebaseBookingService: Found ${snapshot.docs.length} total bookings",
      );

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Defensive null checks and default values
        final studentId = data['studentId'] ?? '';
        final lecturer = data['lecturer'] ?? '';
        final timestamp = data['dateTime'] as Timestamp?;
        final dateTime =
            timestamp != null ? timestamp.toDate() : DateTime.now();
        final topic = data['topic'] ?? '';
        final notes = data['notes'] ?? '';
        final status = data['status'] ?? 'pending';

        return Booking(
          id: doc.id,
          studentId: studentId,
          lecturer: lecturer,
          dateTime: dateTime,
          topic: topic,
          notes: notes,
          status: status,
        );
      }).toList();
    } catch (e, stack) {
      print("FirebaseBookingService: Error fetching all bookings: $e");
      print(stack);
      throw e;
    }
  }
}
