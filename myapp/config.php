<?php
// Database connection parameters
$db_hostname = "localhost";
$db_port     = 3306;
$db_database = "MyApp_database";
$db_username = "MyApp_dbuser";
$db_password = "MyApp_dbpass";

// Image upload options
$storage_option = "hd";
$hd_folder  = "/var/www/myapp/uploads";

// Simulate latency, in seconds
$latency = 0;

// Cache configuration
$enable_cache = false;
$cache_server = "dns-or-ip-of-memcached-server";
?>
