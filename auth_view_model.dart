import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultationbookingapp/models/admin_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/firebase_auth_service.dart';
import 'package:image_picker/image_picker.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _firebaseAuthService;

  AuthViewModel(this._firebaseAuthService) {
    // Listen to Firebase auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        print('AuthViewModel: authStateChanges user logged in: ${user.uid}');
        if (currentStudent == null) {
          currentStudent = await _firebaseAuthService.fetchStudentProfile();
        }
        print(
          'AuthViewModel: authStateChanges fetched currentStudent = $currentStudent',
        );
      } else {
        print('AuthViewModel: authStateChanges user logged out');
        currentStudent = null;
      }
      notifyListeners();
    });
  }

  String? errorMessage;
  Student? currentStudent;

  Future<void> initializeCurrentStudent() async {
    final user = _firebaseAuthService.currentStudentUid;
    print('AuthViewModel: currentStudentUid = \n$user');
    if (user != null) {
      currentStudent = await _firebaseAuthService.fetchStudentProfile();
      print('AuthViewModel: fetched currentStudent = \n$currentStudent');
      notifyListeners();
    } else {
      print('AuthViewModel: No current user found during initialization');
    }
  }

  Future<bool> registerStudent(Student student) async {
    final result = await _firebaseAuthService.registerStudent(student);
    if (result == null) {
      // Registration success, fetch profile
      currentStudent = await _firebaseAuthService.fetchStudentProfile();
      errorMessage = null;
      notifyListeners();
      return true;
    } else {
      // Registration failed
      errorMessage = result;
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadProfileImage(XFile image) async {
    final url = await _firebaseAuthService.uploadProfileImage(image);
    currentStudent = await _firebaseAuthService.fetchStudentProfile();
    notifyListeners();
    return url;
  }

  Future<void> updateProfile(String email, String contact) async {
    await _firebaseAuthService.updateStudentProfile(
      email: email,
      contactNumber: contact,
    );
    currentStudent = await _firebaseAuthService.fetchStudentProfile();
    notifyListeners();
  }

  Future<bool> loginStudent(String email, String password) async {
    print('AuthViewModel: loginStudent called with email: \$email');
    final result = await _firebaseAuthService.loginStudent(email, password);
    errorMessage = result;
    print('AuthViewModel: loginStudent result: \$result');
    if (result == null) {
      print('AuthViewModel: loginStudent succeeded, fetching student profile');
      currentStudent = await _firebaseAuthService.fetchStudentProfile();
      if (currentStudent == null) {
        errorMessage = 'Student profile not found.';
        print('AuthViewModel: loginStudent failed - student profile not found');
        notifyListeners();
        return false;
      }
      print(
        'AuthViewModel: loginStudent fetched currentStudent = \$currentStudent',
      );
      notifyListeners();
      return true;
    } else {
      print('AuthViewModel: loginStudent failed with error: \$result');
    }
    notifyListeners();
    return false;
  }

  registerAdmin(Admin admin) {}

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    currentStudent = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuthService.sendPasswordResetEmail(email);
  }
}
