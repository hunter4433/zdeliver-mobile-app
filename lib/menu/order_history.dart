import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Reuse the same model classes from the first code
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
  final int id;
  final int userId;
  final String bookingType;
  final double totalPrice;
  final int? basketId;
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
      deliveryAddress: json['address'],
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

class OrderHistoryScreen extends StatefulWidget {
  final String userId;

  const OrderHistoryScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<BookingHistoryItem> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Filter options
  final List<String> filters = [
    'Full history',
    'Z vegetable cart history',
    'Z fruit cart history',
    'Z customized cart history',
  ];

  // Use a Set to store multiple selected filters
  Set<String> selectedFilters = {'Full history'};

  // Sort options
  final List<String> sortOptions = [
    'Date - ascending',
    'Date - descending',
    'Bill price - highest first',
    'Bill price - lowest first',
    'Earliest arrival first',
    'Earliest arrival last',
  ];

  Set<String> selectedSorts = {};
  Map<int, int> currentItemIndex = {};

  @override
  void initState() {
    super.initState();
    _fetchBookingHistory();
  }

  Future<void> _fetchBookingHistory() async {
    try {
      final url = Uri.parse('http://13.126.169.224/api/v1/book/user/${widget.userId}');
      final response = await http.get(url);
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          setState(() {
            _bookings = data.map((item) => BookingHistoryItem.fromJson(item)).toList();
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

  List<BookingHistoryItem> get filteredHistory {
    if (selectedFilters.contains('Full history') || selectedFilters.isEmpty) {
      return _bookings;
    }

    return _bookings.where((bookingItem) {
      final bookingType = bookingItem.booking.bookingType.toLowerCase();
      bool match = false;

      if (selectedFilters.contains('Z vegetable cart history') && bookingType.contains('vegetable')) {
        match = true;
      }
      if (selectedFilters.contains('Z fruit cart history') && bookingType.contains('fruit')) {
        match = true;
      }
      if (selectedFilters.contains('Z customized cart history') && bookingType.contains('customized')) {
        match = true;
      }

      return match;
    }).toList();
  }

  List<BookingHistoryItem> get sortedHistory {
    List<BookingHistoryItem> list = List<BookingHistoryItem>.from(filteredHistory);

    for (String sort in selectedSorts) {
      if (sort == 'Date - ascending') {
        list.sort((a, b) => a.booking.createdAt.compareTo(b.booking.createdAt));
      } else if (sort == 'Date - descending') {
        list.sort((a, b) => b.booking.createdAt.compareTo(a.booking.createdAt));
      } else if (sort == 'Bill price - highest first') {
        list.sort((a, b) => b.booking.totalPrice.compareTo(a.booking.totalPrice));
      } else if (sort == 'Bill price - lowest first') {
        list.sort((a, b) => a.booking.totalPrice.compareTo(b.booking.totalPrice));
      } else if (sort == 'Earliest arrival first') {
        list.sort((a, b) => a.booking.createdAt.compareTo(b.booking.createdAt));
      } else if (sort == 'Earliest arrival last') {
        list.sort((a, b) => b.booking.createdAt.compareTo(a.booking.createdAt));
      }
    }
    return list;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: filters.map((filter) {
                  return CheckboxListTile(
                    selectedTileColor: const Color(0xFF4527A0),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      filter,
                      style: GoogleFonts.leagueSpartan(fontSize: 16),
                    ),
                    value: selectedFilters.contains(filter),
                    onChanged: (val) {
                      setModalState(() {
                        if (filter == 'Full history') {
                          selectedFilters = {'Full history'};
                        } else {
                          selectedFilters.remove('Full history');
                          if (val == true) {
                            selectedFilters.add(filter);
                          } else {
                            selectedFilters.remove(filter);
                          }
                          if (selectedFilters.isEmpty) {
                            selectedFilters = {'Full history'};
                          }
                        }
                      });
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sortOptions.map((sort) {
                  return CheckboxListTile(
                    selectedTileColor: const Color(0xFF4527A0),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      sort,
                      style: GoogleFonts.leagueSpartan(fontSize: 16),
                    ),
                    value: selectedSorts.contains(sort),
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          selectedSorts.add(sort);
                        } else {
                          selectedSorts.remove(sort);
                        }
                      });
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 15, top: 5),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                ' History',
                style: GoogleFonts.leagueSpartan(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: _showFilterSheet,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Filters',
                            style: GoogleFonts.leagueSpartan(fontSize: 18),
                          ),
                        ),
                        SizedBox(width: 5),
                        IconButton(
                          icon: Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.black,
                          ),
                          onPressed: _showFilterSheet,
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.grey[500],
                    thickness: 2,
                    indent: 2,
                    endIndent: 2,
                    width: 24,
                  ),
                  InkWell(
                    onTap: _showSortSheet,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Sort by',
                            style: GoogleFonts.leagueSpartan(fontSize: 18),
                          ),
                        ),
                        SizedBox(width: 5),
                        IconButton(
                          icon: Icon(Icons.filter_list, color: Colors.black),
                          onPressed: _showSortSheet,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_bookings.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No order history found',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: sortedHistory.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final bookingItem = sortedHistory[index];
                  final booking = bookingItem.booking;
                  final items = bookingItem.items;
                  final idx = currentItemIndex[index] ?? 0;
                  final showArrow = items.length > 5 && (idx + 5) < items.length;

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.bookingType.isNotEmpty
                                ? booking.bookingType
                                : 'Order',
                            style: GoogleFonts.leagueSpartan(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "cart delivered at",
                            style: GoogleFonts.leagueSpartan(
                              color: Colors.grey[700],
                                fontSize: 16
                            ),
                          ),
                          Text(
                            booking.deliveryAddress ?? 'No address provided',
                            style: GoogleFonts.leagueSpartan(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Time ",
                                    style: GoogleFonts.leagueSpartan(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(booking.createdAt),
                                    style: GoogleFonts.leagueSpartan(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Date ",
                                    style: GoogleFonts.leagueSpartan(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(booking.createdAt),
                                    style: GoogleFonts.leagueSpartan(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (booking.totalPrice > 0) ...[
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  "Total: ",
                                  style: GoogleFonts.leagueSpartan(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "₹${booking.totalPrice.toStringAsFixed(2)}",
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 13,
                                    color: const Color(0xFF4527A0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 5),
                          Divider(thickness: 1.5, color: Colors.grey[300]),
                          Text(
                            "Items bought (${items.length})",
                            style: GoogleFonts.leagueSpartan(),
                          ),
                          if (items.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...List.generate(
                                    items.length < 5 ? items.length : 5,
                                        (i) {
                                      int displayIdx = idx + i;
                                      if (displayIdx >= items.length)
                                        return SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0,
                                          ),
                                          child: Stack(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  items[displayIdx].imageUrl,
                                                ),
                                                radius: 20,
                                                backgroundColor: Colors.transparent,
                                                onBackgroundImageError: (exception, stackTrace) {
                                                  // Handle image load error
                                                },
                                              ),
                                              // if (items[displayIdx].quantity > 1)
                                              //   Positioned(
                                              //     top: 0,
                                              //     right: 0,
                                              //     child: Container(
                                              //       padding: const EdgeInsets.all(2),
                                              //       decoration: BoxDecoration(
                                              //         color: Colors.red,
                                              //         borderRadius: BorderRadius.circular(8),
                                              //       ),
                                              //       constraints: const BoxConstraints(
                                              //         minWidth: 16,
                                              //         minHeight: 16,
                                              //       ),
                                              //       child: Text(
                                              //         '${items[displayIdx].quantity}',
                                              //         style: const TextStyle(
                                              //           color: Colors.white,
                                              //           fontSize: 10,
                                              //         ),
                                              //         textAlign: TextAlign.center,
                                              //       ),
                                              //     ),
                                              //   ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (showArrow)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15.0,
                                        right: 5.0,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if ((idx + 5) < items.length) {
                                              currentItemIndex[index] = idx + 1;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "No items found",
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
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
      ),
    );
  }
}