<?php

return [
    'payments' => [
        // Set this only in the hosting provider's secret environment variables.
        'webhook_secret' => env('PAYMENT_WEBHOOK_SECRET'),
    ],
];
