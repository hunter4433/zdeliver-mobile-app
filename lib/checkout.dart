import 'package:flutter/material.dart';


class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);


  @override
  State<CheckoutPage> createState() => _CheckoutPage();
}


class _CheckoutPage extends State<CheckoutPage> {
  bool _addressSelected = false;
  String _selectedAddress = "";


  // List to track which items have "Added" status
  List<bool> isAddedList = [true, true, true, true, true, true];


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
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
                      const Text(
                        "Items in customized cart",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                        child: const Text(
                          "you can add 7 more items",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),


                      // Cart items
                      _buildCartItem(0, "Potato", "potato"),
                      _buildCartItem(1, "Cauliflower", "cauliflower"),
                      _buildCartItem(2, "Cauliflower", "cauliflower"),
                      _buildCartItem(3, "Potato", "potato"),
                      _buildCartItem(4, "Cauliflower", "cauliflower"),
                      _buildCartItem(5, "Cauliflower", "cauliflower"),


                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF0F8FF),
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                                side: BorderSide(color: Colors.grey.shade500, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Create Basket",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Container(
                                    height: 22,
                                    width: 22,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                      image: DecorationImage(
                                        image: AssetImage('assests/shopping-bag (1) 1.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF0F8FF),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                                side: const BorderSide(color: Color(0xFFE47650), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Add more items",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFFE47650),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(Icons.add, color: Color(0xFFE47650), size: 28),
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
                // Container(
                //   height: 200,
                //   margin: const EdgeInsets.symmetric(horizontal: 5),
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         "Discounts and coupons",
                //         style: TextStyle(
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "See all coupons",
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFFE47650)),
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


                // Bill details section - RESTORED FROM ORIGINAL CODE
                Container(
                  margin: const EdgeInsets.fromLTRB(5, 25, 5, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "To pay : Rs. 120",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Rs 40 saved with Gorilla 20",
                        style: TextStyle(
                          color: Color(0xFF4A8F3C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Bill Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Items Total", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                          Text(
                            "Rs. 140.00",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomPaint(
                          painter: DashPainter(color: Colors.grey),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Discounts",
                                style: TextStyle(color: Color(0xFF4A8F3C), fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.info_outline, size: 16, color: Colors.grey),
                            ],
                          ),
                          const Text(
                            "Rs. 40.00",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A8F3C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomPaint(
                          painter: DashPainter(color: Colors.grey),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("Platform fee", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                              const SizedBox(width: 10),
                              Icon(Icons.info_outline, size: 16, color: Colors.grey),
                            ],
                          ),
                          const Text(
                            "Rs. 8.00",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomPaint(
                          painter: DashPainter(color: Colors.grey),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("Delivery charge", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                              const SizedBox(width: 10),
                              Icon(Icons.info_outline, size: 16, color: Colors.grey),
                            ],
                          ),
                          const Text(
                            "Rs. 12.00",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomPaint(
                          painter: DashPainter(color: Colors.grey),
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Grand Total",
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                          ),
                          Text(
                            "Rs. 120.00",
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                          ),
                        ],
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
                        "mrs.Gorilla",
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
                          onPressed: () {
                            if (_addressSelected) {
                              // Handle payment
                              _proceedToPayment();
                            } else {
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
                                children: const [
                                  Text(
                                    "To pay",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "Rs. 120",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 24),
                              // Right side: Place Order text
                              Text(
                                "Place Order",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                          // Content when no address is selected - Only "Select Address to deliver order"
                              : Center(
                            child: Text(
                              "Select Address to deliver order",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
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


  void _showAddressSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F8FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Select Address",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),


              // Search field
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Enter location",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.grey),
                  ],
                ),
              ),


              // Current location
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current location",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Enable device location to fetch current location",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange,
                          elevation: 0, // No default elevation
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white),
                          ),
                          shadowColor: Colors.black.withOpacity(0.5), // Shadow effect color
                        ).copyWith(
                          elevation: MaterialStateProperty.all(4), // Custom elevation for shadow
                          shadowColor: MaterialStateProperty.all(Colors.black.withOpacity(0.5)),
                        ),
                        child: const Text(
                          "Enable",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
              ),


              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Saved addresses",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),


              // Add new address
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.add,
                    color: Colors.red,
                    size: 34,
                  ),
                  title: const Text(
                    "Add new address",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right,size: 30,),
                  onTap: () {
                    // Handle add new address
                  },
                ),
              ),


              // Saved addresses list
              _buildAddressItem(
                "Katik Gadade",
                "Hs no. 15, Sharadanagari, karjat, mirajgaon road, 414402, dist- ahmednagar.",
                "8275451335",
                onTap: () => _selectAddress("Katik Gadade"),
              ),


              _buildAddressItem(
                "Home - Omkar",
                "Hs no. 15, Sharadanagari, karjat, mirajgaon road, 414402, dist- ahmednagar.",
                "8275451335",
                onTap: () => _selectAddress("Home - Omkar"),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildAddressItem(String title, String address, String phone, {required Function() onTap}) {
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Phone number : $phone",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCartItem(int index, String name, String imageName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFFF0F8FF), width: 2)),
      ),
      child: Row(
        children: [
          Image.asset(
            "assests/potato_png2391.png",   // You can replace with different vegetable images
            width: 70,
            height: 55,
          ),
          const SizedBox(width: 20),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
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


