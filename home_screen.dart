/*
N.R Mabunda   223037726
A.T Rantoa    222027706
M.C Munyai    223004579
N.T Ngcobo    222006273
T.A Mokaleng  223029362
K Mkhatshwa   222078465
L.W Rabothata 223062005

Question: homescreen.dart
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/booking_view_model.dart';
import 'booking_form.dart';
import 'booking_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedStatus = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final bookingVM = Provider.of<BookingViewModel>(context, listen: false);
    if (authVM.currentStudent != null) {
      bookingVM.loadBookings(authVM.currentStudent!.studentId);
    }
  }

  List<String> getStatusOptions() {
    return ['All', 'Pending', 'Confirmed', 'Cancelled'];
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final bookingVM = Provider.of<BookingViewModel>(context);

    List filteredBookings =
        selectedStatus == 'All'
            ? bookingVM.bookings
            : bookingVM.bookings
                .where(
                  (b) => b.status.toLowerCase() == selectedStatus.toLowerCase(),
                )
                .toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          bookingVM.loadBookings(authVM.currentStudent!.studentId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF9B51E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome, ${authVM.currentStudent?.studentId ?? 'Student'}!",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Take a look at your upcoming consultations!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Filter by Status",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<String>(
                  value: selectedStatus,
                  items:
                      getStatusOptions()
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "My Consultations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                filteredBookings.isEmpty
                    ? const Center(child: Text("No bookings yet."))
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        final date = DateFormat(
                          'yyyy-MM-dd',
                        ).format(booking.dateTime);
                        final time = DateFormat(
                          'HH:mm',
                        ).format(booking.dateTime);
                        Color statusColor;
                        IconData statusIcon;
                        switch (booking.status.toLowerCase()) {
                          case 'pending':
                            statusColor = Colors.orange.shade200;
                            statusIcon = Icons.access_time;
                            break;
                          case 'confirmed':
                            statusColor = Colors.green.shade200;
                            statusIcon = Icons.check_circle;
                            break;
                          case 'cancelled':
                            statusColor = Colors.red.shade200;
                            statusIcon = Icons.cancel;
                            break;
                          default:
                            statusColor = Colors.grey.shade200;
                            statusIcon = Icons.info;
                        }
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingDetail(booking: booking),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    date,
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Consultation with ${booking.lecturer}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        time,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Lecturer: ${booking.lecturer}",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              statusIcon,
                                              size: 16,
                                              color: Colors.grey[800],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              booking.status[0].toUpperCase() +
                                                  booking.status.substring(1),
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingForm()),
          );
        },
      ),
    );
  }
}
