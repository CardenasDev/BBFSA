<?php

return [
    'evidence_max_kilobytes' => (int) env('TOOL_DELIVERY_EVIDENCE_MAX_KB', 5120),
    'allowed_extensions' => ['jpg', 'jpeg', 'png', 'webp'],
    'allowed_mime_types' => ['image/jpeg', 'image/png', 'image/webp'],
    'extension_mime_types' => [
        'jpg' => ['image/jpeg'],
        'jpeg' => ['image/jpeg'],
        'png' => ['image/png'],
        'webp' => ['image/webp'],
    ],
];
