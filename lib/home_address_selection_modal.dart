import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'address_selection_sheet.dart';
import 'orderPlace.dart';

// Updated AddressSelectionSheet Class
class AddressSelectionSheet extends StatefulWidget {
  final Function(String) onAddressSelected;

  const AddressSelectionSheet({
    Key? key,
    required this.onAddressSelected,
  }) : super(key: key);

  static void showAddressSelectionSheet(BuildContext context, Function(String) onAddressSelected) {
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
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadCurrentAddress();
  }

  Future<void> _loadCurrentAddress() async {
    try {
      String? savedAddress = await _secureStorage.read(key: 'saved_address');
      setState(() {
        _currentAddress = savedAddress ?? 'No address saved';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Error loading address';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToSavedAddresses() async {
    _showAddressSelectionSheet();

    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SavedAddressSelectionSheet(
    //       onAddressSelected: (selectedAddress) {
    //         // Update the current address in secure storage
    //         _secureStorage.write(key: 'saved_address', value: selectedAddress);
    //         // Update the UI
    //         setState(() {
    //           _currentAddress = selectedAddress;
    //         });
    //         // Close the SavedAddressSelectionSheet
    //         Navigator.pop(context);
    //       },
    //     ),
    //   ),
    // );
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
      // _addressSelected = true;
      // _selectedAddress = address; // Store the selected address
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
          const Text(
            "Select Address",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
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
                  color: Colors.black.withOpacity(0.04),
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
                  const Text(
                    "Change address",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFFF15A25),
                    size: 28,
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
                      _currentAddress ?? 'No address available',
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
                onPressed: _currentAddress != null && _currentAddress!.isNotEmpty && _currentAddress != 'No address saved'
                    ? () {
                  widget.onAddressSelected(_currentAddress!);
                  Navigator.pop(context);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentAddress != null && _currentAddress!.isNotEmpty && _currentAddress != 'No address saved'
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
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        'assets/images/Frame 540.jpg', // Replace with your asset path
                        width: 16,
                        height: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Call cart at this address",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'League Spartan',
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