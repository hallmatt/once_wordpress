<?php
/**
 * Plugin Name: Once Integration
 * Description: Connects WordPress to Once platform services (SMTP, etc.)
 */

// Configure SMTP from Once environment variables
add_action('phpmailer_init', function ($phpmailer) {
    $host = getenv('SMTP_SERVER');
    if (!$host) {
        return;
    }

    $phpmailer->isSMTP();
    $phpmailer->Host       = $host;
    $phpmailer->Port       = getenv('SMTP_PORT') ?: 587;
    $phpmailer->SMTPAuth   = true;
    $phpmailer->Username   = getenv('SMTP_LOGIN');
    $phpmailer->Password   = getenv('SMTP_PASSWORD');
    $phpmailer->SMTPSecure = 'tls';

    $from = getenv('SMTP_FROM');
    if ($from) {
        $phpmailer->From     = $from;
        $phpmailer->FromName = getenv('SMTP_FROM_NAME') ?: get_bloginfo('name');
    }
});
