import 'package:flutter/material.dart';
import '../models/admin_model.dart';
import '../services/firebase_admin_service.dart';
import '../models/booking_model.dart';
import '../services/firebase_booking_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirebaseAdminService _adminService;
  final FirebaseBookingService _bookingService;

  AdminViewModel(this._adminService, this._bookingService);

  String? errorMessage;
  Admin? currentAdmin;
  List<Booking> _allBookings = [];
  List<Booking> get allBookings => _allBookings;

  Future<void> updateBookingStatus(Booking updatedBooking) async {
  await _bookingService.updateBooking(updatedBooking);
  await loadAllBookings(); 
}


  Future<bool> registerAdmin(Admin admin) async {
    final result = await _adminService.registerAdmin(admin);
    errorMessage = result;
    if (result == null) {
      currentAdmin = admin;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> loginAdmin(String email, String password) async {
    final result = await _adminService.loginAdmin(email, password);
    errorMessage = result;
    if (result == null) {
      currentAdmin = Admin(email: email, password: password);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> loadAllBookings() async {
    _allBookings = await _bookingService.getAllBookings();
    notifyListeners();
  }

  Future<void> deleteBooking(String bookingId) async {
    await _bookingService.deleteBooking(bookingId);
    await loadAllBookings();
  }

  void searchByStudentId(String id) {
    _allBookings = _allBookings.where((b) => b.studentId.contains(id)).toList();
    notifyListeners();
  }

  void filterByDate(DateTime from, DateTime to) {
    _allBookings = _allBookings
        .where((b) => b.dateTime.isAfter(from) && b.dateTime.isBefore(to))
        .toList();
    notifyListeners();
  }
}
