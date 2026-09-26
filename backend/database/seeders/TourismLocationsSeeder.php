<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TourismLocationsSeeder extends Seeder
{
    public function run(): void
    {
        $locations = [
            ['name_en' => 'Erbil Citadel', 'name_ckb' => 'قەڵای هەولێر', 'name_ar' => 'قلعة أربيل', 'slug' => 'erbil-citadel', 'category' => 'historical', 'governorate' => 'Erbil', 'latitude' => 36.1911000, 'longitude' => 44.0092000, 'description_en' => 'Historic citadel in the centre of Erbil and a UNESCO World Heritage site.', 'description_ckb' => 'قەڵای مێژوویی ناوەندی هەولێر و شوێنێکی میراثی جیهانی یونسکۆیە.', 'description_ar' => 'قلعة تاريخية في مركز أربيل وموقع للتراث العالمي لليونسكو.'],
            ['name_en' => 'Qaysari Bazaar', 'name_ckb' => 'بازاڕی قەیسەری', 'name_ar' => 'سوق القيصرية', 'slug' => 'qaysari-bazaar', 'category' => 'market', 'governorate' => 'Erbil', 'latitude' => 36.1884800, 'longitude' => 44.0092400, 'description_en' => 'Traditional covered bazaar beside the Erbil Citadel.', 'description_ckb' => 'بازاڕێکی نەریتی لە تەنیشت قەڵای هەولێر.', 'description_ar' => 'بازار تقليدي مسقوف بجانب قلعة أربيل.'],
            ['name_en' => 'Sami Abdulrahman Park', 'name_ckb' => 'پارکی سامی عەبدولڕەحمان', 'name_ar' => 'متنزه سامي عبد الرحمن', 'slug' => 'sami-abdulrahman-park', 'category' => 'park', 'governorate' => 'Erbil', 'latitude' => 36.1909600, 'longitude' => 43.9832100, 'description_en' => 'Large urban park with green areas, lakes and recreational facilities.', 'description_ckb' => 'پارکێکی گەورەی شارستانی بە سەوزایی و دەریاچە و شوێنی پشوودان.', 'description_ar' => 'متنزه حضري كبير يضم مساحات خضراء وبحيرات ومرافق ترفيهية.'],
            ['name_en' => 'Mudhafaria Minaret', 'name_ckb' => 'مینارەی مووزەفەری', 'name_ar' => 'منارة المظفرية', 'slug' => 'mudhafaria-minaret', 'category' => 'historical', 'governorate' => 'Erbil', 'latitude' => 36.1875300, 'longitude' => 43.9997000, 'description_en' => 'Medieval brick minaret in Erbil associated with the Muzaffarid period.', 'description_ckb' => 'مینارەیەکی مێژوویی لە هەولێر کە بە سەردەمی مووزەفەری پەیوەندیدارە.', 'description_ar' => 'مئذنة تاريخية من الطوب في أربيل تعود إلى العصر المظفري.'],
            ['name_en' => 'Shaqlawa', 'name_ckb' => 'شەقڵاوە', 'name_ar' => 'شقلاوة', 'slug' => 'shaqlawa', 'category' => 'nature', 'governorate' => 'Erbil', 'latitude' => 36.4000000, 'longitude' => 44.3368000, 'description_en' => 'Mountain town known for its pleasant climate and surrounding valleys.', 'description_ckb' => 'شارۆچکەیەکی شاخاوی بە ناوبانگ بۆ کەشوهەوا و دۆڵەکانی دەوروبەری.', 'description_ar' => 'بلدة جبلية معروفة بمناخها ووديانها المحيطة.'],
            ['name_en' => 'Rawanduz', 'name_ckb' => 'ڕەواندز', 'name_ar' => 'رواندوز', 'slug' => 'rawanduz', 'category' => 'nature', 'governorate' => 'Erbil', 'latitude' => 36.6146000, 'longitude' => 44.5265000, 'description_en' => 'Mountain town surrounded by dramatic gorges and highlands.', 'description_ckb' => 'شارۆچکەیەکی شاخاوی لە نێوان گەڕەک و شاخە بەرزەکان.', 'description_ar' => 'بلدة جبلية تحيط بها الأخاديد والمرتفعات.'],
            ['name_en' => 'Gali Ali Beg Waterfall', 'name_ckb' => 'ئاویشارەی گەلی عەلی بەگ', 'name_ar' => 'شلال كلي علي بك', 'slug' => 'gali-ali-beg-waterfall', 'category' => 'waterfall', 'governorate' => 'Erbil', 'latitude' => 36.6314500, 'longitude' => 44.4458900, 'description_en' => 'Popular waterfall and natural attraction in the Rawanduz area.', 'description_ckb' => 'ئاویشارێکی ناسراو و شوێنێکی سروشتی لە ناوچەی ڕەواندز.', 'description_ar' => 'شلال طبيعي شهير في منطقة رواندوز.'],
            ['name_en' => 'Korek Mountain', 'name_ckb' => 'شاخی کۆڕەک', 'name_ar' => 'جبل كورك', 'slug' => 'korek-mountain', 'category' => 'mountain', 'governorate' => 'Erbil', 'latitude' => 36.6083500, 'longitude' => 44.4927300, 'description_en' => 'Mountain destination known for panoramic views and recreation.', 'description_ckb' => 'شوێنێکی شاخاوی بە دیمەنی پانۆرامی و چالاکییە گەشتیارییەکان.', 'description_ar' => 'وجهة جبلية معروفة بإطلالاتها والأنشطة الترفيهية.'],
            ['name_en' => 'Halgurd Mountain', 'name_ckb' => 'شاخی هەڵگورد', 'name_ar' => 'جبل هلكورد', 'slug' => 'halgurd-mountain', 'category' => 'mountain', 'governorate' => 'Erbil', 'latitude' => 36.7411000, 'longitude' => 44.8614000, 'description_en' => 'High Zagros mountain destination popular with hikers and nature visitors.', 'description_ckb' => 'شاخێکی بەرزی زاگرۆس بۆ پیاسە و سروشتگەڕی.', 'description_ar' => 'وجهة جبلية عالية في زاغروس لمحبي المشي والطبيعة.'],
            ['name_en' => 'Shanidar Cave', 'name_ckb' => 'ئەشکەوتی شانەدەر', 'name_ar' => 'كهف شانيدر', 'slug' => 'shanidar-cave', 'category' => 'archaeological', 'governorate' => 'Erbil', 'latitude' => 36.8316000, 'longitude' => 44.2211000, 'description_en' => 'Important archaeological cave in the Baradost Mountains.', 'description_ckb' => 'ئەشکەوتێکی گرنگی شوێنەواری لە شاخەکانی بارادۆست.', 'description_ar' => 'كهف أثري مهم في جبال برادوست.'],
            ['name_en' => 'Amedi', 'name_ckb' => 'ئامێدی', 'name_ar' => 'العمادية', 'slug' => 'amedi', 'category' => 'historical', 'governorate' => 'Duhok', 'latitude' => 37.0920000, 'longitude' => 43.4874000, 'description_en' => 'Historic mountain town on a distinctive high plateau.', 'description_ckb' => 'شارۆچکەیەکی مێژوویی شاخاوی لەسەر تەختاییەکی بەرز.', 'description_ar' => 'بلدة جبلية تاريخية على هضبة مرتفعة مميزة.'],
            ['name_en' => 'Lalish', 'name_ckb' => 'لالش', 'name_ar' => 'لالش', 'slug' => 'lalish', 'category' => 'cultural', 'governorate' => 'Duhok', 'latitude' => 36.7715000, 'longitude' => 43.3030000, 'description_en' => 'Sacred cultural valley and major Yazidi pilgrimage destination.', 'description_ckb' => 'دۆڵێکی پیرۆز و شوێنێکی گرنگی کۆمەڵایەتی و زیارەت.', 'description_ar' => 'وادي مقدس ووجهة رئيسية للحج الإيزيدي.'],
            ['name_en' => 'Duhok Dam', 'name_ckb' => 'بەندی دهوک', 'name_ar' => 'سد دهوك', 'slug' => 'duhok-dam', 'category' => 'nature', 'governorate' => 'Duhok', 'latitude' => 36.8758100, 'longitude' => 43.0045900, 'description_en' => 'Reservoir and scenic recreation area near Duhok.', 'description_ckb' => 'دەریاچە و ناوچەیەکی جوانی سروشتی لە نزیک دهوک.', 'description_ar' => 'خزان ومنطقة ترفيهية ذات مناظر طبيعية قرب دهوك.'],
            ['name_en' => 'Zawa Mountain', 'name_ckb' => 'شاخی زاوا', 'name_ar' => 'جبل زاوا', 'slug' => 'zawa-mountain', 'category' => 'mountain', 'governorate' => 'Duhok', 'latitude' => 36.8375000, 'longitude' => 42.9536700, 'description_en' => 'Mountain viewpoint and recreational destination overlooking Duhok.', 'description_ckb' => 'شوێنی دیمەن و پشوودان بە سەر دهوکەوە.', 'description_ar' => 'وجهة جبلية وإطلالة ترفيهية على دهوك.'],
            ['name_en' => 'Akre', 'name_ckb' => 'ئاکرێ', 'name_ar' => 'عقرة', 'slug' => 'akre', 'category' => 'historical', 'governorate' => 'Duhok', 'latitude' => 36.7304900, 'longitude' => 43.8748900, 'description_en' => 'Historic town in the northern Zagros foothills.', 'description_ckb' => 'شارۆچکەیەکی مێژوویی لە پێدەشتی زاگرۆس.', 'description_ar' => 'بلدة تاريخية عند سفوح زاغروس الشمالية.'],
            ['name_en' => 'Delal Bridge', 'name_ckb' => 'پردی دەلال', 'name_ar' => 'جسر دلال', 'slug' => 'delal-bridge', 'category' => 'historical', 'governorate' => 'Duhok', 'latitude' => 37.1365400, 'longitude' => 42.6945700, 'description_en' => 'Historic stone bridge in the Zakho area.', 'description_ckb' => 'پردێکی مێژوویی بەردین لە ناوچەی زاخۆ.', 'description_ar' => 'جسر حجري تاريخي في منطقة زاخو.'],
            ['name_en' => 'Dukan Lake', 'name_ckb' => 'دەریاچەی دوکان', 'name_ar' => 'بحيرة دوكان', 'slug' => 'dukan-lake', 'category' => 'lake', 'governorate' => 'Sulaymaniyah', 'latitude' => 36.0925000, 'longitude' => 44.9358000, 'description_en' => 'Large reservoir surrounded by mountains and rural landscapes.', 'description_ckb' => 'دەریاچەیەکی گەورە لە نێوان شاخ و دیمەنی گوندنشینی.', 'description_ar' => 'بحيرة كبيرة تحيط بها الجبال والمناظر الريفية.'],
            ['name_en' => 'Sulaymaniyah', 'name_ckb' => 'سلێمانی', 'name_ar' => 'السليمانية', 'slug' => 'sulaymaniyah', 'category' => 'city', 'governorate' => 'Sulaymaniyah', 'latitude' => 35.5649640, 'longitude' => 45.4329050, 'description_en' => 'Major cultural city known for museums, markets and arts.', 'description_ckb' => 'شاری سەرەکی کە بە مۆزەخانە و بازاڕ و هونەر ناسراوە.', 'description_ar' => 'مدينة ثقافية رئيسية تشتهر بالمتاحف والأسواق والفنون.'],
            ['name_en' => 'Amna Suraka Museum', 'name_ckb' => 'مۆزەخانەی ئەمنە سورەکە', 'name_ar' => 'متحف أمنه سوراكا', 'slug' => 'amna-suraka-museum', 'category' => 'museum', 'governorate' => 'Sulaymaniyah', 'latitude' => 35.5621900, 'longitude' => 45.4254500, 'description_en' => 'Museum and memorial complex in Sulaymaniyah.', 'description_ckb' => 'مۆزەخانە و یادگارییەکی گرنگ لە سلێمانی.', 'description_ar' => 'متحف ومجمع تذكاري مهم في السليمانية.'],
            ['name_en' => 'Halabja', 'name_ckb' => 'هەڵەبجە', 'name_ar' => 'حلبجة', 'slug' => 'halabja', 'category' => 'cultural', 'governorate' => 'Halabja', 'latitude' => 35.1792000, 'longitude' => 45.9874000, 'description_en' => 'Historic city and memorial destination in the Kurdistan Region.', 'description_ckb' => 'شارێکی مێژوویی و شوێنی یادەوەری لە هەرێمی کوردستان.', 'description_ar' => 'مدينة تاريخية ووجهة تذكارية في إقليم كردستان.'],
        ];

        foreach ($locations as $location) {
            $location['name'] = $location['name_en'];
            $location['is_active'] = true;
            $location['is_verified'] = true;
            $location['created_at'] = now();
            $location['updated_at'] = now();

            DB::table('locations')->updateOrInsert(
                ['slug' => $location['slug']],
                $location
            );

            DB::statement(
                'UPDATE locations SET geom = ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography WHERE slug = ?',
                [$location['longitude'], $location['latitude'], $location['slug']]
            );
        }
    }
}
