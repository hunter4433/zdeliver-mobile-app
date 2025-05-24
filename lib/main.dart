import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show rootBundle;
import 'package:mrsgorilla/auth_page.dart';
// Add Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mrsgorilla/api/firebase.dart';
import 'firebase_options.dart';
// Add location permission imports
import 'package:geolocator/geolocator.dart';

import 'gohome.dart';

// Global navigator key for use in notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Handler for background messages (must be a top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase here if needed when app is terminated
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
  print('Background message data: ${message.data}');
  print('Background message notification: ${message.notification?.title}');
}

// Function to request location permission
Future<void> requestLocationPermission() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      // You might want to show a dialog explaining why location is needed
      // and direct users to app settings
    } else if (permission == LocationPermission.denied) {
      print('Location permissions denied');
    } else {
      print('Location permission granted: $permission');
    }
  } catch (e) {
    print('Error requesting location permission: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Register background handler before initializing Firebase
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize notification service
    await NotificationService().initialize();

    // Request location permission after notification setup
    await requestLocationPermission();

    // Other initializations...
    String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
    mapbox.MapboxOptions.setAccessToken(ACCESS_TOKEN);

  } catch (e) {
    print("Error during initialization: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mrs.Gorilla',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Used for navigation from notifications
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
       home: LoginScreen(),
      //   home:  HomePageWithMap(),

    );
  }
}