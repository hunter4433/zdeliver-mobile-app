import 'dart:convert';
import 'package:http/http.dart' as http;

class VendorAssignAndNotification {
  // Replace with your actual API base URL
  static const String baseUrl = 'http://13.126.169.224/api/v1/warehouse-finder';

  /// Finds the nearest available vendor based on provided coordinates
  ///
  /// Parameters:
  /// - [latitude]: User's current latitude (required)
  /// - [longitude]: User's current longitude (required)
  /// - [bookingId]: Optional booking ID for tracking
  ///
  /// Returns a Map containing the API response or error details
  static Future<Map<String, dynamic>> findNearestVendor({
    required double latitude,
    required double longitude,
    String? bookingId,
  }) async {
    try {
      // Validate input parameters
      if (latitude < -90 || latitude > 90) {
        return {
          'success': false,
          'error': 'Latitude must be between -90 and 90'
        };
      }

      if (longitude < -180 || longitude > 180) {
        return {
          'success': false,
          'error': 'Longitude must be between -180 and 180'
        };
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'latitude': latitude,
        'longitude': longitude,
      };

      // Add booking_id if provided
      if (bookingId != null && bookingId.isNotEmpty) {
        requestBody['booking_id'] = bookingId;
      }

      // Make API call
      final response = await http.post(
        Uri.parse('$baseUrl/find-nearest-vendors'), // Adjust endpoint as needed
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if required
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      // Parse response
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? '',
          'vendor': responseData['vendor'],
          'notification_sent': responseData['notification_sent'] ?? false,
          'notification_details': responseData['notification_details'],
          'estimated_wait_time': responseData['estimated_wait_time'],
          'debug_nearestVendor': responseData['debug_nearestVendor'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Bad request',
          'required': responseData['required'],
        };
      } else if (response.statusCode == 500) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Server error',
          'details': responseData['details'],
        };
      } else {
        return {
          'success': false,
          'error': 'Unexpected error occurred',
          'status_code': response.statusCode,
        };
      }

    } catch (e) {
      return {
        'success': false,
        'error': 'Network error or request failed',
        'details': e.toString(),
      };
    }
  }

  /// Helper method to extract vendor information from the response
  static VendorInfo? parseVendorFromResponse(Map<String, dynamic> response) {
    if (response['success'] == true && response['vendor'] != null) {
      try {
        final vendorData = response['vendor'] as Map<String, dynamic>;
        return VendorInfo.fromJson(vendorData);
      } catch (e) {
        print('Error parsing vendor data: $e');
        return null;
      }
    }
    return null;
  }
}

/// Model class for vendor information
class VendorInfo {
  final int id;
  final String vendorId;
  final String status;
  late final double latitude;
  late final double longitude;
  final double distanceKm;
  final Map<String, dynamic>? inventory;
  final String? sessionId;
  final String? lastUpdated;

  VendorInfo({
    required this.id,
    required this.vendorId,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.inventory,
    this.sessionId,
    this.lastUpdated,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>;

    return VendorInfo(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as String,
      status: json['status'] as String,
      latitude: (coordinates['latitude'] as num).toDouble(),
      longitude: (coordinates['longitude'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      inventory: json['inventory'] as Map<String, dynamic>?,
      sessionId: json['session_id'] as String?,
      lastUpdated: json['last_updated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'status': status,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'distance_km': distanceKm,
      'inventory': inventory,
      'session_id': sessionId,
      'last_updated': lastUpdated,
    };
  }
}

/// Example usage class showing how to implement this in your app
class VendorAssignmentExample {

  /// Example method showing how to use the findNearestVendor function
  static Future<void> assignVendorToUser({
    required double userLatitude,
    required double userLongitude,
    String? bookingId,
  }) async {

    // Show loading indicator
    print('Finding nearest vendor...');

    // Call the API
    final result = await VendorAssignAndNotification.findNearestVendor(
      latitude: userLatitude,
      longitude: userLongitude,
      bookingId: bookingId,
    );

    if (result['success'] == true) {
      if (result['vendor'] != null) {
        // Vendor found and assigned
        final vendor = VendorAssignAndNotification.parseVendorFromResponse(result);
        if (vendor != null) {
          print('Vendor assigned successfully!');
          print('Vendor ID: ${vendor.vendorId}');
          print('Distance: ${vendor.distanceKm} km');
          print('Notification sent: ${result['notification_sent']}');

          // Handle successful vendor assignment
          // Navigate to tracking screen or update UI
        }
      } else {
        // No vendor available at the moment
        print('No vendor available right now');
        print('Message: ${result['message']}');
        print('Estimated wait time: ${result['estimated_wait_time']}');

        // Show message to user about waiting
        // Maybe retry after some time
      }
    } else {
      // Handle error
      print('Error: ${result['error']}');
      if (result['details'] != null) {
        print('Details: ${result['details']}');
      }

      // Show error message to user
    }
  }
}