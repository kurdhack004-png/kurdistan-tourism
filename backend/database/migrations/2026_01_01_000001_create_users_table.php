<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('users')) {
            Schema::create('users', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('full_name', 150)->nullable();
                $table->string('email', 190)->unique();
                $table->string('phone_number', 30)->nullable();
                $table->timestamp('email_verified_at')->nullable();
                $table->string('password');
                $table->string('role')->default('tourist');
                $table->string('preferred_lang', 5)->default('ckb');
                $table->boolean('is_active')->default(true);
                $table->rememberToken();
                $table->timestamps();
            });
            return;
        }

        if (! Schema::hasColumn('users', 'full_name')) {
            Schema::table('users', fn (Blueprint $table) => $table->string('full_name', 150)->nullable());
        }
        if (! Schema::hasColumn('users', 'phone_number')) {
            Schema::table('users', fn (Blueprint $table) => $table->string('phone_number', 30)->nullable());
        }
        if (! Schema::hasColumn('users', 'preferred_lang')) {
            Schema::table('users', fn (Blueprint $table) => $table->string('preferred_lang', 5)->default('ckb'));
        }
        if (! Schema::hasColumn('users', 'is_active')) {
            Schema::table('users', fn (Blueprint $table) => $table->boolean('is_active')->default(true));
        }
        if (! Schema::hasColumn('users', 'role')) {
            Schema::table('users', fn (Blueprint $table) => $table->string('role')->default('tourist'));
        }

        DB::statement("UPDATE users SET full_name = COALESCE(full_name, name) WHERE full_name IS NULL");
    }

    public function down(): void {}
};
