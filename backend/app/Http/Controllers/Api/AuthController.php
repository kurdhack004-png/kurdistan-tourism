<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $data = $request->validate([
            'full_name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:190', 'unique:users,email'],
            'phone_number' => ['nullable', 'string', 'max:30'],
            // Enforced strength — the V8.1 starter accepted anything.
            'password' => ['required', 'string', 'min:10', 'confirmed'],
        ]);

        $user = User::create([
            ...$data,
            'password' => Hash::make($data['password']), // bcrypt/argon2id, never plaintext
            'role' => 'user',
        ]);

        $token = $user->createToken('mobile', ['*'], now()->addDays(30))->plainTextToken;

        return response()->json(['success' => true, 'token' => $token, 'user' => $user], 201);
    }

    public function login(Request $request)
    {
        $key = 'login:' . $request->ip();

        // Five attempts per minute per IP — the V8.1 starter had no rate limiting at all.
        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);
            return response()->json([
                'success' => false,
                'error' => "Too many attempts. Try again in {$seconds}s.",
            ], 429);
        }

        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if (! Auth::attempt($credentials)) {
            RateLimiter::hit($key, 60);
            throw ValidationException::withMessages(['email' => ['Invalid credentials.']]);
        }

        RateLimiter::clear($key);

        $user = Auth::user();
        $token = $user->createToken('mobile', ['*'], now()->addDays(30))->plainTextToken;

        return response()->json(['success' => true, 'token' => $token, 'user' => $user]);
    }

    public function me(Request $request)
    {
        return response()->json(['success' => true, 'user' => $request->user()]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['success' => true]);
    }
}
