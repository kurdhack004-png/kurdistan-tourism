<?php

namespace Database\Seeders;

use App\Models\Location;
use Clickbar\Magellan\Data\Geometries\Point;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Curated starter dataset of real tourism locations in the Kurdistan Region of Iraq.
 *
 * Coordinates are based on OpenStreetMap/Wikidata-derived public map records.
 * This seeder intentionally does not invent accommodation businesses, prices,
 * ratings, or owner accounts; those require verified operator data.
 */
class RealTourismDataSeeder extends Seeder
{
    public function run(): void
    {
        $locations = [
            [
                'name_ckb' => 'قەڵای هەولێر',
                'name_ar' => 'قلعة أربيل',
                'name_en' => 'Erbil Citadel',
                'category' => 'historical',
                'governorate' => 'Erbil',
                'district' => null,
                'lat' => 36.19141,
                'lng' => 44.00926,
                'elevation' => null,
                'description_ckb' => 'قەڵای هەولێر شوێنێکی مێژوویی و گەشتیاریی ناسراوە لە ناوەندی شاری هەولێر.',
                'description_ar' => 'قلعة أربيل موقع تاريخي وسياحي بارز في مركز مدينة أربيل.',
                'description_en' => 'Erbil Citadel is a prominent historic and tourist site in the center of Erbil.',
            ],
            [
                'name_ckb' => 'دەریاچەی دووکان',
                'name_ar' => 'بحيرة دوكان',
                'name_en' => 'Dukan Lake',
                'category' => 'lake',
                'governorate' => 'Sulaymaniyah',
                'district' => 'Dukan',
                'lat' => 36.12921,
                'lng' => 44.91551,
                'elevation' => 477,
                'description_ckb' => 'دەریاچەی دووکان دەریاچەیەکی گەورەی ناوچەکەیە و بە دیمەنی سروشتی و شوێنەکانی پیکنیک ناسراوە.',
                'description_ar' => 'بحيرة دوكان خزان مائي كبير في المنطقة وتشتهر بمناظرها الطبيعية ومواقع التنزه.',
                'description_en' => 'Dukan Lake is a large reservoir known for its mountain scenery and recreation areas.',
            ],
            [
                'name_ckb' => 'تاڤگەی گەلیی عەلی بەگ',
                'name_ar' => 'شلال كلي علي بك',
                'name_en' => 'Geli Ali Beg Waterfall',
                'category' => 'waterfall',
                'governorate' => 'Erbil',
                'district' => 'Rawanduz',
                'lat' => 36.63134,
                'lng' => 44.44584,
                'elevation' => null,
                'description_ckb' => 'تاڤگەی گەلیی عەلی بەگ لە ناوچەی سۆرانە و یەکێکە لە شوێنە سروشتییە گەشتیارییە ناسراوەکانی ناوچەکە.',
                'description_ar' => 'شلال كلي علي بك يقع في منطقة سوران ويعد من المواقع الطبيعية السياحية المعروفة في المنطقة.',
                'description_en' => 'Geli Ali Beg Waterfall is in the Soran area and is a well-known natural attraction.',
            ],
            [
                'name_ckb' => 'تاڤگەی بێخاڵ',
                'name_ar' => 'شلال بيخال',
                'name_en' => 'Bekhal Waterfall',
                'category' => 'waterfall',
                'governorate' => 'Erbil',
                'district' => 'Rawanduz',
                'lat' => 36.61780,
                'lng' => 44.49750,
                'elevation' => null,
                'description_ckb' => 'تاڤگەی بێخاڵ لە نزیک ڕەواندز و سۆرانە و بە ئاوی تاڤگە و دیمەنی سروشتی ناسراوە.',
                'description_ar' => 'شلال بيخال يقع قرب رواندز وسوران ويشتهر بالمياه والمناظر الطبيعية.',
                'description_en' => 'Bekhal Waterfall is near Rawanduz and Soran, known for its waterfall and surrounding scenery.',
            ],
            [
                'name_ckb' => 'دیمەنی کانیۆنی ڕەواندز',
                'name_ar' => 'إطلالة وادي رواندز',
                'name_en' => 'Rawanduz Canyon View',
                'category' => 'other',
                'governorate' => 'Erbil',
                'district' => 'Rawanduz',
                'lat' => 36.61773,
                'lng' => 44.52801,
                'elevation' => null,
                'description_ckb' => 'دیمەنی کانیۆنی ڕەواندز شوێنێکی بینینەرییە بۆ بینینی درە و شاخەکانی دەوروبەری ڕەواندز.',
                'description_ar' => 'إطلالة وادي رواندز نقطة مشاهدة تطل على الوادي والجبال المحيطة بمدينة رواندز.',
                'description_en' => 'Rawanduz Canyon View is a scenic viewpoint overlooking the canyon and surrounding mountains.',
            ],
            [
                'name_ckb' => 'چیای سەفین',
                'name_ar' => 'جبل سفين',
                'name_en' => 'Safeen Mountain',
                'category' => 'mountain',
                'governorate' => 'Erbil',
                'district' => 'Shaqlawa',
                'lat' => 36.41110,
                'lng' => 44.28990,
                'elevation' => null,
                'description_ckb' => 'چیای سەفین لە ناوچەی شەقڵاوەیە و یەکێکە لە شاخە دیارەکانی دەوروبەری هەولێر.',
                'description_ar' => 'جبل سفين يقع في منطقة شقلاوة ويعد من الجبال المعروفة حول أربيل.',
                'description_en' => 'Safeen Mountain is in the Shaqlawa area and is one of the prominent mountains around Erbil.',
            ],
            [
                'name_ckb' => 'چیای هەڵگورد',
                'name_ar' => 'جبل هلكورد',
                'name_en' => 'Halgurd Mountain',
                'category' => 'mountain',
                'governorate' => 'Erbil',
                'district' => null,
                'lat' => 36.74110,
                'lng' => 44.86140,
                'elevation' => 3607,
                'description_ckb' => 'چیای هەڵگورد لە ناوچەی چۆمانە و بەرزییەکەی ٣٦٠٧ مەترە.',
                'description_ar' => 'جبل هلكورد يقع في منطقة چومان ويبلغ ارتفاعه 3607 أمتار.',
                'description_en' => 'Halgurd Mountain is in the Choman area and has an elevation of 3,607 metres.',
            ],
            [
                'name_ckb' => 'کۆڕەک',
                'name_ar' => 'جبل كورك',
                'name_en' => 'Korek Mountain',
                'category' => 'mountain',
                'governorate' => 'Erbil',
                'district' => null,
                'lat' => 36.74851,
                'lng' => 44.83501,
                'elevation' => 3365,
                'description_ckb' => 'کۆڕەک لە ناوچەی چۆمانە و شاخێکی بەرزە بە دیمەنی شاخستانی و ناوچە گەشتیارییەکانی دەوروبەر.',
                'description_ar' => 'جبل كورك يقع في منطقة چومان وهو من الجبال المرتفعة ذات المناظر الجبلية والمواقع السياحية المحيطة.',
                'description_en' => 'Korek is a high mountain in the Choman area, surrounded by mountain scenery and tourist sites.',
            ],
            [
                'name_ckb' => 'شەقڵاوە',
                'name_ar' => 'شقلاوة',
                'name_en' => 'Shaqlawa',
                'category' => 'other',
                'governorate' => 'Erbil',
                'district' => 'Shaqlawa',
                'lat' => 36.40000,
                'lng' => 44.33680,
                'elevation' => 870,
                'description_ckb' => 'شەقڵاوە شارێکی مێژوویی و گەشتیارییە لە بناری چیای سەفین و بە سەوزایی و دیمەنە سروشتییەکانی ناسراوە.',
                'description_ar' => 'شقلاوة مدينة تاريخية وسياحية تقع عند سفح جبل سفين وتشتهر بالخضرة والمناظر الطبيعية.',
                'description_en' => 'Shaqlawa is a historic hill town at the foot of Safeen Mountain, known for greenery and scenery.',
            ],
            [
                'name_ckb' => 'ئامێدی',
                'name_ar' => 'العمادية',
                'name_en' => 'Amedi',
                'category' => 'historical',
                'governorate' => 'Duhok',
                'district' => 'Amedi',
                'lat' => 37.09200,
                'lng' => 43.48740,
                'elevation' => 1187,
                'description_ckb' => 'ئامێدی شارۆچکەیەکی مێژووییە لەسەر تەختاییەکی شاخستانی لە پارێزگای دهۆک.',
                'description_ar' => 'العمادية بلدة تاريخية تقع على هضبة جبلية في محافظة دهوك.',
                'description_en' => 'Amedi is a historic town set on a mountain plateau in Duhok Governorate.',
            ],
            [
                'name_ckb' => 'لالش',
                'name_ar' => 'لالش',
                'name_en' => 'Lalish',
                'category' => 'historical',
                'governorate' => null,
                'district' => null,
                'lat' => 36.77150,
                'lng' => 43.30300,
                'elevation' => 717,
                'description_ckb' => 'لالش دۆڵ و پەرستگایەکی مێژوویی و ئایینییە و شوێنێکی گرنگی کولتوورییە لە ناوچەکە.',
                'description_ar' => 'لالش وادٍ وموقع ديني وتاريخي مهم، وله مكانة ثقافية بارزة في المنطقة.',
                'description_en' => 'Lalish is a historic valley and sanctuary with major cultural importance in the region.',
            ],
            [
                'name_ckb' => 'تاڤگەی ئەحمەد ئاوا',
                'name_ar' => 'شلال أحمد آوا',
                'name_en' => 'Ahmad Awa Waterfall',
                'category' => 'waterfall',
                'governorate' => 'Sulaymaniyah',
                'district' => null,
                'lat' => 35.31720,
                'lng' => 46.09030,
                'elevation' => null,
                'description_ckb' => 'تاڤگەی ئەحمەد ئاوا لە پارێزگای سلێمانییە و بە ئاودەربڕین و دیمەنی شاخستانی ناسراوە.',
                'description_ar' => 'شلال أحمد آوا يقع في محافظة السليمانية ويشتهر بالمياه والمناظر الجبلية.',
                'description_en' => 'Ahmad Awa Waterfall is in Sulaymaniyah Governorate, known for its water features and mountain scenery.',
            ],
        ];

        foreach ($locations as $item) {
            $governorateId = $item['governorate']
                ? DB::table('governorates')->where('name_en', $item['governorate'])->value('id')
                : null;

            $districtId = null;
            if ($governorateId && $item['district']) {
                $districtId = DB::table('districts')
                    ->where('governorate_id', $governorateId)
                    ->where('name_en', $item['district'])
                    ->value('id');
            }

            $location = Location::updateOrCreate(
                ['name_en' => $item['name_en']],
                [
                    'category' => $item['category'],
                    'governorate_id' => $governorateId,
                    'district_id' => $districtId,
                    'name_ckb' => $item['name_ckb'],
                    'name_ar' => $item['name_ar'],
                    'name_en' => $item['name_en'],
                    'description_ckb' => $item['description_ckb'],
                    'description_ar' => $item['description_ar'],
                    'description_en' => $item['description_en'],
                    'elevation_meters' => $item['elevation'],
                    'geom' => Point::make($item['lat'], $item['lng'], srid: 4326),
                    'is_verified' => true,
                ]
            );

            $this->command?->line("Seeded: {$location->name_en}");
        }
    }
}
