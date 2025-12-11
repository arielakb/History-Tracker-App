import 'package:geocoding/geocoding.dart';

class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();

  factory GeocodingService() {
    return _instance;
  }

  GeocodingService._internal();

  // Convert coordinates to address
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];

        // Build address from placemark
        final addressParts = <String>[];

        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }
        if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
          addressParts.add(placemark.postalCode!);
        }

        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        }
      }

      return null;
    } catch (e) {
      print('Error converting coordinates to address: $e');
      return null;
    }
  }

  // Convert address to coordinates (if needed in future)
  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      return locations.isNotEmpty ? locations : null;
    } catch (e) {
      print('Error converting address to coordinates: $e');
      return null;
    }
  }
}
