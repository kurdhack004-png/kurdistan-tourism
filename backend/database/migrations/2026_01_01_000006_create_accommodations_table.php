<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('accommodations', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('uuid_generate_v4()'));
            $table->foreignUuid('owner_id')->nullable()->constrained('users');
            $table->string('type', 30); // hotel|chalet|guesthouse|campsite|eco_lodge
            $table->string('name_ckb', 200);
            $table->decimal('price_per_night', 10, 2)->nullable();
            $table->jsonb('amenities')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        DB::statement('ALTER TABLE accommodations ADD COLUMN geom geography(Point,4326) NOT NULL');
        DB::statement('CREATE INDEX idx_accommodations_geom ON accommodations USING GIST (geom)');
    }

    public function down(): void
    {
        Schema::dropIfExists('accommodations');
    }
};
