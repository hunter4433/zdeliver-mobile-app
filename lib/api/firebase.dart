// In services/notification_service.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart'; // Import to use navigatorKey
import 'package:mrsgorilla/menu/notifications.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final storage = FlutterSecureStorage();
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Define notification channel for Android
  final androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.max,  // Use max instead of high
    enableLights: true,
    enableVibration: true,
    playSound: true,
  );

  // Initialize the notification service
  Future<void> initialize() async {
    try {
      await _requestPermissions();
      await _setupToken();
      await initLocalNotifications();
      await initPushNotifications();
      print('mohit here');
      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
      FirebaseCrashlytics.instance.recordError(
          e,
          StackTrace.current,
          reason: 'Error initializing notification service'
      );
    }
  }


  // Add this to your NotificationService class
  Future<void> showTestNotification() async {
    _localNotifications.show(
      99,
      'Test Notification',
      'This is a test notification',
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    print('Test notification triggered');
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('Notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('Error requesting notification permissions: $e');
      FirebaseCrashlytics.instance.recordError(
          e,
          StackTrace.current,
          reason: 'Error requesting notification permissions'
      );
    }
  }

  // Setup FCM token and store it
  Future<void> _setupToken() async {
    try {
      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
        storage.write(key: 'fcmToken', value: fcmToken);
        print('new fcm token');
        print('FCM Token refreshed: $fcmToken');
        // You may want to send the refreshed token to your server
        // sendTokenToServer(fcmToken);
      });

      // Get the current token
      await FirebaseMessaging.instance.deleteToken();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('New FCM token: $fcmToken');
      // final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print('kundu is ');
        print('FCM Token: $fcmToken');
        await storage.write(key: 'fcmToken', value: fcmToken);
        // Send the token to your server
        // await sendTokenToServer(fcmToken);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
      FirebaseCrashlytics.instance.recordError(
          e,
          StackTrace.current,
          reason: 'Error getting FCM token'
      );
    }
  }

  // Initialize local notifications
  Future<void> initLocalNotifications() async {
    // iOS settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Android settings
    // const androidSettings = AndroidInitializationSettings('@drawable/android_logo');
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combined settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    // Initialize
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print(response.payload);
        if (response.payload != null) {
          try {
            final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
            handleMessage(message);
          } catch (e) {
            print('Error processing notification payload: $e');
          }
        }
      },
    );

    // Create notification channel for Android
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  // Initialize push notifications
  Future<void> initPushNotifications() async {
    // Set foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle initial message (app opened from terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('App opened from terminated state with message: ${message.messageId}');
        handleMessage(message);
      }
    });

    // Listen for messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('App opened from background state with message: ${message.messageId}');
      handleMessage(message);
    });

    // Handle foreground messages
    // In your NotificationService class
    // In your NotificationService class
    FirebaseMessaging.onMessage.listen((message) {
      print('FCM DEBUG: Message received in foreground');
      print('FCM DEBUG: Message ID: ${message.messageId}');
      print('FCM DEBUG: Message data: ${message.data}');
      print('FCM DEBUG: Has notification? ${message.notification != null}');
      if (message.notification != null) {
        print('FCM DEBUG: Notification title: ${message.notification!.title}');
        print('FCM DEBUG: Notification body: ${message.notification!.body}');
      }
      _showForegroundNotification(message);
    });
  }

  // Show foreground notification
  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    print(notification);
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android:AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          icon: '@mipmap/ic_launcher', // Updated icon reference
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
  }

  // Handle message and navigate to appropriate screen
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    try {
      Map<String, dynamic> data = message.data;
      String? notificationTitle = message.notification?.title;
      String? notificationBody = message.notification?.body;
      String? messageType = data['type'];

      print('Handling message of type: $messageType');
      print('Notification title: $notificationTitle');
      print('Notification body: $notificationBody');

      // Make sure the navigator key is available and context is ready
      if (navigatorKey.currentState == null) {
        print('Navigator key is not available yet');
        return;
      }

      // Navigate based on notification type
      switch (messageType) {
        case 'artist':
        case 'user':
        case 'app':
        case 'vendor':
        default:
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => NotificationsScreen(),
            ),
          );
          break;
      }
    } catch (e) {
      print('Error handling message: $e');
      FirebaseCrashlytics.instance.recordError(
          e,
          StackTrace.current,
          reason: 'Error handling push notification message'
      );
    }
  }

  // Send FCM token to server
  Future<void> sendTokenToServer(String token) async {
    try {
      const String url = 'https://your-api-endpoint.com/fcm-token';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'token': token,
          // Add additional user information if needed
          // 'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('Token successfully sent to server');
      } else {
        print('Failed to send token to server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token to server: $e');
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }
}