import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../models/location_entry.dart';
import '../database/database_helper.dart';
import 'geocoding_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final GeocodingService _geocodingService = GeocodingService();
  final uuid = const Uuid();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  // Request location permissions
  Future<bool> requestLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Get current location
  Future<LocationEntry?> getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Check if location service is enabled
      bool isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Create location entry
      final locationEntry = LocationEntry(
        id: uuid.v4(),
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: position.accuracy.toString(),
      );

      // Try to get address if available
      try {
        final address = await _geocodingService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        return locationEntry.copyWith(address: address);
      } catch (e) {
        // If geocoding fails, return without address
        return locationEntry;
      }
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Save location to database
  Future<bool> saveLocation(LocationEntry location) async {
    try {
      await _databaseHelper.insertLocationEntry(location);
      return true;
    } catch (e) {
      print('Error saving location: $e');
      return false;
    }
  }

  // Get all locations
  Future<List<LocationEntry>> getAllLocations() async {
    try {
      return await _databaseHelper.getAllLocationEntries();
    } catch (e) {
      print('Error getting all locations: $e');
      return [];
    }
  }

  // Get locations by date
  Future<List<LocationEntry>> getLocationsByDate(DateTime date) async {
    try {
      return await _databaseHelper.getLocationEntriesByDate(date);
    } catch (e) {
      print('Error getting locations by date: $e');
      return [];
    }
  }

  // Get locations by day of week
  Future<List<LocationEntry>> getLocationsByDayOfWeek(int dayOfWeek) async {
    try {
      return await _databaseHelper.getLocationEntriesByDayOfWeek(dayOfWeek);
    } catch (e) {
      print('Error getting locations by day of week: $e');
      return [];
    }
  }

  // Get locations in date range
  Future<List<LocationEntry>> getLocationsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _databaseHelper.getLocationEntriesInRange(
        startDate,
        endDate,
      );
    } catch (e) {
      print('Error getting locations in range: $e');
      return [];
    }
  }

  // Delete a location
  Future<bool> deleteLocation(String id) async {
    try {
      await _databaseHelper.deleteLocationEntry(id);
      return true;
    } catch (e) {
      print('Error deleting location: $e');
      return false;
    }
  }

  // Delete all locations
  Future<bool> deleteAllLocations() async {
    try {
      await _databaseHelper.deleteAllLocationEntries();
      return true;
    } catch (e) {
      print('Error deleting all locations: $e');
      return false;
    }
  }

  // Update location with address
  Future<bool> updateLocationAddress(String id, String address) async {
    try {
      final allLocations = await _databaseHelper.getAllLocationEntries();
      final location = allLocations.firstWhere((loc) => loc.id == id);
      await _databaseHelper.updateLocationEntry(
        location.copyWith(address: address),
      );
      return true;
    } catch (e) {
      print('Error updating location address: $e');
      return false;
    }
  }
}
