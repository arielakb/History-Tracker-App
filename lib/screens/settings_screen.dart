import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_history_provider.dart';
import '../services/background_location_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _backgroundTrackingEnabled = false;
  final BackgroundLocationService _backgroundLocationService =
      BackgroundLocationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // In a real app, you would load this from shared preferences
    // For now, we'll just initialize it
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Consumer<LocationHistoryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pengaturan'), centerTitle: true),
          body: ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Text(
                  'Pelacakan Latar Belakang',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(
                  'Aktifkan Pelacakan Lokasi Latar Belakang',
                  style: TextStyle(fontSize: isMobile ? 13 : 15),
                ),
                subtitle: Text(
                  'Catat lokasi Anda secara otomatis setiap hari',
                  style: TextStyle(fontSize: isMobile ? 12 : 13),
                ),
                value: _backgroundTrackingEnabled,
                onChanged: (value) async {
                  setState(() {
                    _backgroundTrackingEnabled = value;
                  });

                  if (value) {
                    await _backgroundLocationService
                        .initializeBackgroundLocationTracking();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pelacakan lokasi latar belakang diaktifkan',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    await _backgroundLocationService
                        .cancelBackgroundLocationTracking();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pelacakan lokasi latar belakang dinonaktifkan',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                },
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Text(
                  'Manajemen Data',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_sweep,
                  color: Colors.red,
                  size: isMobile ? 20 : 24,
                ),
                title: Text(
                  'Hapus Semua Lokasi',
                  style: TextStyle(fontSize: isMobile ? 13 : 15),
                ),
                subtitle: Text(
                  'Hapus permanen semua lokasi yang tersimpan',
                  style: TextStyle(fontSize: isMobile ? 12 : 13),
                ),
                onTap: () => _showDeleteAllConfirmation(context, provider),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Text(
                  'Tentang',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Versi Aplikasi',
                  style: TextStyle(fontSize: isMobile ? 13 : 15),
                ),
                subtitle: Text(
                  '1.0.0',
                  style: TextStyle(fontSize: isMobile ? 12 : 13),
                ),
              ),
              ListTile(
                title: Text(
                  'Total Lokasi',
                  style: TextStyle(fontSize: isMobile ? 13 : 15),
                ),
                subtitle: Text(
                  '${provider.allLocations.length} tercatat',
                  style: TextStyle(fontSize: isMobile ? 12 : 13),
                ),
              ),
              SizedBox(height: isMobile ? 12 : 20),
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cara Kerja',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      Text(
                        '1. Aktifkan pelacakan latar belakang untuk merekam lokasi Anda secara otomatis setiap hari.\n\n'
                        '2. Lokasi Anda dicatat dengan koordinat (lintang dan bujur).\n\n'
                        '3. Lihat riwayat lokasi Anda kapan saja dari tab Riwayat.\n\n'
                        '4. Filter lokasi berdasarkan tanggal atau hari dalam seminggu.\n\n'
                        '5. Cari lokasi atau alamat tertentu.\n\n'
                        '6. Semua data disimpan lokal di perangkat Anda untuk privasi.',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAllConfirmation(
    BuildContext context,
    LocationHistoryProvider provider,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Semua Lokasi',
          style: TextStyle(fontSize: isMobile ? 16 : 20),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus permanen semua lokasi? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: isMobile ? 13 : 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteAllLocations();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Semua lokasi dihapus',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red, fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
