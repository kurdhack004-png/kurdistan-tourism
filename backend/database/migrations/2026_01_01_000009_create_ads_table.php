<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ads', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('uuid_generate_v4()'));
            $table->foreignUuid('created_by')->constrained('users');
            $table->string('title_ckb', 200);
            $table->string('title_ar', 200)->nullable();
            $table->string('title_en', 200)->nullable();
            $table->text('description_ckb')->nullable();
            $table->text('description_ar')->nullable();
            $table->text('description_en')->nullable();
            $table->string('image_storage_key', 500)->nullable();
            $table->string('target_url', 1000)->nullable();
            $table->decimal('price_iqd', 12, 2)->default(10000);
            $table->timestampTz('starts_at');
            $table->timestampTz('ends_at');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->index(['is_active','starts_at','ends_at']);
        });
    }

    public function down(): void { Schema::dropIfExists('ads'); }
};
