import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/location_history_provider.dart';
import '../widgets/location_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationHistoryProvider>(
      builder: (context, provider, child) {
        final screenSize = MediaQuery.of(context).size;
        final isMobile = screenSize.width < 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Riwayat Lokasi'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    provider.searchLocations(value);
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Cari berdasarkan tanggal, koordinat, atau alamat...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.searchLocations('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Filters section
              if (_showFilters)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _selectDate(context, provider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: provider.selectedDate != null
                                    ? Colors.blue
                                    : Colors.grey[300],
                              ),
                              child: Text(
                                provider.selectedDate != null
                                    ? DateFormat(
                                        'd MMM yyyy',
                                      ).format(provider.selectedDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                  color: provider.selectedDate != null
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (provider.selectedDate != null)
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => provider.clearFilters(),
                            ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 1; i <= 7; i++)
                              Padding(
                                padding: EdgeInsets.only(
                                  right: isMobile ? 6 : 8,
                                ),
                                child: FilterChip(
                                  label: Text(
                                    _getDayName(i),
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 13,
                                    ),
                                  ),
                                  selected: provider.selectedDayOfWeek == i,
                                  onSelected: (selected) {
                                    if (selected) {
                                      provider.filterByDayOfWeek(i);
                                    } else {
                                      provider.clearFilters();
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      if (provider.selectedDate != null ||
                          provider.selectedDayOfWeek != null)
                        TextButton(
                          onPressed: () => provider.clearFilters(),
                          child: Text(
                            'Clear Filters',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                        ),
                      SizedBox(height: isMobile ? 8 : 12),
                    ],
                  ),
                ),

              // Location list
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.filteredLocations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: isMobile ? 48 : 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            Text(
                              'Tidak ada lokasi yang ditemukan',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadAllLocations(),
                        child: ListView.builder(
                          itemCount: provider.filteredLocations.length,
                          itemBuilder: (context, index) {
                            final location = provider.filteredLocations[index];
                            return LocationCard(
                              location: location,
                              onDelete: () {
                                _showDeleteConfirmation(
                                  context,
                                  location.id,
                                  provider,
                                );
                              },
                              onTap: () {
                                _showLocationDetails(context, location);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectDate(
    BuildContext context,
    LocationHistoryProvider provider,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      provider.filterByDate(selectedDate);
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String locationId,
    LocationHistoryProvider provider,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Lokasi',
          style: TextStyle(fontSize: isMobile ? 16 : 20),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus lokasi ini?',
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
              await provider.deleteLocation(locationId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lokasi telah dihapus',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails(BuildContext context, dynamic location) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Lokasi',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 20),
              _buildDetailRow(
                context,
                'Tanggal & Waktu',
                DateFormat('d MMMM yyyy, HH:mm:ss').format(location.timestamp),
              ),
              _buildDetailRow(
                context,
                'Latitude',
                location.latitude.toString(),
              ),
              _buildDetailRow(
                context,
                'Longitude',
                location.longitude.toString(),
              ),
              if (location.address != null && location.address!.isNotEmpty)
                _buildDetailRow(context, 'Alamat', location.address!),
              if (location.accuracy != null)
                _buildDetailRow(context, 'Akurasi', '${location.accuracy}m'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 13 : 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
      ],
    );
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[dayOfWeek - 1];
  }
}
