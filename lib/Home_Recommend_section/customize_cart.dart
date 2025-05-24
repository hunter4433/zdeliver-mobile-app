import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:mrsgorilla/checkoutPage.dart";
import 'package:google_fonts/google_fonts.dart';


class customize_cart extends StatefulWidget {
  const customize_cart({Key? key}) : super(key: key);

  @override
  State<customize_cart> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<customize_cart> {
  int itemCount = 0; // Initial count for bottom button
  final searchController = TextEditingController();
  // Track added products with more details
  Map<String, Map<String, dynamic>> selectedProducts = {};
  List<dynamic> items = []; // Original fetched items
  List<dynamic> filteredItems = []; // Filtered items based on search
  bool isLoading = true;
  bool hasError = false;
  // Maximum items allowed in cart
  final int maxItems = 15;
  // Show toast message for the first item only
  bool showToast = false;
  // Show sticky counter after first item
  bool showStickyCounter = false;
  int remainingItems = 15;
  String toastMessage = '';

  @override
  void initState() {
    super.initState();
    fetchItems();

    // Add listener to search controller
    searchController.addListener(() {
      filterItems();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Method to filter items based on search text
  void filterItems() {
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // If search is empty, show all items
        filteredItems = List.from(items);
      } else {
        // Filter items that contain the search query in name or description
        filteredItems = items.where((item) {
          final name = item['name'].toString().toLowerCase();
          final description = item['description'].toString().toLowerCase();
          return name.contains(query) || description.contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://13.126.169.224/api/v1/items/all'),
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode({"category": "vegetables"}), // Change category if needed
      );
print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data);
        setState(() {
          items = data['data'];
          filteredItems = List.from(items); // Initialize filtered items with all items
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

  void toggleProductAdded(String productName) {
    // Find the product details from items list
    final product = items.firstWhere(
          (item) => item['name'] == productName,
      orElse: () => null,
    );

    if (product == null) return;

    setState(() {
      // Toggle product added state
      if (selectedProducts.containsKey(productName)) {
        // Product is already added, clicking will remove it
        selectedProducts.remove(productName);
        itemCount -= 1;
        remainingItems += 1;

        if (itemCount == 0) {
          // Hide sticky counter when all items are removed
          showStickyCounter = false;
        }
      } else {
        // Check if we've reached the maximum items limit
        if (itemCount >= maxItems) {
          // Show toast that maximum limit is reached
          showToast = true;
          toastMessage = 'Maximum items limit reached!';

          // Hide toast after 3 seconds
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showToast = false;
              });
            }
          });
          return;
        }

        // Product not added, add it with details
        selectedProducts[productName] = {
          'id': product['id'],
          'name': product['name'],
          'unit': product['unit'],
          'price': product['price'],
          'image_url': product['image_url'],
          'description': product['description'],
          'quantity': 1, // Default quantity
        };

        itemCount += 1;
        remainingItems = maxItems - itemCount;

        // For the first item, show toast message
        if (itemCount == 1) {
          showToast = true;
          toastMessage = 'You can add up to ${remainingItems} more items';
          showStickyCounter = true;

          // Hide toast after showing it for 3 seconds
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                showToast = false;
              });
            }
          });
        } else {
          // For subsequent items, just update the sticky counter
          showStickyCounter = true;
        }
      }
    });
  }

  // Widget to show when no search results found
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customized Cart',
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Select your veggies, fruits, and quantity, and our delivery partner brings them fresh to your doorstep in minutes!',
                              style: GoogleFonts.leagueSpartan(
                                  fontSize: 15,
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
                      const Icon(Icons.location_on, color: Colors.black, size: 27),
                      const SizedBox(width: 5),
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
                            Icon(Icons.access_time, size: 27),
                            const SizedBox(width: 7),
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 7),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFF95CCBA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            '10% less than market price',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 8, right: 16),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFA7BA42),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Freshness guarantee',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Enhanced Search Bar with clear button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 0.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F8FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFA8CCE0)),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search vegetables...',
                        hintStyle: TextStyle(
                            color: Color(0xFFA8CCE0),
                            fontWeight: FontWeight.w600,
                            fontSize: 17
                        ),
                        prefixIcon: Icon(Icons.search, color: Color(0xFFA8CCE0)),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: Color(0xFFA8CCE0)),
                          onPressed: () {
                            searchController.clear();
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        // Search functionality will be handled by the listener in initState
                      },
                    ),
                  ),
                ),

                // Recommended section title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        searchController.text.isEmpty
                            ? 'Recommended for you'
                            : 'Search Results',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${filteredItems.length} items',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade700),
                    ],
                  ),
                ),

                // Product List with dividers after each item
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : hasError
                    ? Center(child: Text("Error loading products"))
                    : filteredItems.isEmpty
                    ? _buildNoResultsFound()
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final product = filteredItems[index];
                    return Column(
                      children: [
                        // Product Card
                        ProductCard(
                          name: product['name'],
                          unit: product['price_per_unit'],
                          description: product['description'],
                          imagePath: product['image_url'],
                          isAdded: selectedProducts.containsKey(product['name']),
                          onToggleAdded: () => toggleProductAdded(product['name']),
                        ),

                        // Blue divider after each product except the last one
                        if (index < filteredItems.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15),
                            child: Container(
                              height: 2,
                              color: Color(0xFFF0F8FF),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                // Add some extra space at the bottom if there are few or no items
                if (filteredItems.isEmpty || filteredItems.length < 3)
                  SizedBox(height: 300),
              ],
            ),
          ),

          // Toast message for first item only
          if (showToast)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    toastMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // Sticky widget showing remaining items count (after first item)
          if (showStickyCounter)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF3F2E78),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_basket,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '$remainingItems items left',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Fixed bottom button
          Positioned(
            bottom: 32,
            left: 30,
            right:30,
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
                        // Pass the selected products data to the checkout page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                                selectedProducts: selectedProducts.values.toList(),
                                sourceScreen: 'customiseCart'
                            ),
                          ),
                        );
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
        ],
      ),
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
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'in ',
                      style: GoogleFonts.leagueSpartan(fontSize: 21),
                    ),
                    Text(
                      unit,
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 21,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: GoogleFonts.leagueSpartan(
                      fontSize: 16,
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