import 'package:Zdeliver/about_us.dart';
import 'package:Zdeliver/coordinate_class.dart';
import 'package:Zdeliver/home_address_selection_modal.dart';
import 'package:Zdeliver/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import 'address_book.dart';

import 'auth_page.dart';

import 'menu/notifications.dart';
import 'menu/order_history.dart';
import 'menu/support.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import ''

class ProfilePage extends StatefulWidget {
  final VoidCallback? onUserPositionChanged;
  const ProfilePage({Key? key, this.onUserPositionChanged}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _selectedAddress = 'loading...';
  CoordinatesPair? _lastUserPosition;
  LocalStorage _localStorage = LocalStorage();

  Future getAddress() async {
    try {
      // Read the saved address from secure storage
      CoordinatesPair? userPosition =
          await _localStorage.getUserPositionLocally();
      if (userPosition == null) {
        setState(() {
          _selectedAddress = 'No address selected';
          _lastUserPosition = null;
        });
        return null; // No address saved
      }
      setState(() {
        _selectedAddress = userPosition.address ?? 'No address selected';
        _lastUserPosition = userPosition;
      });
    } catch (e) {
      print('Error reading saved_address: $e');
      return null;
    }
  }

  void _selectAddress(String address) async {
    print('Selected address: $address');
    // Get the current position of the user
    CoordinatesPair? newPosition = await _localStorage.getUserPositionLocally();
    print(
      'old position: ${_lastUserPosition?.latitude}, ${_lastUserPosition?.longitude}',
    );
    print('New position: ${newPosition?.latitude}, ${newPosition?.longitude}');
    // Only call update if the position changed
    if (_lastUserPosition == null ||
        _lastUserPosition!.latitude != newPosition!.latitude ||
        _lastUserPosition!.longitude != newPosition.longitude) {
      print(
        'User position changed: ${newPosition!.latitude}, ${newPosition.longitude}',
      );
      widget.onUserPositionChanged?.call();
    }

    setState(() {
      _selectedAddress = address;
      _lastUserPosition = newPosition;
    });

    Navigator.pop(context); // Close the bottom sheet
  }

  void _showAddressSelectionSheet() {
    // Use the static method from AddressSelectionSheet class
    AddressSelectionSheet.showAddressSelectionSheet(
      context,
      (address) {
        // Handle the selected address
        _selectAddress(address);
        // The sheet will be closed automatically
      },
      //currentAddress: _selectedAddress
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize the selected address from secure storage
    getAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3F2E78), // Upper part color
              Color(0xFF5421FF), // Lower part color
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button on top left corner
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              // Header section with profile and name
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Profile image
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey, // Fallback color
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/woman_avatar.png', // Replace with your image path
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String?>(
                                  future:
                                      _localStorage
                                          .getUserName(), // Use your authService instance
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? 'Loading...',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 2),
                                FutureBuilder<String?>(
                                  future:
                                      _localStorage
                                          .getUserPhoneNumber(), // Use your authService instance
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? 'Loading...',
                                      style: GoogleFonts.leagueSpartan(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Shine effect/star in top right
                  ],
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                child: Divider(color: Colors.white24, height: 1),
              ),

              // Address section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedAddress,
                      maxLines: 2,
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Change address button
                    OutlinedButton(
                      onPressed: () async {
                        // Navigate to change address page
                        _showAddressSelectionSheet();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          8.0,
                        ), // Optional: adds padding for better touch area
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Change address',
                              style: GoogleFonts.leagueSpartan(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider

              // Settings menu (white background)
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    children: [
                      // Support option
                      _buildMenuOption(
                        context: context,
                        imagePath:
                            'assets/images/menu1.png', // Replace with your image path
                        title: 'Support',
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SupportScreen(),
                              ),
                            ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 28,
                        endIndent: 28,
                        color: Color(0xFFEEEEEE),
                      ),

                      // My history option
                      _buildMenuOption(
                        context: context,
                        imagePath:
                            'assets/images/menu2.png', // Replace with your image path
                        title: 'My history',
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        OrderHistoryScreen(userId: '1'),
                              ),
                            ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 28,
                        endIndent: 28,
                        color: Color(0xFFEEEEEE),
                      ),

                      // Address book option
                      _buildMenuOption(
                        context: context,
                        imagePath:
                            'assets/images/menu4.png', // Replace with your image path
                        title: 'Address book',
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddressBookPage(),
                              ),
                            ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 28,
                        endIndent: 28,
                        color: Color(0xFFEEEEEE),
                      ),

                      // Favourites option
                      // _buildMenuOption(
                      //   context: context,
                      //   imagePath: 'assets/images/favourites_icon.png', // Replace with your image path
                      //   title: 'Favourites',
                      //   onTap: () => _navigateToPage(context, 'FavouritesPage'),
                      // ),
                      const Divider(
                        height: 1,
                        indent: 28,
                        endIndent: 28,
                        color: Color(0xFFEEEEEE),
                      ),

                      // Notifications option
                      _buildMenuOption(
                        context: context,
                        imagePath:
                            'assets/images/menu6.png', // Replace with your image path
                        title: 'Notifications',
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NotificationsScreen(),
                              ),
                            ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 28,
                        endIndent: 28,
                        color: Color(0xFFEEEEEE),
                      ),

                      // Share app option
                      _buildMenuOption(
                        context: context,
                        imagePath:
                            'assets/images/menu7.png', // Replace with your image path
                        title: 'Share app',
                        onTap: () async {
                          print('Share app tapped');
                          // Use SharePlus to share the app
                          await SharePlus.instance.share(
                            ShareParams(
                              text:
                                  'Check out this amazing app!\n link: https://www.example.com',
                              subject: 'Z Deliver App',
                              // uri: Uri.parse('https://www.youtube.com/'),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 28,
                        endIndent: 28,
                        color: Color(0xFFEEEEEE),
                      ),

                      // About us option
                      _buildMenuOption(
                        context: context,
                        imagePath:
                            'assets/images/menu8.png', // Replace with your image path
                        title: 'About us',
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AboutUsScreen(),
                              ),
                            ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 28,
                        endIndent: 28,
                        color: Color(0xFFEEEEEE),
                      ),

                      // Logout option
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 8,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16),
                        ),

                        onTap: () async {
                          // Clear secure storage

                          _showLogoutDialog(context);

                          // Implement logout functionality
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 24,
                        endIndent: 24,
                        color: Color(0xFFEEEEEE),
                      ),
                      // Delete account option
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 8,
                        ),
                        title: const Text(
                          'Delete account',
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () async {
                          _showDeleteAccountDialog(context);
                        },
                      ),

                      // Terms and privacy
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'terms of services & privacy policy',
                          style: GoogleFonts.leagueSpartan(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Logout',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to logout from your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          // Implement logout functionality here
                          _performLogout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4527A0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          // Implement delete account functionality here
                          _performDeleteAccount(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    // Add your logout logic here (clear user data, tokens, etc.)
    await _secureStorage.deleteAll();
    // Navigate to the login screen

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  void _performDeleteAccount(BuildContext context) async {
    // Add your delete account logic here (API call, clear data, etc.)
    await _secureStorage.deleteAll();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  // Helper method to build menu options with images
  Widget _buildMenuOption({
    required BuildContext context,
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      leading: Container(
        width: 33,
        height: 33,
        decoration: BoxDecoration(
          // Light purple background for icons
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 35,
            height: 35,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image fails to load
              return Icon(
                Icons.error,
                color: const Color(0xFF4527A0),
                size: 24,
              );
            },
          ),
        ),
      ),
      title: Text(title, style: GoogleFonts.leagueSpartan(fontSize: 18)),
      onTap: onTap,
    );
  }

  // Helper method to navigate to pages
  void _navigateToPage(BuildContext context, String pageName) {
    // You can replace this with actual navigation to your page classes
    print('Navigating to $pageName');
    // Example:
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => YourPage()));
  }
}
