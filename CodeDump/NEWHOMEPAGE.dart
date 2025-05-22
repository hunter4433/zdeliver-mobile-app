import 'package:flutter/material.dart';
import 'package:mrsgorilla/mapView.dart';
import 'package:mrsgorilla/Home_Recommend_section/standardGorillaCart.dart';
import 'package:mrsgorilla/Home_Recommend_section/gorillaFruitcart.dart';
import 'package:mrsgorilla/Home_Recommend_section/customize_cart.dart';

import 'dart:convert';
import '../lib/menu/support.dart';
import "package:mrsgorilla/menu/Addreass.dart";
import "package:mrsgorilla/address_book.dart";
import "package:mrsgorilla/menu/order_details.dart";
import 'package:mrsgorilla/menu/order_history.dart';
import 'package:mrsgorilla/menu/notifications.dart';
import 'package:mrsgorilla/menu/cart_history.dart';
import 'package:mrsgorilla/searchResult.dart';
import 'package:http/http.dart' as http;
// import '../CodeDump/basket.dart';
import 'package:flutter/material.dart';
import 'package:mrsgorilla/orderPlace.dart';
import 'package:mrsgorilla/searchPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mrsgorilla/checkoutPage.dart';
import 'package:mrsgorilla/address_selection.dart';
import 'package:mrsgorilla/address_selection_sheet.dart';
import 'package:mrsgorilla/auth_page.dart';
import 'package:google_fonts/google_fonts.dart';


class newDmeo extends StatefulWidget {
  const newDmeo({Key? key}) : super(key: key);

  @override
  State<newDmeo> createState() => _newDmeo();
}

class _newDmeo extends State<newDmeo> with SingleTickerProviderStateMixin {
  // Track which recommended item is selected
  int? selectedRecommendedIndex;

  // Animation controller for the menu drawer
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _scrimAnimation;
  bool _isDrawerOpen = false;
  List<dynamic> _lowPriceItems = [];
  bool _isLoading = true;
  bool addressLoading=true;
  String _errorMessage = '';
  late final FlutterSecureStorage _secureStorage;
  String? savedAddress;

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _initializePage();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _drawerAnimation = Tween<double>(begin: -300, end: 0).animate(
        CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut)
    );

    _scrimAnimation = Tween<double>(begin: 0, end: 0.5).animate(
        CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      if (_isDrawerOpen) {
        _drawerController.reverse();
      } else {
        _drawerController.forward();
      }
      _isDrawerOpen = !_isDrawerOpen;
    });
  }


  Future<void> _initializePage() async {
    // Retrieve saved address first
    savedAddress = await _secureStorage.read(key: 'saved_address');

   // Update loading state
    setState(() {
      addressLoading= false;
    });
  }


  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Upper section with background image
                Container(
                  height: 217,
                  child: Stack(
                    children: [
                      // Map as the background - using Positioned.fill to ensure it fills the container
                      // and properly receives gestures


                      // SafeArea ensures elements don't overlap system UI elements
                      SafeArea(
                        bottom: false,
                        child: Column(
                          children: [
                            // App Bar with Search and title
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Menu and profile icons row
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: _toggleDrawer,
                                          child: const Icon(
                                            Icons.menu,
                                            color: Colors.black,
                                            size: 35,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),

                                  // Home - Location text
                                  addressLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : Padding(
                                    padding: const EdgeInsets.only(left: 20, top: 15, bottom: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        const SizedBox(width: 10), // Add some spacing

                                      ],
                                    ),
                                  ),
                                  // Search bar
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.white,
                                    ),

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

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFF0CB), Colors.white],
                      stops: [0.5, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        height: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white,
                            width: 6.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.13),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9), // Adjusted for the thicker border
                          child: MapScreen(
                            containerHeight: 180,
                            isEmbedded: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Recommended for you section
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recommended for you',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Recommended items
                _buildRecommendedItem(
                  index: 0,
                  title: 'Standard Vegetable Cart',
                  subtitle: 'includes 13 vegetables',
                  time: '7 min',
                  backgroundColor: Colors.white,
                  imagePath: 'assets/images/yellow_truck_2-removebg-preview (1).png',
                ),
                _buildRecommendedItem(
                  index: 1,
                  title: 'Standard Fruit Cart',
                  subtitle: 'includes 15 fruits',
                  time: '11 min',
                  backgroundColor: Colors.white,
                  imagePath: 'assets/images/homefruitcart.png',
                ),
                _buildRecommendedItem(
                  index: 2,
                  title: 'Customized cart',
                  subtitle: 'any 13 vegitables and fruits',
                  time: '17 min',
                  backgroundColor: Colors.white,
                  imagePath: 'assets/images/homecustomizecart.png',
                ),

                SizedBox(height: 15,),

                Divider(height: 40,),


                // Bottom branding
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        "Zdeliver",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Text(
                        "your personalized sabzi cart",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AnimatedBuilder(
              animation: _scrimAnimation,
              builder: (context, child) {
                return _isDrawerOpen
                    ? GestureDetector(
                  onTap: _toggleDrawer,
                  child: Container(
                    color: Colors.black.withOpacity(_scrimAnimation.value),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                )
                    : const SizedBox.shrink();
              },
            ),

          // Animated drawer
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_drawerAnimation.value, 0),
                  child: Container(
                    width: 300,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(10,80,10,10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Menu",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: _toggleDrawer,
                                child: const Icon(Icons.close, size: 24),
                              ),
                            ],
                          ),
                        ),

                        // Profile section
                        Container(
                          margin: const EdgeInsets.all(10), // Margin from all sides
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F8FF), // Background color
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          child: Row(
                            children: [
                              // Circular Profile Icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFB7CA79),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    "KG",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Profile Information and "Edit Profile" at Bottom Right
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "My Profile",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Text(
                                      "+918275451335",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4,),

                                    // Aligning "Edit Profile" to Bottom Right
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min, // Prevents Row from expanding full width
                                        children: const [
                                          Text(
                                            "Edit Profile",
                                            style: TextStyle(fontSize: 13,
                                              color: Color(0xFF3F2E78),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF3F2E78)), // iOS-style arrow
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Menu items
                        _buildMenuItem('assets/images/menu1.png', "Support", SupportScreen()),
                        _buildMenuItem('assets/images/menu2.png', "My history", OrderHistoryScreen()),
                        // _buildMenuItem('assets/images/menu3.png', "My Baskets", BasketPage()),
                        _buildMenuItem('assets/images/menu4.png', "Address book", AddressBookPage()),
                        _buildMenuItem('assets/images/menu5.png', "Vegetables quality", OrderDetailsPage()),
                        _buildMenuItem('assets/images/menu6.png', "Notifications", NotificationsScreen()),
                        _buildMenuItem('assets/images/menu7.png', "Share app", NotificationsScreen()),
                        _buildMenuItem('assets/images/menu8.png', "About us", NotificationsScreen()),
                        _buildMenuItem('assets/images/menu8.png', "Log Out", LoginScreen()),
                      ],
                    ),
                  ),
                );
              },
            ),


            // Sticky buttons at the bottom right corner

          ],
        ),

      ),

    );
  }

  Widget _buildMenuItem(String imagePath, String title, Widget destination) {
    return GestureDetector(
      onTap: () {
        _toggleDrawer(); // Close the drawer first
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.leagueSpartan(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New helper method to build recommended items with images and clickable functionality
  Widget _buildRecommendedItem({
    required int index,
    required String title,
    required String subtitle,
    required String time,
    required Color backgroundColor,
    required String imagePath,
  }) {
    // Check if this item is selected
    bool isSelected = selectedRecommendedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle selection - if already selected, deselect it
          if (selectedRecommendedIndex == index) {
            selectedRecommendedIndex = null;
          } else {
            selectedRecommendedIndex = index;

            // Add navigation based on the selected index
            switch (index) {
              case 0:
              // Show standard gorilla cart bottom sheet instead of navigating
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.7,
                    minChildSize: 0.5,
                    maxChildSize: 0.95,
                    builder: (_, controller) {
                      return StandardGorillaCartBottomSheet();
                    },
                  ),
                );
                break;
              case 1:
              // Show fruit cart bottom sheet instead of navigating
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.7,
                    minChildSize: 0.5,
                    maxChildSize: 0.95,
                    builder: (_, controller) {
                      return FruitCartBottomSheet();
                    },
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => customize_cart()),
                );
                break;

            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(10,0,10,0),
        padding: const EdgeInsets.fromLTRB(0,12,10,12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          // Only show border and shadow when selected
          border:
          isSelected
              ? Border.all(color: Colors.grey.shade400, width: 1.5)
              : null,
          boxShadow:
          isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image instead of icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 75,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.leagueSpartan(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: GoogleFonts.leagueSpartan(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: GoogleFonts.leagueSpartan(color:Color(0xFF17A773),
                    fontWeight: FontWeight.w500,
                    fontSize: 20, // Larger font size
                  ),
                ),
                Center(child: Text(
                  'away',
                  style: GoogleFonts.leagueSpartan(
                    fontWeight: FontWeight.w500,
                    fontSize: 14, // Smaller font size
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



Future<bool> sendVendorNotification() async {
  try {
    // API endpoint from your Postman example
    const String url = 'http://3.111.39.222/api/v1/notifisent/send-notification';

    // Request payload based on your Postman example
    Map<String, dynamic> payload = {
      "user_id": 1,
      "booking_order_id": 2,
      "vendor_id": 1
    };

    // Make POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add any additional headers if needed, like authorization
      },
      body: jsonEncode(payload),
    );

    // Check if request was successful
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Notification sent successfully: ${data['message']}");
      return true;
    } else {
      print("Failed to send notification. Status code: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Error sending notification: $e");
    // Consider showing an error message to the user
    return false;
  }
}




class CartBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0F8FF),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),



            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(

                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  border: Border.all(color: Colors.grey.shade300), // Grey border
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: InkWell(
                  onTap: () {
                    // Add navigation logic for changing address
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddressBookPage()), // Replace with your page
                    );

                  },
                  borderRadius: BorderRadius.circular(12), // Ensures ripple effect follows rounded corners
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change address',
                          style: TextStyle(fontSize: 16),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Katik Gadade',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hs no. 15, Sharadanagar, karjat, mirajgaon road,\n414402, dist- ahmednagar.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Phone number : 8275451335',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              child: ElevatedButton(
                onPressed: () async {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(child: CircularProgressIndicator());
                    },
                  );

                  // Make API call
                  bool success = await sendVendorNotification();

                  // Close loading indicator
                  Navigator.pop(context);

                  // if (success) {
                  // Navigate to next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderPlacedPage()),
                  );
                  // } else {
                  //   // Show error message
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text('Failed to send notification. Please try again.')),
                  //   );
                  // }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF15A25), // Button color
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32), // Rounded corners
                    side: BorderSide(color: Colors.white, width: 2.5), // White border
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Frame 522 (1).png', // Replace with your image path
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Call cart at this address',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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


}

