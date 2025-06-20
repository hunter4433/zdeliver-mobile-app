import 'package:Zdeliver/Home_Recommend_section/customize_cart.dart';
import 'package:Zdeliver/Home_Recommend_section/gorillaFruitcart.dart';
import 'package:Zdeliver/Home_Recommend_section/standardGorillaCart.dart';
import 'package:Zdeliver/address_selection.dart';
import 'package:Zdeliver/coordinate_class.dart';
import 'package:Zdeliver/services/local_storage.dart';
import 'package:Zdeliver/map_screen_checkout.dart';
import 'package:Zdeliver/orderPlace.dart';
import 'package:Zdeliver/services/warehouse_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Zdeliver/new_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Zdeliver/home_address_selection_modal.dart';

class HomePageWithMap extends StatefulWidget {
  final CoordinatesPair? userPosition;
  final Warehouse? warehousePosition;

  HomePageWithMap({Key? key, this.userPosition, this.warehousePosition})
    : super(key: key);

  @override
  State<HomePageWithMap> createState() => _HomePageWithMapState();
}

class _HomePageWithMapState extends State<HomePageWithMap>
    with TickerProviderStateMixin {
  // Track which recommended item is selected
  int? selectedRecommendedIndex;

  LocalStorage _localStorage = LocalStorage();

  // Animation controller for the menu drawer
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _scrimAnimation;
  bool _isDrawerOpen = false;
  bool _isCardExpanded = false;

  // String _selectedAddress = "loading ...";
  String name = "Nirmala";
  String discountPercentage = "25";
  // Drag controller
  DraggableScrollableController _dragController =
      DraggableScrollableController();

  // Secure storage
  String? savedAddress;
  bool addressLoading = true;

  // Animation controllers for the selection indicators
  Map<int, AnimationController> _selectionAnimControllers = {};
  Map<int, Animation<double>> _selectionAnimations = {};

  CoordinatesPair? userPosition;
  Warehouse? warehousePosition;

  Future getUserAndWarehousePosition() async {
    try {
      // get user postion
      CoordinatesPair? userLocation =
          await LocalStorage().getUserPositionLocally();

      Warehouse? warehouseLocation = await WarehouseService().getWareHouse(
        userLocation!.latitude,
        userLocation.longitude,
        context,
      );

      if (warehouseLocation == null) {
        _showNotAvailableDialog();
        return;
      }
      if (warehouseLocation.isAvailable == false) {
        _showNotAvailableDialog();
      }
      setState(() {
        userPosition = userLocation;
        warehousePosition = warehouseLocation;
      });
    } catch (e) {
      print('Error getting user and warehouse position: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get user and warehouse position.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // _selectedAddress = widget.address ?? 'No address selected';
    userPosition = widget.userPosition;
    warehousePosition = widget.warehousePosition;
    // _selectedAddress = userPosition?.address ?? 'No address selected';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.warehousePosition!.isAvailable) {
        _showNotAvailableDialog();
      }
    });

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _drawerAnimation = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut),
    );

    _scrimAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut),
    );

    // Add listener to the drag controller to implement snap behavior
    _dragController.addListener(_handleDragUpdate);
  }

  void _showNotAvailableDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              "Oops! , Sorry ",
              style: GoogleFonts.leagueSpartan(
                color: Color.fromRGBO(63, 46, 120, 1),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            content: Text(
              'Right now we are not available in your city.',
              style: GoogleFonts.leagueSpartan(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color.fromRGBO(67, 67, 67, 1),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Color.fromRGBO(72, 72, 72, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Continue Browsing',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
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

  // Address Selection Sheet Methods
  // Updated function call example
  void showAddressSelectionSheet(int? selectedRecommendedIndex) {
    AddressSelectionSheet.showAddressSelectionSheet(
      context,
      (address) {
        _selectAddress(address);
      },
      selectedRecommendedIndex: selectedRecommendedIndex, // Pass the parameter
      // Pass the current
    );
  }

  void _selectAddress(String address) async {
    // Get the current position of the user
    CoordinatesPair? newPosition = await _localStorage.getUserPositionLocally();

    // Only call update if the position changed
    if (userPosition == null ||
        userPosition!.latitude != newPosition!.latitude ||
        userPosition!.longitude != newPosition.longitude) {
      // Update user position
      Warehouse? newWarehousePosition = await WarehouseService().getWareHouse(
        newPosition!.latitude,
        newPosition.longitude,
        context,
      );
      setState(() {
        userPosition = newPosition;
        warehousePosition = newWarehousePosition;
      });
    }
    if (warehousePosition == null || !warehousePosition!.isAvailable) {
      // Close loading indicator
      // Navigator.pop(context);
      _showNotAvailableDialog();
      return;
    }
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Make API call here
      // bool success = await sendVendorNotification();

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 2));

      // Close loading indicator
      Navigator.pop(context);

      // Navigate to next page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderPlacedPage()),
      );
    } catch (e) {
      // Close loading indicator
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    // Dispose all animation controllers
    _selectionAnimControllers.forEach(
      (key, controller) => controller.dispose(),
    );
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
                            'assets/images/Image.jpg',
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
      const String url =
          'http://3.111.39.222/api/v1/notifisent/send-notification';
      Map<String, dynamic> payload = {
        "user_id": 1,
        "booking_order_id": 2,
        "vendor_id": 1,
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
        print(
          "Failed to send notification. Status code: ${response.statusCode}",
        );
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
          builder:
              (context) => DraggableScrollableSheet(
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
          builder:
              (context) => DraggableScrollableSheet(
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
          MapScreenCheckout(
            containerHeight: MediaQuery.of(context).size.height,
            isEmbedded: false,
            warehousePosition: warehousePosition ?? widget.warehousePosition,
            initialPosition: userPosition ?? widget.userPosition!,
          ),

          // Top app bar with profile and menu - UPDATED
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
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
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProfilePage(
                                  onUserPositionChanged: () async {
                                    // Refresh user position after returning from ProfilePage
                                    await getUserAndWarehousePosition();
                                  },
                                ),
                          ),
                        );
                        setState(() {
                          // Refresh the state after returning from ProfilePage
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.red.shade400,
                        radius: 20,
                        foregroundImage: AssetImage(
                          'assets/images/woman_avatar.png',
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
                            "Home",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            userPosition!.address ?? 'No address selected',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // final res =
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SelectAddressPage(),
                          ),
                        );
                        // if (res != null && res is String) {
                        //   setState(() {
                        //     _selectedAddress = res;
                        //   });
                        // }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF3F2D7D), // #3F2D7D
                              Color(0xFF4927BE), // #4927BE
                            ],
                            center: Alignment(0.0, 0.0), // center of the screen
                            radius: 0.4,
                          ),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Draggable bottom sheet with modified snap behavior
          DraggableScrollableSheet(
            initialChildSize: 0.66,
            minChildSize: 0.15,
            maxChildSize: 0.66,
            controller: _dragController,
            snap: true,
            snapSizes: [0.15, 0.60],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      MediaQuery.of(context).size.width * 0.08,
                    ), // Responsive border radius
                    topRight: Radius.circular(
                      MediaQuery.of(context).size.width * 0.08,
                    ),
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
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.0,
                          ), // Responsive top margin
                          width:
                              MediaQuery.of(context).size.width *
                              0.12, // Responsive width for handle
                          height:
                              MediaQuery.of(context).size.height *
                              0.001, // Responsive height
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.08,
                            ), // Responsive border radius
                          ),
                        ),
                      ),
                      // Promotional banner with updated gradient
                      Container(
                        width: double.infinity,
                        height:
                            MediaQuery.of(context).size.height *
                            0.17, // Responsive height
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF3F2E78), Color(0xFF5421FF)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              MediaQuery.of(context).size.width * 0.08,
                            ), // Responsive border radius
                            topRight: Radius.circular(
                              MediaQuery.of(context).size.width * 0.08,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04,
                        ), // Responsive padding
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Hey ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.055, // Responsive font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      FutureBuilder<String?>(
                                        future:
                                            LocalStorage()
                                                .getUserName(), // Fetch username
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? 'Loading...',
                                            style: const TextStyle(
                                              color: Color.fromRGBO(
                                                241,
                                                90,
                                                37,
                                                1,
                                              ),
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "call your first cart",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.06, // Responsive font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.007,
                                  ), // Responsive spacing
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.03, // Responsive horizontal padding
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                          0.005, // Responsive vertical padding
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                      ), // Responsive border radius
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          discountPercentage + "%",
                                          style: TextStyle(
                                            color: Colors.amber,
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.035, // Responsive font size
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          " off on your first bill",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.035, // Responsive font size
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                'assets/images/meow meow 1.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Veggies or Fruit section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                        iconPath:
                            'assets/images/yellow_truck_2-removebg-preview (1).png',
                        title: 'Z vegetable cart',
                        subtitle: 'includes 13 veggie',
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
                        checkText: '',
                        color: Colors.purple,
                      ),

                      // QR code and Call your cart buttons (UPDATED)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // QR Code button with onTap handler for modal
                            GestureDetector(
                              onTap:
                                  _showQRCodeModal, // Added QR modal function call
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Color(0xFF3F2D7D), // #3F2D7D
                                      Color(0xFF4927BE), // #4927BE
                                    ],
                                    center: Alignment(
                                      0.0,
                                      0.0,
                                    ), // center of the screen
                                    radius: 0.5,
                                  ),
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
                                onTap:
                                    selectedRecommendedIndex != null
                                        ? () async {
                                          showAddressSelectionSheet(
                                            selectedRecommendedIndex,
                                          );
                                        }
                                        : null,

                                child: Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color:
                                        selectedRecommendedIndex != null
                                            ? Color(0xFFF15A25)
                                            : Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                      topRight: Radius.circular(60),
                                      bottomRight: Radius.circular(60),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/cartcall.png', // Replace with your image path
                                        width: 38,
                                        height: 38,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Call your cart now",
                                        style: GoogleFonts.leagueSpartan(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              selectedRecommendedIndex != null
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
    if (isSelected &&
        !_selectionAnimControllers[index]!.isAnimating &&
        _selectionAnimControllers[index]!.value == 0) {
      _selectionAnimControllers[index]!.forward();
    } else if (!isSelected &&
        !_selectionAnimControllers[index]!.isAnimating &&
        _selectionAnimControllers[index]!.value == 1) {
      _selectionAnimControllers[index]!.reverse();
    }

    return Container(
      height: 74,
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  children: [
                    // Cart icon with color background
                    Container(
                      width: 60,
                      height: 74,
                      child: Image.asset(iconPath, fit: BoxFit.contain),
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
                                  fontSize: 14,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          "away",
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 15,
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
