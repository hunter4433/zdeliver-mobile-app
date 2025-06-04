import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'address_selection_sheet.dart';
import 'orderPlace.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Updated AddressSelectionSheet Class
class AddressSelectionSheet extends StatefulWidget {
  final Function(String) onAddressSelected;
  final int? selectedRecommendedIndex; // Added parameter

  const AddressSelectionSheet({
    Key? key,
    required this.onAddressSelected,
    this.selectedRecommendedIndex, // Added parameter
  }) : super(key: key);

  // Updated static method to accept selectedRecommendedIndex
  static void showAddressSelectionSheet(
      BuildContext context,
      Function(String) onAddressSelected,
      {int? selectedRecommendedIndex} // Added optional parameter
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return AddressSelectionSheet(
          onAddressSelected: onAddressSelected,
          selectedRecommendedIndex: selectedRecommendedIndex, // Pass parameter
        );
      },
    );
  }

  @override
  _AddressSelectionSheetState createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<AddressSelectionSheet> {
  String? _currentAddress;
  bool _isLoading = true;
  String? selectedAddress;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadCurrentAddress();
  }

  Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: 'userId');
    } catch (e) {
      print('Error reading userId: $e');
      return null;
    }
  }


  Future<void> _loadCurrentAddress() async {
    try {
      String? savedAddress = await _secureStorage.read(key: 'saved_address');
      setState(() {
        selectedAddress = savedAddress ?? 'No address saved';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        selectedAddress = 'Error loading address';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToSavedAddresses() async {
    _showAddressSelectionSheet();
  }

  // Address Selection Sheet Methods
  void _showAddressSelectionSheet() {
    SavedAddressSelectionSheet.showAddressSelectionSheet(
      context,
          (address) {
        _selectAddress(address);
      },
    );
  }

  void _selectAddress(String address) async {
    setState(() {
     //  _addressSelected = true;
       selectedAddress = address; // Store the selected address
    });

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

  // Helper method to determine booking type based on selectedRecommendedIndex
  String _getBookingType() {
    if (widget.selectedRecommendedIndex == 0) {
      return "vegetable cart";
    } else {
      return "fruit cart";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: 300,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            "Select Address",
            style: GoogleFonts.leagueSpartan(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 24),

          // Change address option
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _navigateToSavedAddresses,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Change address",
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFFF15A25),
                    size: 32,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Current Address Display
          Flexible(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF15A25)),
              ),
            )
                : Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF15A25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Type
                    const Text(
                      'Current Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Full address
                    Text(
                      selectedAddress ?? 'No address available',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B6B6B),
                        height: 1.4,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button
          Container(
            margin: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedAddress != null &&
                    selectedAddress!.isNotEmpty &&
                    selectedAddress != 'No address saved'
                    ? () async {


                  String? userIdString = await _secureStorage.read(key: 'userId');
                  int? userId = userIdString != null ? int.tryParse(userIdString) : null;


                  final result = await CartBookingService.callCartAtAddress(
                    userId: userId!, // Replace with actual user ID
                    address : selectedAddress!,
                    cartType: widget.selectedRecommendedIndex == 0 ? "Z vegetable cart" : "Z fruit cart",
                    latitude: 30.73900000, // Replace with actual coordinates
                    longitude: 76.79000000,
                  );

                  // if (result['success']) {
                    // Success - show message and proceed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
                    );
                    widget.onAddressSelected(selectedAddress!);
                  await Future.delayed(Duration(seconds: 2));

                  // Close loading indicator
                  Navigator.pop(context);

                  // Navigate to next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderPlacedPage()),
                  );
                  // } else {
                  //   // Error - show error message
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
                  //   );
                  // }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAddress != null && selectedAddress!.isNotEmpty && selectedAddress != 'No address saved'
                      ? const Color(0xFFF15A25)
                      : const Color(0xFFCCCCCC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height:32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        'assets/images/cartcall.png', // Replace with your asset path
                        width: 32,
                        height: 32,

                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Call cart at this address",
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class CartBookingService {
  static const String baseUrl = 'http://13.126.169.224/api/v1';

  // First API call - Create booking
  static Future<Map<String, dynamic>?> createBooking({
    required int userId,
    required String cartType,
     required String address,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/book/create-cart');

      final body = {
        "user_id": userId,
        "cart_type": cartType,
         "address": address,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Booking created successfully: ${data['message']}');
        return data;
      } else {
        print('Failed to create booking: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  // Second API call - Smart order request
  static Future<Map<String, dynamic>?> createSmartOrder({
    required int userId,
    required int bookingId,
    required String cartType,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/smartOrders/smart-order');

      final body = {
        "user_id": userId,
        "booking_id": bookingId,
        "cart_type": cartType,
        "latitude": latitude,
        "longitude": longitude,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Smart order created successfully: ${data['message']}');
        return data;
      } else {
        print('Failed to create smart order: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating smart order: $e');
      return null;
    }
  }

  // Combined function to call both APIs sequentially
  static Future<Map<String, dynamic>> callCartAtAddress({
    required int userId,
    required String address,
    required String cartType,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Step 1: Create booking
      final bookingResult = await createBooking(
        userId: userId,
        cartType: cartType,
        address: address,
      );

      if (bookingResult == null || !bookingResult['success']) {
        return {
          'success': false,
          'message': 'Failed to create booking',
        };
      }

      // Extract booking_id from the response
      final bookingId = bookingResult['data']['booking_id'];

      // Step 2: Create smart order using the booking_id
      final smartOrderResult = await createSmartOrder(
        userId: userId,
        bookingId: bookingId,
        cartType: cartType,
        latitude: latitude,
        longitude: longitude,
      );

      if (smartOrderResult == null || !smartOrderResult['success']) {
        return {
          'success': false,
          'message': 'Booking created but failed to assign vendor',
          'booking_id': bookingId,
        };
      }

      return {
        'success': true,
        'message': 'Cart successfully called to your address!',
        'booking_data': bookingResult['data'],
        'smart_order_data': smartOrderResult['data'],
        'estimated_time': smartOrderResult['data']['estimated_assignment_time'] ?? 'Unknown',
      };

    } catch (e) {
      print('Error in callCartAtAddress: $e');
      return {
        'success': false,
        'message': 'An error occurred while processing your request',
      };
    }
  }
}