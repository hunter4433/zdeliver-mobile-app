import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model classes to improve type safety and mapping
class BookingHistoryItem {
  final Booking booking;
  final List<OrderItem> items;

  BookingHistoryItem({
    required this.booking,
    required this.items,
  });

  factory BookingHistoryItem.fromJson(Map<String, dynamic> json) {
    return BookingHistoryItem(
      booking: Booking.fromJson(json['booking'] ?? {}),
      items: (json['items'] as List?)
          ?.map((itemJson) => OrderItem.fromJson(itemJson))
          .toList() ?? [],
    );
  }
}

class Booking {
  final String? id;
  final int userId;
  final String bookingType;
  final double totalPrice;
  final String? basketId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deliveryAddress;

  Booking({
    required this.id,
    required this.userId,
    required this.bookingType,
    required this.totalPrice,
    this.basketId,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryAddress,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bookingType: json['booking_type'] ?? '',
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0.0') ?? 0.0,
      basketId: json['basket_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      deliveryAddress: json['order_address'],
    );
  }
}

class OrderItem {
  final int id;
  final String name;
  final String imageUrl;
  final int quantity;

  OrderItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Item',
      imageUrl: json['image_url'] ?? 'assets/images/placeholder.png',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    );
  }
}

class CartHistoryPage extends StatefulWidget {
  final String userId;
  final String historyType; // 'cart' or 'order'

  const CartHistoryPage({
    Key? key,
    required this.userId,
    required this.historyType
  }) : super(key: key);

  @override
  _CartHistoryPageState createState() => _CartHistoryPageState();
}

class _CartHistoryPageState extends State<CartHistoryPage> {
  List<BookingHistoryItem> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBookingHistory();
  }

  Future _fetchBookingHistory() async {
    try {

      final url = widget.historyType == 'all'
          ? Uri.parse('http://13.126.169.224/api/v1/book/user/${widget.userId}')
          : Uri.parse('http://13.126.169.224/api/v1/book/user/${widget.userId}?type=${widget.historyType}');

      final response = await http.get(url);
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // Map the JSON data to our strongly typed model
          final List<dynamic> data = jsonResponse['data'] ?? [];
          setState(() {
            _bookings = data.map((item) =>
                BookingHistoryItem.fromJson(item)
            ).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = jsonResponse['message'] ?? 'Failed to load bookings';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load bookings. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.historyType.capitalize()} History',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Check all your past ${widget.historyType} history',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : _bookings.isEmpty
          ? Center(
        child: Text(
          'No ${widget.historyType} history found',
          style: const TextStyle(fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ...(_bookings.map((bookingItem) =>
                _buildCartHistoryItem(context, bookingItem)
            ).toList()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCartHistoryItem(BuildContext context, BookingHistoryItem bookingItem) {
    final booking = bookingItem.booking;
    final items = bookingItem.items;

    // Calculate total quantity of items
    final totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.historyType.capitalize()} Delivered',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 35,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black, size: 25),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              booking.deliveryAddress ?? 'No address provided',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatTime(booking.createdAt),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatDate(booking.createdAt),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Divider(height: 1, thickness: 2, color: Color(0xFFF2F2F2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Items (${totalQuantity}) ${widget.historyType == 'cart' ? 'in Cart' : 'Ordered'}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                ...items.map((item) =>
                    _buildFoodItem(item.imageUrl, item.quantity)
                ).toList(),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 24,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(String imagePath, int quantity) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        if (quantity > 1)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}