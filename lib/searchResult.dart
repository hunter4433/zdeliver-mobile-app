import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mrsgorilla/checkoutPage.dart';
import 'package:mrsgorilla/Home_Recommend_section/customize_cart.dart';

class Product {
  final String name;
  // final String id;
  // final String Unit;
  final double price;
  final String image;
  final String mealTime;
  final String description;
  int quantity;
  final String? imageUrl;

  Product({
    required this.name,
    // required this.id,
    // required this.unit,
    required this.price,
    required this.image,
    required this.mealTime,
    required this.description,
    this.quantity = 0,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      // id:json['id'] ?? '',
      // unit:json['unit'] ?? '',
      price: double.tryParse(json['price_per_unit'] ?? '0') ?? 0.0,
      image: 'assets/images/homebrocalli.png', // Default image
      mealTime: 'Available Now', // Default meal time
      description: 'Fresh produce', // Default description
      quantity: 0,
      imageUrl: json['image_url'],
    );
  }
}

class VegetableOrderingPage extends StatefulWidget {
   String? searchQuery;
   VegetableOrderingPage ({Key? key, this.searchQuery}) : super(key: key);

  @override
  _VegetableOrderingPageState createState() => _VegetableOrderingPageState();
}

class _VegetableOrderingPageState extends State<VegetableOrderingPage> {
  List<Product> products = [
    Product(
        name: 'Potato',
        price: 45,
        image: 'assets/images/homebrocalli.png',
        mealTime: 'Good morning basket',
        description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
    ),
    Product(
        name: 'Capsicum',
        price: 45,
        image: 'assets/images/homeCabbage.png',
        mealTime: 'Tuesday lunch',
        description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
    ),
    Product(
        name: 'Green chilli',
        price: 45,
        image: 'assets/images/homebrocalli.png',
        mealTime: 'Tuesday lunch',
        description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
    ),
  ];



  List<Product> searchResults = [];
  List<Product> selectedProducts = [];
  bool _isBottomSheetOpen = false;
  Product? _currentCustomizingProduct;
  String? _selectedSize;
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
     _performSearch(widget.searchQuery!);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final url = Uri.parse('http://3.111.39.222/api/v1/items/search');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': query}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print(jsonData);

        if (jsonData['success'] == true) {
          setState(() {
            searchResults = (jsonData['data'] as List)
                .map((item) => Product.fromJson(item))
                .toList();
          });
        } else {
          // Handle API error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonData['message'] ?? 'Search failed')),
          );
          setState(() {
            searchResults = [];
          });
        }
      } else {
        // Handle HTTP error
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('No item found.')),
        // );
        setState(() {
          searchResults = [];
        });
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection')),
      );
      setState(() {
        searchResults = [];
      });
    }
  }

  // Rest of the existing methods remain the same as in the original code...
  // (_addProduct, _showCustomOrderBottomSheet, _showCustomProductBottomSheet methods)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Dim background when bottom sheet is open
          if (_isBottomSheetOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),

          Column(
            children: [
              // Top section with search bar
              Container(
                height: 217,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/home1.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Home",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        " - Neelkanth boys hostel, NIT ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter fruit, vegetable name',
                                            hintStyle: TextStyle(color: Colors.grey),
                                            border: InputBorder.none,
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          onSubmitted: (value) {
                                            _performSearch(value);
                                          },
                                        ),
                                      ),
                                      const Icon(Icons.search, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Product List (with search results or default products)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: searchResults.isNotEmpty ? searchResults.length : products.length,
                  itemBuilder: (context, index) {
                    final product = searchResults.isNotEmpty ? searchResults[index] : products[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 1, vertical:1 ),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Product Image
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: product.imageUrl != null
                                    ? Image.network(
                                  product.imageUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      product.image,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.contain,
                                    );
                                  },
                                )
                                    : Image.asset(
                                  product.image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF15A25),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            product.mealTime,
                                            style: TextStyle(fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      product.description,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rs ${product.price}/Kg',
                                          style: TextStyle(fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // Add button moved to the right side
                                        product.quantity == 0
                                            ? ElevatedButton(
                                          onPressed: () => _addProduct(product),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black87,
                                            foregroundColor: Colors.white, // Sets the text color to white
                                            minimumSize: Size(70, 40),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8), // Less circular corners
                                            ),
                                          ),
                                          child: Text('Add',style: TextStyle(fontSize: 17),),
                                        )
                                            : Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(height: 40,width: 40,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey.shade300),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.remove, size: 20),
                                                  onPressed: () {
                                                    setState(() {
                                                      product.quantity--;
                                                      if (product.quantity == 0) {
                                                        selectedProducts.remove(product);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10),
                                                child: Text('${product.quantity}',style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                              ),
                                              Container(height: 40,width: 40,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey.shade300),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.add, size: 20),
                                                  onPressed: () {
                                                    setState(() {
                                                      product.quantity++;
                                                    });
                                                  },
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
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Bottom Order Section (Fixed Position)
          if (selectedProducts.isNotEmpty)
            Positioned(
              left: 30,
              right: 30,
              bottom: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFF328616),
                  borderRadius: BorderRadius.circular(38), // Added rounded corners
                  border: Border.all(color: Colors.white, width: 2.5), // Added white border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedProducts.length} item${selectedProducts.length != 1 ? 's' : ''} added',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Calculate bill components
                        final itemsTotal = selectedProducts.fold(0.0, (total, product) => total + product.price);
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

                        // Navigate to the order details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  CheckoutPage(
                              selectedProducts: selectedProducts.map((product) => {
                                'name': product.name,
                                'price': product.price,
                                'image_url': product.imageUrl,
                                'quantity': product.quantity, // You might want to track quantity separately
                                // 'id': product.id, // Add back the id if needed
                                // 'unit': product.unit ?? 'Kg', // Add unit if available
                                'total_price': product.price, // Calculate total price per item
                              }).toList(),
                                sourceScreen: 'customiseCart'
                              // billData: billData,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View order',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Other existing methods like _addProduct, _showCustomOrderBottomSheet, _showCustomProductBottomSheet remain the same
  void _addProduct(Product product) {
    setState(() {
      if (product.quantity == 0) {
        product.quantity = 1;
        selectedProducts.add(product);
        _currentCustomizingProduct = product;
        _showCustomProductBottomSheet(product);
      }
    });
  }

  // Implement the other methods from the original code...
  void _showCustomOrderBottomSheet() {
    // Existing implementation
  }

  void _showCustomProductBottomSheet(Product product) {
    // Existing implementation
  }
}