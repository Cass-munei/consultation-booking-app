

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/booking_model.dart';

class BookingForm extends StatefulWidget {
  final Booking? existingBooking;

  const BookingForm({super.key, this.existingBooking});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _lecturers = ['Dr. Munyai', 'Prof.Mkhatshwa', 'Ms. Rantoa'];

  String? selectedLecturer;
  DateTime? selectedDateTime;
  String topic = '';
  String notes = '';

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      final booking = widget.existingBooking!;
      selectedLecturer = booking.lecturer;
      selectedDateTime = booking.dateTime;
      topic = booking.topic;
      notes = booking.notes;
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          selectedDateTime ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingVM = Provider.of<BookingViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final isEditing = widget.existingBooking != null;

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
        title: Text(
          widget.existingBooking != null ? 'Edit Booking' : 'New Booking',
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedLecturer,
                items:
                    _lecturers
                        .map(
                          (lecturer) => DropdownMenuItem(
                            value: lecturer,
                            child: Text(lecturer),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedLecturer = value),
                decoration: InputDecoration(
                  labelText: 'Select Lecturer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF1976D2),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator:
                    (value) =>
                        value == null ? 'Please select a lecturer' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  selectedDateTime == null
                      ? 'Select Date & Time'
                      : selectedDateTime.toString(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(context),
              ),
              if (selectedDateTime == null)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    'Date & time required',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: topic,
                decoration: InputDecoration(
                  labelText: 'Consultation Topic',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF1976D2),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                minLines: 1,
                maxLines: 2,
                onChanged: (value) => topic = value,
                validator:
                    (value) =>
                        value != null && value.length >= 20
                            ? null
                            : 'Minimum 20 characters',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: notes,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF1976D2),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                minLines: 1,
                maxLines: 3,
                onChanged: (value) => notes = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final isValid = _formKey.currentState?.validate() ?? false;
                  final hasDate = selectedDateTime != null;

                  if (!isValid || !hasDate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please complete all fields"),
                      ),
                    );
                    return;
                  }

                  final student = authVM.currentStudent;
                  if (student == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Error: student not logged in"),
                      ),
                    );
                    return;
                  }

                  final booking = Booking(
                    id: widget.existingBooking?.id ?? const Uuid().v4(),
                    studentId: student.studentId,
                    lecturer: selectedLecturer!,
                    dateTime: selectedDateTime!,
                    topic: topic,
                    notes: notes,
                    status: widget.existingBooking?.status ?? 'pending',
                  );

                  if (widget.existingBooking != null) {
                    final success = await bookingVM.updateBooking(booking);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Booking updated successfully"),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            bookingVM.errorMessage ??
                                "Failed to update booking",
                          ),
                        ),
                      );
                    }
                  } else {
                    final success = await bookingVM.addBooking(booking);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking submitted")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            bookingVM.errorMessage ??
                                "Failed to submit booking",
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
