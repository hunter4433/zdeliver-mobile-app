import 'package:flutter/material.dart';
 import 'package:mrsgorilla/mapView.dart';
import 'package:mrsgorilla/Home_Recommend_section/standardGorillaCart.dart';
import 'package:mrsgorilla/Home_Recommend_section/gorillaFruitcart.dart';
import 'package:mrsgorilla/Home_Recommend_section/customize_cart.dart';

import 'dart:convert';
import '../lib/menu/support.dart';
import 'Home_Meal_Section/Breakfast.dart';
import 'Home_Meal_Section/Lunch.dart';
import 'Home_Meal_Section/dinner.dart';
import "basket.dart";
import "package:mrsgorilla/menu/Addreass.dart";
import "package:mrsgorilla/menu/order_details.dart";
import 'package:mrsgorilla/menu/order_history.dart';
import 'package:mrsgorilla/menu/notifications.dart';
import 'package:mrsgorilla/menu/cart_history.dart';
// import 'package:mrsgorilla/Home_Incart_Section/FreshVegetable.dart';
// import 'package:mrsgorilla/Home_Incart_Section/herbsPage.dart';
// import 'package:mrsgorilla/Home_Incart_Section/staplePage.dart';
// import 'package:mrsgorilla/Home_Meal_Section/Breakfast_Details.dart';
import 'package:mrsgorilla/searchResult.dart';
// import 'package:mrsgorilla/Home_Meal_Section/Breakfast.dart';
// import 'package:mrsgorilla/Home_Meal_Section/Lunch.dart';
// import 'package:mrsgorilla/Home_Meal_Section/dinner.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Track which recommended item is selected
  int? selectedRecommendedIndex;

  // Animation controller for the menu drawer
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _scrimAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
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

  void navigateToTargetPage(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => FreshVegPage()), // Replace with your page
    // );
  }

  void navigateToHerbsPage(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => HerbsPage()), // Replace with your page
    // );
  }

  void navigateToStaplePage(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => StaplePage()), // Replace with your page
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Upper section with background image
              Container(
                height: 380,
                child: Stack(
                  children: [
                    // Map as the background - using Positioned.fill to ensure it fills the container
                    // and properly receives gestures
                    Positioned.fill(
                      child: MapScreen(
                        containerHeight: 380,
                        isEmbedded: true,
                      ),
                    ),
                    // Positioned.fill(
                    //   child: Image.asset(
                    //     'assets/images/map.PNG',
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),

                    // SafeArea ensures elements don't overlap system UI elements
                    SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          // App Bar with Search
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _toggleDrawer,
                                  child: const Icon(
                                    Icons.menu,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        hintText: 'Enter fruit, vegetable name',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                      // Controller to access text value
                                      controller: TextEditingController(),
                                      // Handle key press events
                                      onSubmitted: (value) {
                                        // Navigate to another page when Enter key is pressed
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => ResultPage(searchQuery: value),
                                        //   ),
                                        // );
                                      },
                                    ),
                                  ),
                                ),
                                const Icon(Icons.search, color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Positioning the "Gorilla carts near you" section at the bottom

                  ],
                ),
              ),

              // Wrap everything below the map container in a SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Free delivery banner
                      Container(
                        color: const Color(0xFF95CCBA),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 70),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_shipping_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Get free delivery on all carts',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),

                      // Recommended for you section
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Recommended for you',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Modified Recommended section with images instead of icons
                      _buildRecommendedItem(
                        index: 0,
                        title: 'Standard gorilla cart',
                        subtitle: 'includes 13 vegetables',
                        time: '7 min',
                        backgroundColor: Colors.white,
                        imagePath: 'assets/images/Asset 1123.png',
                      ),

                      _buildRecommendedItem(
                        index: 1,
                        title: 'Gorilla fruit cart',
                        subtitle: 'includes 15 fruits',
                        time: '11 min',
                        backgroundColor: Colors.white,
                        imagePath: 'assets/images/Asset 2123.png',
                      ),

                      _buildRecommendedItem(
                        index: 2,
                        title: 'Customized cart',
                        subtitle: 'any 13 vegitables and fruits',
                        time: '17 min',
                        backgroundColor: Colors.white,
                        imagePath: 'assets/images/Frame 571.png',
                      ),

                      _buildRecommendedItem(
                        index: 3,
                        title: 'Customized order',
                        subtitle: 'any 5 vegitables and fruits',
                        time: '17 min',
                        backgroundColor: Colors.white,
                        imagePath: 'assets/images/Layer 1 7.png',
                      ),

                      // Promotional banner
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2CC84),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '"Pick any 14 from 50 fresh veggies through customized cart,'
                              ' delivered to your doorstep!"',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),

                      // In cart section
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'In Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Vegetable selection
                      GestureDetector(
                        onTap: () => navigateToTargetPage(context),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.deepPurple,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: const Image(
                                  image: AssetImage('assets/images/fresh_vegi.png'),
                                  width: double.infinity,
                                  height: 125,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Herbs and veggies categories
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // First box (left)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => navigateToHerbsPage(context),
                                child: Container(
                                  height: 127,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.deepPurple,
                                    ),
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: const Image(
                                      image: AssetImage(
                                        'assets/images/essential_herbs.png',
                                      ),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Second box (right)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => navigateToStaplePage(context),
                                child: Container(
                                  height: 127,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.deepPurple,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: const Image(
                                      image: AssetImage('assets/images/staple.png'),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const BreakfastSection(),

                      // Lunch section
                      const LunchSection(),
                      const DinnerSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Animated scrim overlay
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
                        padding: const EdgeInsets.all(20),
                       color:  Color(0xFFF0F8FF),

                child: Row(
                          children: [
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "My Profile",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "+918275451335",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Text(
                                    " Edit profile",
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),


                          ],
                        ),
                      ),

                      // Menu items
                      _buildMenuItem(Icons.headset_mic, "Support", SupportScreen()),
                      _buildMenuItem(Icons.history, "My history", OrderHistoryScreen()),
                      _buildMenuItem(Icons.shopping_basket_outlined, "My Baskets", BasketPage()),
                      _buildMenuItem(Icons.location_on_outlined, "Address book", AddressSelectionScreen()),
                      _buildMenuItem(Icons.eco_outlined, "Vegetables quality", OrderDetailsPage()),
                      _buildMenuItem(Icons.notifications_none, "Notifications", NotificationsScreen()),
                      // _buildMenuItem(Icons.share_outlined, "Share app", ShareAppPage()),
                      // _buildMenuItem(Icons.people_outline, "About us", AboutUsPage()),
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
                  height: 80,
                  width: 80,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Add your onPressed code here for basket button!
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Image.asset(
                      'assets/images/basket.png',
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
                      // Add your onPressed code here for cart button!
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Image.asset(
                      'assets/images/cart.png',
                      height: 90,
                      width: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Widget destination) {
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
            Icon(icon, size: 24),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                height: 35,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
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
                  style: const TextStyle(color:Colors.green ,
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Larger font size
                  ),
                ),
                Center(child: Text(
                  'away',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12, // Smaller font size
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

class StandardGorillaCartBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Standard gorilla cart vegetables",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 0),
            child: Text(
              "Call the cart, and it arrives with 13 fresh veggies. Pick what you need, just like your daily market visit!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16),
          // This Expanded widget allows the ListView to take available space
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildVegetableItem("Tomato", "assets/images/potato_png2391.png"),
                _buildVegetableItem("Potato", "assets/images/color-capsicum.png"),
                _buildVegetableItem("Onion", "assets/images/bunch-of-carrots-isolated-on-transparent-background-png.png"),
                _buildVegetableItem("Carrot", "assets/images/bunch-of-carrots-isolated-on-transparent-background-png.png"),
                _buildVegetableItem("Cucumber", "assets/images/color-capsicum.png"),
                _buildVegetableItem("Bell Pepper", "assets/images/bunch-of-carrots-isolated-on-transparent-background-png.png"),
                _buildVegetableItem("Cauliflower", "assets/images/potato_png2391.png"),
                _buildVegetableItem("Broccoli", "assets/images/color-capsicum.png"),
                _buildVegetableItem("Spinach", "assets/images/potato_png2391.png"),
                _buildVegetableItem("Green Beans", "assets/images/potato_png2391.png"),
                _buildVegetableItem("Eggplant", "assets/images/potato_png2391.png"),
                _buildVegetableItem("Okra", "assets/images/potato_png2391.png"),
                _buildVegetableItem("Bitter Gourd", "assets/images/potato_png2391.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVegetableItem(String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 50,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 40,
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported),
              );
            },
          ),
          SizedBox(width: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class FruitCartBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Gorilla fruit cart",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Call the cart, and it arrives with 15 fresh fruits. Pick what you need, just like your daily market visit!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16),
          // This Expanded widget allows the ListView to take available space
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildFruitItem("Mango", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Banana", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Orange", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Sweet lime", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Dragon fruit", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Apple", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Guava", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Chikoo", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Coconut", "assets/images/Big-brinjal-eggplant.png"),
                _buildFruitItem("Fig", "assets/images/Big-brinjal-eggplant.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitItem(String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 50,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 40,
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported),
              );
            },
          ),
          SizedBox(width: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

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

