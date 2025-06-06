import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:Zdeliver/mapView.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Zdeliver/map_screen_checkout.dart';

class OrderPlacedPage extends StatefulWidget {
  final String? address;

  const OrderPlacedPage({Key? key, this.address}) : super(key: key);

  @override
  State<OrderPlacedPage> createState() => _OrderPlacedPageState();
}

class _OrderPlacedPageState extends State<OrderPlacedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? etaText = '...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  Future<Map<String, dynamic>?> getLatLngAddress() async {
    try {
      final storage = FlutterSecureStorage();
      String? address = await storage.read(key: 'saved_address');
      String? position = await storage.read(key: 'user_position');
      if (address != null && position != null) {
        final coords = position.split(',');
        if (coords.length == 2) {
          double lat = double.parse(coords[0]);
          double lng = double.parse(coords[1]);
          Position position = Position(
            latitude: lat,
            longitude: lng,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
          return {'postion': position, 'address': address};
        }
      }
      return null;
    } catch (e) {
      print('Error reading lat/lng/address: $e');
      return null;
    }
  }

  Future<String?> getAddress() async {
    try {
      return await _secureStorage.read(key: 'saved_address');
    } catch (e) {
      print('Error reading saved_address: $e');
      return null;
    }
  }

  Future<String?> getPhoneNumber() async {
    try {
      String? number = await _secureStorage.read(key: 'phone_number');
      String details = "Guest $number";
      return details;
    } catch (e) {
      print('Error reading phone number: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green header with centered text
            Container(
              color: const Color(0xFF328616),
              padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered title
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Order placed',
                          style: GoogleFonts.leagueSpartan(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Back button aligned to the left
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Centered subtitle
                  Text(
                    'order will be arriving in $etaText',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.leagueSpartan(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Map section with full width and animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Full width map without border
                SizedBox(
                  height: 422,
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: getLatLngAddress(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          height: 422,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final position = snapshot.data!['postion'] as Position;
                      final address = snapshot.data!['address'] as String;
                      return SizedBox(
                        height: 422,
                        width: MediaQuery.of(context).size.width,
                        child: MapScreenCheckout(
                          containerHeight: 422,
                          isEmbedded: true,
                          initialPosition: position,
                          initialAddress: address,
                          onEtaCalculated: (eta) {
                            setState(() {
                              etaText = eta;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Centered animation circle
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/newlogo.png',
                            width: 100,
                            height: 100,
                            // Replace with your animation asset
                            // If you don't have a gif, use Lottie or a custom animated widget
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom overlay text
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 8, 0, 8),
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.65),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/lottie/hourglass.json',
                                width: 60,
                                height: 60,
                                repeat: true,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'We will assign you a \ndelivery partner soon',
                                style: GoogleFonts.roboto(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF303030),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     vertical: 6,
                        //     horizontal: 18,
                        //   ),
                        //   decoration: const BoxDecoration(
                        //     gradient: LinearGradient(
                        //       begin: Alignment.topCenter,
                        //       end: Alignment.bottomRight,
                        //       colors: [Color(0xFF3F2E78), Color(0xFF745EBF)],
                        //     ),
                        //     borderRadius: BorderRadius.only(
                        //       topLeft: Radius.circular(20),
                        //       bottomLeft: Radius.circular(20),
                        //       topRight: Radius.zero,
                        //       bottomRight: Radius.zero,
                        //     ),
                        //   ),
                        //   child: const Column(
                        //     children: [
                        //       Text(
                        //         'see cart',
                        //         style: TextStyle(
                        //           fontWeight: FontWeight.w600,
                        //           color: Colors.white,
                        //           fontSize: 15,
                        //         ),
                        //       ),
                        //       Text(
                        //         'location',
                        //         style: TextStyle(
                        //           fontWeight: FontWeight.w600,
                        //           color: Colors.white,
                        //           fontSize: 15,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Receiver details section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 20, 12, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: const Color(0xFFFFF0CB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receivers details',
                    style: GoogleFonts.leagueSpartan(
                      color: Color(0xFF4CAF50),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white, height: 10),
                  Text(
                    'Delivery address',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF303030),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Guest',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF303030),
                    ),
                  ),
                  FutureBuilder<String?>(
                    future: getAddress(), // Use your authService instance
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Loading...',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white, height: 10),
                  Text(
                    'Receivers details',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF303030),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<String?>(
                    future: getPhoneNumber(), // Use your authService instance
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Loading...',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Need help section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need help?',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF303030),
                        ),
                      ),
                      Text(
                        'Chat with us for any help regarding \nyour order',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, size: 40, color: Color(0xFF9E9E9E)),
                ],
              ),
            ),

            // Brand footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Zdeliver',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    'your personalized sabzi cart',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
