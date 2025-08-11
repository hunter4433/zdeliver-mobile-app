import 'dart:convert';

import 'package:Zdeliver/coordinate_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

//this class is used to manage user location data
class UserLocationService {
  FlutterSecureStorage storage = FlutterSecureStorage();

  // Method to get the current user location
  Future<CoordinatesPair?> getCurrentLocation(BuildContext context) async {
    try {
      // Request permission to access location
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permission denied! Please enable it in settings.',
            ),
          ),
        );
        return null; // Permission denied, return null
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('LOCATION SERVICES DISABLED');
        _showLocationServiceDisabledDialog(context);
        return null;
      }
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return CoordinatesPair(
        latitude: position.latitude,
        longitude: position.longitude,
      ); // Return the current position
    } catch (e) {
      print('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location: $e')),
      );
      return null; // Return null in case of an error
    }
  }

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
    BuildContext context,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch address: ${response.statusCode}'),
          ),
        );
      }

      final data = json.decode(response.body);
      print(data);

      if (data != null && data['display_name'] != null) {
        // Return the formatted address
        return data['display_name'] as String;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No address found for the given coordinates.'),
          ),
        );
        // If no results found, return the raw coordinates
        return 'Unknown location: $latitude, $longitude';
      }
    } catch (error) {
      print('Error converting coordinates to address: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to convert coordinates to address: $error'),
        ),
      );
      // Return raw coordinates if geocoding fails
      return '$latitude, $longitude';
    }
  }

  void _showLocationServiceDisabledDialog(BuildContext context) {
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
}
