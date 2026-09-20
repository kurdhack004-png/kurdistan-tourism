<?php

namespace App\Http\Requests;

use App\Models\Accommodation;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreBookingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'accommodation_id' => [
                'required',
                'uuid',
                Rule::exists(Accommodation::class, 'id')->where(fn ($q) =>
                    $q->where('is_active', true)
                      ->whereIn('type', ['hotel', 'house', 'cabin', 'chalet'])
                ),
            ],
            'check_in' => ['required', 'date', 'after_or_equal:today'],
            'check_out' => ['required', 'date', 'after:check_in'],
            'guests' => ['required', 'integer', 'min:1', 'max:20'],
        ];
    }
}
