import 'package:Zdeliver/address_model.dart';
import 'package:Zdeliver/coordinate_class.dart';
import 'package:Zdeliver/services/local_storage.dart';
import 'package:Zdeliver/services/warehouse_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Zdeliver/address_selection_sheet.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Zdeliver/orderPlace.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_address_selection_modal.dart';
// import 'vendorAssignAndNotification.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;
  final String? sourceScreen;
  final Map<String, dynamic>? billData;

  const CheckoutPage({
    Key? key,
    required this.selectedProducts,
    this.sourceScreen,
    this.billData,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPage();
}

class _CheckoutPage extends State<CheckoutPage> {
  bool _addressSelected = false;
  bool isLoading = false;
  String _selectedAddress = "Loading address...";
  late String? totalpay;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // List to track which items have "Added" status
  late List<bool> isAddedList;

  @override
  void initState() {
    super.initState();

    // Initialize isAddedList with true values for each product
    isAddedList = List.generate(widget.selectedProducts.length, (_) => true);
    // totalpay= '${widget.billData!['grand_total'].toStringAsFixed(2)}';

    // Load the saved address when the page is initialized
    setAddress();
  }

  Future setAddress() async {
    try {
      Address? addressData = await LocalStorage().getUserSelectedAddress();
      if (addressData == null) {
        setState(() {
          _selectedAddress = 'No address saved';
          _addressSelected = false; // Set address as not selected
        });
        return;
      }

      String? address = addressData.fullAddress;

      // Optional: Format the address for better display
      // You can adjust the character limit as needed
      if (address.length > 100) {
        address = '${address.substring(0, 100)}...';
      }
      setState(() {
        _selectedAddress = address!;
        _addressSelected = true; // Set address as selected
      });
      print('Address loaded: $_selectedAddress');
    } catch (e) {
      print('Error reading saved_address: $e');
      setState(() {
        _selectedAddress = 'No address saved';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(253, 204, 41, 1), elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(widget.selectedProducts),
        ),

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 15, right: 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      ' Customize Cart',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Check your items and select the address',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Address selection section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: GoogleFonts.leagueSpartan(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedAddress,
                        style: GoogleFonts.leagueSpartan(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: () {
                          // Open address selection dialog
                          _showAddressSelectionSheet();
                        },
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.black,
                        ),
                        label: Text(
                          "Change address",
                          style: GoogleFonts.leagueSpartan(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromRGBO(0, 0, 0, 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Items in cart section
                Container(
                  margin: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Items in customized cart",
                        style: GoogleFonts.leagueSpartan(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 12,
                      //     vertical: 6,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFEEF7E8),
                      //     borderRadius: BorderRadius.circular(13),
                      //     border: Border.all(
                      //       color: const Color(0xFF4A8F3C),
                      //       width: 2,
                      //     ),
                      //   ),
                      //   child: Text(
                      //     "you can add 7 more items",
                      //     style: GoogleFonts.leagueSpartan(
                      //       fontSize: 16,

                      //       color: Colors.black54,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 10),
                      const Divider(),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.selectedProducts.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(
                            index,
                            "",
                            "",
                          ); // The name and imageName will be taken from the product data
                        },
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, widget.selectedProducts);
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>  GroceryPage()
                              //     )
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(80, 40),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 18,
                              ),
                              side: const BorderSide(
                                color: const Color.fromRGBO(253, 204, 41, 1),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Add more items",
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Extra space at the bottom to account for the fixed button
                const SizedBox(height: 100),
              ],
            ),
          ),

          Positioned(
            bottom: 10,
            left: 30,
            right: 30,
            child: Container(

              height: 60,
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xFF328616),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 6),
                    // >>>>>>> origin/aman1
                  ),
                ],
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    // Check if address is selected
                    if (_addressSelected) {
                      print('placing order');
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(child: CircularProgressIndicator());
                        },
                      );
                      CoordinatesPair? userposition =
                          await LocalStorage().getUserPositionLocally();
                      if (userposition != null) {
                        bool wareHouseAvailable =
                            await WarehouseService()
                                .checkWarehouseAvailability();

                        if (!wareHouseAvailable) {
                          Navigator.pop(context);
                          _showNotAvailableDialog();
                          return;
                        }
                      }


                      // Place order and wait for completionr
                      Map<String, dynamic>? orderResult = await placeOrder();
                      String? booking_id= orderResult!['data']['data']['booking_id'].toString();
print(orderResult);
                      print('--------------bookingid is ------------$booking_id');




                      if (orderResult == null || orderResult['success'] != true) {
                        // Order failed
                        Navigator.pop(context); // Close loading dialog

                        String errorMessage = orderResult?['error'] ?? 'Failed to place order';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                        return;
                      }


                      // Close loading indicator
                      Navigator.pop(context);

                      // if (true) {
                      // success && placeOrder != false
                        // Show success message

                        // Navigate to next page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrderPlacedPage(
                                  address: null,
                                  bookingId:booking_id
                                ),
                          ),
                        );
                      // }
                    } else {
                      // Show address selection
                      _showAddressSelectionSheet();
                    }
                  },
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF328616),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Place order',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Fixed placeOrder function
  Future<Map<String, dynamic>?> placeOrder() async {
    String? ordertype;

    String? userId = await LocalStorage().getUserId();

    // Check if we have selected products to order
    if (widget.selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected for order')),
      );
      return null;
    }

    try {
      print(widget.selectedProducts);

      // Format items as required by API
      final List<Map<String, dynamic>> formattedItems = widget.selectedProducts.map((product) {
        return {
          "item_id": product['id'], // Fixed: removed asterisk
          "quantity": product['quantity'],
          "price_per_unit": product['price_per_unit'],
        };
      }).toList();

      print(formattedItems);

      // if (widget.sourceScreen == 'GroceryPage') {
      //   ordertype = "order";
      // } else {
      //   ordertype = "cart";
      // }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "user_id": userId,
        "booking_type": "order", // Use the determined order type
        "address": _selectedAddress, // Fixed: removed asterisk
        "items": formattedItems,
      };

      print('Request Body: ${jsonEncode(requestBody)}');

      // Make API call
      final response = await http.post(
        Uri.parse('http://13.126.169.224/api/v1/book/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success, order created
        final responseData = jsonDecode(response.body);
        print('Order created successfully: $responseData');

        String? address;
        if (responseData['data'] != null && responseData['data']['order_address'] != null) {
          address = responseData['data']['order_address']; // Fixed: removed asterisk
        }

        return {
          'success': true,
          'address': address,
          'data': responseData
        };
      } else {
        // Handle API error
        print('API Error: Status ${response.statusCode}, Body: ${response.body}');

        // Try to parse error message from response
        String errorMessage = 'Failed to place order';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message if parsing fails
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );

        return {
          'success': false,
          'error': errorMessage
        };
      }
    } catch (e) {
      print('Exception in placeOrder: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: ${e.toString()}')),
      );

      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  Future<bool> sendVendorNotification() async {
    try {
      print('sending notification');
      // API endpoint from your Postman example
      const String url =
          'http://13.126.169.224/api/v1/notifisent/send-notification';

      // Request payload based on your Postman example
      Map<String, dynamic> payload = {
        "user_id": 1,
        "booking_order_id": 2,
        "vendor_id": 1,
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
        print(
          "Failed to send notification. Status code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error sending notification: $e");
      // Consider showing an error message to the user
      return false;
    }
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
      //  currentAddress: _selectedAddress
    );
  }

  Widget _buildCartItem(int index, String name, String imageName) {
    // Get the actual product from the passed list
    final product = widget.selectedProducts[index];
    print(product);

    // Check if navigation is from the grocery page
    final isFromGroceryPage = widget.sourceScreen == 'GroceryPage';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFF0F8FF), width: 2),
        ),
      ),
      child: Row(
        children: [
          // Image - remains the same for both views
          product['image_url'] != null && product['image_url'].isNotEmpty
              ? Image.network(
                product['image_url'],
                width: 70,
                height: 55,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assests/potato_png2391.png",
                    width: 70,
                    height: 55,
                  );
                },
              )
              : Image.asset(
                "assests/potato_png2391.png",
                width: 70,
                height: 55,
              ),
          const SizedBox(width: 20),
          // Product details - remains the same for both views
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['name'] ?? product['name'] ?? name,
                style: GoogleFonts.leagueSpartan(
                  color: Color.fromRGBO(0, 0, 0, 0.75),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "₹${product['price_per_unit']?.toString() ?? '0.00'}",
                style: GoogleFonts.leagueSpartan(
                  color: Color.fromRGBO(0, 0, 0, 0.65),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Conditional rendering based on source screen
          // if (isFromGroceryPage)
          //   // Quantity controls for grocery page
          //   Container(
          //     decoration: BoxDecoration(
          //       color: const Color(0xFF3F8F3C),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Row(
          //       children: [
          //         // Decrease button
          //         IconButton(
          //           icon: const Icon(Icons.remove, color: Colors.white),
          //           onPressed: () {
          //             // Decrease quantity logic
          //           },
          //         ),
          //         // Quantity display
          //         Container(
          //           padding: const EdgeInsets.symmetric(horizontal: 8),
          //           child: Text(
          //             (product['quantity'] ?? 1).toString(),
          //             style: const TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.white,
          //             ),
          //           ),
          //         ),
          //         // Increase button
          //         IconButton(
          //           icon: const Icon(Icons.add, color: Colors.white),
          //           onPressed: () {
          //             // Increase quantity logic
          //           },
          //         ),
          //       ],
          //     ),
          //   )
          // else
          // "Added/Add" button for CustomizeCart page (existing code)
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    // delted the item from the cart

                    isAddedList[index] = !isAddedList[index];
                    isAddedList.removeAt(index);
                    widget.selectedProducts.removeAt(index);
                    print(widget.selectedProducts);
                  });
                },
                icon: Icon(Icons.delete_outline_sharp, color: Colors.black54),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  "Added",
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  void _selectAddress(String address) async {
    setState(() {
      _addressSelected = true;
      _selectedAddress = address;
    });
    Navigator.pop(context); // Close the bottom sheet
    CoordinatesPair? userposition =
        await LocalStorage().getUserPositionLocally();
    if (userposition != null) {
      print('------------calling getWareHouse------');
      Warehouse? warehouse = await WarehouseService().getWareHouse(
        userposition.latitude,
        userposition.longitude,
        context,
      );
      print('----sdncjk----');
      // print( warehousePosition);


      if (warehouse != null) {
        print('Warehouse position: ${warehouse.warehousePosition
            .latitude}, ${warehouse.warehousePosition.longitude}');
        print('Warehouse available: ${warehouse.isAvailable}');

        if (!warehouse.isAvailable) {
          _showNotAvailableDialog();
          return;
        }
      }



    }
  }

  void _proceedToPayment() {
    // Handle payment logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Proceeding to payment with address: $_selectedAddress"),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

