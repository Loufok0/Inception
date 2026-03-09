<?php
// Settings from .env
define('DB_NAME', getenv('WORDPRESS_DB_NAME') ?: '42_inception');
define('DB_USER', getenv('WORDPRESS_DB_USER') ?: 'user42');
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD') ?: 'user42');
define('DB_HOST', getenv('WORDPRESS_DB_HOST') ?: 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Debug mode
define('WP_DEBUG', getenv('WP_DEBUG') === 'true');

// Absolute path
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

// Table prefix
$table_prefix = 'wp_';

// Load WordPress
require_once ABSPATH . 'wp-settings.php';
