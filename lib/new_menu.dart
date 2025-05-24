import 'package:flutter/material.dart';

import 'address_book.dart';
import 'auth_page.dart';
import 'menu/Addreass.dart';
import 'menu/notifications.dart';
import 'menu/order_history.dart';
import 'menu/support.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import ''

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // Method to retrieve stored user ID
  Future<String?> getAddress() async {
    try {
      return await _secureStorage.read(key: 'saved_address');
    } catch (e) {
      print('Error reading saved_address: $e');
      return null;
    }
  }

  // Method to retrieve stored phone number
  Future<String?> getPhoneNumber() async {
    try {
      return await _secureStorage.read(key: 'phone_number');
    } catch (e) {
      print('Error reading phone number: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF4527A0), // Deep purple color
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Profile image placeholder
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey, // Placeholder color
                              ),
                              // Replace this with your image when available
                              // child: Image.network('YOUR_IMAGE_URL'),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hey Guest',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FutureBuilder<String?>(
                                  future: getPhoneNumber(), // Use your authService instance
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? 'Loading...',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                child: Divider(color: Colors.white24, height: 1),
              ),

              // Address section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Address',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String?>(
                      future: getAddress(), // Use your authService instance
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Loading...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Change address button
                    OutlinedButton(
                      onPressed: () {
                        // Navigate to change address page
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Change address',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                child: Divider(color: Colors.white24, height: 1),
              ),

              // Settings menu (white background)
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    children: [
                      // Support option
                      _buildMenuOption(
                        context: context,
                        icon: Icons.headset_mic_outlined, // Placeholder icon
                        title: 'Support',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SupportScreen())),
                      ),
                      const Divider(height: 1, indent: 28, endIndent: 28),

                      // My history option
                      _buildMenuOption(
                        context: context,
                        icon: Icons.history_outlined, // Placeholder icon
                        title: 'My history',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderHistoryScreen())),
                      ),
                      const Divider(height: 1, indent: 28, endIndent: 28),

                      // Address book option
                      _buildMenuOption(
                        context: context,
                        icon: Icons.book_outlined, // Placeholder icon
                        title: 'Address book',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddressBookPage())),
                      ),
                      const Divider(height: 1, indent: 28, endIndent: 28),

                      // Favourites option
                      // _buildMenuOption(
                      //   context: context,
                      //   icon: Icons.favorite_border, // Placeholder icon
                      //   title: 'Favourites',
                      //   onTap: () => _navigateToPage(context, 'FavouritesPage'),
                      // ),
                      const Divider(height: 1, indent: 28, endIndent: 28),

                      // Notifications option
                      _buildMenuOption(
                        context: context,
                        icon: Icons.notifications_outlined, // Placeholder icon
                        title: 'Notifications',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsScreen())),
                      ),
                      const Divider(height: 1, indent: 28, endIndent: 28),

                      // Share app option
                      _buildMenuOption(
                        context: context,
                        icon: Icons.share_outlined, // Placeholder icon
                        title: 'Share app',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderHistoryScreen())),
                      ),
                      const Divider(height: 1, indent: 28, endIndent: 28),

                      // About us option
                      _buildMenuOption(
                        context: context,
                        icon: Icons.people_outline, // Placeholder icon
                        title: 'About us',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderHistoryScreen())),
                      ),
                      const Divider(height: 1, indent: 28, endIndent: 28),

                      // Logout option
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                        title: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>LoginScreen()),
                          );
                          // Implement logout functionality
                        },
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24),

                      // Delete account option
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: const Text(
                          'Delete account',
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>LoginScreen()),
                          );
                          // Implement delete account functionality
                        },
                      ),

                      // Terms and privacy
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'terms of services & privacy policy',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
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

  // Helper method to build menu options
  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EAF9), // Light purple background for icons
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4527A0), // Deep purple color for icons
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
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