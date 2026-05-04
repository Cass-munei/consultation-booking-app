import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/firebase_booking_service.dart';

class BookingViewModel extends ChangeNotifier {
  final FirebaseBookingService _bookingService;

  BookingViewModel(this._bookingService);

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? errorMessage;

  Future<void> loadBookings(String studentId) async {
    try {
      _isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      print("BookingViewModel: Loading bookings for studentId: $studentId");
      _bookings = await _bookingService.getBookingsForStudent(studentId);
      print("BookingViewModel: Loaded ${_bookings.length} bookings");
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("BookingViewModel: Error loading bookings: $e");
      errorMessage = "Failed to load bookings: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBooking(Booking booking) async {
    try {
      _isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      print("BookingViewModel: Adding booking for studentId: ${booking.studentId}");
      print("BookingViewModel: Booking details: ${booking.topic}, ${booking.lecturer}, ${booking.dateTime}");
      
      await _bookingService.addBooking(booking);
      print("BookingViewModel: Booking added successfully");
      
      // Reload bookings to refresh the list
      await loadBookings(booking.studentId);
      
      return true;
    } catch (e) {
      print("BookingViewModel: Error adding booking: $e");
      errorMessage = "Failed to add booking: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBooking(Booking booking) async {
    try {
      _isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      await _bookingService.updateBooking(booking);
      
      // Reload bookings to refresh the list
      await loadBookings(booking.studentId);
      
      return true;
    } catch (e) {
      print("BookingViewModel: Error updating booking: $e");
      errorMessage = "Failed to update booking: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBooking(String bookingId, String studentId) async {
    try {
      _isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      await _bookingService.deleteBooking(bookingId);
      
      // Reload bookings to refresh the list
      await loadBookings(studentId);
      
      return true;
    } catch (e) {
      print("BookingViewModel: Error deleting booking: $e");
      errorMessage = "Failed to delete booking: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}