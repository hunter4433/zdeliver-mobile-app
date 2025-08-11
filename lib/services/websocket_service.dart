// lib/services/websocket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:Zdeliver/coordinate_class.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebSocketService extends ChangeNotifier {
  IO.Socket? socket;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Tracking data
  CoordinatesPair? vendorLocation;
  CoordinatesPair? userLocation;
  String? currentBookingId;
  bool isConnected = false;
  bool isJoinedTracking = false; // ✅ Added to track room join status
  DateTime? lastUpdateTime;
  String? connectionError;

  // Callbacks
  Function(CoordinatesPair)? onVendorLocationUpdate;
  Function(String)? onEtaUpdate;
  Function(String)? onConnectionStatusChange; // ✅ Added status callback

  // ✅ Initialize WebSocket connection
  Future<void> connectToTracking({
    required String bookingId,
    required String userId,
    required CoordinatesPair userPosition,
    String userType = 'customer', // ✅ Allow customization
  }) async {
    try {
      currentBookingId = bookingId;
      userLocation = userPosition;

      // ✅ Clean Socket.IO configuration
      socket = IO.io(
        'http://10.0.2.2:8000', // ✅ Replace with your actual server URL
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // ✅ Allow fallback
            .enableAutoConnect()
            .setQuery({
          'bookingId': bookingId,
          'userId': userId,
          'userType': userType,
        })
            .build(),
      );

      _setupEventListeners();
      socket!.connect();

    } catch (e) {
      connectionError = e.toString();
      onConnectionStatusChange?.call('Connection failed: $e');
      notifyListeners();
    }
  }

  void _setupEventListeners() {
    // ✅ Connection success confirmation
    socket!.on('connection_success', (data) {
      print('✅ Connection confirmed: $data');
      onConnectionStatusChange?.call('Connected successfully');
    });

    socket!.on('connect', (_) {
      print('🔌 WebSocket connected');
      isConnected = true;
      connectionError = null;
      onConnectionStatusChange?.call('Connected');

      // ✅ Join tracking room after connection
      _joinTrackingRoom();
      notifyListeners();
    });

    // ✅ Room join confirmation
    socket!.on('joined_tracking', (data) {
      print('📍 Successfully joined tracking: $data');
      isJoinedTracking = true;
      onConnectionStatusChange?.call('Tracking started');
      notifyListeners();
    });

    socket!.on('disconnect', (reason) {
      print('❌ WebSocket disconnected: $reason');
      isConnected = false;
      isJoinedTracking = false;
      onConnectionStatusChange?.call('Disconnected: $reason');
      notifyListeners();
    });

    socket!.on('connect_error', (error) {
      print('❌ Connection error: $error');
      connectionError = error.toString();
      isConnected = false;
      onConnectionStatusChange?.call('Connection error: $error');
      notifyListeners();
    });

    // ✅ Tracking events (matching server events)
    socket!.on('vendor_location_update', (data) {
      _handleVendorLocationUpdate(data);
    });

    socket!.on('eta_update', (data) {
      _handleEtaUpdate(data);
    });

    socket!.on('tracking_error', (data) {
      print('❌ Tracking error: $data');
      connectionError = data['message'] ?? 'Unknown tracking error';
      onConnectionStatusChange?.call('Tracking error: ${data['message']}');
      notifyListeners();
    });

    // ✅ Reconnection handling
    socket!.on('reconnect', (_) {
      print('🔄 WebSocket reconnected');
      isJoinedTracking = false; // Reset join status
      _joinTrackingRoom(); // Rejoin room
    });

    // ✅ Health check support
    socket!.on('pong', (data) {
      print('🏓 Pong received: $data');
    });
  }

  // ✅ Separate method for joining tracking room
  void _joinTrackingRoom() {
    if (currentBookingId != null && userLocation != null) {
      socket!.emit('join_tracking', {
        'bookingId': currentBookingId,
        'userLocation': {
          'latitude': userLocation!.latitude,
          'longitude': userLocation!.longitude,
        },
      });
    }
  }

  void _handleVendorLocationUpdate(dynamic data) {
    try {
      vendorLocation = CoordinatesPair(
        latitude: data['latitude'].toDouble(),
        longitude: data['longitude'].toDouble(),
      );
      lastUpdateTime = DateTime.now();

      print('📍 Vendor location updated: ${vendorLocation!.latitude}, ${vendorLocation!.longitude}');
      onVendorLocationUpdate?.call(vendorLocation!);
      notifyListeners();
    } catch (e) {
      print('❌ Error parsing vendor location: $e');
    }
  }

  void _handleEtaUpdate(dynamic data) {
    try {
      String eta = data['eta']?.toString() ?? 'Unknown';
      print('⏰ ETA update: $eta');
      onEtaUpdate?.call(eta);
      notifyListeners();
    } catch (e) {
      print('❌ Error parsing ETA: $e');
    }
  }

  // ✅ Update user location
  void updateUserLocation(CoordinatesPair newLocation) {
    userLocation = newLocation;

    if (socket != null && isConnected && isJoinedTracking) {
      socket!.emit('user_location_update', {
        'bookingId': currentBookingId,
        'location': {
          'latitude': newLocation.latitude,
          'longitude': newLocation.longitude,
        },
      });
      print('📱 User location sent: ${newLocation.latitude}, ${newLocation.longitude}');
    }
  }

  // ✅ Health check method
  void pingServer() {
    if (socket != null && isConnected) {
      socket!.emit('ping');
    }
  }

  // ✅ Disconnect from tracking
  void disconnect() {
    if (socket != null && isConnected) {
      socket!.emit('leave_tracking', {'bookingId': currentBookingId});
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }

    isConnected = false;
    isJoinedTracking = false;
    vendorLocation = null;
    currentBookingId = null;
    lastUpdateTime = null;
    connectionError = null;
    onConnectionStatusChange?.call('Disconnected');
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}