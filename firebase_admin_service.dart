import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_model.dart';

class FirebaseAdminService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<String?> registerAdmin(Admin admin) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: admin.email,
        password: admin.password,
      );

      await _firestore.collection('admins').doc(userCred.user!.uid).set({
        'email': admin.email,
        'isAdmin': true,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> loginAdmin(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Check isAdmin in Firestore
      final doc = await _firestore.collection('admins').doc(cred.user!.uid).get();
      if (!doc.exists || !(doc.data()?['isAdmin'] ?? false)) {
        return 'Not an admin';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  String? get currentAdminUid => _auth.currentUser?.uid;
}
