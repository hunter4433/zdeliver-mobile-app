import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlooParathaPage extends StatefulWidget {
  final List<dynamic>? ingredients;
  final String? description;
  final String? dishName;
  final String? Image;

  const AlooParathaPage({Key? key, this.ingredients,this.description, this.dishName, this.Image}) : super(key: key);

  @override
  State<AlooParathaPage> createState() => _AlooParathaPageState();
}

class _AlooParathaPageState extends State<AlooParathaPage> {
  bool _showNutritionCard = false;
  bool _showOrderCard = false;
  bool _isLoading = false;
  bool _hasError = false;
  List<dynamic> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _ingredients = widget.ingredients ?? [];
    printIngredients();
  }

  void printIngredients() {
    print(_ingredients);
    if (_ingredients != null && _ingredients!.isNotEmpty) {
      // print('Ingredients for $dishName:');
      for (var ingredient in _ingredients!) {
        // Assuming each ingredient is a Map with keys like 'name', 'quantity', 'unit'
        print('- ${ingredient['name']}: ${ingredient['quantity']} ${ingredient['unit']}');
      }
    } else {
      // print('No ingredients available for $dishName');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    return Scaffold(backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 50),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  height: 250 + statusBarHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('${widget.Image}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildContentBelowImage(),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: _buildBottomButton(),
          ),
          if (_showNutritionCard) _buildOverlay(),
          if (_showOrderCard) _buildOrderCard(),
        ],
      ),
    );
  }

  Widget _buildContentBelowImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.dishName}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.description}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.black54, size: 30),
                  const SizedBox(width: 4),
                  Text(
                    'Navi Mumbai',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: Colors.green, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '27 mins',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showNutritionCard = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F8FF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Check nutritional benefits of ${widget.dishName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.info_outline, size: 20, color: Colors.black),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                height: 6,
                color: Color(0xFFF0F8FF),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'How many delicious ${widget.dishName} are you craving today?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF3F2E78),
                          Color(0xFF745EBF),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                height: 4,
                color: Color(0xFFF0F8FF),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_up, color: Colors.black, size: 30),
                ],
              ),
              const SizedBox(height: 16),

              // Display ingredients from the passed data if available
              // Otherwise, fall back to defaults
              if (_ingredients.isEmpty) ...[
                _buildIngredientItem('Potato', '1 Kg', 'assests/potato_png2391.png'),
                _buildIngredientItem('Onion', '1 Kg', 'assests/oninon.png'),
                _buildIngredientItem('Green chilli', '0.5 Kg', 'assests/Frame 605.png'),
              ] else ...[
                ..._ingredients.map((ingredient) => _buildIngredientItem(
                  ingredient['name'] ?? 'Unknown',
                  '${ingredient['quantity'] ?? ''} ${ingredient['unit'] ?? ''}',
                  ingredient['image_url'] ?? ''
                  // _getIngredientImagePath(ingredient['name'] ?? ''),
                )).toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getIngredientImagePath(String ingredientName) {
    print(_ingredients);
    ingredientName = ingredientName.toLowerCase();
    if (ingredientName.contains('aloo') || ingredientName.contains('potato')) {
      return 'assests/potato_png2391.png';
    } else if (ingredientName.contains('onion')) {
      return 'assests/oninon.png';
    } else if (ingredientName.contains('chilli') || ingredientName.contains('mirch') ||
        ingredientName.contains('dhaniya') || ingredientName.contains('adrak')) {
      return 'assests/Frame 605.png';
    }

    // Default image if no match
    return 'assests/potato_png2391.png';
  }

  Widget _buildIngredientItem(String name, String quantity, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            quantity,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 17,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOrderCard = true;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Color(0xFF328616),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '4 items added',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  'View order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    // ... existing code stays the same
    return GestureDetector(
      onTap: () {
        setState(() {
          _showNutritionCard = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF0F4F7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aloo Paratha',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'per one medium-sized paratha, approx. 100g, cooked with ghee',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNutritionItem('Calories', '~260-300 kcal'),
                  _buildNutritionItem('Carbohydrates', '~40g (from whole wheat flour & potatoes)'),
                  _buildNutritionItem('Protein', '~6g (from wheat and dairy if used)'),
                  _buildNutritionItem('Fats', '~10-12g (depends on ghee/butter usage)'),
                  _buildNutritionItem('Fiber', '~4g (from whole wheat and potatoes)'),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Color(0xFF328616),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '4 items added',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
      ),
    );
  }

  Widget _buildOrderCard() {
    // ... existing code stays the same
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOrderCard = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aloo Paratha',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'per one medium-sized paratha, approx. 100g, cooked with ghee',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNutritionItem('Calories', '~260-300 kcal'),
                  _buildNutritionItem('Carbohydrates', '~40g (from whole wheat flour & potatoes)'),
                  _buildNutritionItem('Protein', '~6g (from wheat and dairy if used)'),
                  _buildNutritionItem('Fats', '~10-12g (depends on ghee/butter usage)'),
                  _buildNutritionItem('Fiber', '~4g (from whole wheat and potatoes)'),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 350,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Color(0xFF328616),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '4 items added',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'View order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String name, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name + ':',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}