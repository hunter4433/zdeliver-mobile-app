import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:mrsgorilla/address_selection.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({Key? key}) : super(key: key);

  @override
  _AddressBookPageState createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  List<dynamic> _addresses = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      String? userId= await _secureStorage.read(key: 'userId');
     print('http://13.126.169.224/api/v1/addresses?user_id=$userId');

      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse('http://13.126.169.224/api/v1/addresses?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          // Add any necessary authentication headers
        },
      );
print('mhit not here $response');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Check if the response has a 'data' key with an array of addresses
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          setState(() {
            _addresses = jsonResponse['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid response format';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load addresses';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF), // Light blue background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Address book',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Add new address button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  bool? refresh= await  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectAddressPage(),
                    ),
                  );

                  if (refresh == true) {
                    setState(() {
                      _fetchAddresses();
                      // Trigger a refresh, e.g., reload the baskets or other data
                    });
                  }
                },
                icon: Icon(Icons.add, color: Colors.red, size: 30),
                label: Text('Add new address', style: TextStyle(color: Colors.black87)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

          // Saved addresses section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
                  : _addresses.isEmpty
                  ? Center(child: Text('No addresses Saved Yet'))
                  : ListView(
                padding: EdgeInsets.zero,
                children: [
                  Text(
                    'Saved addresses',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 12),
                  ..._addresses.map((address) => _buildAddressCard(
                    address['receiver_name'] ?? 'N/A',
                    address['full_address'] ?? 'N/A',
                    address['receiver_phone'] ?? 'N/A',
                  )).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String name, String address, String phoneNumber) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    address,
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Phone number : $phoneNumber',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black54),
              onPressed: () {
                // More options functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}