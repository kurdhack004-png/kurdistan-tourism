class Booking {
  const Booking({required this.id, required this.accommodationName, required this.checkIn, required this.checkOut, required this.guests, required this.totalPrice, required this.status});
  final String id; final String accommodationName; final DateTime checkIn; final DateTime checkOut; final int guests; final double totalPrice; final String status;
  factory Booking.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse((json['check_in'] ?? json['date']).toString());
    final nights = (json['nights'] as num?)?.toInt() ?? 1;
    final end = json['check_out'] != null ? DateTime.parse(json['check_out'].toString()) : date.add(Duration(days: nights));
    final acc = json['accommodation'];
    return Booking(
      id: json['id'].toString(),
      accommodationName: acc is Map ? (acc['name_ckb'] ?? acc['name'] ?? 'شوێنی مانەوە').toString() : (json['accommodation_name'] ?? 'شوێنی مانەوە').toString(),
      checkIn: date, checkOut: end, guests: (json['guests'] as num?)?.toInt() ?? 1,
      totalPrice: ((json['total_price'] ?? json['total'] ?? 0) as num).toDouble(),
      status: (json['status'] ?? 'pending').toString(),
    );
  }
}
