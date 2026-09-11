class Hospital {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String phone;
  final double distanceMeters;
  final String openStatus;

  const Hospital({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phone,
    required this.distanceMeters,
    required this.openStatus,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    } else {
      final km = distanceMeters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  factory Hospital.fromOverpassJson(
    Map<String, dynamic> json,
    double userLat,
    double userLng,
    double calculatedDistance,
  ) {
    final tags = (json['tags'] as Map<String, dynamic>?) ?? {};

    final name = tags['name'] ??
        tags['name:en'] ??
        tags['operator'] ??
        'Emergency Hospital';

    final street = tags['addr:street'] ?? '';
    final city = tags['addr:city'] ?? '';
    final suburb = tags['addr:suburb'] ?? tags['addr:district'] ?? '';

    String addressParts = [street, suburb, city]
        .where((s) => s.toString().trim().isNotEmpty)
        .join(', ');

    if (addressParts.isEmpty) {
      addressParts = tags['address'] ?? 'Nearby Emergency Facility';
    }

    final phone = tags['phone'] ??
        tags['contact:phone'] ??
        tags['emergency:phone'] ??
        '';

    final openingHours = tags['opening_hours'] ?? '';
    final emergency = tags['emergency'] ?? '';

    String status = 'Open 24/7';
    if (emergency == 'yes') {
      status = 'Emergency Care Available';
    } else if (openingHours.isNotEmpty) {
      status = openingHours;
    }

    double lat = 0.0;
    double lng = 0.0;

    if (json['lat'] != null && json['lon'] != null) {
      lat = (json['lat'] as num).toDouble();
      lng = (json['lon'] as num).toDouble();
    } else if (json['center'] != null) {
      lat = (json['center']['lat'] as num).toDouble();
      lng = (json['center']['lon'] as num).toDouble();
    }

    return Hospital(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.toString(),
      latitude: lat,
      longitude: lng,
      address: addressParts.toString(),
      phone: phone.toString(),
      distanceMeters: calculatedDistance,
      openStatus: status,
    );
  }
}
