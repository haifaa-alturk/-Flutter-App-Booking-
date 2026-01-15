import 'package:cozy_app/controllers/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/booking.dart';
import '../home/apartment_model.dart';
import 'booking_page.dart';

class BookingDetailsPage extends StatelessWidget {
  final Booking booking;
  final Apartment apartment;

  BookingDetailsPage({
    super.key,
    required this.booking,
    required this.apartment,
  });

  final BookingController bookingController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Details"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.apartmentName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(height: 10),

            Text("Owner Phone: ${apartment.ownerPhone}",
                style: TextStyle(fontSize: 16, color: Colors.blue)),

            SizedBox(height: 20),

            Text("From: ${booking.fromDate.toLocal().toString().split(' ')[0]}"),
            Text("To: ${booking.toDate.toLocal().toString().split(' ')[0]}"),
            Text("Guests: ${booking.guests}"),
            Text("Price per night: \$${booking.pricePerNight}"),
            Text("Total: \$${booking.totalPrice}"),

            Spacer(),

            // EDIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => BookingPage(
                        apartment: apartment,
                        //oldBooking: booking, // نرسل الحجز القديم
                         existingBooking: {
    'id': booking.id,
    'from': booking.fromDate.toIso8601String(),
    'to': booking.toDate.toIso8601String(),
  },
                      ));
                },
                child: Text("Edit Booking", style: TextStyle(fontSize: 18)),
              ),
            ),

            SizedBox(height: 12),

            // CANCEL BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Get.defaultDialog(
                    title: "Cancel Booking",
                    middleText: "Do you want to cancel this booking?",
                    onConfirm: () {
                      bookingController.cancelBooking(booking.id);
                      Get.back();
                      Get.back();
                      Get.snackbar("Cancelled", "Booking cancelled",
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                    },
                    onCancel: () {},
                  );
                },
                child: Text("Cancel Booking", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
