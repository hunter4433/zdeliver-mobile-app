import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Breakfast_Details.dart';
// import 'package:mrsgorilla/Home_Meal_Section/Breakfast_Details.dart';
// import 'package:your_app_name/pages/meal_details/aloo_paratha_page.dart';

class BreakfastSection extends StatefulWidget {
  const BreakfastSection({Key? key}) : super(key: key);

  @override
  State<BreakfastSection> createState() => _BreakfastSectionState();
}

class _BreakfastSectionState extends State<BreakfastSection> {
  List<dynamic> breakfastItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBreakfastItems();
  }

  Future<void> fetchBreakfastItems() async {
    try {
      // Your API endpoint
      final url = Uri.parse('http://3.14.131.252/api/dishes/get-by-category');

      // API expects a POST request with category in the body
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category': 'breakfast'}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("breakfast");
        print(responseData);
        setState(() {
          breakfastItems = responseData['dishes'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load breakfast items: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('subhansh here ');
      print('${e.toString()}');
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });

      // Fallback to default items if API fails
      setState(() {
        breakfastItems = [
          {
            'id': 1,
            'name': 'Aloo Paratha',
            'description': 'Traditional Indian breakfast',
            'image_url': 'assets/images/aloo_pratha.png',
            'ingredients': [
              {
                'id': 1,
                'name': 'Aloo',
                'type': 'vegetable',
                'price_per_unit': '30.00',
                'quantity': '3',
                'unit': 'kg'
              },
              {
                'id': 16,
                'name': 'Dhaniya',
                'type': 'ingredient',
                'price_per_unit': '10.00',
                'quantity': '4 gram',
                'unit': 'bundle'
              },
              {
                'id': 4,
                'name': 'Adrak',
                'type': 'herbs',
                'price_per_unit': '80.00',
                'quantity': '2',
                'unit': 'kg'
              }
            ],
          },
          {
            'id': 2,
            'name': 'Carrot and Peas Upma',
            'description': 'Healthy breakfast option',
            'image_url': 'assets/images/gajar_upma.png',
            'ingredients': [
              {'id': 2, 'name': 'Carrot', 'type': 'vegetable'},
              {'id': 3, 'name': 'Peas', 'type': 'vegetable'},
              {'id': 5, 'name': 'Semolina', 'type': 'grain'}
            ],
          },
          {
            'id': 3,
            'name': 'Broccoli Poha',
            'description': 'Nutritious flattened rice dish',
            'image_url': 'assets/images/Lunch1.png',
            'ingredients': [
              {'id': 6, 'name': 'Broccoli', 'type': 'vegetable'},
              {'id': 7, 'name': 'Poha', 'type': 'grain'},
              {'id': 8, 'name': 'Onion', 'type': 'vegetable'}
            ],
          },
        ];
      });
    }
  }

  String getImagePath(String? apiImageUrl, String dishName) {
    // If API provides an image URL, use it
    if (apiImageUrl != null && apiImageUrl.isNotEmpty) {
      return apiImageUrl;
    }

    print('abhishek here ');
    // Fallback to local assets based on dish name
    switch (dishName.toLowerCase()) {
      case 'aloo paratha':
        return 'assets/images/aloo_pratha.png';
      case 'carrot and peas upma':
      case 'gajar upma':
        return 'assets/images/gajar_upma.png';
      default:
        return 'assets/images/Lunch1.png'; // Default fallback image
    }
  }

  String getIngredientsText(dynamic item) {
    // Extract ingredient names from the ingredients list if it exists
    if (item['ingredients'] != null && item['ingredients'] is List && item['ingredients'].isNotEmpty) {
      // Map each ingredient to its name and join with commas
      return (item['ingredients'] as List)
          .map((ingredient) => ingredient['name'] as String)
          .join(', ');
    }
    return 'No ingredients listed';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose meal-Breakfasts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Horizontal scrollable section with meal boxes
        Container(
          height: 250, // Increased height to accommodate name and ingredients
          margin: const EdgeInsets.only(bottom: 12),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty && breakfastItems.isEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: breakfastItems.length,
            itemBuilder: (context, index) {
              final item = breakfastItems[index];
              final String dishName = item['name'] ?? 'Unknown Dish';
              final String imagePath = getImagePath(item['image_url'], dishName);
              final String ingredients = getIngredientsText(item);
              final String description = item['description'] ?? 'Not Available';
              final bool isHighlighted = index == 2; // Example: highlight the third item

              return GestureDetector(
                onTap: () {
                  print('mohit');
                  print(item);
                  print('$dishName selected');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlooParathaPage(
                        dishName: item['name'],
                        ingredients: item['ingredients'],
                        description: item['description'],
                        Image:item['image_url_2']
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 160, // Slightly wider to accommodate ingredients text
                  margin: EdgeInsets.only(
                    right: index == breakfastItems.length - 1 ? 12 : 8,
                    left: index == 0 ? 4 : 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHighlighted ? Colors.deepPurple : Colors.transparent,
                      width: isHighlighted ? 2 : 0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3, // Give more space to the image
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                          child: Image(
                            image: imagePath.startsWith('assets/')
                                ? AssetImage(imagePath)
                                : NetworkImage(imagePath) as ImageProvider,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: Text(
                          dishName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Text(
                          ingredients,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}