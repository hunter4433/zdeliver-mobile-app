import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final List<Map<String, dynamic>> historyData = [
    {
      "title": "Z vegetable cart",
      "address": "Hs no. 15 shardanganagri ,mirajgaon road karhat",
      "time": "11:00 AM",
      "date": "11/03/2025",
      "items": [
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
      ],
    },
    {
      "title": "Z fruit cart",
      "address": "Hs no. 15 shardanganagri ,mirajgaon road karhat",
      "time": "11:30 AM",
      "date": "11/03/2025",
      "items": [
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
      ],
    },
  ];

  // Filter options
  final List<String> filters = [
    'Full history',
    'Z vegetable cart history',
    'Z fruit cart history',
    'Z customized cart history',
  ];

  // Use a Set to store multiple selected filters
  Set<String> selectedFilters = {'Full history'};

  List<Map<String, dynamic>> get filteredHistory {
    // If "Full history" is selected or nothing is selected, show all
    if (selectedFilters.contains('Full history') || selectedFilters.isEmpty) {
      return historyData;
    }
    // Otherwise, filter by selected types
    return historyData.where((d) {
      final title = d['title'].toString().toLowerCase();
      bool match = false;
      if (selectedFilters.contains('Z vegetable cart history') &&
          title.contains('vegetable'))
        match = true;
      if (selectedFilters.contains('Z fruit cart history') &&
          title.contains('fruit'))
        match = true;
      if (selectedFilters.contains('Z customized cart history') &&
          title.contains('customized'))
        match = true;
      return match;
    }).toList();
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
                children:
                    filters.map((filter) {
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(filter),
                        value: selectedFilters.contains(filter),
                        onChanged: (val) {
                          setModalState(() {
                            if (filter == 'Full history') {
                              // If "Full history" is selected, clear others
                              selectedFilters = {'Full history'};
                            } else {
                              selectedFilters.remove('Full history');
                              if (val == true) {
                                selectedFilters.add(filter);
                              } else {
                                selectedFilters.remove(filter);
                              }
                              // If none selected, default to "Full history"
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

  // Dummy bill and arrival data for demonstration
  // Add these fields to each historyData item in your real data
  // "bill": 100, "arrival": "11:00 AM"
  List<Map<String, dynamic>> get sortedHistory {
    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
      filteredHistory,
    );

    for (String sort in selectedSorts) {
      if (sort == 'Date - ascending') {
        list.sort(
          (a, b) => _parseDate(a['date']).compareTo(_parseDate(b['date'])),
        );
      } else if (sort == 'Date - descending') {
        list.sort(
          (a, b) => _parseDate(b['date']).compareTo(_parseDate(a['date'])),
        );
      } else if (sort == 'Bill price - highest first') {
        list.sort((a, b) => (b['bill'] ?? 0).compareTo(a['bill'] ?? 0));
      } else if (sort == 'Bill price - lowest first') {
        list.sort((a, b) => (a['bill'] ?? 0).compareTo(b['bill'] ?? 0));
      } else if (sort == 'Earliest arrival first') {
        list.sort(
          (a, b) => _parseTime(
            a['arrival'] ?? a['time'],
          ).compareTo(_parseTime(b['arrival'] ?? b['time'])),
        );
      } else if (sort == 'Earliest arrival last') {
        list.sort(
          (a, b) => _parseTime(
            b['arrival'] ?? b['time'],
          ).compareTo(_parseTime(a['arrival'] ?? a['time'])),
        );
      }
    }
    return list;
  }

  DateTime _parseDate(String date) {
    // Expects format "dd/MM/yyyy"
    final parts = date.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  TimeOfDay _parseTime(String time) {
    // Expects format "hh:mm AM/PM"
    final format = RegExp(r'(\d+):(\d+) (\w{2})');
    final match = format.firstMatch(time);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!;
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay(hour: 0, minute: 0);
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
                children:
                    sortOptions.map((sort) {
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(sort),
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

  Map<int, int> currentItemIndex = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0), // Deep purple color
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
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
                  VerticalDivider(
                    color: Colors.grey[500],
                    thickness: 2,
                    indent: 2,
                    endIndent: 2,
                    width: 24,
                  ),
                  Row(
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
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: sortedHistory.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final data = sortedHistory[index];
                final items = data["items"] as List;
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
                          data["title"],
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
                          ),
                        ),
                        Text(
                          data["address"],
                          style: GoogleFonts.leagueSpartan(fontSize: 13),
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
                                  ),
                                ),
                                Text(
                                  data["time"],
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 13,
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
                                  ),
                                ),
                                Text(
                                  data["date"],
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5),

                        Divider(thickness: 1.5, color: Colors.grey[300]),
                        Text(
                          "Items bought",
                          style: GoogleFonts.leagueSpartan(),
                        ),

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
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          items[displayIdx],
                                        ),
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
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
                                        // Move window right, but don't overflow
                                        if ((idx + 5) < items.length) {
                                          currentItemIndex[index] = idx + 1;
                                        }
                                      });
                                    },
                                  ),
                                ),
                            ],
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

// import 'package:flutter/material.dart';
// import 'package:mrsgorilla/menu/cart_history.dart';
// import 'package:google_fonts/google_fonts.dart';

// class OrderHistoryScreen extends StatelessWidget {
//   const OrderHistoryScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(''),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 ' History',
//                 style: GoogleFonts.leagueSpartan(
//                   color: Colors.black,
//                   fontSize: 26,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 'Check all your past orders and cart history',
//                 style: GoogleFonts.leagueSpartan(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                   fontSize: 18,
//                 ),
//               ),
//               const SizedBox(height: 25),
//               _buildHistoryItem(context, 'All orders', null),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
//                 child: const Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: Color(0xFFEEEEEE),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildHistoryItem(
//                 context,
//                 'Standard Gorilla cart history',
//                 'cart',
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
//                 child: const Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: Color(0xFFEEEEEE),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildHistoryItem(context, 'Gorilla fruit cart history', 'cart'),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
//                 child: const Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: Color(0xFFEEEEEE),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildHistoryItem(context, 'Customized cart history', 'cart'),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
//                 child: const Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: Color(0xFFEEEEEE),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildHistoryItem(context, 'Customized order history', 'order'),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 18.0),
//                 child: const Divider(
//                   height: 2,
//                   thickness: 1,
//                   color: Color(0xFFEEEEEE),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryItem(BuildContext context, String title, String? type) {
//     return GestureDetector(
//       onTap: () {
//         // TODO: Replace '123' with actual user ID
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => CartHistoryPage(
//                   userId: '1', // Replace with actual user ID
//                   historyType:
//                       type ??
//                       'all', // Use 'all' if no specific type is provided
//                 ),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         decoration: BoxDecoration(
//           color: Color(0xFFF0F8FF),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: const Color(0xFFFAFAFA), width: 2.5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.leagueSpartan(
//                 color: Colors.black,
//                 fontSize: 19,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const Icon(size: 30, Icons.arrow_forward, color: Colors.black),
//           ],
//         ),
//       ),
//     );
//   }
// }
