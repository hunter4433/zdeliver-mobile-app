import 'dart:convert';

import 'package:Zdeliver/coordinate_class.dart';
import 'package:Zdeliver/services/local_storage.dart';
import 'package:Zdeliver/profilesetup.dart';
import 'package:Zdeliver/services/userlocation_service.dart';

import 'package:Zdeliver/services/warehouse_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:Zdeliver/auth_page.dart';
import 'package:Zdeliver/gohome.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();
  bool _isWareHouseAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  //check if any new update is available
  Future checkforUpdates() async {
    print('-------- checking for updates --------');

    final String baseUrl = 'http://13.126.169.224/api/v1/version/check';
    try {
      final response = await http.post(
        Uri.parse(baseUrl), // Adjust the endpoint to match your backend route
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // get latest version
        final latestVersion = data['data']['latest_version'];
        final updateUrl = data['data']['update_url'];
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        print('Current Version: $currentVersion');

        final bool forceUpdate = data['data']['force_update'];
        if (latestVersion != currentVersion) {
          return {
            'isUpdateAvailable': true,
            'latestVersion': latestVersion,
            'updateUrl': updateUrl,
            'forceUpdate': forceUpdate,
          };
        }
        return null; // No update available
      } else {
        // Parse error message from response if available
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to check for updates');
      }
    } catch (e) {
      print('Failed to check for updates: $e');
    }
  }

  // check if user is logged in and navigate accordingly
  Future<void> _checkLogin() async {
    String? userId = await LocalStorage().getUserId();

    if (userId == null || userId.isEmpty) {
      // User is not logged in, navigate to AuthPage
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    // Check for updates first
    var updateInfo = await checkforUpdates();
    if (updateInfo != null) {
      String latestVersion = updateInfo['latestVersion'];
      String updateUrl = updateInfo['updateUrl'];

      // Show update dialog and wait for user action
      bool shouldUpdate =
          await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: Text('Update Available'),
                  content: Text(
                    'A new version ($latestVersion) is available. Please update the app for the best experience.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Continue
                      },
                      child: Text('Continue'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(true); // Update
                      },
                      child: Text('Update'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (shouldUpdate) {
        // Open Play Store URL
        if (await canLaunchUrl(Uri.parse(updateUrl))) {
          await launchUrl(
            Uri.parse(updateUrl),
            mode: LaunchMode.externalApplication,
          );
        }
        return; // Exit the splash screen after update
      }
    }

    CoordinatesPair? userPosition =
        await LocalStorage().getUserPositionLocally();

    if(userPosition == null) {
      // No user position stored, get current location
      userPosition = await UserLocationService().getCurrentLocation(context);
      if (userPosition == null) {
        // If still null, show error and exit
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location, please enable location services.')),
        );
        return;
      }
      String address =
          await UserLocationService().getAddressFromCoordinates(
            userPosition.latitude,
            userPosition.longitude,
            context,
          ) ?? 'Unknown Address';
          userPosition.address = address;
      // Save the user position locally
      await LocalStorage().saveUserPositionLocally(
        userPosition.latitude,
        userPosition.longitude,
        address,
        
      );
    }


    Warehouse? wareHousePosition =
        await WarehouseService().getWareHouse(userPosition.latitude,userPosition.longitude, context);
    

    // check profile completion
    String? username = await  LocalStorage().getUserName();

    if (username == null || username.isEmpty) {
      // User profile is not complete, navigate to AuthPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => ProfileSetupPage(userPoistion: userPosition, 
              warehousePosition: wareHousePosition
              ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => HomePageWithMap(
              userPosition: userPosition,
              
              warehousePosition: wareHousePosition,
              
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
