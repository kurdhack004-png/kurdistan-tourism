class Accommodation {
  const Accommodation({required this.id, required this.nameCkb, required this.type, required this.pricePerNight});
  final String id; final String nameCkb; final String type; final double pricePerNight;
  factory Accommodation.fromJson(Map<String, dynamic> json) => Accommodation(
    id: json['id'].toString(),
    nameCkb: _pickName(json),
    type: (json['type'] ?? 'hotel').toString(),
    pricePerNight: ((json['price_per_night'] ?? json['price'] ?? 0) as num).toDouble(),
  );
}

String _pickName(Map<String, dynamic> json) {
  for (final key in const ['name_ckb', 'name_ku', 'name']) {
    final v = json[key]?.toString().trim() ?? '';
    if (v.isNotEmpty) return v;
  }
  return 'شوێنی مانەوە';
}
