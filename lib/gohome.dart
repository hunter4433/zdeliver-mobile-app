import 'package:flutter/material.dart';
import 'package:mrsgorilla/mapView.dart';
import 'package:mrsgorilla/Home_Recommend_section/standardGorillaCart.dart';
import 'package:mrsgorilla/Home_Recommend_section/gorillaFruitcart.dart';
import 'package:mrsgorilla/Home_Recommend_section/customize_cart.dart';
import 'package:mrsgorilla/orderPlace.dart';
import 'dart:convert';
import 'menu/support.dart';
import "package:mrsgorilla/menu/Addreass.dart";
import "package:mrsgorilla/address_book.dart";
import "package:mrsgorilla/menu/order_details.dart";
import 'package:mrsgorilla/menu/order_history.dart';
import 'package:mrsgorilla/menu/notifications.dart';
import 'package:mrsgorilla/menu/cart_history.dart';
import 'package:http/http.dart' as http;
import 'package:mrsgorilla/menu/basket.dart';
import 'package:mrsgorilla/auth_page.dart';
import 'package:mrsgorilla/new_menu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePageWithMap extends StatefulWidget {
  const HomePageWithMap({Key? key}) : super(key: key);

  @override
  State<HomePageWithMap> createState() => _HomePageWithMapState();
}

class _HomePageWithMapState extends State<HomePageWithMap> with TickerProviderStateMixin {
  // Track which recommended item is selected
  int? selectedRecommendedIndex;

  // Animation controller for the menu drawer
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _scrimAnimation;
  bool _isDrawerOpen = false;
  bool _isCardExpanded = false;

  // Drag controller
  DraggableScrollableController _dragController = DraggableScrollableController();

  // Secure storage
  late final FlutterSecureStorage _secureStorage;
  String? savedAddress;
  bool addressLoading = true;

  // Animation controllers for the selection indicators
  Map<int, AnimationController> _selectionAnimControllers = {};
  Map<int, Animation<double>> _selectionAnimations = {};

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

    // Add listener to the drag controller to implement snap behavior
    _dragController.addListener(_handleDragUpdate);
  }

  void _handleDragUpdate() {
    if (_dragController.isAttached) {
      double position = _dragController.size;

      // If the user has dragged more than halfway, snap to the top, otherwise snap to the bottom
      if (!_isCardExpanded && position > 0.4) {
        _expandCard();
      } else if (_isCardExpanded && position < 0.4) {
        _minimizeCard();
      }
    }
  }

  Future<void> _initializePage() async {
    // Retrieve saved address
    savedAddress = await _secureStorage.read(key: 'saved_address');

    setState(() {
      addressLoading = false;
    });
  }

  @override
  void dispose() {
    _drawerController.dispose();
    // Dispose all animation controllers
    _selectionAnimControllers.forEach((key, controller) => controller.dispose());
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

  void _expandCard() {
    if (_dragController.isAttached) {
      _dragController.animateTo(
        0.66,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _isCardExpanded = true;
      });
    }
  }

  void _minimizeCard() {
    if (_dragController.isAttached) {
      _dragController.animateTo(
        0.15,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _isCardExpanded = false;
      });
    }
  }

  // New QR Code Modal function
  void _showQRCodeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.75), // Dim background
      backgroundColor: Colors.transparent, // Transparent background for modal
      builder: (BuildContext context) {
        // Dismiss when tapping outside the card
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          // This ensures taps outside the card are captured
          behavior: HitTestBehavior.opaque,
          child: GestureDetector(
            // This prevents taps on the card from dismissing
            onTap: () {},
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  elevation: 10,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 16),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Show this QR code to the cartboy",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: 240,
                          height: 240,
                          child: Image.asset(
                            'assets/images/qr_code.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFF3F2E78),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "Get your bill and approve what\nyou have bought",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> sendVendorNotification() async {
    try {
      const String url = 'http://3.111.39.222/api/v1/notifisent/send-notification';
      Map<String, dynamic> payload = {
        "user_id": 1,
        "booking_order_id": 2,
        "vendor_id": 1
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

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
      return false;
    }
  }

  void _showCartDetails(int index) {
    switch (index) {
      case 0:
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map as full-screen background
          MapScreen(
            containerHeight: MediaQuery.of(context).size.height,
            isEmbedded: false,
          ),

          // Top app bar with profile and menu - UPDATED
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.red.shade400,
                        radius: 20,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Kartik - Home",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Neelkanth boys hostel,Anu...",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Draggable bottom sheet with modified snap behavior
          DraggableScrollableSheet(
            initialChildSize: 0.60,
            minChildSize: 0.15,
            maxChildSize: 0.60,
            controller: _dragController,
            snap: true,
            snapSizes: [0.15, 0.60],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 0),
                          width: double.infinity,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),

                      // Promotional banner with updated gradient
                      Container(
                        width: double.infinity,
                        height: 135,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF3F2E78), Color(0xFF5421FF)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Hey Nirmala",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "call your first cart",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "25% off on your first bill",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                'assets/images/homecustomizecart.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Veggies or Fruit section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                        child: Text(
                          "veggies or fruit?",
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Vegetable cart option
                      _buildCartOption(
                        index: 0,
                        iconPath: 'assets/images/yellow_truck_2-removebg-preview (1).png',
                        title: 'Z vegetable cart',
                        subtitle: 'includes 13 vegetables',
                        time: '7 min',
                        checkText: 'check here',
                        color: Colors.yellow,
                      ),

                      // Fruit cart option
                      _buildCartOption(
                        index: 1,
                        iconPath: 'assets/images/homefruitcart.png',
                        title: 'Z fruit cart',
                        subtitle: 'includes 15 fruits',
                        time: '11 min',
                        checkText: 'check here',
                        color: Colors.orange,
                      ),

                      // Customized cart option
                      _buildCartOption(
                        index: 2,
                        iconPath: 'assets/images/homecustomizecart.png',
                        title: 'Z Customized cart',
                        subtitle: 'any 13 veggie & fruits',
                        time: '17 min',
                        checkText: 'check here',
                        color: Colors.purple,
                      ),

                      // QR code and Call your cart buttons (UPDATED)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                        child: Row(
                          children: [
                            // QR Code button with onTap handler for modal
                            GestureDetector(
                              onTap: _showQRCodeModal, // Added QR modal function call
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            // Call your cart button with more rounded right corners
                            Expanded(
                              child: GestureDetector(
                                onTap: selectedRecommendedIndex != null ? () async {
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

                                  // Navigate to next page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OrderPlacedPage()),
                                  );
                                } : null,
                                child: Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: selectedRecommendedIndex != null
                                        ? Colors.orange
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                      topRight: Radius.circular(24),
                                      bottomRight: Radius.circular(24),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delivery_dining,
                                        size: 28,
                                        color: selectedRecommendedIndex != null
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Call your cart now",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: selectedRecommendedIndex != null
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartOption({
    required int index,
    required String iconPath,
    required String title,
    required String subtitle,
    required String time,
    required String checkText,
    required Color color,
  }) {
    bool isSelected = selectedRecommendedIndex == index;

    // Create animation controller for this item if it doesn't exist
    if (!_selectionAnimControllers.containsKey(index)) {
      _selectionAnimControllers[index] = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      );
      _selectionAnimations[index] = Tween<double>(begin: 0, end: 50).animate(
        CurvedAnimation(
          parent: _selectionAnimControllers[index]!,
          curve: Curves.easeInOut,
        ),
      );
    }

    // Start or reverse animation based on selection state
    if (isSelected && !_selectionAnimControllers[index]!.isAnimating && _selectionAnimControllers[index]!.value == 0) {
      _selectionAnimControllers[index]!.forward();
    } else if (!isSelected && !_selectionAnimControllers[index]!.isAnimating && _selectionAnimControllers[index]!.value == 1) {
      _selectionAnimControllers[index]!.reverse();
    }

    return Container(height: 74,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.black87 : Colors.grey.shade500,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.15 : 0.05),
            blurRadius: isSelected ? 10 : 5,
            spreadRadius: isSelected ? 2 : 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Animated purple indicator for selected item
            if (isSelected)
              AnimatedBuilder(
                animation: _selectionAnimations[index]!,
                builder: (context, child) {
                  return Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: _selectionAnimations[index]!.value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF3F2E78), Color(0xFF745EBF)],
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Main content
            InkWell(
              onTap: () {
                if (index == 2) {
                  // Navigate to customize_cart page for the third option
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => customize_cart()),
                  );
                } else {
                  // Select this cart
                  setState(() {
                    selectedRecommendedIndex = index;
                  });
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12,vertical: 7),
                child: Row(
                  children: [
                    // Cart icon with color background
                    Container(
                      width: 60,
                      height: 74,
                      child: Image.asset(
                        iconPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 12),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                subtitle,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (index != 2) {
                                    setState(() {
                                      selectedRecommendedIndex = index;
                                    });
                                    _showCartDetails(index);
                                  }
                                },
                                child: Text(
                                  checkText,
                                  style: GoogleFonts.leagueSpartan(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.deepPurple,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Time indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          "away",
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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