import 'package:Zdeliver/coordinate_class.dart';
import 'package:Zdeliver/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:Zdeliver/mapView.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Zdeliver/map_screen_checkout.dart';
import 'package:Zdeliver/vendorAssignAndNotification.dart'; // Import your vendor service

import 'menu/support.dart';

class OrderPlacedPage extends StatefulWidget {
  final String? address;
  final String? bookingId; // Add booking ID parameter

  const OrderPlacedPage({Key? key, this.address, this.bookingId}) : super(key: key);

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

  // Vendor assignment states
  bool isSearchingVendor = true;
  VendorInfo? assignedVendor;
  String vendorSearchMessage = 'We will assign you a delivery partner soon';
  bool notificationSent = false;

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

    // Start searching for vendor after animation completes
    _searchForVendor();
  }

  // Function to search for nearest vendor
  Future<void> _searchForVendor() async {
    try {
      // Get user's current position
      CoordinatesPair? userPosition = await LocalStorage().getUserPositionLocally();

      if (userPosition != null) {
        final result = await VendorAssignAndNotification.findNearestVendor(
          latitude: userPosition.latitude,
          longitude: userPosition.longitude,
          bookingId: widget.bookingId,
        );

        if (mounted) {
          setState(() {
            isSearchingVendor = false;

            if (result['success'] == true) {
              if (result['vendor'] != null) {
                assignedVendor = VendorAssignAndNotification.parseVendorFromResponse(result);
                notificationSent = result['notification_sent'] ?? false;
                vendorSearchMessage = result['message'] ?? 'Vendor assigned successfully!';

                // Update ETA based on distance (you can customize this logic)
                if (assignedVendor != null) {
                  double estimatedMinutes = (assignedVendor!.distanceKm * 3).round().toDouble(); // 3 min per km estimate
                  etaText = '${estimatedMinutes.round()} min';
                }
              } else {
                vendorSearchMessage = result['message'] ?? 'We will assign you a vendor soon';
                etaText = result['estimated_wait_time'] ?? 'Please check back in a few minutes';

                // Retry after 30 seconds if no vendor found
                Future.delayed(const Duration(seconds: 30), () {
                  if (mounted && assignedVendor == null) {
                    _searchForVendor();
                  }
                });
              }
            } else {
              vendorSearchMessage = 'Unable to find vendor right now. We\'ll keep trying!';

              // Retry after 30 seconds on error
              Future.delayed(const Duration(seconds: 30), () {
                if (mounted && assignedVendor == null) {
                  _searchForVendor();
                }
              });
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSearchingVendor = false;
          vendorSearchMessage = 'We\'ll find you a delivery partner shortly';
        });

        // Retry after 30 seconds on exception
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted && assignedVendor == null) {
            _searchForVendor();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Widget to build vendor details section
  Widget _buildVendorDetailsSection() {
    if (assignedVendor == null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Finding Delivery Partner',
                  style: GoogleFonts.leagueSpartan(
                    color: Colors.blue.shade600,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isSearchingVendor) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white, height: 10),
            Text(
              vendorSearchMessage,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining, color: Colors.green.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                'Delivery Partner Assigned',
                style: GoogleFonts.leagueSpartan(
                  color: Colors.green.shade600,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (notificationSent) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white, height: 10),

          // Vendor ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partner ID',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF303030),
                    ),
                  ),
                  Text(
                    assignedVendor!.vendorId,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(assignedVendor!.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  assignedVendor!.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Distance and Location
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red.shade400, size: 16),
              const SizedBox(width: 4),
              Text(
                'Distance: ${assignedVendor!.distanceKm} km',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Coordinates (optional, you might want to remove this in production)
          Text(
            'Partner Location: ${assignedVendor!.latitude.toStringAsFixed(4)}, ${assignedVendor!.longitude.toStringAsFixed(4)}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),

          if (notificationSent) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Partner has been notified',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'offline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Column(
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
    FutureBuilder<CoordinatesPair?>(
    future: LocalStorage().getUserPositionLocally(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
    return const SizedBox(
    height: 422,
    child: Center(child: CircularProgressIndicator()),
    );
    }

    return MapScreenCheckout(
    containerHeight: 422,
    isEmbedded: true,
    initialPosition: snapshot.data!,
      bookingId: widget.bookingId,
    vendorInfo: assignedVendor, // Pass vendor info
    onEtaCalculated: (eta) {
    setState(() {
    etaText = eta;
    });
    },
    );
    },
    ),

    // Centered animation circle - Make it ignore pointer events
    IgnorePointer(
    child: SlideTransition(
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
        ),
      ),
    ),
    ),
    ),
    ),
    ),

      // Bottom overlay text - Also make it ignore pointer events
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: IgnorePointer(
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
                      assignedVendor != null
                          ? Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      )
                          : Lottie.asset(
                        'assets/lottie/hourglass.json',
                        width: 60,
                        height: 60,
                        repeat: true,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          assignedVendor != null
                              ? 'Delivery partner assigned!\nPreparing your order'
                              : vendorSearchMessage,
                          style: GoogleFonts.roboto(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF303030),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
    ),

            // Scrollable content below map
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Vendor details section
                    _buildVendorDetailsSection(),

                    // Receiver details section
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(12, 10, 12, 20),
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
                              color: const Color(0xFF4CAF50),
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
                              color: const Color(0xFF303030),
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
                            future: LocalStorage().getUserAddressLocally(),
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
                              color: const Color(0xFF303030),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<String?>(
                            future: LocalStorage().getUserPhoneNumber(),
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

                    // Need help section with tap navigation
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupportScreen(),
                          ),
                        );
                      },
                      child: Container(
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
                                    color: const Color(0xFF303030),
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
                            const Icon(
                              Icons.chevron_right,
                              size: 40,
                              color: Color(0xFF9E9E9E),
                            ),
                          ],
                        ),
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
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
    );
  }
}