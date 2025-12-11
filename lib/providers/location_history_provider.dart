import 'package:flutter/material.dart';
import '../models/location_entry.dart';
import '../services/location_service.dart';
import 'package:intl/intl.dart';

class LocationHistoryProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  List<LocationEntry> _allLocations = [];
  List<LocationEntry> _filteredLocations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  DateTime? _selectedDate;
  int? _selectedDayOfWeek;
  String _searchQuery = '';

  // Getters
  List<LocationEntry> get allLocations => _allLocations;
  List<LocationEntry> get filteredLocations => _filteredLocations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;
  int? get selectedDayOfWeek => _selectedDayOfWeek;
  String get searchQuery => _searchQuery;

  LocationHistoryProvider() {
    loadAllLocations();
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final hasPermission = await _locationService.requestLocationPermissions();
      if (hasPermission) {
        _errorMessage = null;
      } else {
        _errorMessage =
            'Location permission denied. Please enable it in Settings.';
      }
      notifyListeners();
      return hasPermission;
    } catch (e) {
      _errorMessage = 'Error requesting permission: $e';
      print(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllLocations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allLocations = await _locationService.getAllLocations();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error loading locations: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get current location and save it
  Future<bool> captureCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final location = await _locationService.getCurrentLocation();

      if (location != null) {
        await _locationService.saveLocation(location);
        await loadAllLocations();
        return true;
      } else {
        _errorMessage = 'Failed to get current location';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error capturing location: $e';
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter by date
  void filterByDate(DateTime? date) {
    _selectedDate = date;
    _selectedDayOfWeek = null;
    _applyFilters();
    notifyListeners();
  }

  // Filter by day of week
  void filterByDayOfWeek(int? dayOfWeek) {
    _selectedDayOfWeek = dayOfWeek;
    _selectedDate = null;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedDate = null;
    _selectedDayOfWeek = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Search by query
  void searchLocations(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters logic
  void _applyFilters() {
    _filteredLocations = _allLocations;

    // Filter by date
    if (_selectedDate != null) {
      final selectedDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
      _filteredLocations = _filteredLocations.where((location) {
        final locationDate = DateTime(
          location.timestamp.year,
          location.timestamp.month,
          location.timestamp.day,
        );
        return locationDate.isAtSameMomentAs(selectedDate);
      }).toList();
    }

    // Filter by day of week
    if (_selectedDayOfWeek != null) {
      _filteredLocations = _filteredLocations
          .where((location) => location.timestamp.weekday == _selectedDayOfWeek)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      _filteredLocations = _filteredLocations.where((location) {
        final dateStr = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(location.timestamp);
        final coordStr =
            '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
        final addressStr = location.address ?? '';

        return dateStr.contains(_searchQuery) ||
            coordStr.contains(_searchQuery) ||
            addressStr.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // Delete a location
  Future<bool> deleteLocation(String id) async {
    try {
      final success = await _locationService.deleteLocation(id);
      if (success) {
        await loadAllLocations();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error deleting location: $e';
      print(_errorMessage);
      return false;
    }
  }

  // Delete all locations
  Future<bool> deleteAllLocations() async {
    try {
      final success = await _locationService.deleteAllLocations();
      if (success) {
        await loadAllLocations();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error deleting all locations: $e';
      print(_errorMessage);
      return false;
    }
  }

  // Get formatted date string
  String getFormattedDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy').format(date);
  }

  // Get day of week name
  String getDayOfWeekName(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return days[dayOfWeek - 1];
    }
    return 'Unknown';
  }
}
