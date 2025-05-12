import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import "package:mrsgorilla/checkoutPage.dart";

class GroceryPage extends StatefulWidget {
   // String? searchQuery;
  const GroceryPage({Key? key}) : super(key: key);


  @override
  State<GroceryPage> createState() => _GroceryPageState();
}


class _GroceryPageState extends State<GroceryPage> {
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
         body: jsonEncode({"category": "vegetables"}), // Change category if needed
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
print('dta is msk');
print(data);
        setState(() {
          items = data['data'];
          // Enrich item data with additional fields
          for (var item in items) {
            // Add price if not present
            if (!item.containsKey('price')) {
              item['price'] = 45.0; // Default price
            }

            // Add tags if not present
            if (!item.containsKey('tags')) {
              // Randomly assign tags for demonstration
              final tagOptions = ['Good morning basket', 'Tuesday lunch', 'Weekend special'];
              final randomTags = <String>[];
              if (item['name'].toString().toLowerCase().contains('potato')) {
                randomTags.add('Good morning basket');
              } else if (item['name'].toString().toLowerCase().contains('capsicum')) {
                randomTags.add('Tuesday lunch');
                randomTags.add('Good morning basket');
              } else {
                if (math.Random().nextBool()) {
                  randomTags.add(tagOptions[math.Random().nextInt(tagOptions.length)]);
                }
              }
              item['tags'] = randomTags;
            }
          }
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

// Navigate to order summary page with selected items
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {
              // Help action
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load products',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: fetchItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customized order',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Select your veggies, fruits, and quantity, and our delivery partner brings them fresh to your doorstep in minutes!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location and delivery time
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.black),
                        const SizedBox(width: 8),
                        const Text(
                          'Navi Mumbai',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                              ),
                              child: Icon(Icons.access_time, size: 20, ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '27 mins',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Badges
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB5D8CB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '10% less than market price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB6CC56),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Freshness guarantee',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          // You can add more containers here if needed
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Enter fruit, vegetable name',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recommended section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommended for you',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_up, color: Colors.grey[700]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Product list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final product = items[index];
                      final productName = product['name'] ?? '';
                      final isAdded = addedProducts[productName] ?? false;
                      final quantity = productQuantities[productName] ?? 1;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product information
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'in ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            product['unit'] ?? 'kilos',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Tags
                                      Wrap(
                                        spacing: 8,
                                        children: List<String>.from(product['tags'] ?? []).map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF7E47),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              tag,
                                              style: const TextStyle(fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product['description'] ?? 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Product image and add button
                                Column(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            product['image_url'] ?? 'https://via.placeholder.com/100',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (!isAdded)
                                    // Add button when not added
                                      SizedBox(
                                        width: 100,
                                        child: ElevatedButton(
                                          onPressed: () => toggleProductAdded(productName),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF5E3984),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: const Text(
                                            'Add',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                    // Quantity selector when added
                                      Container(
                                        width: 100,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          color: Colors.grey[100],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () => updateQuantity(productName, quantity - 1),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                                child: const Icon(
                                                  Icons.remove,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '$quantity',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => updateQuantity(productName, quantity + 1),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Colors.grey[200], thickness: 1),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

          // Bottom view order button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: itemCount > 0 ? navigateToOrderSummary : null,
              child: Container(
                decoration: BoxDecoration(
                  color: itemCount > 0 ? const Color(0xFF328616) : Colors.grey,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$itemCount ${itemCount == 1 ? 'item' : 'items'} added',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'View order',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleProductAdded(String productName) {
    setState(() {
      // If product is already added, keep it added but handle in updateQuantity
      if (!(addedProducts[productName] ?? false)) {
        // Product not added yet, add it with quantity 1
        addedProducts[productName] = true;
        productQuantities[productName] = 1;
        itemCount++;
      }
    });
  }

  void updateQuantity(String productName, int newQuantity) {
    if (newQuantity <= 0) {
      // Remove the product if quantity is 0 or less
      setState(() {
        itemCount -= productQuantities[productName] ?? 0;
        addedProducts[productName] = false;
        productQuantities.remove(productName);
      });
    } else {
      // Update the quantity
      setState(() {
        int oldQuantity = productQuantities[productName] ?? 0;
        productQuantities[productName] = newQuantity;
        itemCount += (newQuantity - oldQuantity);
      });
    }
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

