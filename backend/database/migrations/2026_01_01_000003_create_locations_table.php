<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("CREATE TYPE location_category AS ENUM (
            'mountain','cave','lake','river','waterfall','spring',
            'historical','archaeological','nature_reserve','other'
        )");

        Schema::create('locations', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('uuid_generate_v4()'));
            $table->string('category'); // bound to location_category enum below
            $table->foreignId('governorate_id')->nullable()->constrained('governorates');
            $table->foreignId('district_id')->nullable()->constrained('districts');
            $table->string('name_ckb', 200);
            $table->string('name_ar', 200)->nullable();
            $table->string('name_en', 200)->nullable();
            $table->text('description_ckb')->nullable();
            $table->text('description_en')->nullable();
            $table->integer('elevation_meters')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->foreignUuid('created_by')->nullable()->constrained('users');
            $table->timestamps();
        });

        DB::statement('ALTER TABLE locations ALTER COLUMN category TYPE location_category USING category::location_category');

        // geography(Point,4326) — a real spatial column, not separate lat/lng floats
        DB::statement('ALTER TABLE locations ADD COLUMN geom geography(Point,4326) NOT NULL');
        DB::statement('CREATE INDEX idx_locations_geom ON locations USING GIST (geom)');
        DB::statement('CREATE INDEX idx_locations_name_trgm ON locations USING GIN (name_ckb gin_trgm_ops)');
    }

    public function down(): void
    {
        Schema::dropIfExists('locations');
        DB::statement('DROP TYPE IF EXISTS location_category');
    }
};
