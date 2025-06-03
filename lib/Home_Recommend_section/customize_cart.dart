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
  void showCustomPopup(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              "How to order customized cart?",
              style: GoogleFonts.leagueSpartan(
                color: Color.fromRGBO(63, 46, 120, 1),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Step 1",
                  style: GoogleFonts.leagueSpartan(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color.fromRGBO(67, 67, 67, 1),
                  ),
                ),
                Text(
                  "Choose vegetables you want in your customized cart.\n",
                  style: GoogleFonts.leagueSpartan(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color.fromRGBO(67, 67, 67, 0.8),
                  ),
                ),
                Text(
                  "Step 2",
                  style: GoogleFonts.leagueSpartan(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color.fromRGBO(67, 67, 67, 1),
                  ),
                ),
                Text(
                  "Proceed to checkout to select address.\n",
                  style: GoogleFonts.leagueSpartan(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color.fromRGBO(67, 67, 67, 0.8),
                  ),
                ),
                Text(
                  "Step 3",
                  style: GoogleFonts.leagueSpartan(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color.fromRGBO(67, 67, 67, 1),
                  ),
                ),
                Text(
                  "Your customized vegetable cart arrives near you — handpick fresh veggies just like at the sabzi mandi!",

                  style: GoogleFonts.leagueSpartan(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color.fromRGBO(67, 67, 67, 0.8),
                  ),
                ),
              ],
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
                      "OK",
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

  @override
  void initState() {
    super.initState();
    // Show custom popup after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomPopup(context);
    });
    fetchItems();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
          var getlist = data['data'];
          items = List.from(
            getlist,
          ); // Initialize filtered items with all items
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
          'price_per_unit': product['price_per_unit'],
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // allow pop unless you want to block it
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context, selectedProducts);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(253, 204, 41, 1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
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
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.info_outline, color: Colors.black),
                        onPressed: () {
                          showCustomPopup(context);
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose vegetables that you want in your\ncustomized cart',
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ProductCard(
                    name: item['name']!,
                    price: item['price_per_unit']!,
                    imageUrl: item['image_url']!,
                    toggleProductAdded: (String productName) {
                      toggleProductAdded(productName);
                    },
                    isAdded: selectedProducts.containsKey(item['name']),
                  );
                },
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
                        onTap: () async {
                          
                          // Pass the selected products data to the checkout page
                          final updatedList = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CheckoutPage(
                                    selectedProducts:
                                        selectedProducts.values.toList(),
                                    sourceScreen: 'customiseCart',
                                  ),
                            ),
                          );
                          print(updatedList);
                          if (updatedList != null) {
                            // Handle any updates from the checkout page if needed
                            setState(() {
                              selectedProducts = {
                                for (var item in updatedList)
                                  item['name']: item,
                              };
                              itemCount = selectedProducts.length;
                              remainingItems = maxItems - itemCount;
                              showStickyCounter = itemCount > 0;
                            });
                          }
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name, price, imageUrl;
  final Function(String productName) toggleProductAdded;
  final bool isAdded;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.toggleProductAdded,
    required this.isAdded,
  });

  // SOLUTION 1: Add Expanded to flexible content
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fixed size image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                    imageUrl,
                    height: 100,
                    fit: BoxFit.cover
                ),
              ),
              Positioned(
                top: 2,
                left: 0,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey.withOpacity(0.6),
                  child: Icon(
                    Icons.favorite_outline_rounded,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Flexible content section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text content with flexible space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.leagueSpartan(
                            fontWeight: FontWeight.w600,
                            fontSize: 14, // Reduced to fit better
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Rs ' + price + '/Kg',
                          style: GoogleFonts.leagueSpartan(
                            fontWeight: FontWeight.w700,
                            fontSize: 12, // Reduced to fit better
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fixed size button at bottom
                  SizedBox(
                    width: double.infinity,
                    height: 30, // Fixed smaller height
                    child: ElevatedButton(
                      onPressed: () {
                        toggleProductAdded(name);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdded ? Color(0xFF3F2E78) : Color
                            .fromRGBO(47, 47, 47, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                      ),
                      child: Text(
                        isAdded ? 'Added' : 'Add',
                        style: GoogleFonts.leagueSpartan(
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Reduced from 18
                          color: Colors.white,
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