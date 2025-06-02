import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
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

class MapScreen extends StatefulWidget {
  final double containerHeight;
  final bool isEmbedded;
  final wareHouseLatLng;
  // final Function(double, double, String)? onLocationPinned; // Add this
  final Function(double lat, double lng, String address)?
  onCenterChanged; // <-- Add this
  // final bool startInPinMode;
  const MapScreen({
    Key? key,
    this.containerHeight = double.infinity,
    this.isEmbedded = false,
    // this.onLocationPinned,
    // this.startInPinMode = false,
    this.onCenterChanged,
    this.wareHouseLatLng,
  }) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

final GlobalKey<MapScreenState> mapKey = GlobalKey<MapScreenState>();

class MapScreenState extends State<MapScreen> {
  mapbox.MapboxMap? mapboxMap;
  mapbox.PointAnnotationManager? userLocationManager;
  mapbox.PointAnnotationManager? warehouseManager;
  mapbox.PointAnnotationManager? cartAnnotationManager;
  mapbox.PolylineAnnotationManager? routeLineManager;
  mapbox.PointAnnotation? draggablePin;
  bool mapInitialized = false;
  bool hasLocationPermission = false;
  String? currentAddress;
  final GlobalKey _mapKey = GlobalKey();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Number of carts to place at warehouse
  final int numberOfCarts = 4;

  // Image data for markers
  Uint8List? locationIconData;
  Uint8List? cartIconData;
  Uint8List? warehouseIconData;

  // Warehouse and user locations
  Position? userPosition;
  CoordinatePair? warehousePosition;

  bool pinMode = false;
  double? pinnedLat;
  double? pinnedLng;
  String? pinnedAddress;

  // void enablePinMode() async {
  //   setState(() {
  //     pinMode = true;
  //     pinnedLat = userPosition?.latitude;
  //     pinnedLng = userPosition?.longitude;
  //     pinnedAddress = null;
  //   });
  //   if (userPosition != null &&
  //       userLocationManager != null &&
  //       locationIconData != null) {
  //     // Remove previous pin if any
  //     if (draggablePin != null) {
  //       await userLocationManager!.delete(draggablePin!);
  //       draggablePin = null;
  //     }
  //     final options = mapbox.PointAnnotationOptions(
  //       geometry: mapbox.Point(
  //         coordinates: mapbox.Position(
  //           userPosition!.longitude,
  //           userPosition!.latitude,
  //         ),
  //       ),
  //       image: locationIconData!,
  //       iconSize: 2,
  //     );
  //     draggablePin = await userLocationManager!.create(options);

  //     // Optionally move camera to pin
  //     await mapboxMap?.flyTo(
  //       mapbox.CameraOptions(
  //         center: mapbox.Point(
  //           coordinates: mapbox.Position(
  //             userPosition!.longitude,
  //             userPosition!.latitude,
  //           ),
  //         ),
  //         zoom: 16.0,
  //       ),
  //       mapbox.MapAnimationOptions(duration: 1000),
  //     );
  //   }
  // }

  void moveCameraTo(double lat, double lng) {
    mapboxMap?.flyTo(
      mapbox.CameraOptions(
        center: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
        zoom: 16.0,
      ),
      mapbox.MapAnimationOptions(duration: 1000),
    );
  }

  void _onCameraIdle() async {
    final cameraState = await mapboxMap?.getCameraState();
    if (cameraState != null && widget.onCenterChanged != null) {
      double lat = cameraState.center.coordinates.lat.toDouble();
      double lng = cameraState.center.coordinates.lng.toDouble();
      String address = await _getAddressFromCoordinates(lat, lng);
      widget.onCenterChanged!(lat, lng, address);
    }
  }
  // void setAddressAndInitialisation() async {
  //   var userposition;
  //   setState(() {
  //     isLoading = true;
  //   });
  //   await _secureStorage.read(key: 'userposition').then((value) {
  //     if (value != null) {
  //       List<String> coords = value.split(',');
  //       if (coords.length == 2) {
  //         Position position = Position(
  //           latitude: double.parse(coords[0]),
  //           longitude: double.parse(coords[1]),
  //           timestamp: DateTime.now(),
  //           accuracy: 0,
  //           altitude: 0,
  //           speed: 0,
  //           speedAccuracy: 0,
  //           heading: 0,
  //           altitudeAccuracy: 0,
  //           headingAccuracy: 0,
  //         );

  //         userposition = position;
  //       }
  //     }
  //   });
  //   await _secureStorage.read(key: 'saved_address').then((value) {
  //     setState(() {
  //       currentAddress = value;
  //       userPosition = userposition;
  //     });
  //   });
  //   print('Current address: $currentAddress');
  //   print('User position: $userPosition');
  //   if (currentAddress == null || userPosition == null) {
  //     // If address or position is not set, initialize them
  //     print('Address or position not set, initializing location features');
  //     await _initializeLocationFeatures();
  //   } else {
  //     if (mapboxMap == null) return;
  //     // If address and position are already set,
  //     // check whether location service is on or off
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       print('LOCATION SERVICES DISABLED');
  //       _showLocationServiceDisabledDialog();
  //       return;
  //     }

  //     await mapboxMap!.location.updateSettings(
  //       mapbox.LocationComponentSettings(enabled: true),
  //     );

  //     // Rest of the method remains the same...
  //     await _initializeAnnotationManagers();
  //     await _createWarehouseAndRoute();
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _loadMarkerImages();
    _checkAndRequestLocationPermission();
    // if (widget.startInPinMode) {
    //   enablePinMode();
    // }
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

  // Method to convert coordinates to address using Mapbox Geocoding API
  // Future<String?> _getAddressFromCoordinates(double latitude, double longitude) async {
  //   String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
  //   final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/'
  //       '$longitude,$latitude.json?access_token=$ACCESS_TOKEN';
  //
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       // Check if features exist and are not empty
  //       if (data['features'] != null && data['features'].isNotEmpty) {
  //         // You can customize the address format as needed
  //         // This example uses the most complete place name
  //         final placeNames = data['features'].map((feature) =>
  //         feature['place_name'] as String
  //         ).toList();
  //
  //        String? _currentAddress = placeNames.isNotEmpty ? placeNames.first : null;
  //
  //         await _secureStorage.write(
  //             key: 'saved_address',
  //             value: _currentAddress!
  //         );
  //
  //         return placeNames.isNotEmpty ? placeNames.first : null;
  //       }
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error fetching address: $e');
  //     return null;
  //   }
  // }

  // Add this method to fetch directions
  // In your _getDirections method, update the coordinate handling:
  Future<List<List<double>>> _getDirections(
    CoordinatePair start,
    CoordinatePair end,
  ) async {
    String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
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
        return coordinates
            .map<List<double>>(
              (coord) => [coord[0].toDouble(), coord[1].toDouble()],
            )
            .toList();
      } else {
        print('Failed to get directions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching directions: $e');
      return [];
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

      final results = await Future.wait([
        locationBytes,
        cartBytes,
        warehouseBytes,
      ]);

      locationIconData = results[0].buffer.asUint8List();
      cartIconData = results[1].buffer.asUint8List();
      warehouseIconData = results[2].buffer.asUint8List();

      if (locationIconData == null ||
          cartIconData == null ||
          warehouseIconData == null) {
        // throw Exception("Error: One or more marker images failed to load.");
        print("Marker images are not loaded properly.");
        return;
      }

      print('Marker images loaded successfully');
    } catch (e) {
      print('Error loading marker images: $e');
    }
  }

  // Future<void> _checkLocationPermission() async {
  //   final permission = await Geolocator.checkPermission();

  //   bool newPermissionStatus =
  //       permission == LocationPermission.whileInUse ||
  //       permission == LocationPermission.always;

  //   if (mounted && newPermissionStatus != hasLocationPermission) {
  //     setState(() {
  //       hasLocationPermission = newPermissionStatus;
  //     });

  //     if (hasLocationPermission) {
  //       print('Location permission granted, initializing location features');
  //       // _initializeLocationFeatures();
  //       // Stop monitoring
  //     } else {
  //       print('Location permission not available');
  //     }
  //   }
  // }

  //
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

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while userPosition is null
    // if (userPosition == null) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    final double initialLat = userPosition?.latitude ?? 26.50;
    final double initialLng = userPosition?.longitude ?? 80.56;
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
      bearing: 0, // Will be set dynamically based on route
      pitch: 0, // Will be set dynamically to match the Uber app style
    );

    final mapWidget = mapbox.MapWidget(
      key: _mapKey,
      cameraOptions: camera,
      styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      // onTapListener: _onMapTap,
      onMapIdleListener: (mapIdleEventData) {
        _onCameraIdle();
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapContainer = SizedBox(
          height:
              widget.containerHeight != double.infinity
                  ? widget.containerHeight
                  : constraints.maxHeight,
          width: constraints.maxWidth,
          child: mapWidget,
        );

        return widget.isEmbedded
            ? mapContainer
            : Scaffold(
              // appBar: AppBar(title: const Text('Map')),
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

    // Ensure map is not null before interacting with it
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

    if (hasLocationPermission) {
      _initializeLocationFeatures();
    }
  }

  Future<void> _initializeLocationFeatures() async {
    if (mapboxMap == null) return;

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
      if (savedPosition != null) {
        print('USING SAVED POSITION');

        List<String> coords = savedPosition.split(',');

        var userposition = Position(
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
        print('USING SAVED POSITION: $userPosition');

        String? savedAddress = await _secureStorage.read(key: 'saved_address');
        if (savedAddress != null) {
          setState(() {
            currentAddress = savedAddress;
            userPosition = userposition;
          });
        }
        print('Current address: $currentAddress');
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
            currentAddress = address ?? 'Address not found';
            userPosition = geoPosition;
          });
        }
      }
      await mapboxMap!.location.updateSettings(
        mapbox.LocationComponentSettings(enabled: true),
      );

      // Rest of the method remains the same...
      await _initializeAnnotationManagers();
      await _createWarehouseAndRoute();
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

  Future<void> _initializeAnnotationManagers() async {
    if (mapboxMap == null) return;

    try {
      // Create separate annotation managers for different elements
      userLocationManager =
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

  Future<void> _createWarehouseAndRoute() async {
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
            iconSize: 1, // Make it smaller like in the Uber app
          );
      await userLocationManager!.create(userLocationOptions);

      // If warehouse position is already provided, use it
      if (widget.wareHouseLatLng is Map) {
        warehousePosition = CoordinatePair(
          widget.wareHouseLatLng['position'].latitude,
          widget.wareHouseLatLng['position'].longitude,
        );
      } else {
        // Create warehouse at a sensible distance (1-3km away)
        warehousePosition = _getRandomLocationWithinDistance(
          userPosition!.latitude,
          userPosition!.longitude,
          minDistanceKm: 0.5,
          maxDistanceKm: 1.5,
        );
      }

      // Create warehouse annotation
      mapbox.PointAnnotationOptions warehouseOptions =
          mapbox.PointAnnotationOptions(
            geometry: mapbox.Point(
              coordinates: mapbox.Position(
                warehousePosition!.longitude,
                warehousePosition!.latitude,
              ),
            ),
            image: warehouseIconData!,
            iconSize: 0.7, // Bigger than carts but not too big
          );
      await warehouseManager!.create(warehouseOptions);

      // Create cart annotations clustered near warehouse
      List<mapbox.PointAnnotationOptions> cartAnnotations = [];

      for (int i = 0; i < numberOfCarts; i++) {
        // Generate position near warehouse (within ~50-100 meters)
        final offset = _getRandomOffsetInMeters(50, 100);
        final cartPosition = _getPositionWithOffset(
          warehousePosition!.latitude,
          warehousePosition!.longitude,
          offset.first, // latitude offset
          offset.second, // longitude offset
        );

        // Create cart annotation
        mapbox.PointAnnotationOptions cartOptions =
            mapbox.PointAnnotationOptions(
              geometry: mapbox.Point(
                coordinates: mapbox.Position(
                  cartPosition.longitude,
                  cartPosition.latitude,
                ),
              ),
              image: cartIconData!,
              iconSize: 0.5, // Make carts very small like in the Uber app
            );

        cartAnnotations.add(cartOptions);
      }

      await cartAnnotationManager!.createMulti(cartAnnotations);

      // Create route line from warehouse to user
      // Get route that follows roads
      // In your _createWarehouseAndRoute method, update the route creation part:
      List<List<double>> routeCoordinates = await _getDirections(
        CoordinatePair(
          warehousePosition!.latitude,
          warehousePosition!.longitude,
        ),
        CoordinatePair(userPosition!.latitude, userPosition!.longitude),
      );

      if (routeCoordinates.isNotEmpty) {
        // Convert route coordinates to a list of positions - note the order here
        List<mapbox.Position> positions =
            routeCoordinates
                .map((coord) => mapbox.Position(coord[0], coord[1]))
                .toList();

        // Create route line
        mapbox.PolylineAnnotationOptions routeOptions =
            mapbox.PolylineAnnotationOptions(
              geometry: mapbox.LineString(coordinates: positions),
              lineColor: 0xFF000000, // Black line
              lineWidth: 3.0,
              lineOpacity: 0.7,
            );

        await routeLineManager!.create(routeOptions);
      }

      // Calculate bearing for the camera to point along the route direction
      double bearing = _calculateBearing(
        warehousePosition!.latitude,
        warehousePosition!.longitude,
        userPosition!.latitude,
        userPosition!.longitude,
      );

      // Calculate center point of the route
      double centerLat =
          (warehousePosition!.latitude + userPosition!.latitude) / 2;
      double centerLng =
          (warehousePosition!.longitude + userPosition!.longitude) / 2;

      // Calculate appropriate zoom level based on distance
      double distance = _calculateDistanceInKm(
        warehousePosition!.latitude,
        warehousePosition!.longitude,
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

      // Set camera to match the angle in the Uber app
      await mapboxMap!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(centerLng, centerLat),
          ),
          zoom: zoom,
          bearing: bearing,
          pitch: 45.0, // Set pitch to match the Uber app's perspective view
        ),
        mapbox.MapAnimationOptions(duration: 2000),
      );

      print('Created warehouse, carts, and route successfully');
    } catch (e) {
      print("Error creating warehouse and route: $e");
    }
  }

  // Helper method to regenerate warehouse and route
  void _regenerateWarehouseAndRoute() async {
    if (!hasLocationPermission || !mapInitialized) {
      _showErrorDialog(
        "Not Ready",
        "Please wait for map initialization and location permissions.",
      );
      return;
    }

    try {
      // Update current position
      userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );

      // Create new warehouse and route
      await _createWarehouseAndRoute();
    } catch (e) {
      print("Error regenerating warehouse and route: $e");
      _showErrorDialog("Error", "Failed to refresh the map.");
    }
  }

  // Helper method to get random location within a specific distance range
  CoordinatePair _getRandomLocationWithinDistance(
    double lat,
    double lng, {
    required double minDistanceKm,
    required double maxDistanceKm,
  }) {
    // Earth's radius in kilometers
    final double earthRadius = 6371.0;

    // Generate a random distance in meters (within specified range)
    final double distance =
        minDistanceKm +
        math.Random().nextDouble() * (maxDistanceKm - minDistanceKm);

    // Generate a random angle in radians
    final double angle = math.Random().nextDouble() * 2 * math.pi;

    // Convert distance to radians
    final double distRadians = distance / earthRadius;

    // Convert lat/lng to radians
    final double latRad = lat * math.pi / 180;
    final double lngRad = lng * math.pi / 180;

    // Calculate new position
    final double newLatRad = math.asin(
      math.sin(latRad) * math.cos(distRadians) +
          math.cos(latRad) * math.sin(distRadians) * math.cos(angle),
    );

    final double newLngRad =
        lngRad +
        math.atan2(
          math.sin(angle) * math.sin(distRadians) * math.cos(latRad),
          math.cos(distRadians) - math.sin(latRad) * math.sin(newLatRad),
        );

    // Convert back to degrees
    final double newLat = newLatRad * 180 / math.pi;
    final double newLng = newLngRad * 180 / math.pi;

    return CoordinatePair(newLat, newLng);
  }

  // Helper method to get random offset in meters
  Pair<double, double> _getRandomOffsetInMeters(
    double minOffsetMeters,
    double maxOffsetMeters,
  ) {
    final double randomDistance =
        minOffsetMeters +
        math.Random().nextDouble() * (maxOffsetMeters - minOffsetMeters);
    final double randomAngle = math.Random().nextDouble() * 2 * math.pi;

    // Convert to lat/lng offsets (approximation)
    // 1 degree latitude ≈ 111km
    // 1 degree longitude ≈ 111km * cos(latitude)
    final double latOffset = (randomDistance * math.cos(randomAngle)) / 111000;
    final double lngOffset =
        (randomDistance * math.sin(randomAngle)) /
        (111000 * math.cos(math.pi * warehousePosition!.latitude / 180));

    return Pair(latOffset, lngOffset);
  }

  // Helper method to get a position with an offset
  CoordinatePair _getPositionWithOffset(
    double lat,
    double lng,
    double latOffset,
    double lngOffset,
  ) {
    return CoordinatePair(lat + latOffset, lng + lngOffset);
  }

  // Calculate bearing between two points (in degrees)
  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    // Convert to radians
    lat1 = lat1 * math.pi / 180;
    lon1 = lon1 * math.pi / 180;
    lat2 = lat2 * math.pi / 180;
    lon2 = lon2 * math.pi / 180;

    double y = math.sin(lon2 - lon1) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);

    double bearing = math.atan2(y, x);
    bearing = bearing * 180 / math.pi; // Convert to degrees
    bearing = (bearing + 360) % 360; // Normalize to 0-360

    return bearing;
  }

  // Calculate distance between two points (in km)
  double _calculateDistanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius of the earth in km

    double latDistance = _degreesToRadians(lat2 - lat1);
    double lonDistance = _degreesToRadians(lon2 - lon1);

    double a =
        math.sin(latDistance / 2) * math.sin(latDistance / 2) +
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

  // void _onMapTap(mapbox.MapContentGestureContext context) async {
  //   if (mapboxMap == null || userLocationManager == null) return;

  //   mapbox.Point mapPoint = context.point;
  //   mapbox.Position coordinates = mapPoint.coordinates;
  //   double lat = coordinates.lat.toDouble();
  //   double lng = coordinates.lng.toDouble();

  //   // Remove previous pin if any
  //   if (draggablePin != null) {
  //     await userLocationManager!.delete(draggablePin!);
  //     draggablePin = null;
  //   }

  //   // Add new pin at tapped location
  //   final options = mapbox.PointAnnotationOptions(
  //     geometry: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
  //     image: locationIconData!,
  //     iconSize: 2,
  //   );
  //   draggablePin = await userLocationManager!.create(options);

  //   // Get address for new location
  //   String address = await _getAddressFromCoordinates(lat, lng);

  //   setState(() {
  //     pinnedLat = lat;
  //     pinnedLng = lng;
  //     pinnedAddress = address;
  //     pinMode = false;
  //   });

  //   if (widget.onLocationPinned != null) {
  //     widget.onLocationPinned!(lat, lng, address);
  //   }
  // }

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

        if (mapInitialized) {
          _initializeLocationFeatures();
        }
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

  Future<CurrentLocationResult?> getCurrentLocation() async {
    try {
      // Get device location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Optionally, reverse geocode to get address
      String address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return CurrentLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      print('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location: $e')),
      );

      return null;
    }
  }
}

// Helper class for latitude and longitude pairs
class CoordinatePair {
  final double latitude;
  final double longitude;

  CoordinatePair(this.latitude, this.longitude);
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
