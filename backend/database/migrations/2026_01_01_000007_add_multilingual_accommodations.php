<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('accommodations')) return;

        foreach ([
            'name_ar' => fn (Blueprint $t) => $t->string('name_ar', 200)->nullable(),
            'name_en' => fn (Blueprint $t) => $t->string('name_en', 200)->nullable(),
            'description_ckb' => fn (Blueprint $t) => $t->text('description_ckb')->nullable(),
            'description_ar' => fn (Blueprint $t) => $t->text('description_ar')->nullable(),
            'description_en' => fn (Blueprint $t) => $t->text('description_en')->nullable(),
            'city_ckb' => fn (Blueprint $t) => $t->string('city_ckb', 120)->nullable(),
            'city_ar' => fn (Blueprint $t) => $t->string('city_ar', 120)->nullable(),
            'city_en' => fn (Blueprint $t) => $t->string('city_en', 120)->nullable(),
            'rating' => fn (Blueprint $t) => $t->decimal('rating', 3, 2)->default(0),
            'review_count' => fn (Blueprint $t) => $t->unsignedInteger('review_count')->default(0),
        ] as $column => $definition) {
            if (! Schema::hasColumn('accommodations', $column)) {
                Schema::table('accommodations', $definition);
            }
        }
    }

    public function down(): void {}
};
