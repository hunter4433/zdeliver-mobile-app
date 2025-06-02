import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  Future<void> _checkLogin() async {
    String? userId = await _storage.read(key: 'userId');
    var latLngAddress = await getLatLngAddress();
    Position? position = latLngAddress?['postion'];
    String? address = latLngAddress?['address'];
    if (userId != null && userId.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePageWithMap(position: position, address: address),
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
