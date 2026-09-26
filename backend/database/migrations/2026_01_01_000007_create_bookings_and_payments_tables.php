<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("CREATE TYPE booking_status AS ENUM ('pending','confirmed','cancelled','completed')");
        DB::statement("CREATE TYPE payment_method AS ENUM ('fib','visa','cash','bank_transfer')");
        DB::statement("CREATE TYPE payment_status AS ENUM ('pending','paid','failed','refunded')");

        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('accommodation_id')->constrained('accommodations');
            $table->date('check_in');
            $table->date('check_out');
            $table->integer('guests')->default(1);
            $table->string('status')->default('pending');
            $table->decimal('total_price', 10, 2);
            $table->timestamps();
        });
        DB::statement('ALTER TABLE bookings ALTER COLUMN status TYPE booking_status USING status::booking_status');

        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained('bookings');
            $table->string('method');
            $table->string('status')->default('pending');
            $table->decimal('amount', 10, 2);
            $table->string('provider_ref', 120)->nullable(); // FIB/Visa transaction id
            // Prevents double-charging when a client retries a failed request.
            $table->string('idempotency_key', 64)->unique();
            $table->timestamps();
        });
        DB::statement('ALTER TABLE payments ALTER COLUMN method TYPE payment_method USING method::payment_method');
        DB::statement('ALTER TABLE payments ALTER COLUMN status TYPE payment_status USING status::payment_status');
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
        Schema::dropIfExists('bookings');
        DB::statement('DROP TYPE IF EXISTS payment_status');
        DB::statement('DROP TYPE IF EXISTS payment_method');
        DB::statement('DROP TYPE IF EXISTS booking_status');
    }
};
