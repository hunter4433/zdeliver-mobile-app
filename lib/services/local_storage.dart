import 'dart:convert';

import 'package:Zdeliver/address_model.dart';
import 'package:Zdeliver/coordinate_class.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  FlutterSecureStorage storage = FlutterSecureStorage();

  // get user_id
  Future<String?> getUserId() async {
    final String? userId = await storage.read(key: 'userId');

    return userId; // Return the stored user ID
  }

  // Save User ID
  Future<void> saveUserId(String userId) async {
    await storage.write(key: 'userId', value: userId);
  }

  // get user_name
  Future<String?> getUserName() async {
    final String? userName = await storage.read(key: 'user_name');
    return userName; // Return the stored user name
  }

  // Save User Name
  Future<void> saveUserName(String userName) async {
    await storage.write(key: 'user_name', value: userName);
  }

  // save gender
  Future<void> saveUserGender(String gender) async {
    await storage.write(key: 'gender', value: gender);
  }

  // get user gender
  Future<String?> getUserGender() async {
    final String? userGender = await storage.read(key: 'gender');
    return userGender; // Return the stored user gender
  }

  // save user phone number
  Future<void> saveUserPhoneNumber(String phoneNumber) async {
    await storage.write(key: 'phone_number', value: phoneNumber);
  }

  // get user phone number
  Future<String?> getUserPhoneNumber() async {
    final String? userPhoneNumber = await storage.read(key: 'phone_number');
    return userPhoneNumber; // Return the stored user phone number
  }

  // Get User Postion Locally
  Future<CoordinatesPair?> getUserPositionLocally() async {
    final String? userPosition = await storage.read(key: 'user_position');
    if (userPosition == null) {
      return null; // No position stored, return null
    }
    final List<String> latLng = userPosition.split(',');
    if (latLng.length != 2) {
      return null; // Invalid format, return null
    }
    final double latitude = double.tryParse(latLng[0]) ?? 0.0;
    final double longitude = double.tryParse(latLng[1]) ?? 0.0;
    final address = await storage.read(key: 'user_address');
    return CoordinatesPair(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  // Get User Address Locally
  Future<String?> getUserAddressLocally() async {
    final String? userAddress = await storage.read(key: 'user_address');
    if (userAddress == null) {
      return null; // No address stored, return null
    }
    return userAddress; // Return the stored address
  }

  // Save User Position Locally
  Future<void> saveUserPositionLocally(
    double latitude,
    double longitude,
    String? address,
  ) async {
    final String userPosition = '$latitude,$longitude';
    await storage.write(key: 'user_position', value: userPosition);
    await storage.write(key: 'user_address', value: address);
  }

  // Save User Address Locally
  Future<void> saveUserAddressLocally(String address) async {
    await storage.write(key: 'user_address', value: address);
  }

  // save user cuurent selected address
  Future<void> saveUserSelectedAddress(Address address) async {
    await storage.write(
      key: 'user_selected_address',
      value: address.toJsonString(),
    );
  }

  // get user current selected address
  Future<Address?> getUserSelectedAddress() async {
    final String? userSelectedAddress = await storage.read(
      key: 'user_selected_address',
    );
    if (userSelectedAddress == null) {
      return null; // No address stored, return null
    }
    return Address.fromJsonString(userSelectedAddress);
  }
}
