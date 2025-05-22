import 'package:flutter/material.dart';
import 'createBasket.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mrsgorilla/checkoutPage.dart';
import 'package:google_fonts/google_fonts.dart';


class BasketPage extends StatefulWidget {
  const BasketPage({Key? key}) : super(key: key);


  @override
  State<BasketPage> createState() => _BasketPageState();
}


class _BasketPageState extends State<BasketPage> {
  // Controller for the basket name text field
  final TextEditingController _basketNameController = TextEditingController();
  IconData? _selectedDpIcon;

  // List to store baskets
  List<dynamic> _savedBaskets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBaskets();
  }

  // Method to fetch baskets from API
  Future<void> _fetchBaskets() async {
    try {
      final response = await http.get(
        Uri.parse('http://3.111.39.222/api/v1/baskets/user/1'),
        headers: {
          'Content-Type': 'application/json',
          // Add any necessary authentication headers
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['baskets'] != null) {
          setState(() {
            _savedBaskets = responseData['baskets'];
            _isLoading = false;
          });
          print(_savedBaskets);
        } else {
          // If no baskets, use default baskets
          _setDefaultBaskets();
        }
      } else {
        // If API call fails, use default baskets
        _setDefaultBaskets();
      }
    } catch (e) {
      // If any error occurs, use default baskets
      _setDefaultBaskets();
    }
  }

  // Method to set default baskets if API fails
  void _setDefaultBaskets() {
    setState(() {
      _savedBaskets = [
        {
          'basket_name': 'Good Morning basket',
          'icon_image': 'grocery_icon.png',
          'items': [
            {'item_name': 'Onion', 'quantity': '1 Kg'},
            {'item_name': 'Cauliflower', 'quantity': '2 Kg'},
            {'item_name': 'Brinjal', 'quantity': '1 Kg'},
            {'item_name': 'Carrot', 'quantity': '2 Kg'},
            {'item_name': 'Bottle gourd', 'quantity': '1 Kg'},
          ]
        },
        {
          'basket_name': 'Tuesday lunch basket',
          'icon_image': 'grocery_icon.png',
          'items': [
            {'item_name': 'Onion', 'quantity': '1 Kg'},
            {'item_name': 'Cauliflower', 'quantity': '2 Kg'},
            {'item_name': 'Brinjal', 'quantity': '1 Kg'},
            {'item_name': 'Carrot', 'quantity': '2 Kg'},
          ]
        }
      ];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _basketNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (remains the same)
            Container(color: Colors.white,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(
                          'Basket',
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Create your own basket for everyday needs',
                          style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Create new basket button (remains the same)
            Container(color: Color(0xFFF0F8FF),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDCC29),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/home8.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                    title:  Text(
                      'Create new basket',
                      style: GoogleFonts.leagueSpartan(color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 38,color: Colors.white,),
                    onTap: () {
                      _showCreateBasketCard(context);
                    },
                  ),
                ),
              ),
            ),

            // Saved Baskets section
            Container(color: Color(0xFFF0F8FF),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:  Text(
                  'Saved Baskets',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),

            // Saved basket cards
            _isLoading
                ? Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : Expanded(
              child: _savedBaskets.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No basket created yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _setDefaultBaskets,
                      child: Text('See Sample Basket'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _savedBaskets.length,
                itemBuilder: (context, index) {
                  var basket = _savedBaskets[index];
                  return Column(
                    children: [
                  _buildBasketCard(
                  basket['basket_name'] ?? 'Unnamed Basket',
                    List<Map<String, String>>.from(
                      (basket['items'] ?? []).map(
                            (item) {
                          // Ensure the item is of type Map<String, dynamic>
                          if (item is Map<String, dynamic>) {
                            return item.map((key, value) => MapEntry(key, value.toString()));
                          }
                          // If the item is not a Map<String, dynamic>, handle accordingly
                          return <String, String>{};
                        },
                      ),
                    ),
                  ),



                  if (index < _savedBaskets.length - 1)
                        const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Method to show the create basket card
  void _showCreateBasketCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: const BoxDecoration(
            color:Color(0xFFF0F8FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name your basket section
                 Text(
                  'Name your basket',
                   style: GoogleFonts.leagueSpartan(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _basketNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                ),


                // Add DP section
                const SizedBox(height: 25),
                 Text(
                  'Add DP',
                   style: GoogleFonts.leagueSpartan(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),


                // DP icons row
                Row(
                  children: [
                    _buildDpIcon(Icons.shopping_bag_outlined, Colors.blue),
                    const SizedBox(width: 10),
                    _buildDpIcon(Icons.shopping_basket_outlined, Colors.orange),
                    const SizedBox(width: 10),
                    _buildDpIcon(Icons.restaurant, Colors.green),
                    const SizedBox(width: 10),
                    _buildDpIcon(Icons.home_outlined, Colors.red),
                  ],
                ),


                // Add Vegetables button
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    // Close this dialog
                    Navigator.pop(context);

                    // Navigate to vegetables page
                    bool? refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BasketCreationScreen(
                          basketName: _basketNameController.text,
                          selectedDpIcon: _selectedDpIcon,
                        ),
                      ),
                    );
                    if (refresh == true) {
                      setState(() {
                        _fetchBaskets();
                        // Trigger a refresh, e.g., reload the baskets or other data
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE86031),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: Colors.white, width: 3), // Added white border
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE86031).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Add Vegetables',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 40),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // Method to build DP icons

  Widget _buildDpIcon(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDpIcon = icon;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }


  Widget _buildBasketCard(String title, List<Map<String, String>> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.wb_sunny,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Handle more options
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),
             Text(
              'Basket Contains',
               style: GoogleFonts.leagueSpartan(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Basket items
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['item_name']!,
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        item['quantity']!,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        item['unit']!,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),

            const SizedBox(height: 16),

            // Order now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToOrderSummary(items),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF328616),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    Text(
                      'Order now',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white,size: 22,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOrderSummary(List<Map<String, String>> basketItems) {
    // Collect all selected items with their details
    final selectedItems = <Map<String, dynamic>>[];
    double itemsTotal = 0.0;
    print('ofiop');
    print(basketItems);

    for (var item in basketItems) {
      final productName = item['item_name'] ?? '';
      final item_id=item['item_id'] ?? '';
      final image=item['image_url'] ?? '';
      final quantity = int.tryParse(item['quantity'] ?? '1') ?? 1;
      final price = 45.0; // Default price, replace with actual price logic if needed
      final totalPrice = price * quantity;

      itemsTotal += totalPrice;

      selectedItems.add({
        'id':item_id,
        'name': productName,
        'quantity': quantity,
        'image_url':image,
        'price': price,
        'unit': item['unit'] ?? 'Kg',
        'total_price': totalPrice,
      });
    }
print(selectedItems);
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


// Placeholder for the Vegetables Page
class VegetablesPage extends StatelessWidget {
  const VegetablesPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vegetables'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Text('Vegetables Page - Add implementation here'),
      ),
    );
  }
}


