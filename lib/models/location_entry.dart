class LocationEntry {
  final String id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? address;
  final String? accuracy;

  LocationEntry({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.address,
    this.accuracy,
  });

  // Convert to JSON for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
      'accuracy': accuracy,
    };
  }

  // Create from database map
  factory LocationEntry.fromMap(Map<String, dynamic> map) {
    return LocationEntry(
      id: map['id'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      address: map['address'] as String?,
      accuracy: map['accuracy'] as String?,
    );
  }

  // Create a copy with modifications
  LocationEntry copyWith({
    String? id,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? address,
    String? accuracy,
  }) {
    return LocationEntry(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  String toString() =>
      'LocationEntry(id: $id, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, address: $address)';
}
