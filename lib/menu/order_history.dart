import 'package:flutter/material.dart';
import 'package:mrsgorilla/menu/cart_history.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Order history',
                 style: GoogleFonts.leagueSpartan(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
               Text(
                'Check all your past orders and cart history',
                 style: GoogleFonts.leagueSpartan(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 25),
              _buildHistoryItem(context, 'All orders', null),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                child: const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              ),
              const SizedBox(height: 16),
              _buildHistoryItem(context, 'Standard Gorilla cart history', 'cart'),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                child: const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              ),
              const SizedBox(height: 16),
              _buildHistoryItem(context, 'Gorilla fruit cart history', 'cart'),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                child: const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              ),
              const SizedBox(height: 16),
              _buildHistoryItem(context, 'Customized cart history', 'cart'),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                child: const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              ),
              const SizedBox(height: 16),
              _buildHistoryItem(context, 'Customized order history', 'order'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: const Divider(height: 2, thickness: 1, color: Color(0xFFEEEEEE)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String title, String? type) {
    return GestureDetector(
      onTap: () {
        // TODO: Replace '123' with actual user ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartHistoryPage(
              userId: '1', // Replace with actual user ID
              historyType: type ?? 'all', // Use 'all' if no specific type is provided
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Color(0xFFF0F8FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFAFAFA),
            width: 2.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.leagueSpartan(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              size: 30,
              Icons.arrow_forward,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}