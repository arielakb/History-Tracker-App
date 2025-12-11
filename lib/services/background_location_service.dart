import 'package:workmanager/workmanager.dart';
import 'location_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('Tugas pelacakan lokasi latar belakang dimulai: $task');

      final locationService = LocationService();
      final notificationService = NotificationService();

      // Dapatkan lokasi saat ini
      final location = await locationService.getCurrentLocation();

      if (location != null) {
        // Simpan ke database
        await locationService.saveLocation(location);
        print('Lokasi disimpan: ${location.latitude}, ${location.longitude}');

        // Tampilkan notifikasi
        await notificationService.showLocationCapturedNotification(
          latitude: location.latitude.toString(),
          longitude: location.longitude.toString(),
          address: location.address ?? 'Lokasi Tidak Diketahui',
        );
      }

      return true;
    } catch (e) {
      print('Kesalahan dalam tugas latar belakang: $e');
      return false;
    }
  });
}

class BackgroundLocationService {
  static final BackgroundLocationService _instance =
      BackgroundLocationService._internal();

  factory BackgroundLocationService() {
    return _instance;
  }

  BackgroundLocationService._internal();

  /// Inisialisasi pelacakan lokasi latar belakang
  Future<void> initializeBackgroundLocationTracking() async {
    try {
      final notificationService = NotificationService();

      // Inisialisasi notifikasi
      await notificationService.initializeNotifications();

      // Inisialisasi WorkManager
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

      // Daftar tugas periodik - berjalan sekali sehari (minimum 15 menit di Android)
      await Workmanager().registerPeriodicTask(
        'location_tracking_task',
        'trackLocation',
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(minutes: 15),
      );

      // Tampilkan notifikasi bahwa pelacakan aktif
      await notificationService.showBackgroundTrackingActiveNotification();

      print('Pelacakan lokasi latar belakang diinisialisasi');
    } catch (e) {
      print('Kesalahan menginisialisasi pelacakan lokasi latar belakang: $e');
    }
  }

  /// Batalkan pelacakan lokasi latar belakang
  Future<void> cancelBackgroundLocationTracking() async {
    try {
      final notificationService = NotificationService();

      // Batalkan tugas WorkManager
      await Workmanager().cancelByTag('location_tracking_task');

      // Batalkan notifikasi
      await notificationService.cancelNotification(2);

      print('Pelacakan lokasi latar belakang dibatalkan');
    } catch (e) {
      print('Kesalahan membatalkan pelacakan lokasi latar belakang: $e');
    }
  }

  // Register a one-time location tracking task
  Future<void> registerOneTimeLocationTracking() async {
    try {
      await Workmanager().registerOneOffTask(
        'location_tracking_one_time',
        'trackLocationOneTime',
        initialDelay: const Duration(minutes: 1),
      );

      print('One-time location tracking task registered');
    } catch (e) {
      print('Error registering one-time location tracking: $e');
    }
  }
}
