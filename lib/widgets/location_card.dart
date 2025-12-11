import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/location_entry.dart';

class LocationCard extends StatelessWidget {
  final LocationEntry location;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const LocationCard({
    Key? key,
    required this.location,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.location_on, color: Colors.red),
        title: Text(
          DateFormat('d MMMM yyyy, HH:mm:ss').format(location.timestamp),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (location.address != null && location.address!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                location.address!,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (location.accuracy != null) ...[
              const SizedBox(height: 4),
              Text(
                'Accuracy: ${location.accuracy}m',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
