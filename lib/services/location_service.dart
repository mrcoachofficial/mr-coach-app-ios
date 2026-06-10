import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mrcoach/services/api_service.dart';

class LocationDetails {
  final double latitude;
  final double longitude;
  final String area;
  final String district;
  final String state;
  final String pincode;
  final String country;
  final String formattedAddress;

  LocationDetails({
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.district,
    required this.state,
    required this.pincode,
    required this.country,
    required this.formattedAddress,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'area': area,
    'district': district,
    'state': state,
    'pincode': pincode,
    'country': country,
    'formattedAddress': formattedAddress,
  };

  factory LocationDetails.fromJson(Map<String, dynamic> json) => LocationDetails(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    area: json['area'] ?? '',
    district: json['district'] ?? '',
    state: json['state'] ?? '',
    pincode: json['pincode'] ?? '',
    country: json['country'] ?? '',
    formattedAddress: json['formattedAddress'] ?? '',
  );
}

class LocationService {
  static const String _cacheKey = 'cached_location_details';

  // Request location permission using permission_handler
  static Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) return true;
    
    // Fallback check through geolocator
    final geoPermission = await Geolocator.checkPermission();
    if (geoPermission == LocationPermission.always || geoPermission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }

  // Get current position (GPS)
  static Future<Position?> getCurrentPosition() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Check last known position first (instant lookup from OS cache) - only on native mobile
      if (!kIsWeb) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return lastKnown;
        }
      }

      // Fallback to low-accuracy request to get a fast satellite/network lock
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 4),
      );
    } catch (e) {
      print('Error getting GPS coordinates: $e');
      return null;
    }
  }

  // Reverse geocoding using OpenStreetMap Nominatim API
  static Future<LocationDetails?> reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
      final response = await http.get(url, headers: {
        'User-Agent': 'MrCoachFlutterApp/1.0', // Nominatim requests/requires a valid User-Agent
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final area = address['suburb'] ?? address['neighbourhood'] ?? address['village'] ?? address['subdivision'] ?? address['area'] ?? '';
        final district = address['city'] ?? address['town'] ?? address['city_district'] ?? address['district'] ?? '';
        final state = address['state'] ?? '';
        final pincode = address['postcode'] ?? '';
        final country = address['country'] ?? '';
        
        final displayName = data['display_name'] ?? '';

        // Generate friendly "Area, City" format
        String friendlyLabel = '';
        if (area.toString().isNotEmpty) {
          friendlyLabel = area.toString();
        }
        if (district.toString().isNotEmpty) {
          if (friendlyLabel.isNotEmpty) {
            friendlyLabel += ', ${district.toString()}';
          } else {
            friendlyLabel = district.toString();
          }
        }

        if (friendlyLabel.isEmpty) {
          friendlyLabel = displayName.toString().split(',').take(2).join(', ');
        }

        return LocationDetails(
          latitude: lat,
          longitude: lon,
          area: area.toString(),
          district: district.toString(),
          state: state.toString(),
          pincode: pincode.toString(),
          country: country.toString(),
          formattedAddress: friendlyLabel,
        );
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
    }
    return null;
  }

  // Search locations using OpenStreetMap Nominatim Search API
  static Future<List<LocationDetails>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5');
      final response = await http.get(url, headers: {
        'User-Agent': 'MrCoachFlutterApp/1.0',
      });

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) {
          final address = item['address'] as Map<String, dynamic>? ?? {};
          final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;

          final area = address['suburb'] ?? address['neighbourhood'] ?? address['village'] ?? address['subdivision'] ?? address['area'] ?? '';
          final district = address['city'] ?? address['town'] ?? address['city_district'] ?? address['district'] ?? '';
          final state = address['state'] ?? '';
          final pincode = address['postcode'] ?? '';
          final country = address['country'] ?? '';
          final displayName = item['display_name'] ?? '';

          String friendlyLabel = '';
          if (area.toString().isNotEmpty) {
            friendlyLabel = area.toString();
          }
          if (district.toString().isNotEmpty) {
            if (friendlyLabel.isNotEmpty) {
              friendlyLabel += ', ${district.toString()}';
            } else {
              friendlyLabel = district.toString();
            }
          }

          if (friendlyLabel.isEmpty) {
            friendlyLabel = displayName.toString().split(',').take(2).join(', ');
          }

          return LocationDetails(
            latitude: lat,
            longitude: lon,
            area: area.toString(),
            district: district.toString(),
            state: state.toString(),
            pincode: pincode.toString(),
            country: country.toString(),
            formattedAddress: friendlyLabel,
          );
        }).toList();
      }
    } catch (e) {
      print('Error searching locations: $e');
    }
    return [];
  }

  // Cache location details locally
  static Future<void> cacheLocation(LocationDetails details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(details.toJson()));
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  // Retrieve locally cached location details
  static Future<LocationDetails?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_cacheKey);
      if (str != null) {
        return LocationDetails.fromJson(jsonDecode(str));
      }
    } catch (e) {
      print('Error getting cached location: $e');
    }
    return null;
  }

  // Sync location with backend
  static Future<bool> syncLocationWithBackend(LocationDetails details) async {
    try {
      return await ApiService.updateLocation({
        'latitude': details.latitude,
        'longitude': details.longitude,
        'area': details.area,
        'district': details.district,
        'state': details.state,
        'pincode': details.pincode,
        'country': details.country,
      });
    } catch (e) {
      print('Error syncing location: $e');
      return false;
    }
  }
}
