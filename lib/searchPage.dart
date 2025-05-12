// import 'package:flutter/material.dart';
//
// class Product {
//   final String name;
//   final double price;
//   final String image;
//   final String mealTime;
//   final String description;
//   int quantity;
//
//   Product({
//     required this.name,
//     required this.price,
//     required this.image,
//     required this.mealTime,
//     required this.description,
//     this.quantity = 0
//   });
// }
//
// class VegetableOrderingPage extends StatefulWidget {
//   @override
//   _VegetableOrderingPageState createState() => _VegetableOrderingPageState();
// }
//
// class _VegetableOrderingPageState extends State<VegetableOrderingPage> {
//   List<Product> products = [
//     Product(
//         name: 'Potato',
//         price: 45,
//         image: 'assets/images/homebrocalli.png',
//         mealTime: 'Good morning basket',
//         description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
//     ),
//     Product(
//         name: 'Capsicum',
//         price: 45,
//         image: 'assets/images/homeCabbage.png',
//         mealTime: 'Tuesday lunch',
//         description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
//     ),
//     Product(
//         name: 'Green chilli',
//         price: 45,
//         image: 'assets/images/homebrocalli.png',
//         mealTime: 'Tuesday lunch',
//         description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
//     ),
//     Product(
//         name: 'Potato',
//         price: 45,
//         image: 'assets/images/homebrocalli.png',
//         mealTime: 'Good morning basket',
//         description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
//     ),
//     Product(
//         name: 'Capsicum',
//         price: 45,
//         image: 'assets/images/homeCabbage.png',
//         mealTime: 'Tuesday lunch',
//         description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
//     ),
//     Product(
//         name: 'Green chilli',
//         price: 45,
//         image: 'assets/images/homebrocalli.png',
//         mealTime: 'Tuesday lunch',
//         description: 'Make paratha, aloo sabzi, vadapao, dam aloo, aloo matar, aloo pakoda'
//     ),
//   ];
//
//   List<Product> selectedProducts = [];
//   bool _isBottomSheetOpen = false;
//   Product? _currentCustomizingProduct;
//   String? _selectedSize;
//
//   void _addProduct(Product product) {
//     setState(() {
//       if (product.quantity == 0) {
//         product.quantity = 1;
//         selectedProducts.add(product);
//         _currentCustomizingProduct = product;
//         _showCustomProductBottomSheet(product);
//       }
//     });
//   }
//
//   void _showCustomOrderBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.4,
//           minChildSize: 0.4,
//           maxChildSize: 0.4,
//           builder: (_, controller) {
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: ListView(
//                 controller: controller,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Your Order',
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         // List of selected products
//                         ...selectedProducts.map((product) => ListTile(
//                           leading: Image.asset(
//                             product.image,
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.contain,
//                           ),
//                           title: Text(product.name),
//                           subtitle: Text('Quantity: ${product.quantity}'),
//                           trailing: Text('Rs ${product.price * product.quantity}'),
//                         )).toList(),
//
//                         // Total calculation
//                         Divider(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Total',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'Rs ${selectedProducts.fold(0.0, (total, product) => total + (product.price * product.quantity)).toStringAsFixed(2)}',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 16),
//                         // Proceed to Checkout button
//                         Center(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               // Implement checkout logic
//                               Navigator.of(context).pop();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF328616),
//                               minimumSize: Size(double.infinity, 50),
//                             ),
//                             child: Text(
//                               'Proceed to Checkout',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showCustomProductBottomSheet(Product product) {
//     setState(() {
//       _isBottomSheetOpen = true;
//     });
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return DraggableScrollableSheet(
//               initialChildSize: 0.5,
//               minChildSize: 0.4,
//               maxChildSize: 0.5,
//               builder: (_, controller) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                   ),
//                   child: ListView(
//                     controller: controller,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Image.asset(
//                                   product.image,
//                                   width: 50,
//                                   height: 50,
//                                   fit: BoxFit.contain,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   product.name,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               'Choose how do you want your ${product.name.toLowerCase()}s',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             SizedBox(height: 16),
//                             RadioListTile(
//                               title: Text('Big ones'),
//                               value: 'big',
//                               groupValue: _selectedSize,
//                               onChanged: (value) {
//                                 setModalState(() {
//                                   _selectedSize = value;
//                                 });
//                               },
//                             ),
//                             RadioListTile(
//                               title: Text('Small ones'),
//                               value: 'small',
//                               groupValue: _selectedSize,
//                               onChanged: (value) {
//                                 setModalState(() {
//                                   _selectedSize = value;
//                                 });
//                               },
//                             ),
//                             SizedBox(height: 16),
//                             Row(
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey.shade300),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(Icons.remove, size: 20),
//                                     onPressed: () {
//                                       setModalState(() {
//                                         if (product.quantity > 1) {
//                                           product.quantity--;
//                                         }
//                                       });
//                                     },
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Text(
//                                     '${product.quantity}',
//                                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                                   ),
//                                 ),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey.shade300),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(Icons.add, size: 20),
//                                     onPressed: () {
//                                       setModalState(() {
//                                         product.quantity++;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                                 Spacer(),
//                                 ElevatedButton(
//                                   onPressed: _selectedSize != null ? () {
//                                     Navigator.of(context).pop();
//                                   } : null,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green,
//                                     minimumSize: Size(100, 50),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Text('Add item',style: TextStyle(color: Colors.white),),
//                                       SizedBox(width: 5),
//                                       Icon(Icons.arrow_forward),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     ).whenComplete(() {
//       setState(() {
//         _isBottomSheetOpen = false;
//         _selectedSize = null;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // Dim background when bottom sheet is open
//           if (_isBottomSheetOpen)
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: () => Navigator.of(context).pop(),
//                 child: Container(
//                   color: Colors.black.withOpacity(0.5),
//                 ),
//               ),
//             ),
//
//           Column(
//             children: [
//               // Top section with search bar
//               Container(
//                 height: 217,
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                       child: Image.asset(
//                         'assets/images/home1.png',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     SafeArea(
//                       bottom: false,
//                       child: Column(
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.only(top: 5),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
//                                   child: Row(
//                                     children: [
//                                       const Text(
//                                         "Home",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 22,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const Text(
//                                         " - Neelkanth boys hostel, NIT ",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                       Icon(
//                                         Icons.chevron_right,
//                                         color: Colors.white,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(30),
//                                     color: Colors.white,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: TextField(
//                                           decoration: const InputDecoration(
//                                             hintText: 'Enter fruit, vegetable name',
//                                             hintStyle: TextStyle(color: Colors.grey),
//                                             border: InputBorder.none,
//                                           ),
//                                           style: const TextStyle(color: Colors.black),
//                                         ),
//                                       ),
//                                       const Icon(Icons.search, color: Colors.grey),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Product List
//               Expanded(
//                 child: ListView.builder(
//                   padding: EdgeInsets.zero,
//                   itemCount: products.length,
//                   itemBuilder: (context, index) {
//                     final product = products[index];
//                     return Container(
//                       margin: EdgeInsets.symmetric(horizontal: 1, vertical:1 ),
//                       padding: const EdgeInsets.all(8.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 5,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               // Product Image
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Image.asset(
//                                     product.image,
//                                     width: 100,
//                                     height: 100,
//                                     fit: BoxFit.contain
//                                 ),
//                               ),
//
//                               // Product Details
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       product.name,
//                                       style: TextStyle(
//                                         fontSize: 19,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(height: 6),
//                                     Row(
//                                       children: [
//                                         Container(
//                                           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                           decoration: BoxDecoration(
//                                             color: Color(0xFFF15A25),
//                                             borderRadius: BorderRadius.circular(5),
//                                           ),
//                                           child: Text(
//                                             product.mealTime,
//                                             style: TextStyle(fontWeight: FontWeight.w600,
//                                               color: Colors.white,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 4),
//                                     Text(
//                                       product.description,
//                                       style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Rs ${product.price}/Kg',
//                                           style: TextStyle(fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         // Add button moved to the right side
//                                         product.quantity == 0
//                                             ? ElevatedButton(
//                                           onPressed: () => _addProduct(product),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.black87,
//                                             foregroundColor: Colors.white, // Sets the text color to white
//                                             minimumSize: Size(70, 40),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(8), // Less circular corners
//                                             ),
//                                           ),
//                                           child: Text('Add',style: TextStyle(fontSize: 17),),
//                                         )
//                                             : Container(
//                                           child: Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Container(height: 40,width: 40,
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(color: Colors.grey.shade300),
//                                                   borderRadius: BorderRadius.circular(4),
//                                                 ),
//                                                 child: IconButton(
//                                                   icon: Icon(Icons.remove, size: 20),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       product.quantity--;
//                                                       if (product.quantity == 0) {
//                                                         selectedProducts.remove(product);
//                                                       }
//                                                     });
//                                                   },
//                                                 ),
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10),
//                                                 child: Text('${product.quantity}',style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
//                                               ),
//                                               Container(height: 40,width: 40,
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(color: Colors.grey.shade300),
//                                                   borderRadius: BorderRadius.circular(4),
//                                                 ),
//                                                 child: IconButton(
//                                                   icon: Icon(Icons.add, size: 20),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       product.quantity++;
//                                                     });
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//
//           // Bottom Order Section (Fixed Position)
//           if (selectedProducts.isNotEmpty)
//             Positioned(
//               left: 30,
//               right: 30,
//               bottom: 20,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF328616),
//                   borderRadius: BorderRadius.circular(38), // Added rounded corners
//                   border: Border.all(color: Colors.white, width: 2.5), // Added white border
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '${selectedProducts.length} item${selectedProducts.length != 1 ? 's' : ''} added',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: _showCustomOrderBottomSheet,
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.zero,
//                         foregroundColor: Colors.white,
//                       ),
//                       child: Row(
//                         children: [
//                           Text(
//                             'View order',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 5),
//                           Icon(Icons.arrow_forward, size: 20, color: Colors.white),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }