<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('locations')) {
            Schema::create('locations', function (Blueprint $table) {
                $table->id();
                $table->string('name')->nullable();
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->string('category')->nullable();
                $table->string('region')->nullable();
                $table->string('governorate')->nullable();
                $table->foreignId('governorate_id')->nullable()->constrained('governorates');
                $table->foreignId('district_id')->nullable()->constrained('districts');
                $table->string('name_ckb', 200)->nullable();
                $table->string('name_ar', 200)->nullable();
                $table->string('name_en', 200)->nullable();
                $table->text('description_ckb')->nullable();
                $table->text('description_en')->nullable();
                $table->integer('elevation_meters')->nullable();
                $table->boolean('is_verified')->default(false);
                $table->foreignId('created_by')->nullable()->constrained('users');
                $table->decimal('latitude', 10, 7)->nullable();
                $table->decimal('longitude', 10, 7)->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
            DB::statement('ALTER TABLE locations ADD COLUMN geom geography(Point,4326)');
            DB::statement('CREATE INDEX IF NOT EXISTS locations_geom_gist ON locations USING GIST (geom)');
            return;
        }

        foreach ([
            'name_ckb' => fn (Blueprint $t) => $t->string('name_ckb', 200)->nullable(),
            'name_ar' => fn (Blueprint $t) => $t->string('name_ar', 200)->nullable(),
            'name_en' => fn (Blueprint $t) => $t->string('name_en', 200)->nullable(),
            'description_ckb' => fn (Blueprint $t) => $t->text('description_ckb')->nullable(),
            'description_en' => fn (Blueprint $t) => $t->text('description_en')->nullable(),
            'elevation_meters' => fn (Blueprint $t) => $t->integer('elevation_meters')->nullable(),
            'is_verified' => fn (Blueprint $t) => $t->boolean('is_verified')->default(false),
            'governorate_id' => fn (Blueprint $t) => $t->foreignId('governorate_id')->nullable(),
            'district_id' => fn (Blueprint $t) => $t->foreignId('district_id')->nullable(),
            'created_by' => fn (Blueprint $t) => $t->foreignId('created_by')->nullable(),
        ] as $column => $definition) {
            if (! Schema::hasColumn('locations', $column)) {
                Schema::table('locations', $definition);
            }
        }

        if (! Schema::hasColumn('locations', 'geom')) {
            DB::statement('ALTER TABLE locations ADD COLUMN geom geography(Point,4326)');
            DB::statement('CREATE INDEX IF NOT EXISTS locations_geom_gist ON locations USING GIST (geom)');
        }

        DB::statement("UPDATE locations SET name_ckb = COALESCE(name_ckb, name) WHERE name_ckb IS NULL");
        DB::statement("UPDATE locations SET description_ckb = COALESCE(description_ckb, description) WHERE description_ckb IS NULL");
        DB::statement("UPDATE locations SET name_en = COALESCE(name_en, name) WHERE name_en IS NULL");
        DB::statement("UPDATE locations SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude),4326)::geography WHERE geom IS NULL AND latitude IS NOT NULL AND longitude IS NOT NULL");
    }

    public function down(): void {}
};
