import 'dart:io';

import 'package:Zdeliver/address_model.dart';
import 'package:Zdeliver/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_search/mapbox_search.dart';
// import 'package:gorilla/AddressSelectionScreen.dart';
import 'package:Zdeliver/menu/Addreass.dart';
import 'package:Zdeliver/mapView.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({Key? key}) : super(key: key);

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  final GlobalKey<MapScreenState> _mapKey = GlobalKey();

  FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;
  bool addressLoading = true;
  bool _isLocating = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<MapBoxPlace> _suggestions = [];
  bool _isSearching = false;
  String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
  bool _isProgrammaticMove = false;

  LocalStorage _localStorage = LocalStorage();
  late final _placesSearch;

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _placesSearch = SearchBoxAPI(apiKey: ACCESS_TOKEN, limit: 5);
    _initializePage();
  }

  bool hasLocationPermission = false;
  Future<void> _checkAndRequestLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    if (mounted) {
      setState(() {
        hasLocationPermission =
            permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      });
    }

    if (hasLocationPermission) {
      print('Initializing location features');
      // Get the user's current position and set userPosition
      _initializeLocationFeatures();
    } else {
      print('No location permission yet, will initialize when granted');
      _requestLocationPermission();
    }
  }

  Future _initializeLocationFeatures() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('LOCATION SERVICES DISABLED');
        _showLocationServiceDisabledDialog();
        return;
      }
      print('checking location is saved or not');

      //check if user position is already saved
      String? savedPosition = await _secureStorage.read(key: 'user_position');
      Position? userPosition;
      if (savedPosition != null) {
        print('USING SAVED POSITION');

        List<String> coords = savedPosition.split(',');

        userPosition = Position(
          latitude: double.parse(coords[0]),
          longitude: double.parse(coords[1]),
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          speed: 0,
          speedAccuracy: 0,
          heading: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        String? savedAddress = await _secureStorage.read(key: 'saved_address');
        if (savedAddress != null) {
          setState(() {
            _selectedAddress = savedAddress;
          });
        }
        print('Current address: $_selectedAddress');
      }

      if (savedPosition == null) {
        print('GETTING CURRENT LOCATION...');
        Position geoPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );
        print(
          'CURRENT LOCATION: ${geoPosition.latitude}, ${geoPosition.longitude}',
        );

        // Save user position for later use
        await _secureStorage.write(
          key: 'user_position',
          value: '${geoPosition.latitude},${geoPosition.longitude}',
        );

        // Fetch address for the current location
        String? address = await _getAddressFromCoordinates(
          geoPosition.latitude,
          geoPosition.longitude,
        );
        await _secureStorage.write(
          key: 'saved_address',
          value: address ?? 'Address not found',
        );
        // Update the address in the state
        if (mounted) {
          setState(() {
            _selectedAddress = address ?? 'Address not found';
          });
        }
      }
      return {'userPosition': userPosition, 'address': _selectedAddress};
    } catch (e) {
      print("Error in location handling: $e");
      if (mounted) {
        _showErrorDialog(
          "Location Error",
          "Could not access your location. Please check your settings.",
        );
      }
    }
  }

  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Use Nominatim OpenStreetMap API for reverse geocoding (coords to address)
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
        ),
        headers: {
          'Accept-Language': 'en', // Ensure English results
          'User-Agent':
              'LocationPickerComponent/1.0', // Required by Nominatim usage policy
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Network response was not ok (${response.statusCode})');
      }

      final data = json.decode(response.body);
      print(data);

      if (data != null && data['display_name'] != null) {
        // Return the formatted address
        return data['display_name'] as String;
      } else {
        // If no results found, return the raw coordinates
        return 'Unknown location: $latitude, $longitude';
      }
    } catch (error) {
      print('Error converting coordinates to address: $error');
      // Return raw coordinates if geocoding fails
      return '$latitude, $longitude';
    }
  }

  Future<void> _requestLocationPermission() async {
    print('REQUESTING LOCATION PERMISSION');

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        LocationPermission geolocatorPermission =
            await Geolocator.requestPermission();
        print('GEOLOCATOR PERMISSION RESULT: $geolocatorPermission');

        if (geolocatorPermission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        } else if (geolocatorPermission == LocationPermission.deniedForever) {
          _showPermissionPermanentlyDeniedDialog();
          return;
        }

        if (mounted) {
          setState(() {
            hasLocationPermission = true;
          });
        }

        _initializeLocationFeatures();
      }
    } catch (e) {
      print("Error requesting location permission: $e");
      _showErrorDialog(
        "Permission Error",
        "Failed to request location permission. Please try again.",
      );
    }
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Required"),
          content: Text(
            "This app needs location permission to show your position on the map.",
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Try Again"),
              onPressed: () {
                Navigator.pop(context);
                _requestLocationPermission();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Denied"),
          content: Text(
            "Location permission is permanently denied. Please enable it in app settings.",
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLocationServiceDisabledDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Services Disabled"),
          content: Text(
            "Please enable location services in your device settings.",
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
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
    _selectedAddress =
        await _localStorage.getUserAddressLocally() ?? 'No address selected';
    print(_selectedAddress);

    setState(() {
      addressLoading = false;
    });
  }

  //String _selectedAddress = "Mirajgaon road, Sharadanaghari, karhat, dist ahmednagar";
  bool _showDetailsForm = false;
  String _selectedTag = 'Home';

  // Method to save address via API
  Future<void> _saveAddress() async {
    print(
      '----------------------------------------------------------Saving address... $_selectedAddress, $_latitude, $_longitude',
    );
    //
    // Validate inputs
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _houseNoController.text.isEmpty ||
        _apartmentController.text.isEmpty ||
        _selectedTag.isEmpty) {
      // Show error if any field is empty on top of the map
      Fluttertoast.showToast(
        msg: "Please fill all fields and select a tag",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    print('saving address $_selectedAddress $_latitude $_longitude');
    final userId = await _localStorage.getUserId();
    // Prepare the address data
    final addressData = {
      'user_id':
          userId, // Assuming a fixed user ID, replace with actual user ID
      'full_address':
          '${_houseNoController.text}, ${_apartmentController.text},$_selectedAddress',
      'latitude':
          _latitude, // Example coordinates, replace with actual coordinates
      'longitude': _longitude,
      'house_flat_number': _houseNoController.text,
      'apartment_society_road': _apartmentController.text,
      'address_tag': _selectedTag,
      'receiver_name': _nameController.text,
      'receiver_phone': _phoneController.text,
      'is_default': true,
    };

    try {
      // Make API call
      final response = await http.post(
        Uri.parse('http://13.126.169.224/api/v1/addresses'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if required
          // 'Authorization': 'Bearer YOUR_TOKEN_HERE'
        },
        body: json.encode(addressData),
      );
      final responseData = json.decode(response.body);
      print('response data: $responseData');

      // Handle API response
      if (response.statusCode == 201) {
        // Address saved successfully
        print('Address saved successfully: $responseData');
        // Save address to secure storage
        Address address = Address.fromMap(responseData['data']);
        print('Address model created: ${address.toString()}');
        await _localStorage.saveUserAddressLocally(_selectedAddress!);
        // Optionally, you can also save other details like latitude, longitude, etc.
        await _localStorage.saveUserPositionLocally(
          _latitude!,
          _longitude!,
          _selectedAddress!,
        );

        // save user selected address model locally
        await _localStorage.saveUserSelectedAddress(address);

        // Successfully saved address
        Fluttertoast.showToast(
          msg: "Address saved successfully'",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        // Optional: Reset form or navigate away
        setState(() {
          _nameController.clear();
          _phoneController.clear();
          _houseNoController.clear();
          _apartmentController.clear();
          _selectedTag = '';
        });
        Navigator.pop(context, _selectedAddress);
      } else {
        // Handle error
        Fluttertoast.showToast(
          msg: "Failed to save address. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Select Address',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            // Map image instead of Google Maps
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white, width: 6.0),
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
                borderRadius: BorderRadius.circular(
                  9,
                ), // Adjusted for the thicker border
                child: MapScreen(
                  key: _mapKey,
                  containerHeight: 180,
                  isEmbedded: true,
                  onCenterChanged: (lat, lng, address) {
                    if (_isProgrammaticMove) {
                      _isProgrammaticMove = false; // Reset after first use
                      return; // Skip the first call after programmatic move
                    }
                    setState(() {
                      _selectedAddress = address;
                      _latitude = lat;
                      _longitude = lng;
                    });
                  },
                ),
              ),
            ),

            // // Custom map pin
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
                        const Icon(
                          Icons.location_on,
                          color: Colors.deepOrange,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddressSelectionScreen(
                                        onAddressSelected: (address, lat, lng) {
                                          setState(() {
                                            _selectedAddress = address;
                                            _latitude = lat;
                                            _longitude = lng;
                                            _searchController.text = address;
                                          });
                                        },
                                      ),
                                ),
                              );
                              if (result != null &&
                                  result['lat'] != null &&
                                  result['lng'] != null) {
                                setState(() {
                                  _latitude = result['lat'];
                                  _longitude = result['lng'];
                                  _selectedAddress = result['address'];
                                });
                                _isProgrammaticMove = true;
                                // Move the map to the new location
                                _mapKey.currentState?.moveCameraTo(
                                  _latitude!,
                                  _longitude!,
                                );
                              }
                            },
                            child: Text(
                              'Search Manually',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.deepOrange,
                            size: 30,
                          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
              child: InkWell(
                onTap: () async {
                  setState(() {
                    _isLocating = true;
                  });
                  // Get current location
                  final currentLocation =
                      await _mapKey.currentState?.getCurrentLocation();
                  if (currentLocation != null) {
                    setState(() {
                      _latitude = currentLocation.latitude;
                      _longitude = currentLocation.longitude;
                      _selectedAddress = currentLocation.address;
                      _searchController.text = _selectedAddress ?? '';
                      _isProgrammaticMove = true;
                    });
                    // Move the map to the current location
                    _mapKey.currentState?.moveCameraTo(_latitude!, _longitude!);
                  } else {
                    Fluttertoast.showToast(
                      msg: "Unable to get current location",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                  setState(() {
                    _isLocating = false;
                  });
                },

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.deepOrange,
                          size: 20,
                        ),
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
            ),
            // Animated loading line above the bottom bar
            if (_isLocating)
              Positioned(
                left: 0,
                right: 0,
                bottom:
                    80, // Adjust this value to place it just above your bottom bar
                child: LinearProgressIndicator(
                  minHeight: 4,

                  backgroundColor: Colors.orange.shade100,
                ),
              ),
            // Bottom address bar or details form
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child:
                  _showDetailsForm ? SizedBox() : _buildAddressSelectionBar(),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => AddressSelectionScreen(),
              //       ),
              //     );
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 12,
              //       vertical: 6,
              //     ),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey.shade300),
              //       borderRadius: BorderRadius.circular(12),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.1), // Shadow color
              //           blurRadius: 6, // Blur effect
              //           spreadRadius: 2, // Spread effect
              //           // Shadow position
              //         ),
              //       ],
              //       color:
              //           Colors
              //               .white, // Ensures a solid background for better visibility
              //     ),
              //     child: const Text(
              //       'Change',
              //       style: TextStyle(
              //         fontSize: 15,
              //         color: Colors.deepOrange,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 10),
          addressLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
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
              onTap: () async {
                final res = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: _buildAddressDetailsForm(
                        onSaved: () {
                          Navigator.pop(
                            context,
                          ); // Close the sheet after saving
                        },
                      ),
                    );
                  },
                );
                if (res != null) {
                  Navigator.pop(
                    context,
                    _selectedAddress,
                  ); // Return the selected address
                }
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
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
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
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
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
  Widget _buildAddressDetailsForm({VoidCallback? onSaved}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // or any value you want
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
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
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      size: 24,
                    ),
                    onPressed: () {
                      // Pop the current route/screen
                      if (onSaved != null) onSaved();
                    },
                  ),
                  const SizedBox(width: 8),

                  Icon(Icons.location_on, color: Colors.deepOrange, size: 40),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedAddress ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[600],
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
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
                        Icon(
                          Icons.person_outline,
                          color: Colors.black54,
                          size: 22,
                        ),
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
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
                        _buildTagButton(
                          'Friends and family',
                          _selectedTag == 'Friends and family',
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    _buildTagButton('Other', _selectedTag == 'Other'),
                  ],
                ),
              ),

              // Save Address button
              GestureDetector(
                onTap: () async {
                  await _saveAddress();
                  // if (onSaved != null) onSaved();
                },
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
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 35,
                        ),
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
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
