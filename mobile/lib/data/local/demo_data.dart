import '../../features/accommodations/models/accommodation.dart';
import '../../features/bookings/models/booking.dart';
import '../../features/locations/models/tourist_location.dart';

const demoLocations = <TouristLocation>[
  TouristLocation(
    id: 'demo-dukan', category: 'lake', nameCkb: 'دەریاچەی دوکان',
    latitude: 36.034, longitude: 44.952, elevationMeters: 548, rating: 4.6,
    descriptionCkb: 'یەکێک لە جوانترین شوێنە سروشتییەکانی کوردستان، دەوروبەری دەریاچە بە چیا و دۆڵە جوانەکان داپۆشراوە.',
  ),
  TouristLocation(
    id: 'demo-darbandikhan', category: 'lake', nameCkb: 'دەریاچەی دەربەندیخان',
    latitude: 35.145, longitude: 45.729, elevationMeters: 480, rating: 4.4,
    descriptionCkb: 'دەریاچەیەکی گەورە لە باشووری سلێمانی، گونجاو بۆ کەشتی و ماسیگرتن و پیکنیک.',
  ),
  TouristLocation(
    id: 'demo-rawanduz', category: 'mountain', nameCkb: 'ڕەواندز',
    latitude: 36.618, longitude: 44.535, elevationMeters: 730, rating: 4.8,
    descriptionCkb: 'شارێکی مێژوویی و سروشتی لە ناوچەی شاخاوی کوردستان، نزیک کانی و ڕووبار و دۆڵە جوانەکان.',
  ),
  TouristLocation(
    id: 'demo-halgurd', category: 'mountain', nameCkb: 'چیای هەڵگورد',
    latitude: 36.833, longitude: 44.700, elevationMeters: 3607, rating: 4.9,
    descriptionCkb: 'بەرزترین لووتکەی کوردستان، شوێنی نایابی هایکینگ و کوهنوردی بۆ ئەوانەی حەز لە سروشت دەکەن.',
  ),
  TouristLocation(
    id: 'demo-bekhal', category: 'waterfall', nameCkb: 'ئاوی بەخال',
    latitude: 36.639, longitude: 44.478, elevationMeters: 1100, rating: 4.5,
    descriptionCkb: 'ئاودانێکی ناسراو لە ناوچەی ڕەواندز، گونجاو بۆ سەیران و وێنەگرتن و گەشت.',
  ),
  TouristLocation(
    id: 'demo-gali-ali-bag', category: 'waterfall', nameCkb: 'گەلی عەلی بەگ',
    latitude: 36.708, longitude: 44.437, elevationMeters: 900, rating: 4.7,
    descriptionCkb: 'یەکێک لە بەرزترین ئاودانەکانی کوردستان، لە دۆڵێکی کێوی جوان.',
  ),
  TouristLocation(
    id: 'demo-shanidar', category: 'cave', nameCkb: 'ئەشکەوتی شانەدەر',
    latitude: 36.832, longitude: 44.237, elevationMeters: 745, rating: 4.3,
    descriptionCkb: 'شوێنێکی مێژوویی و ئارکەئۆلۆجی لە ناوچەی بارزان، بە مێژوویەکی زۆر گرنگی مرۆڤایەتی.',
  ),
  TouristLocation(
    id: 'demo-erbil-citadel', category: 'history', nameCkb: 'قەڵای هەولێر',
    latitude: 36.1911, longitude: 44.0092, elevationMeters: 390, rating: 4.6,
    descriptionCkb: 'قەڵای مێژوویی ناوەندی هەولێر و یەکێک لە ناسراوترین شوێنە مێژووییەکانی کوردستان.',
  ),
];

const demoAccommodations = <Accommodation>[
  Accommodation(id: 'hotel-korek', nameCkb: 'ڕیزۆرتی کۆڕەک', type: 'resort', pricePerNight: 120),
  Accommodation(id: 'hotel-dukan', nameCkb: 'هوتێلی دوکان', type: 'hotel', pricePerNight: 80),
  Accommodation(id: 'hotel-rawanduz', nameCkb: 'هوتێلی ڕەواندز', type: 'hotel', pricePerNight: 70),
];

final demoBookings = <Booking>[];
