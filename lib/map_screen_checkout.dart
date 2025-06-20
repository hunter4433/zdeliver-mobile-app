import 'dart:typed_data';
import 'dart:math' as math;
import 'package:Zdeliver/coordinate_class.dart';
import 'package:Zdeliver/services/local_storage.dart';
import 'package:Zdeliver/services/userlocation_service.dart';
import 'package:Zdeliver/services/warehouse_service.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

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
  final bool isEmbedded;
  final CoordinatesPair? initialPosition;

  final void Function(String)? onEtaCalculated;
  final Warehouse? warehousePosition;
  const MapScreenCheckout({
    Key? key,
    this.containerHeight = double.infinity,
    this.isEmbedded = false,
    required this.initialPosition,

    this.onEtaCalculated,
    this.warehousePosition,
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
  mapbox.PointAnnotationManager? cartAnnotationManager;
  mapbox.PolylineAnnotationManager? routeLineManager;
  bool mapInitialized = false;
  bool hasLocationPermission = false;
  String? currentAddress;
  final GlobalKey _mapKey = GlobalKey();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Number of carts to place at warehouse
  final int numberOfCarts = 4;
  String arrivaltime = "...";

  // Image data for markers
  Uint8List? locationIconData;
  Uint8List? cartIconData;
  Uint8List? warehouseIconData;

  // Warehouse and user locations
  CoordinatesPair? userPosition;
  Warehouse? warehousePosition;

  @override
  void initState() {
    super.initState();
    userPosition = widget.initialPosition;
    currentAddress = widget.initialPosition?.address ?? 'No address found';
    _loadMarkerImages();
  }

  // Add this method to fetch directions
  // In your _getDirections method, update the coordinate handling:
  Future<List<List<double>>> _getDirections(
    CoordinatesPair start,
    CoordinatesPair end,
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
        final double durationSeconds = data['routes'][0]['duration'] ?? 0;
        setState(() {
          arrivaltime = '${(durationSeconds / 60).toStringAsFixed(0)} minutes';
        });
        if (widget.onEtaCalculated != null) {
          widget.onEtaCalculated!(arrivaltime);
        }
        print('Route duration: ${durationSeconds / 60} minutes');
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

  void _updateMap() async {
    // Update internal state with new widget values
    setState(() {
      userPosition = widget.initialPosition;
     warehousePosition = widget.warehousePosition;
      
    });

    // Re-create warehouse, user marker, and route
    await _createWarehouseAndRoute();
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

  @override
  void didUpdateWidget(covariant MapScreenCheckout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != oldWidget.initialPosition ||
        widget.warehousePosition != oldWidget.warehousePosition) {
      // Update the map with new positions
      _updateMap();
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
      bearing: 0, // Will be set dynamically based on route
      pitch: 0, // Will be set dynamically to match the Uber app style
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
    await _initializeAnnotationManagers();
    await _createWarehouseAndRoute();
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

      // User location from the Api
      if (widget.warehousePosition != null) {
        warehousePosition = widget.warehousePosition;
      }
      // If no warehouse position provided, generate a random one
      else {
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
                warehousePosition!.warehousePosition.longitude,
                warehousePosition!.warehousePosition.latitude,
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
          warehousePosition!.warehousePosition.latitude,
          warehousePosition!.warehousePosition. longitude,
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
        CoordinatesPair(
         latitude:   warehousePosition!.warehousePosition.latitude,
         longitude:  warehousePosition!.warehousePosition.longitude,
        ),
        CoordinatesPair(latitude:  userPosition!.latitude, longitude:  userPosition!.longitude),
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
        warehousePosition!.warehousePosition.latitude,
        warehousePosition!.warehousePosition. longitude,
        userPosition!.latitude,
        userPosition!.longitude,
      );

      // Calculate center point of the route
      double centerLat =
          (warehousePosition!.warehousePosition.latitude + userPosition!.latitude) / 2;
      double centerLng =
          (warehousePosition!.warehousePosition.longitude + userPosition!.longitude) / 2;

      // Calculate appropriate zoom level based on distance
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
      userPosition = await LocalStorage().getUserPositionLocally();

      // Create new warehouse and route
      await _createWarehouseAndRoute();
    } catch (e) {
      print("Error regenerating warehouse and route: $e");
      _showErrorDialog("Error", "Failed to refresh the map.");
    }
  }

  // Helper method to get random location within a specific distance range
  Warehouse _getRandomLocationWithinDistance(
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
   CoordinatesPair warehousePosition = CoordinatesPair(
      latitude: newLat,
      longitude: newLng,
    );
    return Warehouse(warehousePosition: warehousePosition);
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
        (111000 * math.cos(math.pi * warehousePosition!.warehousePosition.latitude / 180));

    return Pair(latOffset, lngOffset);
  }

  // Helper method to get a position with an offset
  CoordinatesPair _getPositionWithOffset(
    double lat,
    double lng,
    double latOffset,
    double lngOffset,
  ) {
    return CoordinatesPair( latitude: lat + latOffset, longitude: lng + lngOffset);
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

  void _onMapTap(mapbox.MapContentGestureContext context) async {
    if (mapboxMap == null) return;

    try {
      mapbox.Point mapPoint = context.point;
      mapbox.Position coordinates = mapPoint.coordinates;
      // double lat = coordinates.lat.toDouble();
      // double lng = coordinates.lng.toDouble();
      // // Get the address for the tapped coordinates
      // String address = await _getAddressFromCoordinates(lat, lng);
      print(
        'MAP TAPPED AT: ${mapPoint.coordinates.lat}, ${mapPoint.coordinates.lng}',
      );

      // You could use this for selecting destinations or other interactive features
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
