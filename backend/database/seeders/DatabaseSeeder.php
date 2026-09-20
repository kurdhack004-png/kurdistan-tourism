<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $governorates = [
            ['name_ckb' => 'هەولێر', 'name_ar' => 'أربيل', 'name_en' => 'Erbil'],
            ['name_ckb' => 'سلێمانی', 'name_ar' => 'السليمانية', 'name_en' => 'Sulaymaniyah'],
            ['name_ckb' => 'دهۆک', 'name_ar' => 'دهوك', 'name_en' => 'Duhok'],
            ['name_ckb' => 'هەڵەبجە', 'name_ar' => 'حلبجة', 'name_en' => 'Halabja'],
        ];

        foreach ($governorates as $governorate) {
            DB::table('governorates')->updateOrInsert(
                ['name_en' => $governorate['name_en']],
                $governorate
            );
        }

        $ids = DB::table('governorates')->pluck('id', 'name_en');

        $districts = [
            ['Erbil', 'شەقڵاوە', 'شقلاوة', 'Shaqlawa'],
            ['Erbil', 'ڕەواندز', 'راوندوز', 'Rawanduz'],
            ['Sulaymaniyah', 'دوکان', 'دوكان', 'Dukan'],
            ['Duhok', 'ئامێدی', 'العمادية', 'Amedi'],
            ['Halabja', 'حەلبجە', 'حلبجة', 'Halabja'],
        ];

        foreach ($districts as [$gov, $ckb, $ar, $en]) {
            if (!isset($ids[$gov])) continue;
            DB::table('districts')->updateOrInsert(
                ['governorate_id' => $ids[$gov], 'name_en' => $en],
                ['name_ckb' => $ckb, 'name_ar' => $ar]
            );
        }
    }
}
