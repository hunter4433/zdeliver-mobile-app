import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_CardData> cardDataList = [
      _CardData(
        icon: Icons.verified_user,
        title: "Personalised Experience",
        description:
            "Handpicked veggies, tailored for your needs — just like shopping for your family.",
      ),
      _CardData(
        icon: Icons.access_time,
        title: "Quick & Light Purchasing",
        description:
            "Swift, hassle-free buying with no heavy loads — pure convenience delivered.",
      ),
      _CardData(
        icon: Icons.credit_card,
        title: "Smooth Escape from Chaos",
        description:
            "Skip the crowded mandi rush — enjoy fresh shopping at your doorstep.",
      ),
    ];

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
                ' About Us',
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
              "Our Story",
              style: GoogleFonts.leagueSpartan(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Would you trust a stranger to choose what your family eats every day? We wouldn’t. And we believe you shouldn’t have to.\n\nFresh vegetables are not a product — they are a responsibility. For generations, families handpicked every leaf, every tomato, every potato — because food is trust, not just a transaction.\n \nBut today, in a world that’s too busy to care, that trust is being lost. At PreetEnterprises, we’re bringing it back. \n\n We don’t just deliver vegetables. We deliver your choices. We deliver the care you would show if you were standing there yourself. We are building India’s first personalised mandi-on-wheels — fast, fresh, sustainable, and trustworthy.",
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Why choose our services?",
                style: GoogleFonts.leagueSpartan(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 16),
            Column(
              children:
                  cardDataList.map((cardData) => _buildCard(cardData)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_CardData data) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFFFD740),
              child: Icon(data.icon, size: 30, color: Colors.deepPurple),
            ),
            SizedBox(height: 16),
            Text(
              data.title,
              style: GoogleFonts.leagueSpartan(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              data.description,
              style: GoogleFonts.leagueSpartan(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  final IconData icon;
  final String title;
  final String description;

  _CardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
