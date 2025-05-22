import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mrsgorilla/checkoutPage.dart';

class HerbsPage extends StatefulWidget {
  const HerbsPage({Key? key}) : super(key: key);


  @override
  State<HerbsPage> createState() => _HerbsPageState();
}


class _HerbsPageState extends State<HerbsPage> {
  int itemCount = 0; // Initial count for bottom button
  final searchController = TextEditingController();
  // Track added products
  Map<String, bool> addedProducts = {};
  Map<String, int> productQuantities = {};
  String? currentProduct; // Track which product is currently showing the options card
  bool isCardVisible = false;
  List<dynamic> items = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.post(
        Uri.parse('http://3.111.39.222/api/v1/veggies/category'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"category": "herbs"}), // Change category if needed
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          items = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }
  // // // Sample product data
  // final List<Map<String, dynamic>> products = [
  //   {
  //     'name': 'Aloo',
  //     'unit': 'kilos',
  //     'description': 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda',
  //     'image': 'assets/images/potato_png2391.png',
  //   },
  //   {
  //     'name': 'Shimla Mirch',
  //     'unit': 'kilos',
  //     'description': 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda',
  //     'image': 'assets/images/color-capsicum.png',
  //   },
  //   {
  //     'name': 'Mirch',
  //     'unit': 'kilos',
  //     'description': 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda',
  //     'image': 'assets/images/Frame 605.png',
  //   },
  //   {
  //     'name': 'Tamatar',
  //     'unit': 'kilos',
  //     'description': 'Make curry, sauce, salad, soup',
  //     'image': 'assets/images/potato_png2391.png',
  //   },
  //   {
  //     'name': 'Onion',
  //     'unit': 'kilos',
  //     'description': 'Use in curries, salads, and many other dishes',
  //     'image': 'assets/images/oninon.png',
  //   },
  //   {
  //     'name': 'Carrot',
  //     'unit': 'kilos',
  //     'description': 'Make halwa, salad, soup, sabzi',
  //     'image': 'assets/images/bunch-of-carrots-isolated-on-transparent-background-png.png',
  //   },
  //   {
  //     'name': 'baingan',
  //     'unit': 'kilos',
  //     'description': 'Make bharta, sabzi',
  //     'image': 'assets/images/Big-brinjal-eggplant.png',
  //   },
  // ];


  void toggleProductAdded(String productName) {
    if (addedProducts.containsKey(productName) && addedProducts[productName] == true) {
      // Product is already added, clicking will remove it
      setState(() {
        addedProducts[productName] = false;
        itemCount -= productQuantities[productName] ?? 1;
        productQuantities.remove(productName);
      });
    } else {
      // Product not added, show the options card
      setState(() {
        currentProduct = productName;
        isCardVisible = true;
        if (!productQuantities.containsKey(productName)) {
          productQuantities[productName] = 1; // Default quantity
        }
      });
    }
  }


  void addItemWithOptions() {
    if (currentProduct != null) {
      setState(() {
        addedProducts[currentProduct!] = true;
        itemCount += productQuantities[currentProduct!] ?? 1;
        isCardVisible = false;
        currentProduct = null; // Clear current product when added
      });
    }
  }


  void incrementQuantity() {
    if (currentProduct != null) {
      setState(() {
        productQuantities[currentProduct!] = (productQuantities[currentProduct!] ?? 0) + 1;
      });
    }
  }


  void decrementQuantity() {
    if (currentProduct != null && (productQuantities[currentProduct!] ?? 0) > 1) {
      setState(() {
        productQuantities[currentProduct!] = productQuantities[currentProduct!]! - 1;
      });
    }
  }


  void closeOptionsCard() {
    setState(() {
      isCardVisible = false;
      currentProduct = null; // Clear current product when card is closed
    });
  }


  @override
  Widget build(BuildContext context) {
    // Find the current product data
    Map<String, dynamic>? currentProductData;
    if (currentProduct != null) {
      currentProductData = items.firstWhere(
            (product) => product['name'] == currentProduct,
        orElse: () => {},
      );
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28), // Back arrow with stem
          onPressed: () {
            Navigator.pop(context); // Navigates back
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 28), // Three-dot menu icon
            onPressed: () {
              // Handle menu action here
            },
          ),
        ],
        elevation: 4, // Adds a shadow for a better look
        shadowColor: Colors.black.withOpacity(0.3),
      ),


      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80), // Add padding for the bottom button
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                             'Essential herbs And Spices',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Select your veggies, fruits, and quantity, and our delivery partner brings them fresh to your doorstep in minutes!',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                // Location and delivery time
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black, size: 35),
                      const SizedBox(width: 8),
                      const Text(
                        'Navi Mumbai',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '27 mins',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                // Badges
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 16, right: 7),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFF95CCBA),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Text(
                            '10% less than market price',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 8, right: 16),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFA7BA42),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Text(
                            'Freshness guarantee',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, left: 16.0),
                      child: Text(
                        "How do you want your order delivered as?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Customized order button
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          // Your action here
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFE76F51), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          "Customized order",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE76F51),
                          ),
                        ),
                      ),
                    ),
                    // Customized cart button
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          // Your action here
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          "Customized cart",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F8FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFA8CCE0)),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Enter fruit, vegetable name',
                        hintStyle: TextStyle(
                            color: Color(0xFFA8CCE0),
                            fontWeight: FontWeight.w600,
                            fontSize: 17
                        ),
                        suffixIcon: Icon(Icons.search, color: Color(0xFFA8CCE0)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),


                // Recommended section title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        'Recommended for you',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade700),
                    ],
                  ),
                ),


                // Product List
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = items[index];

                    // final hardcodedProduct = products.firstWhere(
                    //       (p) => p['name'] == product['name'],
                    //   orElse: () => {
                    //     'description': 'No description available',
                    //     'image': 'assets/images/png-transparent-red-onions-raw-foodism-organic-food-shallot-red-onion-vegetable-onion-natural-foods-leaf-vegetable-food-thumbnail.png' // Default image if not found
                    //   },
                    // );
                    return ProductCard(
                      name: product['name'] ?? '',
                      unit: product['unit'] ?? '',
                      description: product['description'] ?? '',
                      imagePath: product['image_url'] ?? '',
                      isAdded: addedProducts[product['name']] ?? false,
                      onToggleAdded: () => toggleProductAdded(product['name']),
                    );
                  },
                ),
              ],
            ),
          ),


          // Fixed bottom button
          Positioned(
            bottom: 32,
            left: 50,
            right: 50,
            child: Container(
              height: 60,
              width: 250,
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
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        '$itemCount ${itemCount == 1 ? 'item' : 'items'} added',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Call the navigation method when the container is tapped
                        navigateToOrderSummary();
                      },
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF328616),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'View order',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          // Background overlay when card is visible
          if (isCardVisible)
            GestureDetector(
              onTap: closeOptionsCard,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),


          // Options card that slides up from bottom
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isCardVisible ? 0 : -400, // Increased negative value to ensure it's off-screen
            left: 0,
            right: 0,
            child: currentProductData != null && currentProductData.isNotEmpty
                ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Product image
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            currentProductData['image_url'] as String,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 16),
                        // Product name
                        Text(
                          currentProductData['name'] as String,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Options text
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose how do you want your ${(currentProductData['name'] as String).toLowerCase()}s',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Options list
                  Container(
                    color: Color(0xFFF0F8FF),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(
                        (currentProductData['options'] as List?)?.length ?? 0,
                            (index) => OptionTile(
                          text: (currentProductData?['options'] as List)[index] as String,
                          isSelected: index == 0, // Default select first option
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Quantity selector and Add Item button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Row(
                      children: [
                        // Quantity selector
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: decrementQuantity,
                              ),
                              Text(
                                '${productQuantities[currentProduct] ?? 1}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: incrementQuantity,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Add item button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: addItemWithOptions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF328616),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Add item',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                : SizedBox(), // Empty container if no product is selected
          ),
        ],
      ),
    );
  }

  void navigateToOrderSummary() {
    // Collect all selected items with their details
    final selectedItems = <Map<String, dynamic>>[];
    double itemsTotal = 0.0;
    print('kinu');
    print(items);

    for (var item in items) {

      final productName = item['name'] ?? '';
      if (addedProducts[productName] == true) {
        final quantity = productQuantities[productName] ?? 1;
        final price = item['price'] ?? 45.0;
        final totalPrice = price * quantity;

        itemsTotal += totalPrice;

        selectedItems.add({
          'id':item['id'],
          'name': productName,
          'quantity': quantity,
          'price': price,
          'unit': item['unit'] ?? 'Kg',
          'image_url': item['image_url'] ?? '',
          'total_price': totalPrice,
        });
      }
    }

    // Calculate bill components
    const discountPercent = 22.0; // e.g., Gorilla 20 gives ~22% off
    final discountAmount = (itemsTotal * discountPercent / 100).roundToDouble();
    const platformFee = 8.0;
    const deliveryCharge = 12.0;
    final grandTotal = itemsTotal - discountAmount + platformFee + deliveryCharge;

    // Bill data map
    final billData = {
      'items_total': itemsTotal,
      'discount_amount': discountAmount,
      'platform_fee': platformFee,
      'delivery_charge': deliveryCharge,
      'grand_total': grandTotal,
      'saved_amount': discountAmount,
      'discount_code': 'Gorilla 20',
    };

    // Navigate to the order summary page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CheckoutPage(
              selectedProducts: selectedItems,
              sourceScreen: 'GroceryPage',
              billData: billData,
            )
        )
    );
  }
}


class ProductCard extends StatelessWidget {
  final String name;
  final String unit;
  final String description;
  final String imagePath;
  final bool isAdded;
  final VoidCallback onToggleAdded;


  const ProductCard({
    Key? key,
    required this.name,
    required this.unit,
    required this.description,
    required this.imagePath,
    required this.isAdded,
    required this.onToggleAdded,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product information
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'in ',
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w500
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Divider(),


          // Product image and add button
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Product Image
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),


                  // Add button
                  Positioned(
                    bottom: -7,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggleAdded,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isAdded
                                ? null
                                : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF3F2E78),
                                Color(0xFF745EBF),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                            color: isAdded ? Colors.white : null,
                            borderRadius: BorderRadius.circular(8),
                            border: isAdded ? Border.all(color: Colors.deepPurple, width: 1) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                spreadRadius: 3,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            isAdded ? 'Added' : 'Add',
                            style: TextStyle(
                              fontSize: 17,
                              color: isAdded ? Colors.deepPurple : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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


class OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;


  const OptionTile({
    Key? key,
    required this.text,
    required this.isSelected,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.white : Color(0xFFE0E0E0),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

