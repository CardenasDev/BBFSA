<?php

return [
    'max_file_kb' => (int) env('BULK_LOAD_MAX_FILE_KB', 5120),
    'max_rows' => (int) env('BULK_LOAD_MAX_ROWS', 1000),
];
