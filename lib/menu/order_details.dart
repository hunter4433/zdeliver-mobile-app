import 'package:flutter/material.dart';



class OrderDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor:Color(0xFFF0F8FF),
      appBar: AppBar(backgroundColor: Colors.white,
        title: Text('Order Details',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 21),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // App Bar with back button
                // Main content area with scroll
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80), // Add padding for bottom button
                    children: [
                      // Delivery details card
                      Card(
                        color: Colors.white,
                        margin: const EdgeInsets.all(12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// ✅ Address Section
                              const Text(
                                'Cart delivered at',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Text(
                                'Hs no. 15 shardanaganagri, mirajgaon road, karhat',
                                style: TextStyle(fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),


                              /// ✅ Date Section (Left Text - Right Value)
                              Row(


                                children: const [
                                  Text(
                                    'Date',
                                    style: TextStyle(fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width:170 ,),
                                  Text(
                                    '11/03/2025',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),


                              /// ✅ Cart Ordered Time (Left Text - Right Time)
                              Row(


                                children: const [
                                  Text(
                                    'Cart Ordered at',
                                    style: TextStyle(fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width:87 ,),
                                  Text(
                                    '11:30 AM',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),


                              /// ✅ Cart Arrived Time (Left Text - Right Time)
                              Row(


                                children: const [
                                  Text(
                                    'Cart Arrived at',
                                    style: TextStyle(fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width:95 ,),
                                  Text(
                                    '11:37 AM',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),


                      // Items purchased card
                      Card(color: Colors.white,
                        margin: const EdgeInsets.all(12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '5 Items bought',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),


                              // Onion item
                              buildItemRow(
                                  'assests/oninon.png',
                                  'Onion',
                                  '1 Kg',
                                  'Rs. 65'
                              ),
                              const SizedBox(height: 12),


                              // Cauliflower item
                              buildItemRow(
                                  'assests/potato_png2391.png',
                                  'Cauliflower',
                                  '2 Kg',
                                  'Rs. 80'
                              ),
                              const SizedBox(height: 12),


                              // Brinjal item
                              buildItemRow(
                                  'assests/color-capsicum.png',
                                  'Brinjal',
                                  '1 Kg',
                                  'Rs. 70'
                              ),
                              const SizedBox(height: 12),


                              // Carrot item
                              buildItemRow(
                                  'assests/Frame 605.png',
                                  'Carrot',
                                  '2 Kg',
                                  'Rs. 120'
                              ),
                              const SizedBox(height: 12),


                              // Bottle gourd item
                              buildItemRow(
                                  'assests/oninon.png',
                                  'Bottle gourd',
                                  '1 Kg',
                                  'Rs. 50'
                              ),
                            ],
                          ),
                        ),
                      ),


                      // Payment details card
                      Container(
                        margin: const EdgeInsets.fromLTRB(5, 15, 0, 0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Paid : Rs. 120",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Mode : online",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),


                            const SizedBox(height: 10),
                            const Text(
                              "Bill Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Items Total", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                                Text(
                                  "Rs. 140.00",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomPaint(
                                painter: DashPainter(color: Colors.grey),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Discounts",
                                      style: TextStyle(color: Color(0xFF4A8F3C), fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  ],
                                ),
                                const Text(
                                  "Rs. 40.00",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A8F3C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomPaint(
                                painter: DashPainter(color: Colors.grey),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text("Platform fee", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                                    const SizedBox(width: 10),
                                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  ],
                                ),
                                const Text(
                                  "Rs. 8.00",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomPaint(
                                painter: DashPainter(color: Colors.grey),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text("Delivery charge", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                                    const SizedBox(width: 10),
                                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  ],
                                ),
                                const Text(
                                  "Rs. 12.00",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomPaint(
                                painter: DashPainter(color: Colors.grey),
                              ),
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Grand Total",
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                                ),
                                Text(
                                  "Rs. 120.00",
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            // Fixed button at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 18),
                      height: 58,
                      width: MediaQuery.of(context).size.width * 0.9,  // ✅ Reduced the button width
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C9A2A),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: Colors.white,  // ✅ Added white border
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,  // ✅ Added subtle shadow
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'Repeat Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: const Row(
                              children: [
                                Text(
                                  'View cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }


  // Helper method to build item rows
  Widget buildItemRow(String imagePath, String name, String quantity, String price) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          quantity,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  // Helper method to build bill detail rows
  Widget buildBillRow(
      String label,
      String value, {
        Color firstColor = Colors.black,
        Color secondColor = Colors.black,
        FontWeight fontWeight = FontWeight.normal,
        bool showInfoIcon = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: fontWeight,
                  color: firstColor,
                ),
              ),
              if (showInfoIcon)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: fontWeight,
              color: secondColor,
            ),
          ),
        ],
      ),
    );
  }
}
class DashPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;


  DashPainter({
    required this.color,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;


    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// You'll need to add these images to your assets folder and update the pubspec.yaml
// Or replace the image widgets with appropriate Image.asset or Image.network calls

