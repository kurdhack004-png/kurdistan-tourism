<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('accommodations', function (Blueprint $table) {
            $table->string('name_ar', 200)->nullable()->after('name_ckb');
            $table->string('name_en', 200)->nullable()->after('name_ar');
            $table->text('description_ckb')->nullable()->after('name_en');
            $table->text('description_ar')->nullable()->after('description_ckb');
            $table->text('description_en')->nullable()->after('description_ar');
            $table->string('city_ckb', 120)->nullable()->after('description_en');
            $table->string('city_ar', 120)->nullable()->after('city_ckb');
            $table->string('city_en', 120)->nullable()->after('city_ar');
            $table->decimal('rating', 3, 2)->default(0)->after('price_per_night');
            $table->unsignedInteger('review_count')->default(0)->after('rating');
        });
    }

    public function down(): void
    {
        Schema::table('accommodations', function (Blueprint $table) {
            $table->dropColumn(['name_ar','name_en','description_ckb','description_ar','description_en','city_ckb','city_ar','city_en','rating','review_count']);
        });
    }
};
