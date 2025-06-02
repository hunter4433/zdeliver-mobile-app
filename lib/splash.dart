import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mrsgorilla/auth_page.dart';
import 'package:mrsgorilla/gohome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<Map<String, dynamic>?> getLatLngAddress() async {
    try {
      final storage = FlutterSecureStorage();
      String? address = await storage.read(key: 'saved_address');
      String? position = await storage.read(key: 'user_position');
      if (address != null && position != null) {
        final coords = position.split(',');
        if (coords.length == 2) {
          double lat = double.parse(coords[0]);
          double lng = double.parse(coords[1]);
          Position position = Position(
            latitude: lat,
            longitude: lng,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
          return {'postion': position, 'address': address};
        }
      }
      return null;
    } catch (e) {
      print('Error reading lat/lng/address: $e');
      return null;
    }
  }

  Future findWarehouseLatLng(double lat, double lng) async {
    print('-------- getting warehouse lat lng --------');

    final String baseUrl =
        'http://13.126.169.224/api/v1/warehouse-finder/find-warehouse-vendors';
    try {
      final response = await http.post(
        Uri.parse(baseUrl), // Adjust the endpoint to match your backend route
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'latitude': lat, 'longitude': lng}),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          return data['error']; // Return the error message
        }
        // Assuming the response contains a 'warehouse' object with 'latitude' and 'longitude'
        final warehouse = data['warehouse'];
        if (warehouse != null) {
          final double lat = warehouse['coordinates']['latitude'];
          final double lng = warehouse['coordinates']['longitude'];
          final String address = warehouse['address'] ?? 'No address found';
          print('Warehouse found at: $lat, $lng, Address: $address');

          // Save the address and position to secure storage
          final storage = FlutterSecureStorage();
          await storage.write(key: 'warehouse_address', value: address);
          await storage.write(key: 'warehouse_position', value: '$lat,$lng');

          // Return the position and address
          return {
            'position': Position(
              latitude: lat,
              longitude: lng,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
            ),
            'address': address,
          };
        } else {
          throw Exception('Warehouse not found');
        }
      } else {
        // Parse error message from response if available
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to find warehouse');
      }
    } catch (e) {
      print('Failed to get warehouse: $e');
    }
  }

  Future<void> _checkLogin() async {
    String? userId = await _storage.read(key: 'userId');

    var latLngAddress = await getLatLngAddress();
    Position? position =
        latLngAddress?['postion'] ??
        await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
    var wareHouseLatLng = await _storage.read(key: 'warehouse_position');
    if(wareHouseLatLng == null){
      wareHouseLatLng = await findWarehouseLatLng(
        position!.latitude,
        position.longitude,
      );
    }
     
    
    String? address = latLngAddress?['address'];
    if (userId != null && userId.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePageWithMap(position: position, address: address, warehousePosition: wareHouseLatLng),
        ),
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
