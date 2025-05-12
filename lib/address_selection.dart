import 'package:flutter/material.dart';
// import 'package:gorilla/AddressSelectionScreen.dart';
import 'package:mrsgorilla/menu/Addreass.dart';
import 'package:mrsgorilla/mapView.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({Key? key}) : super(key: key);


  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}


class _SelectAddressPageState extends State<SelectAddressPage> {
  late final FlutterSecureStorage _secureStorage;
  String? _selectedAddress;
bool addressLoading=true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();

  @override
  void initState() {
  super.initState();
  _secureStorage = const FlutterSecureStorage();
  _initializePage();

  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _houseNoController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }



  Future<void> _initializePage() async {
  // Retrieve saved address first
    _selectedAddress = await _secureStorage.read(key: 'saved_address');
    print(_selectedAddress );

    setState(() {
      addressLoading= false;
    });
  }

  //String _selectedAddress = "Mirajgaon road, Sharadanaghari, karhat, dist ahmednagar";
  bool _showDetailsForm = false;
  String _selectedTag = 'Home';


  // Method to save address via API
  Future<void> _saveAddress() async {
    // Validate inputs
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _houseNoController.text.isEmpty ||
        _apartmentController.text.isEmpty ||
        _selectedTag.isEmpty) {
      // Show error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select a tag')),
      );
      return;
    }

    // Prepare the address data
    final addressData = {
      'user_id': 1, // Assuming a fixed user ID, replace with actual user ID
      'full_address': '${_houseNoController.text}, ${_apartmentController.text},$_selectedAddress',
      'latitude': 40.7128, // Example coordinates, replace with actual coordinates
      'longitude': -74.0060,
      'house_flat_number': _houseNoController.text,
      'apartment_society_road': _apartmentController.text,
      'address_tag': _selectedTag,
      'receiver_name': _nameController.text,
      'receiver_phone': _phoneController.text,
      'is_default': true
    };

    try {
      // Make API call
      final response = await http.post(
        Uri.parse('http://3.111.39.222/api/v1/addresses'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if required
          // 'Authorization': 'Bearer YOUR_TOKEN_HERE'
        },
        body: json.encode(addressData),
      );
print(response);
      // Handle API response
      if (response.statusCode == 201) {
        // Successfully saved address
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address saved successfully')),
        );


        // Optional: Reset form or navigate away
        setState(() {
          _nameController.clear();
          _phoneController.clear();
          _houseNoController.clear();
          _apartmentController.clear();
          _selectedTag = '';
        });
        Navigator.pop(context,true);
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address. Please try again.')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Select Address',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),


      body: SafeArea(
        child: Stack(
          children: [
            // Map image instead of Google Maps
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              height: double.infinity,
              width:double.infinity ,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white,
                  width: 6.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9), // Adjusted for the thicker border
                child: MapScreen(
                  containerHeight: 180,
                  isEmbedded: true,
                ),
              ),
            ),

            // Custom map pin
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 0,
              right: 0,
              child: Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
            ),


            // Top bar with back button and search
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.deepOrange, size: 30,),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search manually',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.deepOrange, size:30,),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


            // Cart location bubble
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(2, 4),
                      ),
                    ],
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'your cart will be parked here',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),


            // Use current location button
            Positioned(
              right: 0,
              bottom: _showDetailsForm ? 550 : 230,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.my_location, color: Colors.deepOrange, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'use current\nlocation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),


            // Bottom address bar or details form
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _showDetailsForm
                  ? _buildAddressDetailsForm()
                  : _buildAddressSelectionBar(),
            ),
          ],
        ),
      ),
    );
  }


  // Original address selection bar
  Widget _buildAddressSelectionBar() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'your cart will be delivered to',
                style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 16,
                    fontWeight: FontWeight.w700
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddressSelectionScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Shadow color
                        blurRadius: 6, // Blur effect
                        spreadRadius: 2, // Spread effect
                        // Shadow position
                      ),
                    ],
                    color: Colors.white, // Ensures a solid background for better visibility
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(fontSize: 15,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),


            ],
          ),
          const SizedBox(height: 10),
          addressLoading
              ? const Center(child: CircularProgressIndicator())
         : Row(
            children: [
              const Icon(Icons.location_on, color: Colors.deepOrange, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedAddress ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showDetailsForm = true;
                });
              },
              child: Container(
                width: 350,
                height: 65,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white, size: 35),
                    const SizedBox(width: 8),
                    const Text(
                      'Add details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }


  // New address details form
  Widget _buildAddressDetailsForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8FF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Address header with location icon
          Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 24),
                onPressed: () {
                  // Pop the current route/screen
                  setState(() {
                    _showDetailsForm = false;
                  });
                },
              ),
              const SizedBox(width: 8),

              Icon(Icons.location_on, color: Colors.deepOrange, size: 40),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedAddress ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF424242),
                  ),
                ),
              ),

            ],
          ),


          const SizedBox(height: 20),


          // First white box - Receiver details
          Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300, width:1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receiver details section header
                Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.black54, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Receiver details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Name field
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Receivers name',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),

                // Phone number field
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Receivers Phone number',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
          ),

          // Address details container (second white box)
          Container(
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300, width:1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // House/Flat number field
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _houseNoController,
                    decoration: InputDecoration(
                      hintText: 'Enter house/flat no.',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),

                // Apartment/Society/Road field
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _apartmentController,
                    decoration: InputDecoration(
                      hintText: 'Enter Apartment/society/road',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),

                // Address tag section
                Text(
                  'Add tag to your address',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // Tag selection buttons
                Row(
                  children: [
                    _buildTagButton('Home', _selectedTag == 'Home'),
                    const SizedBox(width: 6),
                    _buildTagButton('Work', _selectedTag == 'Work'),
                    const SizedBox(width: 6),
                    _buildTagButton('Friends and family', _selectedTag == 'Friends and family'),
                  ],
                ),

                const SizedBox(height: 10),

                _buildTagButton('Other', _selectedTag == 'Other'),
              ],
            ),
          ),

          // Save Address button
          GestureDetector(
            onTap: _saveAddress, // Call the save method when tapped
            child: Center(
              child: Container(
                width: 350,
                height: 65,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 35),
                    const SizedBox(width: 8),
                    const Text(
                      'Save Address',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),




        ],
      ),
    );
  }


  // Helper method to create address tag buttons
  Widget _buildTagButton(String tag, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTag = tag;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}




