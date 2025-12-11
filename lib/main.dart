import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/location_history_provider.dart';
import 'screens/home_screen.dart';
import 'services/preference_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi notifikasi
  final notificationService = NotificationService();
  await notificationService.initializeNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationHistoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pencatat Lokasi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const PermissionWrapper(child: HomeScreen()),
      ),
    );
  }
}

class PermissionWrapper extends StatefulWidget {
  final Widget child;

  const PermissionWrapper({required this.child, super.key});

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _permissionCheckDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissionOnce();
    });
  }

  /// Cek dan minta izin lokasi hanya sekali saat app start
  Future<void> _checkAndRequestPermissionOnce() async {
    if (!mounted || _permissionCheckDone) return;

    final hasBeenRequested =
        await PreferenceService.hasPermissionBeenRequested();

    if (!hasBeenRequested && mounted) {
      await _showPermissionDialog();
      await PreferenceService.markPermissionAsRequested();
    }

    if (mounted) {
      setState(() {
        _permissionCheckDone = true;
      });
    }
  }

  Future<void> _showPermissionDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Izin Akses Lokasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi memerlukan akses lokasi untuk:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(height: 12),
            PermissionBulletPoint(
              icon: Icons.map,
              text: 'Mencatat riwayat lokasi Anda setiap hari',
            ),
            PermissionBulletPoint(
              icon: Icons.my_location,
              text: 'Merekam pergerakan Anda secara otomatis',
            ),
            PermissionBulletPoint(
              icon: Icons.location_on_outlined,
              text: 'Mengonversi koordinat menjadi alamat',
            ),
            SizedBox(height: 16),
            Text(
              '🔒 Data lokasi Anda disimpan lokal di perangkat dan tidak akan pernah dibagikan.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Nanti Dulu',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final locationProvider = Provider.of<LocationHistoryProvider>(
                context,
                listen: false,
              );
              final hasPermission = await locationProvider
                  .requestLocationPermission();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      hasPermission
                          ? 'Izin diberikan! Siap mencatat lokasi.'
                          : 'Izin ditolak. Anda bisa mengaktifkannya di Pengaturan.',
                    ),
                    backgroundColor: hasPermission
                        ? Colors.green
                        : Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Izinkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class PermissionBulletPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const PermissionBulletPoint({
    required this.icon,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
