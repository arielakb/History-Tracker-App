import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola preferensi pengguna dan penyimpanan lokal
class PreferenceService {
  static const String _permissionRequestedKey = 'location_permission_requested';

  /// Cek apakah izin lokasi sudah diminta sebelumnya
  static Future<bool> hasPermissionBeenRequested() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_permissionRequestedKey) ?? false;
    } catch (e) {
      print('Error checking permission requested: $e');
      return false;
    }
  }

  /// Tandai bahwa izin lokasi sudah diminta
  static Future<void> markPermissionAsRequested() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_permissionRequestedKey, true);
    } catch (e) {
      print('Error marking permission as requested: $e');
    }
  }

  /// Reset flag izin (untuk testing)
  static Future<void> resetPermissionFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_permissionRequestedKey);
    } catch (e) {
      print('Error resetting permission flag: $e');
    }
  }

  /// Hapus semua preferensi
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing preferences: $e');
    }
  }
}
