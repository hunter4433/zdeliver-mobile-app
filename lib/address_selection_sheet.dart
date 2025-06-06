import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as _secureStorage;
import 'dart:convert';
import 'package:Zdeliver/address_selection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_address_selection_modal.dart';

class SavedAddressSelectionSheet extends StatefulWidget {
  final Function(String) onAddressSelected;


  const SavedAddressSelectionSheet({Key? key, required this.onAddressSelected})
    : super(key: key);

  // Static method to show the bottom sheet
  static void showAddressSelectionSheet(
    BuildContext context,
    Function(String) onAddressSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SavedAddressSelectionSheet(onAddressSelected: onAddressSelected);
      },
    );
  }

  @override
  _AddressSelectionSheetState createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<SavedAddressSelectionSheet> {
  List<dynamic> _addresses = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      String? userId = await _secureStorage.read(key: 'userId');
      String? savedAddress = await _secureStorage.read(key: 'saved_address');

      print('http://13.126.169.224/api/v1/addresses?user_id=$userId');
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse('http://13.126.169.224/api/v1/addresses?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers like authorization tokens
        },
      );

      print('Mohit Here');
      print(response);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          _addresses = responseData['data'] ?? [];
          ;

          // Add saved address to the beginning of the list if it exists
          // if (savedAddress != null && savedAddress.isNotEmpty) {
          _addresses.insert(0, {
            'id': 'saved_location',
            'full_address': savedAddress,
            'type': 'Current Location',
            'isCurrentLocation': true,
          });
          // }
          print('mohit here');
          print(_addresses);

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load addresses';
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.48,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Select Address",

            style: GoogleFonts.leagueSpartan(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Search field (unchanged)
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 16),
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.shade100,
          //     borderRadius: BorderRadius.circular(10),
          //     border: Border.all(color: Colors.grey.shade300),
          //   ),
          //   child: const Row(
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           decoration: InputDecoration(
          //             hintText: "Enter location",
          //             hintStyle: TextStyle(color: Colors.grey),
          //             border: InputBorder.none,
          //           ),
          //         ),
          //       ),
          //       Icon(Icons.search, color: Colors.grey),
          //     ],
          //   ),
          // ),

          // // Current location (unchanged)
          // Container(
          //   margin: const EdgeInsets.all(16),
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.shade50,
          //     borderRadius: BorderRadius.circular(24),
          //     border: Border.all(color: Colors.grey.shade200),
          //   ),
          //   child: Row(
          //     children: [
          //       const Icon(
          //         Icons.location_on,
          //         color: Colors.red,
          //         size: 36,
          //       ),
          //       const SizedBox(width: 12),
          //       const Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "Current location",
          //               style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             Text(
          //               "Enable device location to fetch current location",
          //               style: TextStyle(
          //                 fontSize: 14,
          //                 color: Colors.grey,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.all(6.0),
          //         child: ElevatedButton(
          //           onPressed: () {},
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.white,
          //             foregroundColor: Colors.orange,
          //             elevation: 0,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(12),
          //               side: const BorderSide(color: Colors.white),
          //             ),
          //             shadowColor: Colors.black.withOpacity(0.5),
          //           ).copyWith(
          //             elevation: MaterialStateProperty.all(4),
          //             shadowColor: MaterialStateProperty.all(Colors.black.withOpacity(0.5)),
          //           ),
          //           child: const Text(
          //             "Enable",
          //             style: TextStyle(
          //               fontSize: 15,
          //               fontWeight: FontWeight.w700,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved addresses",

                style: GoogleFonts.leagueSpartan(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Add new address (unchanged)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListTile(
              leading: const Icon(Icons.add, color: Colors.red, size: 34),
              title: Text(
                "Add new address",
                style: GoogleFonts.leagueSpartan(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, size: 30),
              onTap: () async {
                // Handle add new address
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectAddressPage()),
                );
                if (res != null) {
                  // set the selected address
                  print('Selected address: $res');
                  widget.onAddressSelected(res as String);
                  // fetch addresses again after adding a new one
                  await _fetchAddresses();
                } // Refresh addresses after adding a new one
              },
            ),
          ),

          // Dynamic addresses list
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Expanded(
                child: ListView.builder(
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return _buildAddressItem(
                      context,
                      address['full_address'] ?? 'Unnamed Address',
                      address['full_address'] ?? '',
                      address['user_id'].toString(),
                      onTap: () async {
                        print (address);
                        widget.onAddressSelected(
                          address['full_address'] ?? 'Unnamed Address',
                        );
                        await _secureStorage.write(
                          key: 'saved_address',
                          value:
                              _addresses[index]['full_address'] ??
                              'Unnamed Address',
                        );
                        // Optionally, you can also save other details like latitude, longitude, etc.
                        // await _secureStorage.write(
                        //   key: 'user_position',
                        //   value: '$_latitude,$_longitude',
                        // );
                        Navigator.pop(
                          context,
                        ); // This will close the bottom sheet
                      },
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(
    BuildContext context,
    String title,
    String address,
    String phone, {
    required Function() onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "User ID: $phone",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
