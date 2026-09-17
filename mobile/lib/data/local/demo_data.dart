import '../../features/accommodations/models/accommodation.dart';
import '../../features/bookings/models/booking.dart';
import '../../features/locations/models/tourist_location.dart';

const demoLocations = <TouristLocation>[
  TouristLocation(
    id: 'demo-dukan', category: 'lake', nameCkb: 'دەریاچەی دوکان',
    latitude: 36.034, longitude: 44.952, elevationMeters: 548,
    descriptionCkb: 'یەکێک لە جوانترین شوێنە سروشتییەکانی کوردستان، دەوروبەری دەریاچە بە چیا و دۆڵە جوانەکان داپۆشراوە.',
  ),
  TouristLocation(
    id: 'demo-rawanduz', category: 'mountain', nameCkb: 'ڕەواندز',
    latitude: 36.618, longitude: 44.535, elevationMeters: 730,
    descriptionCkb: 'شارێکی مێژوویی و سروشتی لە ناوچەی شاخاوی کوردستان، نزیک کانی و ڕووبار و دۆڵە جوانەکان.',
  ),
  TouristLocation(
    id: 'demo-bekhal', category: 'waterfall', nameCkb: 'ئاوی بەخال',
    latitude: 36.639, longitude: 44.478, elevationMeters: 1100,
    descriptionCkb: 'ئاودانێکی ناسراو لە ناوچەی ڕەواندز، گونجاو بۆ سەیران و وێنەگرتن و گەشت.',
  ),
  TouristLocation(
    id: 'demo-shanidar', category: 'cave', nameCkb: 'ئەشکەوتی شانەدەر',
    latitude: 36.832, longitude: 44.237, elevationMeters: 745,
    descriptionCkb: 'شوێنێکی مێژوویی و ئارکەئۆلۆجی لە ناوچەی بارزان، بە مێژوویەکی زۆر گرنگی مرۆڤایەتی.',
  ),
  TouristLocation(
    id: 'demo-erbil-citadel', category: 'history', nameCkb: 'قەڵای هەولێر',
    latitude: 36.1911, longitude: 44.0092, elevationMeters: 390,
    descriptionCkb: 'قەڵای مێژوویی ناوەندی هەولێر و یەکێک لە ناسراوترین شوێنە مێژووییەکانی کوردستان.',
  ),
];

const demoAccommodations = <Accommodation>[
  Accommodation(id: 'hotel-korek', nameCkb: 'ڕیزۆرتی کۆڕەک', type: 'resort', pricePerNight: 120),
  Accommodation(id: 'hotel-dukan', nameCkb: 'هوتێلی دوکان', type: 'hotel', pricePerNight: 80),
  Accommodation(id: 'hotel-rawanduz', nameCkb: 'هوتێلی ڕەواندز', type: 'hotel', pricePerNight: 70),
];

final demoBookings = <Booking>[];
