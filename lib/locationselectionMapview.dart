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

class LocationSelectionScreen extends StatefulWidget {
  final Function(double lat, double lng, String address)? onLocationSelected;

  const LocationSelectionScreen({
    Key? key,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  mapbox.MapboxMap? mapboxMap;
  mapbox.PointAnnotationManager? locationAnnotationManager;
  bool mapInitialized = false;
  bool hasLocationPermission = false;

  // Location data
  Position? userPosition;
  double? selectedLat;
  double? selectedLng;
  String selectedAddress = '';
  bool isLoadingAddress = false;

  // UI Controllers
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool isSearching = false;
  List<SearchResult> searchResults = [];

  // Marker image
  Uint8List? locationIconData;

  // Dragging state
  bool isDragging = false;
  mapbox.PointAnnotation? selectedAnnotation;
  bool isLongPressActive = false;

  @override
  void initState() {
    super.initState();
    _loadMarkerImage();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMarkerImage() async {
    try {
      final locationBytes = await rootBundle.load('assets/images/Frame 784.png');
      locationIconData = locationBytes.buffer.asUint8List();
      print('Location marker image loaded successfully');
    } catch (e) {
      print('Error loading marker image: $e');
      // Create a simple colored circle as fallback
      locationIconData = await _createFallbackMarker();
    }
  }

  Future<Uint8List> _createFallbackMarker() async {
    // This is a simple fallback - in production you might want to create a proper marker
    return Uint8List.fromList([0xFF, 0x00, 0x00, 0xFF]); // Red pixel
  }

  Future<void> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    bool newPermissionStatus = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    if (mounted && newPermissionStatus != hasLocationPermission) {
      setState(() {
        hasLocationPermission = newPermissionStatus;
      });

      if (hasLocationPermission) {
        print('Location permission granted');
        _getCurrentLocation();
      } else {
        _requestLocationPermission();
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        _showPermissionDialog();
        return;
      } else if (permission == LocationPermission.deniedForever) {
        _showSettingsDialog();
        return;
      }

      if (mounted) {
        setState(() {
          hasLocationPermission = true;
        });
      }

      _getCurrentLocation();
    } catch (e) {
      print("Error requesting location permission: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          userPosition = position;
          selectedLat = position.latitude;
          selectedLng = position.longitude;
        });
      }

      // Get address for current location
      await _updateAddressFromCoordinates(position.latitude, position.longitude);
      await _updateLocationMarker(position.latitude, position.longitude);

    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void> _updateAddressFromCoordinates(double lat, double lng) async {
    setState(() {
      isLoadingAddress = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
        ),
        headers: {
          'Accept-Language': 'en',
          'User-Agent': 'LocationSelectionApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['display_name'] != null) {
          if (mounted) {
            setState(() {
              selectedAddress = data['display_name'] as String;
              isLoadingAddress = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error getting address: $e');
      if (mounted) {
        setState(() {
          selectedAddress = '$lat, $lng';
          isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5&addressdetails=1',
        ),
        headers: {
          'Accept-Language': 'en',
          'User-Agent': 'LocationSelectionApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<SearchResult> results = data.map((item) => SearchResult(
          displayName: item['display_name'] ?? '',
          lat: double.parse(item['lat'] ?? '0'),
          lng: double.parse(item['lon'] ?? '0'),
        )).toList();

        if (mounted) {
          setState(() {
            searchResults = results;
            isSearching = false;
          });
        }
      }
    } catch (e) {
      print('Error searching locations: $e');
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  Future<void> _selectSearchResult(SearchResult result) async {
    setState(() {
      selectedLat = result.lat;
      selectedLng = result.lng;
      selectedAddress = result.displayName;
      searchResults = [];
      _searchController.text = result.displayName;
      _searchFocusNode.unfocus();
    });

    await _updateLocationMarker(result.lat, result.lng);
    await _animateToLocation(result.lat, result.lng);
  }

  Future<void> _updateLocationMarker(double lat, double lng) async {
    if (mapboxMap == null || locationAnnotationManager == null || locationIconData == null) {
      return;
    }

    try {
      // Clear existing annotations
      await locationAnnotationManager!.deleteAll();

      // Create new annotation
      mapbox.PointAnnotationOptions locationOptions = mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(lng, lat),
        ),
        image: locationIconData!,
        iconSize: 1.0,
        iconAnchor: mapbox.IconAnchor.BOTTOM,
      );

      selectedAnnotation = await locationAnnotationManager!.create(locationOptions);

    } catch (e) {
      print("Error updating location marker: $e");
    }
  }

  Future<void> _animateToLocation(double lat, double lng) async {
    if (mapboxMap == null) return;

    try {
      await mapboxMap!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(lng, lat),
          ),
          zoom: 16.0,
        ),
        mapbox.MapAnimationOptions(duration: 1000),
      );
    } catch (e) {
      print("Error animating to location: $e");
    }
  }

  // Check if a tap is near the annotation
  bool _isTapNearAnnotation(mapbox.Point tapPoint) {
    if (selectedAnnotation == null || selectedLat == null || selectedLng == null) {
      return false;
    }

    // Convert coordinates to screen points for distance calculation
    // This is a simplified approach - you might want to use more precise calculations
    double annotationLat = selectedLat!;
    double annotationLng = selectedLng!;
    double tapLat = tapPoint.coordinates.lat.toDouble();
    double tapLng = tapPoint.coordinates.lng.toDouble();

    // Calculate distance in degrees (rough approximation)
    double distance = math.sqrt(
        math.pow(annotationLat - tapLat, 2) +
            math.pow(annotationLng - tapLng, 2)
    );

    // Threshold for "near" (adjust based on zoom level if needed)
    double threshold = 0.001; // Approximately 100 meters

    return distance < threshold;
  }

  void _onMapTap(mapbox.MapContentGestureContext context) async {
    if (mapboxMap == null) return;

    try {
      mapbox.Point mapPoint = context.point;

      // If we're not dragging and the tap is not near the annotation, place a new marker
      if (!isDragging && !_isTapNearAnnotation(mapPoint)) {
        mapbox.Position coordinates = mapPoint.coordinates;
        double lat = coordinates.lat.toDouble();
        double lng = coordinates.lng.toDouble();

        setState(() {
          selectedLat = lat;
          selectedLng = lng;
        });

        await _updateLocationMarker(lat, lng);
        await _updateAddressFromCoordinates(lat, lng);
      }

    } catch (e) {
      print("Error handling map tap: $e");
    }
  }

  void _onMapLongClick(mapbox.MapContentGestureContext context) async {
    if (mapboxMap == null) return;

    try {
      mapbox.Point mapPoint = context.point;

      // Check if long press is near the annotation
      if (_isTapNearAnnotation(mapPoint)) {
        setState(() {
          isDragging = true;
          isLongPressActive = true;
        });
        print("Long press on annotation - drag mode activated");
      }

    } catch (e) {
      print("Error handling map long click: $e");
    }
  }

  void _onMapDrag(mapbox.MapContentGestureContext context) async {
    if (!isDragging || selectedAnnotation == null) return;

    try {
      mapbox.Point mapPoint = context.point;
      mapbox.Position coordinates = mapPoint.coordinates;
      double lat = coordinates.lat.toDouble();
      double lng = coordinates.lng.toDouble();

      // Update the annotation position
      setState(() {
        selectedLat = lat;
        selectedLng = lng;
      });

      // Update marker position
      await _updateLocationMarker(lat, lng);

    } catch (e) {
      print("Error handling map drag: $e");
    }
  }

  void _onMapDragEnd(mapbox.MapContentGestureContext context) async {
    if (!isDragging) return;

    setState(() {
      isDragging = false;
      isLongPressActive = false;
    });

    // Update address after drag ends
    if (selectedLat != null && selectedLng != null) {
      await _updateAddressFromCoordinates(selectedLat!, selectedLng!);
    }

    print("Drag ended");
  }

  // Handle annotation click
  void _onAnnotationClick(mapbox.PointAnnotation annotation) {
    print("Annotation clicked - you can long press to drag");
    // You can show a tooltip or hint here
  }

  void _confirmSelection() {
    if (selectedLat != null && selectedLng != null && widget.onLocationSelected != null) {
      widget.onLocationSelected!(selectedLat!, selectedLng!, selectedAddress);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Select Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.location_on, color: Colors.blue, size: 24),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search manually',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: (value) {
                          _searchLocations(value);
                        },
                      ),
                    ),
                    if (isSearching)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.blue),
                        onPressed: () {
                          if (_searchController.text.isNotEmpty) {
                            _searchLocations(_searchController.text);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Drag instruction (show when dragging)
            if (isDragging)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Drag the marker to adjust location',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Search Results
            if (searchResults.isNotEmpty)
              Container(
                height: 200,
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final result = searchResults[index];
                    return ListTile(
                      leading: Icon(Icons.location_on, color: Colors.grey),
                      title: Text(
                        result.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () => _selectSearchResult(result),
                    );
                  },
                ),
              ),

            // Map
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: mapbox.MapWidget(
                    cameraOptions: mapbox.CameraOptions(
                      center: mapbox.Point(
                        coordinates: mapbox.Position(
                          selectedLng ?? 76.5274,
                          selectedLat ?? 31.7084,
                        ),
                      ),
                      zoom: 16.0,
                    ),
                    styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
                    onMapCreated: _onMapCreated,
                    onTapListener: _onMapTap,
                    onLongTapListener: _onMapLongClick,
                    onScrollListener: isDragging ? _onMapDrag : null,
                  ),
                ),
              ),
            ),

            // Bottom Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'your cart will be delivered to',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: isLoadingAddress
                            ? Text(
                          'Loading address...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                            : Text(
                          selectedAddress.isNotEmpty
                              ? selectedAddress
                              : 'Select a location',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Show instruction dialog
                          _showInstructionDialog();
                        },
                        child: Text(
                          'Help',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedLat != null && selectedLng != null
                          ? _confirmSelection
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Add details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMapCreated(mapbox.MapboxMap mapboxMap) async {
    print('Map created successfully');
    this.mapboxMap = mapboxMap;

    try {
      String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
      mapbox.MapboxOptions.setAccessToken(ACCESS_TOKEN);

      await mapboxMap.gestures.updateSettings(
        mapbox.GesturesSettings(
          rotateEnabled: true,
          pinchToZoomEnabled: true,
          scrollEnabled: true,
          doubleTapToZoomInEnabled: true,
          doubleTouchToZoomOutEnabled: true,
          quickZoomEnabled: true,
          pitchEnabled: false,
        ),
      );

      locationAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();

      // Set up click listener
      // locationAnnotationManager!.addOnPointAnnotationClickListener(
      //   mapbox.OnPointAnnotationClickListener(
      //     onPointAnnotationClick: (annotation) {
      //       _onAnnotationClick(annotation);
      //       return true;
      //     },
      //   ),
      // );

      // // Set up gesture listeners for drag functionality
      // await mapboxMap.gestures.OnMapLongTapListener(
      //   mapbox.OnMapLongClickListener(
      //     onMapLongClick: (point) {
      //       _onMapLongClick(mapbox.MapContentGestureContext(point: point));
      //       return true;
      //     },
      //   ),
      // );

      // await mapboxMap.gestures.addOnMoveListener(
      //   // mapbox.OnMapScrollListener(
      //   //   onMove: (detector) {
      //   //     if (isDragging) {
      //   //       // Get the center point during drag
      //   //       mapboxMap.getCameraState().then((cameraState) {
      //   //         if (cameraState.center != null) {
      //   //           _onMapDrag(mapbox.MapContentGestureContext(point: cameraState.center!, touchPosition: null, gestureState: null));
      //   //         }
      //   //       });
      //   //     }
      //   //   },
      //   //   onMoveEnd: (detector) {
      //   //     if (isDragging) {
      //   //       mapboxMap.getCameraState().then((cameraState) {
      //   //         if (cameraState.center != null) {
      //   //           _onMapDragEnd(mapbox.MapContentGestureContext(point: cameraState.center!, touchPosition: null, gestureState: null));
      //   //         }
      //   //       });
      //   //     }
      //   //   },
      //   // ),
      // // );

      if (mounted) {
        setState(() {
          mapInitialized = true;
        });
      }

      // If we have user position, update the marker
      if (selectedLat != null && selectedLng != null) {
        await _updateLocationMarker(selectedLat!, selectedLng!);
      }

    } catch (e) {
      print("Error in map creation: $e");
    }
  }

  void _showInstructionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("How to use"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• Tap anywhere on the map to place a marker"),
            SizedBox(height: 8),
            Text("• Long press on the marker to activate drag mode"),
            SizedBox(height: 8),
            Text("• Drag the map to move the marker when in drag mode"),
            SizedBox(height: 8),
            Text("• Release to confirm the new location"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got it"),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Required"),
        content: Text("This app needs location permission to show your current location."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestLocationPermission();
            },
            child: Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Denied"),
        content: Text("Please enable location permission in app settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Services Disabled"),
        content: Text("Please enable location services in your device settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}

extension on mapbox.GesturesSettingsInterface {
  addOnMoveListener(onMoveListener) {}
}

class SearchResult {
  final String displayName;
  final double lat;
  final double lng;

  SearchResult({
    required this.displayName,
    required this.lat,
    required this.lng,
  });
}