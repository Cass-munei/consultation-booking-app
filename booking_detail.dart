

import 'package:consultationbookingapp/viewmodels/auth_view_model.dart';
import 'package:consultationbookingapp/viewmodels/booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import 'booking_form.dart';

class BookingDetail extends StatelessWidget {
  final Booking booking;

  const BookingDetail({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Booking Details"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit Booking",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingForm(existingBooking: booking),
                ),
              );

              // After editing, refresh the bookings
              final bookingVM = Provider.of<BookingViewModel>(
                context,
                listen: false,
              );
              final authVM = Provider.of<AuthViewModel>(context, listen: false);
              final studentId = authVM.currentStudent?.studentId;

              if (studentId != null) {
                await bookingVM.loadBookings(studentId);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF1E88E5)),
                title: const Text("Lecturer"),
                subtitle: Text(booking.lecturer),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF1E88E5),
                ),
                title: const Text("Date & Time"),
                subtitle: Text(booking.dateTime.toString()),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.topic, color: Color(0xFF1E88E5)),
                title: const Text("Topic"),
                subtitle: Text(booking.topic),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.note, color: Color(0xFF1E88E5)),
                title: const Text("Notes"),
                subtitle: Text(
                  booking.notes.isNotEmpty ? booking.notes : "None",
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.info, color: Color(0xFF1E88E5)),
                title: const Text("Status"),
                subtitle: Text(
                  booking.status,
                  style: TextStyle(
                    color:
                        booking.status == 'confirmed'
                            ? Colors.green
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Example action buttons (can be customized as needed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    minimumSize: const Size(120, 45),
                  ),
                  onPressed: () {
                    // TODO: Implement confirm booking action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Booking confirmed")),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    minimumSize: const Size(120, 45),
                  ),
                  onPressed: () async {
                    final bookingVM = Provider.of<BookingViewModel>(context, listen: false);
                    final authVM = Provider.of<AuthViewModel>(context, listen: false);
                    final studentId = authVM.currentStudent?.studentId;

                    if (studentId != null) {
final success = await bookingVM.deleteBooking(booking.id, studentId);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Booking cancelled successfully")),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(bookingVM.errorMessage ?? "Failed to cancel booking")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User not logged in")),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
