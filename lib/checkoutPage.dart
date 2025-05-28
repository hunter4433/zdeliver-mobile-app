import 'package:flutter/material.dart';
import 'package:mrsgorilla/address_selection_sheet.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mrsgorilla/orderPlace.dart';
import 'package:google_fonts/google_fonts.dart';



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
  bool isLoading=false;
  String _selectedAddress = "";
  late String? totalpay;


  // List to track which items have "Added" status
  late List<bool> isAddedList;

  @override
  void initState() {
    super.initState();
    // Initialize isAddedList with true values for each product
    isAddedList = List.generate(widget.selectedProducts.length, (_) => true);
    // totalpay= '${widget.billData!['grand_total'].toStringAsFixed(2)}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text(
          "Checkout",
          style: GoogleFonts.leagueSpartan(
              color: Colors.black, fontWeight: FontWeight.w600,fontSize: 24),
        ),
      ),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
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

                         fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF7E8),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: const Color(0xFF4A8F3C),
                            width: 2,
                          ),
                        ),
                        child:  Text(
                          "you can add 7 more items",
                          style: GoogleFonts.leagueSpartan(fontSize: 16,

                          color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),


                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.selectedProducts.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(index, "", "");  // The name and imageName will be taken from the product data
                        },
                      ),



                      Row(
                        children: [
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>  GroceryPage()
                                //     )
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF0F8FF),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                                side: const BorderSide(color: Color(0xFFE47650), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Add more items",
                                    style: GoogleFonts.leagueSpartan(
                                      fontSize: 16,
                                      color: Color(0xFFE47650),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(Icons.add, color: Color(0xFFE47650), size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                // Discounts section
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        "Discounts and coupons",
                         style: GoogleFonts.leagueSpartan(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     Container(
                      //       width: 40,
                      //       height: 40,
                      //       decoration: BoxDecoration(
                      //         color: const Color(0xFF4E30A5),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       child: const Center(
                      //         child: Text(
                      //           "20",
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //         const Spacer(),
                      //         Image.asset(
                      //           "assests/confetti 1.png",
                      //           width: 80,
                      //           height: 80,
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     const Text(
                      //       "Rs 40 saved with Gorilla 20",
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w500,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //     // Image.asset(
                      //     //   "",
                      //     //   width: 80,
                      //     //   height: 80,
                      //     // ),
                      //   ],
                      // ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: const Color(0xFFF0F8FF), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            side: const BorderSide(color: Color(0xFFE47650)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child:  Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "See all coupons",
                                style: GoogleFonts.leagueSpartan(fontSize: 16.5, fontWeight: FontWeight.w600, color: Color(0xFFE47650)),
                              ),
                              SizedBox(width: 68),
                              Icon(Icons.chevron_right, color: Color(0xFFE47650)),
                            ],
                          ),
                        ),
                      ),
                    ],
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


                // Extra space at the bottom to account for the fixed button
                const SizedBox(height: 100),
              ],
            ),
          ),


          // Fixed bottom button - UPDATED
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Only show this when address is selected
                  if (_addressSelected)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Deliver to",
                                  style: TextStyle(
                                    fontSize: 15,fontWeight: FontWeight.w700,
                                    color: Color(0xFFE47650),
                                  ),
                                ),
                                Text(
                                  _selectedAddress.split(' - ').first,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Hs no. 15, Sharadanagari, karjat, mirajgaon road...",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              _showAddressSelectionSheet();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              side: const BorderSide(color: Color(0xFFE47650)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: const Text(
                              "Change",
                              style: TextStyle(fontSize: 16,
                                color: Color(0xFFE47650),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                  // Payment row
                  Row(
                    children: [
                      // Only show payment method when address is selected
                      if (_addressSelected)
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 35),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Pay using",
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "Cash on delivery",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),


                      // Payment button - MODIFIED
                      Expanded(
                        flex: _addressSelected ? 3 : 5,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_addressSelected) {
                              // placeOrder();

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                },
                              );

                              // Make API call
                              // bool success = await sendVendorNotification();

                              // Close loading indicator
                              Navigator.pop(context);

                              // if (success) {
                                // Navigate to next page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderPlacedPage()),
                                );
                              // }
                            }else {
                              // Show address selection
                              _showAddressSelectionSheet();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F2E78),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _addressSelected
                          // Content when address is selected - Show price and "Place Order"
                              ? Row(
                            children: [
                              // Left side: To pay + Rs. 120
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:  [
                                  Text(
                                    "To pay",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(width: 17),
                              // Right side: Place Order text
                              Text(
                                "Place Order",
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                          // Content when no address is selected - Only "Select Address to deliver order"
                              : Center(
                            child: Text(
                              "Select Address to deliver order",
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),


                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void placeOrder() async {
    String? ordertype;
    // Check if we have selected products to order
    if (widget.selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected for order')),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      // Format items as required by API
      final List<Map<String, dynamic>> formattedItems = widget.selectedProducts.map((product) {
        return {
          "item_id": product['id'], // Assuming your product has an id field
          "quantity": product['quantity'],
          "price_per_unit": product['price'],
        };
      }).toList();
      print(formattedItems);

      if (widget.sourceScreen == 'GroceryPage') {
        ordertype = "order";  // Assign order value if sourcescreen is GroceryPage
      } else {
        ordertype = "cart";  // Otherwise, assign cart value
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "user_id": 1, // Changed to 1 as shown in the Postman screenshot
        "booking_type": ordertype,
        "order_address":_selectedAddress,
        "items": formattedItems,
      };

      // Make API call
      final response = await http.post(
        Uri.parse('http://3.111.39.222/api/v1/book/create'), // Updated URL from screenshot
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print('mohit here');
print(response.body);
      // Handle response
      if (response.statusCode == 201) { // Changed to specifically check for 201 Created
        // Success, order created
        final responseData = jsonDecode(response.body);
        print(responseData);
        String address=responseData['data']['order_address'];
        print(address);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Order created successfully')),
        );

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderPlacedPage(
                address: address,
                )
            )
        );
      } else {
        // Handle error
        throw Exception('Failed to place order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Show error message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error placing order: ${e.toString()}')),
      // );
    } finally {
      // Hide loading indicator
      setState(() {
        isLoading = false;
      });
    }
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


  void _showAddressSelectionSheet() {
    // Use the static method from AddressSelectionSheet class
    AddressSelectionSheet.showAddressSelectionSheet(
      context,
          (address) {
        // Handle the selected address
        _selectAddress(address);
        // The sheet will be closed automatically
      },
    );
  }

  Widget _buildCartItem(int index, String name, String imageName) {
    // Get the actual product from the passed list
    final product = widget.selectedProducts[index];
    print(widget.sourceScreen );

    // Check if navigation is from the grocery page
    final isFromGroceryPage = widget.sourceScreen == 'GroceryPage';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFFF0F8FF), width: 2)),
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
                product['name'] ?? product['item_name'] ?? name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "₹${product['price']?.toString() ?? 'Cart'} per ${product['unit'] ?? 'unit'}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Conditional rendering based on source screen
          if (isFromGroceryPage)
          // Quantity controls for grocery page
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3F8F3C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Decrease button
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      // Decrease quantity logic
                    },
                  ),
                  // Quantity display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      (product['quantity'] ?? 1).toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Increase button
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      // Increase quantity logic
                    },
                  ),
                ],
              ),
            )
          else
          // "Added/Add" button for CustomizeCart page (existing code)
            GestureDetector(
              onTap: () {
                setState(() {
                  isAddedList[index] = !isAddedList[index];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: isAddedList[index]
                      ? null
                      : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3F2E78),
                      Color(0xFF745EBF),
                    ],
                  ),
                  color: isAddedList[index] ? Colors.white : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  isAddedList[index] ? "Added" : "Add",
                  style: TextStyle(
                    fontSize: 17,
                    color: isAddedList[index] ? const Color(0xFF4A8F3C) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  void _selectAddress(String address) {
    setState(() {
      _addressSelected = true;
      _selectedAddress = address;
    });
    Navigator.pop(context); // Close the bottom sheet
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


class DashPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;


  DashPainter({
    required this.color,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;


    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


