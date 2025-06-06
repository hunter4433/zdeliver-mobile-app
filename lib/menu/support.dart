import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String phoneNumber = "+91-8275451335";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0), // Deep purple color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 15, top: 5),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                ' Support',
                style: GoogleFonts.leagueSpartan(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        child: ListView(
          children: [
            // Call us Section
            Text(
              "Call us",
              style: GoogleFonts.leagueSpartan(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Have questions? Talk to our representative and get all the answers you need. Shop with confidence on Z Deliver!",
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  phoneNumber,
                  style: GoogleFonts.leagueSpartan(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: phoneNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Phone number copied")),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(50, 134, 22, 1),
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              icon: Icon(Icons.phone, size: 20, color: Colors.white),
              label: Text(
                "Call now",
                style: GoogleFonts.leagueSpartan(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                // Handle call functionality
                final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not launch phone app")),
                  );
                }
              },
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey.shade300, thickness: 1.5),
            SizedBox(height: 10),
            // FAQs Section
            Text(
              "FAQs",
              style: GoogleFonts.leagueSpartan(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Find quick answers to common questions and shop confidently with Z Deliver.",
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16),

            // FAQ items
            buildFaqItem(
              "What is the Average time for cart to reach the address",
            ),
            buildFaqItem(
              "What is the Average time for cart to reach the address",
            ),
            buildFaqItem(
              "What is the Average time for cart to reach the address",
            ),
            buildFaqItem(
              "What is the Average time for cart to reach the address",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFaqItem(String question) {
    return ExpansionTile(
      title: Text(
        question,
        style: GoogleFonts.leagueSpartan(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 20.0),
          child: Text(
            "The average time for delivery is 30–45 minutes depending on location and order type.",
            style: GoogleFonts.leagueSpartan(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
