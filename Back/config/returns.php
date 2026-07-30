<?php

return [
    'max_evidence_kilobytes' => 5120,
    'allowed_extensions' => ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'doc', 'docx'],
    'allowed_mime_types' => [
        'application/pdf',
        'image/jpeg',
        'image/png',
        'image/webp',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/zip',
    ],
    'extension_mime_types' => [
        'pdf' => ['application/pdf'],
        'jpg' => ['image/jpeg'],
        'jpeg' => ['image/jpeg'],
        'png' => ['image/png'],
        'webp' => ['image/webp'],
        'doc' => ['application/msword'],
        'docx' => ['application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/zip'],
    ],
];
