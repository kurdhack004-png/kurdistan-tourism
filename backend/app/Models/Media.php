<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Media extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $fillable = ['mediable_type', 'mediable_id', 'type', 'storage_key', 'caption'];

    /** Full public URL, resolved from the S3/MinIO disk rather than a stored local path. */
    public function url(): string
    {
        return \Storage::disk('s3')->url($this->storage_key);
    }
}
