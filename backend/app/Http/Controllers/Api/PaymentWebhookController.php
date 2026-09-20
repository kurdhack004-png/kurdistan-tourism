<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaymentWebhookController extends Controller
{
    /**
     * Provider-neutral webhook endpoint. Configure the provider-specific
     * adapter to send a signed JSON payload with payment_ref and status.
     */
    public function handle(Request $request)
    {
        $secret = (string) config('services.payments.webhook_secret');
        abort_if($secret === '', 503, 'Payment webhook is not configured.');

        $signature = (string) $request->header('X-Payment-Signature');
        $expected = hash_hmac('sha256', $request->getContent(), $secret);
        abort_unless($signature !== '' && hash_equals($expected, $signature), 401, 'Invalid webhook signature.');

        $data = $request->validate([
            'payment_ref' => ['required', 'string', 'max:120'],
            'status' => ['required', 'in:processing,paid,failed,expired,refunded'],
        ]);

        $payment = DB::transaction(function () use ($data) {
            $payment = Payment::where('provider_ref', $data['payment_ref'])
                ->lockForUpdate()
                ->firstOrFail();

            $allowed = [
                'pending' => ['processing', 'paid', 'failed', 'expired'],
                'processing' => ['paid', 'failed', 'expired'],
                'paid' => ['refunded'],
                'failed' => [],
                'expired' => [],
                'refunded' => [],
            ];

            if ($payment->status !== $data['status']) {
                abort_unless(in_array($data['status'], $allowed[$payment->status] ?? [], true), 409, 'Invalid payment state transition.');
                $payment->update(['status' => $data['status']]);

                if ($data['status'] === 'paid') {
                    $payment->booking()->update(['status' => 'confirmed']);
                }
                if (in_array($data['status'], ['failed', 'expired'], true)) {
                    $payment->booking()->where('status', 'pending')->update(['status' => 'cancelled']);
                }
            }

            return $payment->fresh('booking');
        });

        return response()->json(['success' => true, 'data' => $payment]);
    }
}
