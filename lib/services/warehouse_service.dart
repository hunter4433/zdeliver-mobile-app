// this class contains the business logic for the warehouse service
// get warehouse lat long and warehouse availability
import 'dart:convert';
import 'package:Zdeliver/coordinate_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class WarehouseService {
   final storage = FlutterSecureStorage();
  
  // Method to get the lat long of warehouses
  Future<Warehouse?> getWareHouse(
    double userlat,
    double userlng,
    BuildContext context,
  ) async {
    // Logic to fetch warehouses from the database or API
    print('-------- getting warehouse lat lng --------');

    final String baseUrl =
        'http://13.126.169.224/api/v1/warehouse-finder/find-warehouse-vendors';
    try {
      final response = await http.post(
        Uri.parse(baseUrl), // Adjust the endpoint to match your backend route
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'latitude': userlat, 'longitude': userlng}),
      );
      print(response.body);
      bool isWarehouseAvailable = true; // Default to true
      print('-----initalia check njsdjn------');
      print(isWarehouseAvailable.toString());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Failed to find warehouse'),
            ),
          );
          return null; // Return the error message
        }
        // check if the warehouse is available or not
        final message = data['message'];
        if (message != null &&
            message == "Sorry right now we are not available in your city") {
          isWarehouseAvailable = false;
        }
        // Assuming the response contains a 'warehouse' object with 'latitude' and 'longitude'
        final warehouse = data['warehouse'];
        if (warehouse != null) {
          final double lat = double.parse(warehouse['coordinates']['latitude']);
          final double lng = double.parse(
            warehouse['coordinates']['longitude'],
          );
          final String address = warehouse['address'] ?? 'No address found';
          print('Warehouse found at: $lat, $lng, Address: $address');

          // WareHouse Position
          CoordinatesPair warehousePosition = CoordinatesPair(
            latitude: lat,
            longitude: lng,
          );

          print('---------------avaianbility-----');
          // Save the address and position to secure storage
         print(isWarehouseAvailable.toString());
          await storage.write(key: 'isWareHouseAvailable', value: isWarehouseAvailable.toString());
          // await storage.write(key: 'warehouse_position', value: '$lat,$lng');

          // Return the position and address
          return Warehouse(
            warehousePosition: warehousePosition,
            
            isAvailable: isWarehouseAvailable,
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to get warehouse')));
        }
      } else {
        // Parse error message from response if available
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error'] ?? 'Failed to get warehouse';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get warehouse: $e')));
    }
  }

   Future<bool> checkWarehouseAvailability() async {
     print('-------- checking warehouse availability --------');

     try {
       // Make sure to await the storage read operation
       String? isAvailableString = await storage.read(key: 'isWareHouseAvailable');

       print('-----checking value of the iswarehouseAvailable------');
       print(isAvailableString);

       // Handle null case and convert string to boolean
       if (isAvailableString == null) {
         print('No warehouse availability data found in storage');
         return false; // Default to false if no data found
       }

       // Convert string to boolean
       bool isAvailable = isAvailableString.toLowerCase() == 'true';

       print('Warehouse availability (parsed): $isAvailable');
       return isAvailable;

     } catch (e) {
       print('Error checking warehouse availability: $e');
       return false; // Return false on error
     }
   }
}

// Warehouse Model contains the lat , long ,address and availability of the warehouse
class Warehouse {
  CoordinatesPair warehousePosition;
  
  bool isAvailable;
  // Constructor for the Warehouse class
  Warehouse({
    required this.warehousePosition,
    
    this.isAvailable = true,
  });
}
