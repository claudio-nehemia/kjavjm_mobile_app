import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    if (kIsWeb) {
      // For web, always return true (browser will handle permission)
      return true;
    }
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission
  Future<LocationPermission> checkPermission() async {
    if (kIsWeb) {
      // For web, return whileInUse (browser handles permission differently)
      return LocationPermission.whileInUse;
    }
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    if (kIsWeb) {
      // For web, return whileInUse
      return LocationPermission.whileInUse;
    }
    return await Geolocator.requestPermission();
  }

  /// Get current location with permission handling
  Future<Position?> getCurrentLocation() async {
    if (kIsWeb) {
      // For web, try to get position with simpler error handling
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Location request timeout. Please enable location in your browser.');
          },
        );
      } catch (e) {
        throw Exception('Location not available on web: $e');
      }
    }
    
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get address from coordinates
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    if (kIsWeb) {
      // Untuk web, gunakan Nominatim OpenStreetMap API (free reverse geocoding)
      return await _getAddressFromApiWeb(latitude, longitude);
    }
    
    // Untuk mobile, gunakan geocoding plugin
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build address string
        List<String> addressParts = [];
        
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        return addressParts.join(', ');
      }
      
      return 'Unknown location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Lat: $latitude, Long: $longitude';
    }
  }

  /// Get address from API for web platform
  /// Uses Nominatim OpenStreetMap (free, no API key needed)
  Future<String> _getAddressFromApiWeb(double latitude, double longitude) async {
    try {
      // Import Dio jika belum
      final dio = await _getDioInstance();
      
      // Call Nominatim reverse geocoding API
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': latitude,
          'lon': longitude,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'KJAVJM-Mobile-App', // Required by Nominatim
          },
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Build address from response
        final address = data['address'];
        List<String> addressParts = [];
        
        if (address != null) {
          // Add road/street
          if (address['road'] != null) {
            addressParts.add(address['road']);
          }
          
          // Add suburb/neighbourhood
          if (address['suburb'] != null) {
            addressParts.add(address['suburb']);
          } else if (address['neighbourhood'] != null) {
            addressParts.add(address['neighbourhood']);
          }
          
          // Add city/town/village
          if (address['city'] != null) {
            addressParts.add(address['city']);
          } else if (address['town'] != null) {
            addressParts.add(address['town']);
          } else if (address['village'] != null) {
            addressParts.add(address['village']);
          }
          
          // Add state/province
          if (address['state'] != null) {
            addressParts.add(address['state']);
          }
          
          // Add country
          if (address['country'] != null) {
            addressParts.add(address['country']);
          }
          
          if (addressParts.isNotEmpty) {
            return addressParts.join(', ');
          }
        }
        
        // Fallback to display_name
        if (data['display_name'] != null) {
          return data['display_name'];
        }
      }
      
      // Fallback to coordinates
      return 'Lat: ${latitude.toStringAsFixed(6)}, Long: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      print('❌ Error getting address from API: $e');
      // Fallback to coordinates
      return 'Lat: ${latitude.toStringAsFixed(6)}, Long: ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Get Dio instance for HTTP calls
  Future<Dio> _getDioInstance() async {
    // Simple Dio instance untuk reverse geocoding
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  /// Get location with address
  Future<Map<String, dynamic>> getLocationWithAddress() async {
    Position? position = await getCurrentLocation();
    
    if (position == null) {
      throw Exception('Failed to get current location');
    }

    String address = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
      'location': address,
    };
  }
}
