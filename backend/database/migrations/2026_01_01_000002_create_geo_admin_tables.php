<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('governorates', function (Blueprint $table) {
            $table->id();
            $table->string('name_ckb', 100);
            $table->string('name_ar', 100)->nullable();
            $table->string('name_en', 100);
        });

        Schema::create('districts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('governorate_id')->constrained('governorates');
            $table->string('name_ckb', 100);
            $table->string('name_ar', 100)->nullable();
            $table->string('name_en', 100);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('districts');
        Schema::dropIfExists('governorates');
    }
};
