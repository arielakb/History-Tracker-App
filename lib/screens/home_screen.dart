import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_history_provider.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationHistoryProvider>(
      builder: (context, provider, child) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;

        // Breakpoints yang lebih detail
        final isVerySmall = screenWidth < 360;
        final isSmall = screenWidth < 400;
        final isMobile = screenWidth < 600;

        // Responsive values
        final iconSize = isVerySmall
            ? 60.0
            : (isSmall ? 70.0 : (isMobile ? 80.0 : 120.0));
        final titleSize = isVerySmall
            ? 18.0
            : (isSmall ? 20.0 : (isMobile ? 22.0 : 24.0));
        final subtitleSize = isVerySmall
            ? 13.0
            : (isSmall ? 14.0 : (isMobile ? 15.0 : 16.0));
        final horizontalPadding = isVerySmall
            ? 12.0
            : (isSmall ? 16.0 : (isMobile ? 20.0 : 32.0));
        final verticalSpacing = isVerySmall
            ? 12.0
            : (isSmall ? 15.0 : (isMobile ? 20.0 : 30.0));
        final containerWidth = isVerySmall
            ? screenWidth * 0.95
            : (isSmall
                  ? screenWidth * 0.92
                  : (isMobile ? screenWidth * 0.9 : 400.0));

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Pencatat Lokasi',
              style: TextStyle(fontSize: isVerySmall ? 16 : 18),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: verticalSpacing),
                  Icon(Icons.location_on, size: iconSize, color: Colors.red),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Selamat Datang di\nPencatat Lokasi',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: verticalSpacing * 0.75),
                  Text(
                    'Catat lokasi Anda secara otomatis setiap hari dan lihat riwayat lokasi Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 1.5),
                  SizedBox(
                    width: containerWidth,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading
                          ? null
                          : () => _captureLocation(context),
                      icon: Icon(
                        Icons.my_location,
                        size: isVerySmall ? 18 : 20,
                      ),
                      label: provider.isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Catat Lokasi Saat Ini',
                              style: TextStyle(
                                fontSize: isVerySmall
                                    ? 13
                                    : (isSmall ? 14 : 15),
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isVerySmall ? 16 : (isSmall ? 20 : 24),
                          vertical: isVerySmall ? 12 : (isSmall ? 14 : 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 1.2),
                  Container(
                    width: containerWidth,
                    padding: EdgeInsets.all(isVerySmall ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Lokasi Tercatat',
                          style: TextStyle(
                            fontSize: isVerySmall ? 13 : subtitleSize,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: isVerySmall ? 6 : 8),
                        Text(
                          '${provider.allLocations.length}',
                          style: TextStyle(
                            fontSize: isVerySmall ? 24 : (isSmall ? 28 : 32),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (provider.errorMessage != null) ...[
                    SizedBox(height: verticalSpacing),
                    Container(
                      width: containerWidth,
                      padding: EdgeInsets.all(isVerySmall ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(
                          fontSize: isVerySmall ? 11 : (isSmall ? 12 : 14),
                          color: Colors.red[800],
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  SizedBox(height: verticalSpacing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _captureLocation(BuildContext context) async {
    final provider = Provider.of<LocationHistoryProvider>(
      context,
      listen: false,
    );
    final success = await provider.captureCurrentLocation();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil dicatat!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mencatat lokasi. Periksa izin akses Anda.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
