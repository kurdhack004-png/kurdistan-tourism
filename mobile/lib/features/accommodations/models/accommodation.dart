class Accommodation {
  const Accommodation({required this.id, required this.nameCkb, required this.type, required this.pricePerNight});
  final String id; final String nameCkb; final String type; final double pricePerNight;
  factory Accommodation.fromJson(Map<String, dynamic> json) => Accommodation(
    id: json['id'].toString(),
    nameCkb: (json['name_ckb'] ?? json['name'] ?? 'شوێنی مانەوە').toString(),
    type: (json['type'] ?? 'hotel').toString(),
    pricePerNight: ((json['price_per_night'] ?? json['price'] ?? 0) as num).toDouble(),
  );
}
