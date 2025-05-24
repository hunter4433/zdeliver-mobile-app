import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> historyData = [
    {
      "title": "Z vegetable cart",
      "address": "Hs no. 15 shardanganagri ,mirajgaon road karhat",
      "time": "11:30 AM",
      "date": "11/03/2025",
      "items": [
        "https://img.icons8.com/emoji/48/onion.png",
        "https://img.icons8.com/emoji/48/broccoli.png",
        "https://img.icons8.com/emoji/48/eggplant.png",
        "https://img.icons8.com/emoji/48/carrot.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
      ],
    },
    {
      "title": "Z fruit cart",
      "address": "Hs no. 15 shardanganagri ,mirajgaon road karhat",
      "time": "11:30 AM",
      "date": "11/03/2025",
      "items": [
        "https://img.icons8.com/emoji/48/onion.png",
        "https://img.icons8.com/emoji/48/broccoli.png",
        "https://img.icons8.com/emoji/48/eggplant.png",
        "https://img.icons8.com/emoji/48/cucumber.png",
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Filters'),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.grey[500]),
                    onPressed: () {
                      // Implement filter functionality if needed
                    },
                  ),
                ],
              ),
              VerticalDivider(
                color: Colors.grey[500],
                thickness: 1.5,
                indent: 2,
                endIndent: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sort by'),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.grey[500]),
                    onPressed: () {
                      // Implement filter functionality if needed
                    },
                  ),
                ],
              ),
            ],
          ),

          Expanded(
            child: ListView.builder(
              itemCount: historyData.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final data = historyData[index];
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "cart delivered at",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(data["address"], style: TextStyle(fontSize: 13)),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Time ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(data["time"]),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Date ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(data["date"]),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5),

                        Divider(thickness: 1.5, color: Colors.grey[300]),
                        Text("Items bought", style: TextStyle()),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...data["items"].map<Widget>(
                              (img) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0,
                                ),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(img),
                                  radius: 20,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 5.0,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                            ),
                          ],
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
