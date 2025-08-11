import 'dart:typed_data';
import 'dart:math' as math;
import 'package:Zdeliver/coordinate_class.dart';
import 'package:Zdeliver/services/local_storage.dart';
import 'package:Zdeliver/services/userlocation_service.dart';
import 'package:Zdeliver/services/warehouse_service.dart';
import 'package:Zdeliver/services/websocket_service.dart';
import 'package:Zdeliver/vendorAssignAndNotification.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Initialize Mapbox access token early in your app
Future<void> setupMapbox() async {
  String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
  mapbox.MapboxOptions.setAccessToken(ACCESS_TOKEN);
}

class MapScreenCheckout extends StatefulWidget {
  final double containerHeight;
  final String? bookingId;
  final bool isEmbedded;
  final CoordinatesPair? initialPosition;
  final void Function(String)? onEtaCalculated;
  final Warehouse? warehousePosition;
  final VendorInfo? vendorInfo; // Add vendor info parameter

  const MapScreenCheckout({
    Key? key,
    this.containerHeight = double.infinity,
    this.bookingId,
    this.isEmbedded = false,
    required this.initialPosition,
    this.onEtaCalculated,
    this.warehousePosition,
    this.vendorInfo, // Add to constructor
  }) : super(key: key);

  @override
  _MapScreenCheckoutState createState() => _MapScreenCheckoutState();
}

final GlobalKey<_MapScreenCheckoutState> mapKey =
GlobalKey<_MapScreenCheckoutState>();

class _MapScreenCheckoutState extends State<MapScreenCheckout> {
  mapbox.MapboxMap? mapboxMap;
  mapbox.PointAnnotationManager? userLocationManager;
  mapbox.PointAnnotationManager? warehouseManager;
  mapbox.PointAnnotationManager? vendorLocationManager; // Add vendor manager
  mapbox.PointAnnotationManager? cartAnnotationManager;
  mapbox.PolylineAnnotationManager? routeLineManager;
  bool mapInitialized = false;
  bool hasLocationPermission = false;
  String? currentAddress;
  final GlobalKey _mapKey = GlobalKey();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  WebSocketService? _webSocketService;
  Timer? _locationUpdateTimer;
  bool _isWebSocketInitialized = false; // Add this flag

  // Number of carts to place at warehouse
  final int numberOfCarts = 4;
  String arrivaltime = "...";

  // HARDCODED WAREHOUSE COORDINATES
  static const double WAREHOUSE_LAT = 26.83620000;
  static const double WAREHOUSE_LNG = 81.00200000;

  // Image data for markers
  Uint8List? locationIconData;
  Uint8List? cartIconData;
  Uint8List? warehouseIconData;
  Uint8List? vendorIconData; // Add vendor icon data

  // Warehouse and user locations
  CoordinatesPair? userPosition;
  Warehouse? warehousePosition;

  // ADD THESE VARIABLES TO PREVENT UNNECESSARY RECREATION
  CoordinatesPair? _lastUserPosition;
  List<List<double>>? _cachedRouteCoordinates;
  bool _isCreatingRoute = false;
  CoordinatesPair? _latestVendorLocation; // Store latest vendor location

  @override
  void initState() {
    super.initState();

    userPosition = widget.initialPosition;
    _lastUserPosition = widget.initialPosition;
    currentAddress = widget.initialPosition?.address ?? 'No address found';

    // Only initialize warehouse if no vendor is provided
    if (widget.vendorInfo == null) {
      print('No vendor info yet, showing hardcoded warehouse');
      _initializeHardcodedWarehouse();
    }

    _loadMarkerImages();

    // Don't initialize WebSocket here - wait for vendor info
  }

  // Initialize the hardcoded warehouse position
  void _initializeHardcodedWarehouse() {
    warehousePosition = Warehouse(
      warehousePosition: CoordinatesPair(
        latitude: WAREHOUSE_LAT,
        longitude: WAREHOUSE_LNG,
      ),
    );
  }

  // IMPROVED: Add caching and prevent multiple simultaneous calls
  Future<List<List<double>>> _getDirections(
      CoordinatesPair start,
      CoordinatesPair end,
      ) async {
    // Check if we already have cached route coordinates for the same positions
    if (_cachedRouteCoordinates != null &&
        _lastUserPosition != null &&
        _lastUserPosition!.latitude == end.latitude &&
        _lastUserPosition!.longitude == end.longitude) {
      return _cachedRouteCoordinates!;
    }

    String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?geometries=geojson&overview=full&access_token=$ACCESS_TOKEN';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract coordinates from the route
        final List<dynamic> coordinates =
        data['routes'][0]['geometry']['coordinates'];
        final double durationSeconds = data['routes'][0]['duration'] ?? 0;

        if (mounted) {
          setState(() {
            arrivaltime =
            '${(durationSeconds / 60).toStringAsFixed(0)} minutes';
          });
        }

        if (widget.onEtaCalculated != null) {
          widget.onEtaCalculated!(arrivaltime);
        }
        print('Route duration: ${durationSeconds / 60} minutes');

        // Cache the route coordinates
        _cachedRouteCoordinates = coordinates
            .map<List<double>>(
              (coord) => [coord[0].toDouble(), coord[1].toDouble()],
        )
            .toList();

        return _cachedRouteCoordinates!;
      } else {
        print('Failed to get directions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching directions: $e');
      return [];
    }
  }

  Future<void> initializeWebSocket() async {
    // Check if we have all required data
    if (widget.vendorInfo == null || widget.bookingId == null) {
      print('Cannot initialize WebSocket - missing vendor info or booking ID');
      return;
    }

    print('Initializing WebSocket connection...');
    print('Vendor ID: ${widget.vendorInfo!.vendorId}');
    print('Booking ID: ${widget.bookingId}');

    _webSocketService = WebSocketService();

    // Set up all callbacks
    _webSocketService!.onVendorLocationUpdate = (location) {
      print('📍 Vendor location update received in map: ${location.latitude}, ${location.longitude}');
      _updateVendorLocation(location);
    };

    _webSocketService!.onEtaUpdate = (eta) {
      print('⏱️ ETA update received: $eta');
      if (widget.onEtaCalculated != null) {
        widget.onEtaCalculated!(eta);
      }
    };

    // _webSocketService!.onStatusUpdate = (status) {
    //   print('📦 Delivery status update: $status');
    // };

    try {
      // Get user ID
      String? userId = await LocalStorage().getUserId();
      if (userId == null) {
        print('Warning: No user ID found, using default');
        userId = '1';
      }

      print('Connecting to WebSocket...');
      await _webSocketService!.connectToTracking(
        bookingId: widget.bookingId!,
        userId: userId,
        userPosition: userPosition!,
      );

      // Start location updates after successful connection
      if (_webSocketService!.isConnected) {
        print('✅ WebSocket connected successfully, starting location updates');
        startLocationUpdates();
      }
    } catch (e) {
      print('❌ Failed to initialize WebSocket: $e');
      _isWebSocketInitialized = false; // Reset flag to allow retry
    }
  }

  // Add the missing _updateVendorLocation method
  Future<void> _updateVendorLocation(CoordinatesPair newLocation) async {
    if (!mounted) return;

    print('Updating vendor location on map: ${newLocation.latitude}, ${newLocation.longitude}');

    // Store the latest vendor location
    _latestVendorLocation = newLocation;

    // Update vendor location on map
    if (vendorLocationManager != null && vendorIconData != null && mapboxMap != null) {
      try {
        // Clear existing vendor marker
        await vendorLocationManager!.deleteAll();

        // Create new vendor marker at updated location
        mapbox.PointAnnotationOptions vendorOptions = mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(
              newLocation.longitude,
              newLocation.latitude,
            ),
          ),
          image: vendorIconData!,
          iconSize: 0.8,
        );
        await vendorLocationManager!.create(vendorOptions);

        // Check if vendor has moved significantly
        double distance = 0.0;
        if (_latestVendorLocation != null && widget.vendorInfo != null) {
          distance = _calculateDistanceInKm(
            widget.vendorInfo!.latitude,
            widget.vendorInfo!.longitude,
            newLocation.latitude,
            newLocation.longitude,
          );
        }

        // If vendor moved more than 50 meters, update the route
        if (distance > 0.05) {
          print('Vendor moved ${distance.toStringAsFixed(2)} km, updating route...');

          // Clear cached route and update with new vendor location
          _cachedRouteCoordinates = null;
          await _updateVendorRouteOnly(newLocation);
        }

        print('✅ Vendor location updated on map');
      } catch (e) {
        print('❌ Error updating vendor location on map: $e');
      }
    } else {
      print('⚠️ Cannot update vendor marker - managers not initialized');
    }
  }

  // Add helper method to update route only
  Future<void> _updateVendorRouteOnly(CoordinatesPair vendorLocation) async {
    if (!mounted || mapboxMap == null || userPosition == null || routeLineManager == null) {
      return;
    }

    try {
      // Clear existing route
      await routeLineManager!.deleteAll();

      // Create new route from vendor to user
      List<List<double>> routeCoordinates = await _getDirections(
        vendorLocation,
        userPosition!,
      );

      if (routeCoordinates.isNotEmpty) {
        List<mapbox.Position> positions = routeCoordinates
            .map((coord) => mapbox.Position(coord[0], coord[1]))
            .toList();

        mapbox.PolylineAnnotationOptions routeOptions = mapbox.PolylineAnnotationOptions(
          geometry: mapbox.LineString(coordinates: positions),
          lineColor: 0xFF4CAF50, // Green color for delivery route
          lineWidth: 4.0,
          lineOpacity: 0.8,
        );

        await routeLineManager!.create(routeOptions);
        print('✅ Route updated with new vendor location');
      }
    } catch (e) {
      print('❌ Error updating vendor route: $e');
    }
  }

  // Update the startLocationUpdates method
  void startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      if (_webSocketService != null &&
          _webSocketService!.isConnected &&
          userPosition != null) {
        // Get current user location
        CoordinatesPair? currentLocation =
        await LocalStorage().getUserPositionLocally();
        if (currentLocation != null) {
          userPosition = currentLocation;
          _webSocketService!.updateUserLocation(userPosition!);
        }
      }
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _webSocketService?.disconnect(); // Properly disconnect
    super.dispose();
  }

  // IMPROVED: Only update if position actually changed
  void _updateMap() async {
    // Check if position actually changed
    if (_lastUserPosition != null &&
        widget.initialPosition != null &&
        _lastUserPosition!.latitude == widget.initialPosition!.latitude &&
        _lastUserPosition!.longitude == widget.initialPosition!.longitude) {
      return; // No change, don't update
    }

    // Update internal state with new widget values
    setState(() {
      userPosition = widget.initialPosition;
      _lastUserPosition = widget.initialPosition;
    });

    // Only update user marker, don't recreate everything
    await _updateUserMarkerOnly();
  }

  // NEW METHOD: Only update user marker without recreating route
  Future<void> _updateUserMarkerOnly() async {
    if (mapboxMap == null ||
        userPosition == null ||
        userLocationManager == null ||
        locationIconData == null) {
      return;
    }

    try {
      // Clear only user location annotations
      await userLocationManager!.deleteAll();

      // Create new user location annotation
      mapbox.PointAnnotationOptions userLocationOptions =
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(
            userPosition!.longitude,
            userPosition!.latitude,
          ),
        ),
        image: locationIconData!,
        iconSize: 1,
      );
      await userLocationManager!.create(userLocationOptions);

      print('Updated user marker only');
    } catch (e) {
      print("Error updating user marker: $e");
    }
  }

  Future<void> _loadMarkerImages() async {
    try {
      // Load all marker images in parallel
      final locationBytes = rootBundle.load('assets/images/Frame 784.png');
      final cartBytes = rootBundle.load(
        'assets/images/562f42a9-1836-4cf7-8132-2a97588a62fb-removebg-preview 2.png',
      );
      final warehouseBytes = rootBundle.load('assets/images/home8.png');
      // Use a default icon if you don't have a specific delivery partner icon
      final vendorBytes = rootBundle.load('assets/images/Frame 784.png'); // Or use a delivery partner icon

      final results = await Future.wait([
        locationBytes,
        cartBytes,
        warehouseBytes,
        vendorBytes,
      ]);

      locationIconData = results[0].buffer.asUint8List();
      cartIconData = results[1].buffer.asUint8List();
      warehouseIconData = results[2].buffer.asUint8List();
      vendorIconData = results[3].buffer.asUint8List();

      if (locationIconData == null ||
          cartIconData == null ||
          warehouseIconData == null ||
          vendorIconData == null) {
        print("Marker images are not loaded properly.");
        return;
      }

      print('Marker images loaded successfully');
    } catch (e) {
      print('Error loading marker images: $e');
    }
  }

  @override
  void didUpdateWidget(covariant MapScreenCheckout oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if vendor info just became available
    if (widget.vendorInfo != null && oldWidget.vendorInfo == null) {
      print('Vendor info received! Initializing WebSocket connection...');
print(_isWebSocketInitialized);
print(widget.bookingId);
print(widget.vendorInfo);
      // Initialize WebSocket when vendor is assigned
      // if (!_isWebSocketInitialized && widget.bookingId != null) {
        _isWebSocketInitialized = true;
        initializeWebSocket();
      // }

      // Clear cache and create vendor route
      _cachedRouteCoordinates = null;
      _createVendorRouteAndMarkers();
    }

    // Check if vendor info changed (different vendor assigned)
    else if (widget.vendorInfo != null &&
        oldWidget.vendorInfo != null &&
        widget.vendorInfo!.vendorId != oldWidget.vendorInfo!.vendorId) {
      print('Vendor changed! Reconnecting WebSocket...');

      // Disconnect old WebSocket and connect new one
      _webSocketService?.disconnect();
      _isWebSocketInitialized = false;

      // Reinitialize with new vendor
      if (widget.bookingId != null) {
        _isWebSocketInitialized = true;
        initializeWebSocket();
      }

      // Update route for new vendor
      _cachedRouteCoordinates = null;
      _createVendorRouteAndMarkers();
    }

    // Handle position updates
    if (widget.initialPosition != oldWidget.initialPosition) {
      if (oldWidget.initialPosition != null && widget.initialPosition != null) {
        double distance = _calculateDistanceInKm(
          oldWidget.initialPosition!.latitude,
          oldWidget.initialPosition!.longitude,
          widget.initialPosition!.latitude,
          widget.initialPosition!.longitude,
        );

        if (distance > 0.01) {
          _updateMap();
        }
      } else {
        _updateMap();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double initialLat = widget.initialPosition!.latitude;
    final double initialLng = widget.initialPosition!.longitude;
    final mapbox.CameraOptions camera = mapbox.CameraOptions(
      center: mapbox.Point(
        coordinates: mapbox.Position(initialLng, initialLat),
      ),
      padding: mapbox.MbxEdgeInsets(
        top: widget.isEmbedded ? 80.0 : 40.0,
        left: 5.0,
        bottom: widget.isEmbedded ? 100.0 : 80.0,
        right: 5.0,
      ),
      zoom: 14.0,
      bearing: 0,
      pitch: 0,
    );

    final mapWidget = mapbox.MapWidget(
      key: _mapKey,
      cameraOptions: camera,
      styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      onTapListener: _onMapTap,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapContainer = SizedBox(
          height: widget.containerHeight != double.infinity
              ? widget.containerHeight
              : constraints.maxHeight,
          width: constraints.maxWidth,
          child: mapWidget,
        );

        return widget.isEmbedded
            ? mapContainer
            : Scaffold(
          body: mapContainer,
          floatingActionButton: FloatingActionButton(
            heroTag: 'mapScreenFab',
            onPressed: _regenerateWarehouseAndRoute,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  Future<void> _onMapCreated(mapbox.MapboxMap mapboxMap) async {
    if (mapInitialized) return;

    print('MAP CREATED SUCCESSFULLY');
    this.mapboxMap = mapboxMap;

    if (mapboxMap == null) {
      print("Error: Map is null after creation");
      return;
    }

    await mapboxMap.location.updateSettings(
      mapbox.LocationComponentSettings(enabled: true),
    );
    await mapboxMap.gestures.updateSettings(
      mapbox.GesturesSettings(
        rotateEnabled: true,
        pinchToZoomEnabled: true,
        scrollEnabled: true,
        doubleTapToZoomInEnabled: true,
        doubleTouchToZoomOutEnabled: true,
        quickZoomEnabled: true,
        pitchEnabled: true,
      ),
    );

    if (mounted) {
      setState(() {
        mapInitialized = true;
      });
    }
    await _initializeAnnotationManagers();
    await _createWarehouseAndRoute();
  }

  Future<void> _initializeAnnotationManagers() async {
    if (mapboxMap == null) return;

    try {
      userLocationManager =
      await mapboxMap!.annotations.createPointAnnotationManager();
      vendorLocationManager =
      await mapboxMap!.annotations.createPointAnnotationManager();
      warehouseManager =
      await mapboxMap!.annotations.createPointAnnotationManager();
      cartAnnotationManager =
      await mapboxMap!.annotations.createPointAnnotationManager();
      routeLineManager =
      await mapboxMap!.annotations.createPolylineAnnotationManager();

      print('Annotation managers initialized successfully');
    } catch (e) {
      print("Error creating annotation managers: $e");
    }
  }

  // IMPROVED: Add guard to prevent multiple simultaneous calls
  Future<void> _createWarehouseAndRoute() async {
    // If vendor info is available, create vendor route instead
    if (widget.vendorInfo != null) {
      await _createVendorRouteAndMarkers();
      return;
    }

    if (_isCreatingRoute) return; // Prevent multiple simultaneous calls

    if (mapboxMap == null ||
        userPosition == null ||
        userLocationManager == null ||
        warehouseManager == null ||
        cartAnnotationManager == null ||
        routeLineManager == null ||
        locationIconData == null ||
        cartIconData == null ||
        warehouseIconData == null) {
      print("Cannot create warehouse and route - initialization incomplete");
      return;
    }

    _isCreatingRoute = true;

    try {
      // Clear existing annotations
      await userLocationManager!.deleteAll();
      await warehouseManager!.deleteAll();
      await cartAnnotationManager!.deleteAll();
      await routeLineManager!.deleteAll();

      // Create user location annotation
      mapbox.PointAnnotationOptions userLocationOptions =
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(
            userPosition!.longitude,
            userPosition!.latitude,
          ),
        ),
        image: locationIconData!,
        iconSize: 1,
      );
      await userLocationManager!.create(userLocationOptions);

      // Create warehouse annotation
      mapbox.PointAnnotationOptions warehouseOptions =
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(
            warehousePosition!.warehousePosition.longitude,
            warehousePosition!.warehousePosition.latitude,
          ),
        ),
        image: warehouseIconData!,
        iconSize: 0.7,
      );
      await warehouseManager!.create(warehouseOptions);

      // Create cart annotations clustered near warehouse
      List<mapbox.PointAnnotationOptions> cartAnnotations = [];

      for (int i = 0; i < numberOfCarts; i++) {
        final offset = _getRandomOffsetInMeters(50, 100);
        final cartPosition = _getPositionWithOffset(
          warehousePosition!.warehousePosition.latitude,
          warehousePosition!.warehousePosition.longitude,
          offset.first,
          offset.second,
        );

        mapbox.PointAnnotationOptions cartOptions =
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(
              cartPosition.longitude,
              cartPosition.latitude,
            ),
          ),
          image: cartIconData!,
          iconSize: 0.5,
        );

        cartAnnotations.add(cartOptions);
      }

      await cartAnnotationManager!.createMulti(cartAnnotations);

      // Create route line from warehouse to user
      List<List<double>> routeCoordinates = await _getDirections(
        CoordinatesPair(
          latitude: warehousePosition!.warehousePosition.latitude,
          longitude: warehousePosition!.warehousePosition.longitude,
        ),
        CoordinatesPair(
            latitude: userPosition!.latitude,
            longitude: userPosition!.longitude),
      );

      if (routeCoordinates.isNotEmpty) {
        List<mapbox.Position> positions = routeCoordinates
            .map((coord) => mapbox.Position(coord[0], coord[1]))
            .toList();

        mapbox.PolylineAnnotationOptions routeOptions =
        mapbox.PolylineAnnotationOptions(
          geometry: mapbox.LineString(coordinates: positions),
          lineColor: 0xFF000000,
          lineWidth: 3.0,
          lineOpacity: 0.7,
        );

        await routeLineManager!.create(routeOptions);
      }

      // Calculate camera position
      double bearing = _calculateBearing(
        warehousePosition!.warehousePosition.latitude,
        warehousePosition!.warehousePosition.longitude,
        userPosition!.latitude,
        userPosition!.longitude,
      );

      double centerLat =
          (warehousePosition!.warehousePosition.latitude +
              userPosition!.latitude) /
              2;
      double centerLng =
          (warehousePosition!.warehousePosition.longitude +
              userPosition!.longitude) /
              2;

      double distance = _calculateDistanceInKm(
        warehousePosition!.warehousePosition.latitude,
        warehousePosition!.warehousePosition.longitude,
        userPosition!.latitude,
        userPosition!.longitude,
      );

      double zoom = 14.0;
      if (distance < 1.0)
        zoom = 14.5;
      else if (distance < 2.0)
        zoom = 14.0;
      else if (distance < 3.0)
        zoom = 13.5;
      else if (distance < 5.0)
        zoom = 13.0;
      else
        zoom = 12.0;

      await mapboxMap!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(centerLng, centerLat),
          ),
          zoom: zoom,
          bearing: bearing,
          pitch: 45.0,
        ),
        mapbox.MapAnimationOptions(duration: 2000),
      );

      print('Created warehouse, carts, and route successfully');
    } catch (e) {
      print("Error creating warehouse and route: $e");
    } finally {
      _isCreatingRoute = false;
    }
  }

  // NEW METHOD: Create vendor route and markers
  Future<void> _createVendorRouteAndMarkers() async {
    if (_isCreatingRoute) return;

    // Use latest vendor location if available, otherwise use initial vendor info
    final vendorLat = _latestVendorLocation?.latitude ?? widget.vendorInfo?.latitude;
    final vendorLng = _latestVendorLocation?.longitude ?? widget.vendorInfo?.longitude;

    if (mapboxMap == null ||
        userPosition == null ||
        vendorLat == null ||
        vendorLng == null ||
        userLocationManager == null ||
        vendorLocationManager == null ||
        routeLineManager == null ||
        locationIconData == null ||
        vendorIconData == null) {
      print("Cannot create vendor route - initialization incomplete");
      return;
    }

    _isCreatingRoute = true;

    try {
      print('Creating vendor route with location: $vendorLat, $vendorLng');

      // Clear existing annotations
      await userLocationManager!.deleteAll();
      await vendorLocationManager!.deleteAll();
      await warehouseManager!.deleteAll();
      await cartAnnotationManager!.deleteAll();
      await routeLineManager!.deleteAll();

      // Create user location annotation
      mapbox.PointAnnotationOptions userLocationOptions =
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(
            userPosition!.longitude,
            userPosition!.latitude,
          ),
        ),
        image: locationIconData!,
        iconSize: 1,
      );
      await userLocationManager!.create(userLocationOptions);

      // Create vendor location annotation
      mapbox.PointAnnotationOptions vendorOptions =
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(vendorLng, vendorLat),
        ),
        image: vendorIconData!,
        iconSize: 0.8,
      );
      await vendorLocationManager!.create(vendorOptions);

      // Create route line from vendor to user
      List<List<double>> routeCoordinates = await _getDirections(
        CoordinatesPair(latitude: vendorLat, longitude: vendorLng),
        userPosition!,
      );

      if (routeCoordinates.isNotEmpty) {
        List<mapbox.Position> positions = routeCoordinates
            .map((coord) => mapbox.Position(coord[0], coord[1]))
            .toList();

        mapbox.PolylineAnnotationOptions routeOptions =
        mapbox.PolylineAnnotationOptions(
          geometry: mapbox.LineString(coordinates: positions),
          lineColor: 0xFF4CAF50, // Green color for delivery route
          lineWidth: 4.0,
          lineOpacity: 0.8,
        );

        await routeLineManager!.create(routeOptions);
      }

      // Calculate camera position
      double bearing = _calculateBearing(
        vendorLat,
        vendorLng,
        userPosition!.latitude,
        userPosition!.longitude,
      );

      double centerLat = (vendorLat + userPosition!.latitude) / 2;
      double centerLng = (vendorLng + userPosition!.longitude) / 2;

      double distance = _calculateDistanceInKm(
        vendorLat,
        vendorLng,
        userPosition!.latitude,
        userPosition!.longitude,
      );

      double zoom = 14.0;
      if (distance < 1.0)
        zoom = 15.0;
      else if (distance < 2.0)
        zoom = 14.5;
      else if (distance < 3.0)
        zoom = 14.0;
      else if (distance < 5.0)
        zoom = 13.5;
      else
        zoom = 13.0;

      await mapboxMap!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(centerLng, centerLat),
          ),
          zoom: zoom,
          bearing: bearing,
          pitch: 30.0,
        ),
        mapbox.MapAnimationOptions(duration: 2000),
      );

      print('Created vendor route and markers successfully');
    } catch (e) {
      print("Error creating vendor route: $e");
    } finally {
      _isCreatingRoute = false;
    }
  }

  // IMPROVED: Clear cache when regenerating
  void _regenerateWarehouseAndRoute() async {
    if (!mapInitialized) {
      _showErrorDialog(
        "Not Ready",
        "Please wait for map initialization.",
      );
      return;
    }

    try {
      // Clear cached route
      _cachedRouteCoordinates = null;

      // Update current position
      userPosition = await LocalStorage().getUserPositionLocally();
      _lastUserPosition = userPosition;

      // Create new warehouse and route
      await _createWarehouseAndRoute();
    } catch (e) {
      print("Error regenerating warehouse and route: $e");
      _showErrorDialog("Error", "Failed to refresh the map.");
    }
  }

  // Helper methods remain the same...
  Pair<double, double> _getRandomOffsetInMeters(
      double minOffsetMeters,
      double maxOffsetMeters,
      ) {
    final double randomDistance = minOffsetMeters +
        math.Random().nextDouble() * (maxOffsetMeters - minOffsetMeters);
    final double randomAngle = math.Random().nextDouble() * 2 * math.pi;

    final double latOffset = (randomDistance * math.cos(randomAngle)) / 111000;
    final double lngOffset = (randomDistance * math.sin(randomAngle)) /
        (111000 *
            math.cos(math.pi * warehousePosition!.warehousePosition.latitude / 180));

    return Pair(latOffset, lngOffset);
  }

  CoordinatesPair _getPositionWithOffset(
      double lat,
      double lng,
      double latOffset,
      double lngOffset,
      ) {
    return CoordinatesPair(
        latitude: lat + latOffset, longitude: lng + lngOffset);
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    lat1 = lat1 * math.pi / 180;
    lon1 = lon1 * math.pi / 180;
    lat2 = lat2 * math.pi / 180;
    lon2 = lon2 * math.pi / 180;

    double y = math.sin(lon2 - lon1) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);

    double bearing = math.atan2(y, x);
    bearing = bearing * 180 / math.pi;
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double _calculateDistanceInKm(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const double earthRadius = 6371;

    double latDistance = _degreesToRadians(lat2 - lat1);
    double lonDistance = _degreesToRadians(lon2 - lon1);

    double a = math.sin(latDistance / 2) * math.sin(latDistance / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(lonDistance / 2) *
            math.sin(lonDistance / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  void _onMapTap(mapbox.MapContentGestureContext context) async {
    if (mapboxMap == null) return;

    try {
      mapbox.Point mapPoint = context.point;
      mapbox.Position coordinates = mapPoint.coordinates;
      print(
        'MAP TAPPED AT: ${mapPoint.coordinates.lat}, ${mapPoint.coordinates.lng}',
      );
    } catch (e) {
      print("Error handling map tap: $e");
    }
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
}

// Generic pair class for two values
class Pair<A, B> {
  final A first;
  final B second;

  Pair(this.first, this.second);
}

class CurrentLocationResult {
  final double latitude;
  final double longitude;
  final String address;
  CurrentLocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}