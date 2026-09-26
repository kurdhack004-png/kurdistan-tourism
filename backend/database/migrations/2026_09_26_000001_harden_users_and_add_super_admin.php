<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('users', 'full_name')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('full_name', 150)->nullable();
            });
            if (Schema::hasColumn('users', 'name')) {
                DB::table('users')->whereNull('full_name')->update(['full_name' => DB::raw('name')]);
            }
        }

        if (! Schema::hasColumn('users', 'phone_number')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('phone_number', 30)->nullable();
            });
        }

        if (! Schema::hasColumn('users', 'preferred_lang')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('preferred_lang', 5)->default('ckb');
            });
        }

        if (! Schema::hasColumn('users', 'is_active')) {
            Schema::table('users', function (Blueprint $table) {
                $table->boolean('is_active')->default(true);
            });
        }

        if (! Schema::hasColumn('users', 'role')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('role')->default('tourist');
            });
        }

        // Existing installations created by the original PostgreSQL migration use
        // an enum. Newer/compatibility installations may use varchar.
        $enumExists = DB::selectOne(
            "SELECT 1 FROM pg_type WHERE typname = 'user_role' LIMIT 1"
        );

        if ($enumExists) {
            DB::statement("ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'super-admin'");
        }
    }

    public function down(): void
    {
        // Deliberately non-destructive: these columns may be used by existing
        // installations and older application versions.
    }
};
