<?php
/**
 * Plugin Name: Nginx Cache Purge
 * Description: Purges the nginx fastcgi_cache when content changes.
 */

function nginx_cache_purge_all() {
    $cache_dir = '/tmp/nginx-cache';
    if (is_dir($cache_dir)) {
        exec("rm -rf " . escapeshellarg($cache_dir) . "/*");
    }
}

add_action('save_post', 'nginx_cache_purge_all');
add_action('delete_post', 'nginx_cache_purge_all');
add_action('trashed_post', 'nginx_cache_purge_all');
add_action('comment_post', 'nginx_cache_purge_all');
add_action('edit_comment', 'nginx_cache_purge_all');
add_action('delete_comment', 'nginx_cache_purge_all');
add_action('switch_theme', 'nginx_cache_purge_all');
add_action('wp_update_nav_menu', 'nginx_cache_purge_all');
add_action('customize_save_after', 'nginx_cache_purge_all');
