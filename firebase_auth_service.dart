import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_model.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseAuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Register a new student
  Future<String?> registerStudent(Student student) async {
    try {
      // Create user in Firebase Auth
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: student.email,
        password: student.password,
      );

      // Save extra info to Firestore
      try {
        await _firestore.collection('students').doc(userCred.user!.uid).set({
          'studentId': student.studentId,
          'email': student.email,
          'contactNumber': student.contactNumber,
        });
      } catch (e) {
        return 'Failed to save student profile: $e';
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Error
    }
  }

  Future<String?> uploadProfileImage(XFile image) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    await ref.putFile(File(image.path));
    final url = await ref.getDownloadURL();
    await _firestore.collection('students').doc(uid).update({
      'profileImageUrl': url,
    });

    return url;
  }

  // Log in existing student
  Future<String?> loginStudent(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Get current student UID
  String? get currentStudentUid => _auth.currentUser?.uid;

  // Get student info from Firestore
  Future<Student?> fetchStudentProfile() async {
    final uid = currentStudentUid;
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('students').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Student(
        studentId: data['studentId'],
        email: data['email'],
        password: '', // not stored here
        contactNumber: data['contactNumber'],
        profileImageUrl: '',
      );
    } catch (e) {
      print('Error fetching student profile: $e');
      return null;
    }
  }

  Future<void> updateStudentProfile({
    required String email,
    required String contactNumber,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Update Firestore
    await _firestore.collection('students').doc(uid).update({
      'email': email,
      'contactNumber': contactNumber,
    });

    // Optionally update Firebase Auth email too:
    if (_auth.currentUser?.email != email) {
      // ignore: deprecated_member_use
      await _auth.currentUser?.updateEmail(email);
    }
  }

  Future<User?> loginAdmin(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        print("Admin login successful: ${user.uid}");
        // Verify admin document and isAdmin field
        final adminDoc =
            await _firestore.collection('admins').doc(user.uid).get();
        if (adminDoc.exists && adminDoc.data()?['isAdmin'] == true) {
          return user;
        } else {
          print("Admin login failed: User is not an admin");
          await FirebaseAuth.instance.signOut();
          return null;
        }
      }
    } catch (e) {
      print("Admin login failed: $e");
    }
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
