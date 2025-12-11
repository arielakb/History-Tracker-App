import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service untuk mengelola notifikasi lokal
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  /// Inisialisasi notifikasi
  Future<void> initializeNotifications() async {
    try {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Buat notifikasi channel untuk Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'location_tracking_channel',
        'Pelacakan Lokasi',
        description: 'Notifikasi untuk pelacakan lokasi latar belakang',
        importance: Importance.low,
        enableVibration: false,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      print('Notifikasi diinisialisasi');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// Tampilkan notifikasi saat lokasi dicatat
  Future<void> showLocationCapturedNotification({
    required String latitude,
    required String longitude,
    required String address,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'location_tracking_channel',
            'Pelacakan Lokasi',
            channelDescription:
                'Notifikasi untuk pelacakan lokasi latar belakang',
            importance: Importance.low,
            priority: Priority.low,
            showProgress: false,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        1,
        'Lokasi Dicatat',
        'Lokasi: $address\nKoordinat: $latitude, $longitude',
        platformChannelSpecifics,
        payload: 'location_data',
      );

      print('Notifikasi lokasi ditampilkan');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  /// Tampilkan notifikasi background tracking aktif
  Future<void> showBackgroundTrackingActiveNotification() async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'location_tracking_channel',
            'Pelacakan Lokasi',
            channelDescription:
                'Notifikasi untuk pelacakan lokasi latar belakang',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        2,
        'Pelacakan Latar Belakang Aktif',
        'Lokasi Anda sedang dicatat secara otomatis',
        platformChannelSpecifics,
        payload: 'background_tracking',
      );

      print('Notifikasi pelacakan latar belakang ditampilkan');
    } catch (e) {
      print('Error showing background tracking notification: $e');
    }
  }

  /// Callback ketika notifikasi diklik
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    print('Notifikasi diklik: $payload');
  }

  /// Hapus notifikasi
  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  /// Hapus semua notifikasi
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
}
