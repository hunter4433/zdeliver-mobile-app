import 'package:flutter/material.dart';
import 'package:Zdeliver/mapView.dart';
import 'package:Zdeliver/Home_Recommend_section/standardGorillaCart.dart';
import 'package:Zdeliver/Home_Recommend_section/gorillaFruitcart.dart';
import 'package:Zdeliver/Home_Recommend_section/customize_cart.dart';

import 'dart:convert';
import '../lib/menu/support.dart';
import "basket.dart";
import "package:Zdeliver/menu/Addreass.dart";
import "package:Zdeliver/address_book.dart";
import "package:Zdeliver/menu/order_details.dart";
import 'package:Zdeliver/menu/order_history.dart';
import 'package:Zdeliver/menu/notifications.dart';
import 'package:Zdeliver/menu/cart_history.dart';
// import 'package:Zdeliver/Home_Incart_Section/FreshVegetable.dart';
// import 'package:Zdeliver/Home_Incart_Section/herbsPage.dart';
// import 'package:Zdeliver/Home_Incart_Section/staplePage.dart';
// import 'package:Zdeliver/Home_Meal_Section/Breakfast_Details.dart';
import 'package:Zdeliver/searchResult.dart';
// import 'package:Zdeliver/Home_Meal_Section/Breakfast.dart';
// import 'package:Zdeliver/Home_Meal_Section/Lunch.dart';
// import 'package:Zdeliver/Home_Meal_Section/dinner.dart';
import 'package:http/http.dart' as http;
import 'basket.dart';
import 'package:flutter/material.dart';
import 'package:Zdeliver/orderPlace.dart';
import 'package:Zdeliver/searchPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Zdeliver/checkoutPage.dart';
import 'package:Zdeliver/address_selection.dart';
import 'package:Zdeliver/address_selection_sheet.dart';
import 'package:Zdeliver/auth_page.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:Zdeliver/Home_Recommend_section/standardGorillaCart.dart';

class Dmeo extends StatefulWidget {
  const Dmeo({Key? key}) : super(key: key);

  @override
  State<Dmeo> createState() => _Dmeo();
}

class _Dmeo extends State<Dmeo> with SingleTickerProviderStateMixin {
  // Track which recommended item is selected
  int? selectedRecommendedIndex;

  // Animation controller for the menu drawer
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _scrimAnimation;
  bool _isDrawerOpen = false;
  List<dynamic> _featuredItems = [];
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
    _fetchLowPriceItems();
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

  // void navigateToTargetPage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => FreshVegPage()), // Replace with your page
  //   );
  // }
  //
  // void navigateToHerbsPage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => HerbsPage()), // Replace with your page
  //   );
  // }
  //
  // void navigateToStaplePage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => StaplePage()), // Replace with your page
  //   );
  // }

  Future<void> _initializePage() async {
    // Retrieve saved address first
    savedAddress = await _secureStorage.read(key: 'saved_address');

    // Then fetch featured items
    await _fetchFeaturedItems();

// Update loading state
    setState(() {
      addressLoading= false;
    });
  }

  Future<void> _fetchFeaturedItems() async {
     savedAddress = await _secureStorage.read(key: 'saved_address');
    try {
      final response = await http.get(
        Uri.parse('http://3.111.39.222/api/v1/promotion/featured'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          _featuredItems = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load featured items';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to server';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLowPriceItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://3.111.39.222/api/v1/promotion/low-price'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          _lowPriceItems = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load low-price items';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to server';
        _isLoading = false;
      });
    }
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
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/home1.png', // Make sure this image exists in your assets
                          fit: BoxFit.cover,
                        ),
                      ),

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
                                            color: Colors.white,
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
                 Text(
                  "Home",
                   style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10), // Add some spacing
                Expanded(
                  child: GestureDetector(
                    onTap:  () {
                      // Default navigation if no custom tap handler
                       Navigator.push(context, MaterialPageRoute(
                         builder: (context) => SelectAddressPage()
                       ));
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            savedAddress ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 28, // Increase the size as needed
                        ),
                      ],
                    ),
                  ),
                ),
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
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              hintText: 'Enter fruit, vegetable name',
                                              hintStyle: TextStyle(color: Colors.grey),
                                              border: InputBorder.none,
                                            ),
                                            style: const TextStyle(color: Colors.black),
                                            controller: TextEditingController(),
                                            onSubmitted: (value) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => VegetableOrderingPage(
                                                      searchQuery:value
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VegetableOrderingPage(),
                                              ),
                                            );
                                          },
                                          child: const Icon(Icons.search, color: Colors.grey),
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
                    ],
                  ),
                ),

                // Daily Fresh promotional banner
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
                // _buildRecommendedItem(
                //   index: 3,
                //   title: 'Customized order',
                //   subtitle: 'any 5 vegitables and fruits',
                //   time: '17 min',
                //   backgroundColor: Colors.white,
                //   imagePath: 'assets/images/homescooter.png',
                // ),
                SizedBox(height: 15,),

                // Promotional banner



                // Order Your Veggies section
                //  Padding(
                //   padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                //   child: Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //       'Order Your Veggies',
                //       style: GoogleFonts.leagueSpartan(
                //         fontSize: 20,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
                // ),
                //
                // // Vegetable selection
                // GestureDetector(
                //   onTap: () => navigateToTargetPage(context),
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 16),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(26),
                //     ),
                //     child: Stack(
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(26),
                //           child: const Image(
                //             image: AssetImage('assets/images/home2.png'),
                //             width: double.infinity,
                //             height: 125,
                //             fit: BoxFit.cover,
                //           ),
                //         ),
                //         // Text container in bottom left
                //         Positioned(
                //           bottom: 16,
                //           left: 16,
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //             decoration: BoxDecoration(
                //               color: Colors.white,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child:  Text(
                //               '13 Fresh Vegetable',
                //               style: GoogleFonts.sourceSans3(
                //                 fontSize: 14,
                //                 fontWeight: FontWeight.w700,
                //                 color: Colors.black,
                //               ),
                //             ),
                //           ),
                //         ),
                //         // Arrow in bottom right corner
                //         Positioned(
                //           bottom: 16,
                //           right: 16,
                //           child: Container(
                //             width: 28,
                //             height: 28,
                //             decoration: const BoxDecoration(
                //               shape: BoxShape.circle,
                //               color: Colors.white,
                //             ),
                //             child: const Icon(
                //               Icons.arrow_forward_ios_rounded,
                //               size: 22,
                //               color: Colors.black,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20,),
                //
                // GestureDetector(
                //   onTap: () => navigateToTargetPage(context),
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 16),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(26),
                //     ),
                //     child: Stack(
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(26),
                //           child: const Image(
                //             image: AssetImage('assets/images/home4.png'),
                //             width: double.infinity,
                //             height: 125,
                //             fit: BoxFit.cover,
                //           ),
                //         ),
                //         // Text container in bottom left
                //         Positioned(
                //           bottom: 16,
                //           left: 16,
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //             decoration: BoxDecoration(
                //               color: Colors.white,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child:  Text(
                //               'Essential herbs and spices',
                //               style: GoogleFonts.sourceSans3(
                //                 fontSize: 14,
                //                 fontWeight: FontWeight.w700,
                //                 color: Colors.black,
                //               ),
                //             ),
                //           ),
                //         ),
                //         // Arrow in bottom right corner
                //         Positioned(
                //           bottom: 16,
                //           right: 16,
                //           child: Container(
                //             width: 28,
                //             height: 28,
                //             decoration: const BoxDecoration(
                //               shape: BoxShape.circle,
                //               color: Colors.white,
                //             ),
                //             child: const Icon(
                //               Icons.arrow_forward_ios_rounded,
                //               size: 22,
                //               color: Colors.black,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20,),
                //
                // GestureDetector(
                //   onTap: () => navigateToTargetPage(context),
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 16),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(26),
                //     ),
                //     child: Stack(
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(26),
                //           child: const Image(
                //             image: AssetImage('assets/images/home5.png'),
                //             width: double.infinity,
                //             height: 125,
                //             fit: BoxFit.cover,
                //           ),
                //         ),
                //         // Text container in bottom left
                //         Positioned(
                //           bottom: 16,
                //           left: 16,
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //             decoration: BoxDecoration(
                //               color: Colors.white,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child:  Text(
                //               'Staple Vegetables',
                //               style: GoogleFonts.sourceSans3(
                //                 fontSize: 14,
                //                 fontWeight: FontWeight.w700,
                //                 color: Colors.black,
                //               ),
                //             ),
                //           ),
                //         ),
                //         // Arrow in bottom right corner
                //         Positioned(
                //           bottom: 16,
                //           right: 16,
                //           child: Container(
                //             width: 28,
                //             height: 28,
                //             decoration: const BoxDecoration(
                //               shape: BoxShape.circle,
                //               color: Colors.white,
                //             ),
                //             child: const Icon(
                //               Icons.arrow_forward_ios_rounded,
                //               size: 22,
                //               color: Colors.black,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 20,),


                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF0CB),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: GestureDetector(
                    onTapUp: (TapUpDetails details) {
                      // Get the size of the container
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final size = box.size;

                      // Print debug information
                      print('Container Size: $size');
                      print('Tap Position X: ${details.localPosition.dx}');
                      print('Tap Position Y: ${details.localPosition.dy}');

                      // Adjust the navigation region calculation
                      // Use a more flexible approach to determine the right bottom portion
                      if (details.localPosition.dx > size.width * 0.68 &&
                          details.localPosition.dy > size.height * 0.16) {
                        // Navigate to the desired screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => customize_cart(), // Replace with your target screen
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/home6.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200, // Specify a fixed height if needed
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's most bought",
                        style: GoogleFonts.leagueSpartan(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () {

                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => FeaturedItemsPage(
                          //         featuredItems: _featuredItems
                          //     ), // Replace with your target screen
                          //   ),
                          // );
                        },
                        child: Text(
                          "see all",
                          style: GoogleFonts.leagueSpartan(color: Colors.green, fontWeight: FontWeight.w500,fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : SizedBox(
                  height: 255,
                  child: _featuredItems.isEmpty
                      ? Center(child: Text('No featured items available'))
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _featuredItems.length,
                    itemBuilder: (context, index) {
                      return _buildCarouselItem(context, _featuredItems[index]);
                    },
                  ),
                ),

                Divider(height: 40,),

                Container(
                  width: double.infinity,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
                  ),
                  child: GestureDetector(
                    onTapUp: (TapUpDetails details) {
                      // Get the size of the container
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final size = box.size;

                      // Print debug information
                      print('Container Size: $size');
                      print('Tap Position X: ${details.localPosition.dx}');
                      print('Tap Position Y: ${details.localPosition.dy}');

                      // Check if tap is in the bottom center portion of the image
                      // This creates a zone in the bottom center, about 1/3 of the width
                      if (details.localPosition.dy > size.height * 0.30 &&
                          details.localPosition.dy < size.height * 0.35 &&
                          details.localPosition.dx > size.width * 0.17 &&
                          details.localPosition.dx < size.width * 0.825) {
                        // Navigate to the desired screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => customize_cart(), // Replace with your target screen
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/images/home7.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Divider(height: 40,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lowest Price Ever",
                        style: GoogleFonts.leagueSpartan(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => LowPriceItemsPage(
                          //         featuredItems: _lowPriceItems
                          //     ), // Replace with your target screen
                          //   ),
                          // );
                        }, // Add navigation logic here
                        child: Text(
                          "see all",
                          style: GoogleFonts.leagueSpartan(color: Colors.green, fontWeight: FontWeight.w500,fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : SizedBox(
                  height: 255,
                  child: _lowPriceItems.isEmpty
                      ? Center(child: Text('No low-price items available'))
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _lowPriceItems.length,
                    itemBuilder: (context, index) {
                      return _buildCarouselItem2(context, _lowPriceItems[index]);
                    },
                  ),
                ),


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
                        _buildMenuItem('assets/images/menu2.png', "My history", OrderHistoryScreen(userId: '',)),
                        _buildMenuItem('assets/images/menu3.png', "My Baskets", BasketPage()),
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
            Positioned(
              bottom: 20,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BasketPage()),
                        );
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Image.asset(
                        'assets/images/home8.png',
                        height: 80,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 86,
                    width: 86,
                    child: FloatingActionButton(
                      onPressed: () {
                        CartBottomSheet.show(context);
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Image.asset(
                        'assets/images/Frame 522 (1).png',
                        height: 96,
                        width: 96,
                        fit: BoxFit.contain,
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
              case 3:
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;







class AddressSelectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF0F8FF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Address",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter location",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                Icon(Icons.search, color: Colors.grey.shade700),
              ],
            ),
          ),

          // Current location
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red,size: 35,),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current location",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Enable device location to \nfetch current location",
                          style: TextStyle(fontSize: 13,fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    "Enable",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Saved addresses
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved addresses",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Add address button
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.add, color: Colors.red,size: 30,),
                    SizedBox(width: 12),
                    Text(
                      "Add address",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right,size: 30,),
              ],
            ),
          ),

          // Saved address entries
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Katik Gadade",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Hs no. 15, Sharadanagari, karjat, mirajgaon road, 414402, dist- ahmednagar.",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Phone number : 8275451335",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Icon(Icons.more_vert, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Home - Omkar",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Hs no. 15, Sharadanagari, karjat, mirajgaon road, 414402, dist- ahmednagar.",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showDeliveryOptionsBottomSheet(BuildContext context, dynamic item) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),  // Rounded top-left corner
            topRight: Radius.circular(20), // Rounded top-right corner
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        height: MediaQuery.of(context).size.height * 0.22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How do you want your order delivered as?',
              style: GoogleFonts.leagueSpartan(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // Close current bottom sheet
            //     Navigator.pop(context);
            //     // Show customization bottom sheet
            //     _showCustomizationBottomSheet(context, item);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Color(0xFFF15A25),
            //     padding: EdgeInsets.symmetric(vertical: 15),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   child: Text(
            //     'Customized order',
            //     style: GoogleFonts.leagueSpartan(
            //       fontSize: 20,
            //       color: Colors.white,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            SizedBox(height: 15),
            OutlinedButton(
              onPressed: () {
                // Close bottom sheet and navigate to checkout with item data
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          // Pass the entire item object to the checkout page
                          selectedProducts: [
                            {
                              // Map the item to match the expected structure
                              'name': item['item_name'],
                              'image_url': item['image_url'],
                              // 'price_per_unit': item['price_per_unit'],
                              // 'old_price_per_unit': item['old_price_per_unit'],
                              // Add any other relevant fields
                              // You might want to add a quantity field
                              'quantity': 1,
                            }
                          ],
                          // Optional: add source screen if needed
                          sourceScreen: 'customiseCart',
                        )
                    )
                );
              },
              style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xFFF15A25),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Colors.grey, width: 1),
              ),
              child: Text(
                'Customized cart',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showCustomizationBottomSheet(BuildContext context, dynamic item) {
  // State variable to manage quantity
  int quantity = 1;

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Item Details at the top
                Row(
                  children: [
                    Image.network(
                      item['image_url'] ?? 'assets/images/placeholder.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.png',
                          height: 100,
                          width: 100,
                        );
                      },
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['item_name'] ?? 'Unknown Item',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Rs ${item['price_per_unit'] ?? '0'}/Kg',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Customize Your Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Quantity Customization
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) quantity--;
                            });
                          },
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: Color(0xFFF15A25)),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final price = double.parse((item['price_per_unit'] ?? '0.0').toString());
                    final itemsTotal = price * quantity;
                    const discountPercent = 22.0;
                    final discountAmount = (itemsTotal * discountPercent / 100).roundToDouble();
                    const platformFee = 8.0;
                    const deliveryCharge = 12.0;
                    final grandTotal = itemsTotal - discountAmount + platformFee + deliveryCharge;

                    final billData = {
                      'items_total': itemsTotal,
                      'discount_amount': discountAmount,
                      'platform_fee': platformFee,
                      'delivery_charge': deliveryCharge,
                      'grand_total': grandTotal,
                      'saved_amount': discountAmount,
                      'discount_code': 'Gorilla 20',
                    };
                    print(item);
                    // Navigate to CheckoutPage with customized item
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              selectedProducts: [
                                {

                                  // Map the item to match the expected structure
                                  'name': item['item_name'],
                                  'image_url': item['image_url'],
                                  'price': item['price_per_unit'],
                                  'unit': item['unit'] ?? 'Kg',
                                  // Add any other relevant fields
                                  // You might want to add a quantity field
                                  'quantity': quantity,
                                }
                              ],
                              sourceScreen: 'GroceryPage',
                              billData: billData,
                            )
                        )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF15A25),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
// Modify the existing _buildCarouselItem method
Widget _buildCarouselItem(BuildContext context, dynamic item) {
  return Container(
    width: 146,
    margin: EdgeInsets.symmetric(horizontal: 5),
    padding: EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.network(
            item['image_url'] ?? 'assets/images/placeholder.png',
            height: 146,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/placeholder.png',
                height: 146,
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Text(
          item['item_name'] ?? 'Unknown Item',
          style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.w600,fontSize: 17),
          textAlign: TextAlign.left,
        ),
        Text(
          'Rs ${item['price_per_unit'] ?? '0'}/Kg',
          style: GoogleFonts.leagueSpartan(color: Colors.grey.shade600,fontSize: 15,fontWeight: FontWeight.w600),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 33,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showDeliveryOptionsBottomSheet(context, item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2F2F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
                "Add",
                style: GoogleFonts.leagueSpartan(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                )
            ),
          ),
        ),
      ],
    ),
  );
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


Widget _buildCarouselItem2(BuildContext context, dynamic item) {
  return Container(
    width: 156,
    margin: EdgeInsets.symmetric(horizontal: 5),
    padding: EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.network(
            item['image_url'] ?? 'assets/images/placeholder.png',
            height: 146,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/placeholder.png',
                height: 146,
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Text(
          item['item_name'] ?? 'Unknown Item',
          style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.w600,fontSize: 17),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Rs ${item['old_price_per_unit'] ?? '0'}/Kg',
              style: GoogleFonts.leagueSpartan(
                color: Colors.grey.shade600,
                decoration: TextDecoration.lineThrough,
                fontSize: 12,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Rs ${item['price_per_unit'] ?? '0'}/Kg',
              style: GoogleFonts.leagueSpartan(
                color: Color(0xFF17A773),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 33,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Implement add to cart or navigation logic
              _showDeliveryOptionsBottomSheet(context,item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2F2F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              "Add",
              style: GoogleFonts.leagueSpartan(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
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

// Usage in your app
// CartBottomSheet.show(context);