<?php
define('SHORTINIT', true);

$wp_load = __DIR__ . '/wp-load.php';
if (!file_exists($wp_load)) {
    http_response_code(503);
    echo 'NOT CONFIGURED';
    exit;
}

require_once $wp_load;

global $wpdb;
$result = $wpdb->get_var('SELECT 1');

if ($result == 1) {
    http_response_code(200);
    echo 'OK';
} else {
    http_response_code(503);
    echo 'ERROR';
}
