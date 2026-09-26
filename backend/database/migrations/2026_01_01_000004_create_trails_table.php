<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trails', function (Blueprint $table) {
            $table->id();
            $table->foreignId('location_id')->nullable()->constrained('locations');
            $table->string('name_ckb', 200);
            $table->string('difficulty', 20)->default('moderate'); // easy|moderate|hard
            $table->decimal('distance_km', 6, 2)->nullable();
            $table->integer('elevation_gain_m')->nullable();
            $table->jsonb('waypoints')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users');
            $table->timestamps();
        });

        // GPX/GeoJSON tracks live natively as a spatial LineString, not a blob
        DB::statement('ALTER TABLE trails ADD COLUMN route geography(LineString,4326)');
        DB::statement('CREATE INDEX idx_trails_route ON trails USING GIST (route)');
    }

    public function down(): void
    {
        Schema::dropIfExists('trails');
    }
};
