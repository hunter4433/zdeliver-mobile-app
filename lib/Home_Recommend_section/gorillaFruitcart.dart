import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class FruitCartBottomSheet extends StatefulWidget {
  @override
  _FruitCartBottomSheetState createState() => _FruitCartBottomSheetState();
}

class _FruitCartBottomSheetState extends State<FruitCartBottomSheet> {
  List<dynamic> fruits = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchFruits();
  }

  Future<void> fetchFruits() async {
    try {
      final response = await http.post(
        Uri.parse('http://3.111.39.222/api/v1/veggies/category'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"category": "fruits"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fruits = data['data'];
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Standard fruit cart",
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Call the cart, and it arrives with ${fruits.length > 0 ? fruits.length : 'fresh'} fruits. Pick what you need, just like your daily market visit!",
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Content based on loading state
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              "Failed to load fruits. Please try again later.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchFruits,
              child: Text("Retry"),
            ),
          ],
        ),
      );
    } else if (fruits.isEmpty) {
      return Center(
        child: Text(
          "No fruits available at the moment.",
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: fruits.length,
        itemBuilder: (context, index) {
          final fruit = fruits[index];
          return _buildFruitItem(
            fruit['name'] ?? "Unknown Fruit",
            fruit['image_url'] ?? "",
            fruit['price_per_unit']?.toString() ?? "",
            fruit['unit'] ?? "",
          );
        },
      );
    }
  }

  Widget _buildFruitItem(String name, String imageUrl, String price, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 50,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 40,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image_not_supported),
                  );
                },
              )
                  : Container(
                width: 50,
                height: 40,
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported),
              ),
              SizedBox(width: 16),
              Text(
                name,
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          price.isNotEmpty && unit.isNotEmpty
              ? Text(
            "$price per $unit",
            style: GoogleFonts.leagueSpartan(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          )
              : SizedBox(),
        ],
      ),
    );
  }
}