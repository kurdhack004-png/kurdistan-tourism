<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLocationRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Any authenticated user may submit a location; it stays unverified
        // (is_verified=false) until an admin/guide approves it.
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'category' => ['required', 'in:mountain,cave,lake,river,waterfall,spring,historical,archaeological,nature_reserve,other'],
            'governorate_id' => ['nullable', 'exists:governorates,id'],
            'district_id' => ['nullable', 'exists:districts,id'],
            'name_ckb' => ['required', 'string', 'max:200'],
            'name_ar' => ['nullable', 'string', 'max:200'],
            'name_en' => ['nullable', 'string', 'max:200'],
            'description_ckb' => ['nullable', 'string'],
            'description_en' => ['nullable', 'string'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'elevation_meters' => ['nullable', 'integer'],
        ];
    }
}
