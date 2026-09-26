<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->string('reviewable_type', 50); // 'location' | 'accommodation' | 'trail'
            $table->unsignedBigInteger('reviewable_id');
            $table->smallInteger('rating'); // CHECK constraint added below
            $table->text('comment')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['reviewable_type', 'reviewable_id']);
        });
        DB::statement('ALTER TABLE reviews ADD CONSTRAINT rating_range CHECK (rating BETWEEN 1 AND 5)');

        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('location_id')->nullable()->constrained('locations');
            $table->string('name_ckb', 200);
            $table->timestampTz('starts_at');
            $table->timestampTz('ends_at')->nullable();
            $table->text('description_ckb')->nullable();
            $table->timestamp('created_at')->useCurrent();
        });

        Schema::create('offline_packages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('district_id')->nullable()->constrained('districts');
            $table->string('name_ckb', 200);
            $table->string('bundle_storage_key', 500); // pre-built tile+data bundle in object storage
            $table->integer('size_mb')->nullable();
            $table->integer('version')->default(1);
            $table->timestamp('updated_at')->useCurrent();
        });

        Schema::create('favorites', function (Blueprint $table) {
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('favoritable_type', 50);
            $table->unsignedBigInteger('favoritable_id');
            $table->timestamp('created_at')->useCurrent();

            $table->primary(['user_id', 'favoritable_type', 'favoritable_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('favorites');
        Schema::dropIfExists('offline_packages');
        Schema::dropIfExists('events');
        Schema::dropIfExists('reviews');
    }
};
