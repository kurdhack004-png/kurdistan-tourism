<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('uuid_generate_v4()'));
            $table->string('mediable_type', 50); // 'location' | 'trail' | 'accommodation' | ...
            $table->uuid('mediable_id');
            $table->string('type', 20); // image|video|360|audio|gpx
            $table->string('storage_key', 500); // S3/MinIO object key
            $table->string('caption')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['mediable_type', 'mediable_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media');
    }
};
