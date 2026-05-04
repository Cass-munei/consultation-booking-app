


import 'package:consultationbookingapp/services/firebase_admin_service.dart';
import 'package:consultationbookingapp/services/firebase_booking_service.dart';
import 'package:consultationbookingapp/views/landing_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_auth_service.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/booking_view_model.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'views/admin/admin_registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDoXmmdKSEvbRYHa6OMaT61E8aP_WNZCXk",
        authDomain: "consultation-app-8e79d.firebaseapp.com",
        projectId: "consultation-app-8e79d",
        storageBucket: "consultation-app-8e79d.firebasestorage.app",
        messagingSenderId: "71428686097",
        appId: "1:71428686097:web:94ac818cd4bc2eb1314cb0",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const ConsultationApp());
}

class ConsultationApp extends StatelessWidget {
  const ConsultationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final bookingService = FirebaseBookingService();
    final adminService = FirebaseAdminService();
    final adminVM = AdminViewModel(adminService, bookingService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => BookingViewModel(bookingService)),
        ChangeNotifierProvider(create: (_) => adminVM),
      ],
      child: Builder(
        builder: (context) {
          // Initialize currentStudent on app startup
          final authVM = Provider.of<AuthViewModel>(context, listen: false);
          authVM.initializeCurrentStudent();
          return MaterialApp(
            title: 'Consultation Booking App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const LandingScreen(), // Entry point (student login)
            routes: {'/admin': (_) => const AdminRegistrationScreen()},
          );
        },
      ),
    );
  }
}
