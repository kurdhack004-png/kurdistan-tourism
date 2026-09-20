String? _firstText(List<dynamic> values) {
  for (final v in values) {
    final s = v?.toString().trim() ?? '';
    if (s.isNotEmpty) return s;
  }
  return null;
}

class TouristLocation {
  const TouristLocation({
    required this.id, required this.category, required this.nameCkb,
    required this.latitude, required this.longitude, this.elevationMeters, this.descriptionCkb, this.rating, this.imageUrl,
  });

  final String id;
  final String category;
  final String nameCkb;
  final double latitude;
  final double longitude;
  final int? elevationMeters;
  final String? descriptionCkb;
  final double? rating;
  final String? imageUrl;

  factory TouristLocation.fromJson(Map<String, dynamic> json) {
    final geom = json['geom'];
    double? lat, lng;
    if (geom is Map && geom['coordinates'] is List && (geom['coordinates'] as List).length >= 2) {
      final c = geom['coordinates'] as List; lng = (c[0] as num).toDouble(); lat = (c[1] as num).toDouble();
    }
    lat ??= (json['lat'] as num?)?.toDouble() ?? (json['latitude'] as num?)?.toDouble();
    lng ??= (json['lng'] as num?)?.toDouble() ?? (json['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) throw const FormatException('Location coordinates missing');
    var image = _firstText([json['image'], json['image_url']]);
    if (image == null && json['images'] is List) image = _firstText(json['images'] as List);
    return TouristLocation(
      id: json['id'].toString(),
      category: (json['category'] ?? 'other').toString(),
      nameCkb: _firstText([json['name_ckb'], json['name_ku'], json['name']]) ?? 'شوێنی گەشتیاری',
      longitude: lng, latitude: lat,
      elevationMeters: (json['elevation_meters'] as num?)?.toInt(),
      descriptionCkb: _firstText([json['description_ckb'], json['description_ku'], json['description']]),
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: image,
    );
  }
}
