<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;

class CreateAdminCommand extends Command
{
    protected $signature = 'admin:create
        {--email= : Admin email address}
        {--name= : Admin display name}
        {--password= : Admin password (omit to enter it securely)}';

    protected $description = 'Create or promote a private super-admin account';

    public function handle(): int
    {
        $email = trim((string) ($this->option('email') ?: $this->ask('Admin email')));
        $name = trim((string) ($this->option('name') ?: $this->ask('Admin name')));

        if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $this->error('Invalid email address.');
            return self::FAILURE;
        }

        $password = (string) ($this->option('password') ?: $this->secret('Admin password (12+ characters)'));
        if (strlen($password) < 12) {
            $this->error('Password must be at least 12 characters.');
            return self::FAILURE;
        }

        $user = User::firstOrNew(['email' => $email]);
        $user->full_name = $name;
        $user->role = 'super-admin';
        $user->is_active = true;
        $user->preferred_lang = $user->preferred_lang ?: 'ckb';
        $user->password = $password;
        $user->save();

        $this->info("Super-admin ready: {$user->email}");
        $this->warn('Keep this account private. Do not use it as a normal tourist account.');

        return self::SUCCESS;
    }
}
