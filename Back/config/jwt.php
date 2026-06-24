<?php

return [
    'secret' => env('JWT_SECRET'),
    'ttl_minutes' => (int) env('JWT_TTL_MINUTES', 60),
    'refresh_ttl_days' => (int) env('REFRESH_TOKEN_TTL_DAYS', 7),
    'issuer' => env('APP_URL', 'http://localhost'),
];
