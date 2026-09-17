<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement('CREATE EXTENSION IF NOT EXISTS postgis');
        DB::statement('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');
        DB::statement('CREATE EXTENSION IF NOT EXISTS pg_trgm');

        DB::statement("CREATE TYPE user_role AS ENUM ('tourist','guide','accommodation_owner','admin')");

        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('uuid_generate_v4()'));
            $table->string('full_name', 150);
            $table->string('email', 190)->unique();
            $table->string('phone_number', 30)->nullable();
            $table->string('password'); // hashed via Laravel's password_hash (bcrypt/argon2id)
            $table->string('role')->default('tourist'); // cast to the user_role enum below
            $table->string('preferred_lang', 5)->default('ckb');
            $table->boolean('is_active')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });

        // Bind the plain "role" varchar to the Postgres enum type.
        DB::statement('ALTER TABLE users ALTER COLUMN role TYPE user_role USING role::user_role');
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
        DB::statement('DROP TYPE IF EXISTS user_role');
    }
};
