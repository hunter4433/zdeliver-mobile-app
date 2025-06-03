import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

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
  }) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

final GlobalKey<MapScreenState> mapKey = GlobalKey<MapScreenState>();

class MapScreenState extends State<MapScreen> {
  mapbox.MapboxMap? mapboxMap;
  mapbox.PointAnnotationManager? userLocationManager;

  mapbox.PointAnnotation? draggablePin;
  bool mapInitialized = false;
  bool hasLocationPermission = false;
  String? currentAddress;
  final GlobalKey _mapKey = GlobalKey();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Image data for markers
  Uint8List? locationIconData;

  // Warehouse and user locations
  Position? userPosition;

  double? pinnedLat;
  double? pinnedLng;
  String? pinnedAddress;

  // move camera to a specific location
  void moveCameraTo(double lat, double lng) {
    mapboxMap?.flyTo(
      mapbox.CameraOptions(
        center: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
        zoom: 16.0,
      ),
      mapbox.MapAnimationOptions(duration: 1000),
    );
  }

  // on no map movement get the camera state and call the onCenterChanged callback
  void _onCameraIdle() async {
    final cameraState = await mapboxMap?.getCameraState();
    if (cameraState != null && widget.onCenterChanged != null) {
      double lat = cameraState.center.coordinates.lat.toDouble();
      double lng = cameraState.center.coordinates.lng.toDouble();
      String address = await _getAddressFromCoordinates(lat, lng);
      widget.onCenterChanged!(lat, lng, address);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMarkerImages();
    _checkAndRequestLocationPermission();
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

  Future<void> _loadMarkerImages() async {
    try {
      // Load all marker images in parallel
      final locationBytes = rootBundle.load('assets/images/Frame 784.png');

      final results = await Future.wait([locationBytes]);

      locationIconData = results[0].buffer.asUint8List();

      if (locationIconData == null) {
        // throw Exception("Error: One or more marker images failed to load.");
        print("Marker images are not loaded properly.");
        return;
      }

      print('Marker images loaded successfully');
    } catch (e) {
      print('Error loading marker images: $e');
    }
  }

  // check if location permission is granted and request if not
  // This method checks if location permission is granted and requests it if not
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

        return mapContainer;
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

      print('Annotation managers initialized successfully');
    } catch (e) {
      print("Error creating annotation managers: $e");
    }
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
