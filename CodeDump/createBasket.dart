import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BasketCreationScreen extends StatefulWidget {
  final String? basketName;
  final IconData? selectedDpIcon;

  const BasketCreationScreen({
    super.key,
    this.basketName,
    this.selectedDpIcon
  });

  @override
  _BasketCreationScreenState createState() => _BasketCreationScreenState();
}

class _BasketCreationScreenState extends State<BasketCreationScreen> {
  List<dynamic> recommendedItems = [];

  bool isLoading = true;
  Map<int, int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchRecommendedItems();
  }

  Future<void> _fetchRecommendedItems() async {
    try {
      final response = await http.post(
        Uri.parse('http://3.111.39.222/api/v1/items/search'),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          recommendedItems = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recommended items')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create new basket',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Choose vegetables to add in basket',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            widget.selectedDpIcon ?? Icons.wb_sunny_outlined,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.basketName ?? 'Good Morning basket',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Add items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for you',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.separated(
                itemCount: recommendedItems.length,
                separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  var item = recommendedItems[index];
                  return _buildVegetableItem(
                    itemId: item['id'], // Make sure to pass the item_id
                    name: item['name'],
                    image: item['image_url'],
                    description: item['description'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: selectedItems.isNotEmpty ? _createBasket : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedItems.isNotEmpty
                ? const Color(0xFF4C8C4A)
                : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Create Basket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVegetableItem({
    required int itemId,
    required String name,
    required String image,
    required String description,
  }) {
    int currentQuantity = selectedItems[itemId] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      'in ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'kilos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          currentQuantity == 0
              ? GestureDetector(
            onTap: () {
              setState(() {
                selectedItems[itemId] = 1;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF5C4DB1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          )
              : Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () {
                    setState(() {
                      if (currentQuantity > 1) {
                        selectedItems[itemId] = currentQuantity - 1;
                      } else {
                        selectedItems.remove(itemId);
                      }
                    });
                  },
                ),
                Text(
                  '$currentQuantity',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {
                    setState(() {
                      selectedItems[itemId] = currentQuantity + 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createBasket() async {
    // Prepare the basket creation payload
    List<Map<String, dynamic>> items = selectedItems.entries.map((entry) {
      return {
        "item_id": entry.key,
        "quantity": entry.value
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('http://3.111.39.222/api/v1/baskets/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "user_id": 1, // Replace with actual user ID
          "basket_name": widget.basketName ?? "Weekly Groceries",
          "icon_image":  "grocery_icon.png", // Replace with actual icon
          "weekday": "Mon", // Replace with actual weekday
          "items": items
        }),
      );

      if (response.statusCode == 201) {
        // Basket created successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Basket created successfully!')),
        );
        Navigator.pop(context, true); // Optional: go back to previous screen
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create basket: ${response.body}')),
        );
      }
    } catch (e) {
      print(e);
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

}