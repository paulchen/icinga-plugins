<?php

// inspired by https://github.com/jinjie/Nagios-WordPress-Update

// Include your Nagios server IP below
// It is safe to keep 127.0.0.1
$allowed_ips = array(
	'127.0.0.1',
);

// If your Wordpress installation is behind a Proxy like Nginx use 'HTTP_X_FORWARDED_FOR'
if(isset($_SERVER['HTTP_X_FORWARDED_FOR']) && !empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
	$remote_ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
} else {
	$remote_ip = $_SERVER['REMOTE_ADDR'];
}

// Check if the requesting server is allowed
if (! in_array($remote_ip, $allowed_ips))
{
	echo "CRITICAL#IP $remote_ip not allowed.";
	exit;
}

if(!isset($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW'])) {
	header('WWW-Authenticate: Basic realm="Wordpress"');
	http_response_code(401);
	die();
}

require_once('wp-load.php');

require_once('wp-admin/includes/class-wp-site-health.php');
require_once('wp-admin/includes/update.php');
require_once('wp-admin/includes/misc.php');

$health = WP_Site_Health::get_instance();
$reflector = new ReflectionObject($health);
$method = $reflector->getMethod('perform_test');
$method->setAccessible(true);

$tests = $health->get_tests();

$skipped_tests = array('rest_availability', 'authorization_header');

$failed_tests = array();
$successful_tests = array();
foreach ( $tests['direct'] as $name => $test ) {
	if (in_array($name, $skipped_tests)) {
		continue;
	}
	if ( is_string( $test['test'] ) ) {
		$test_function = sprintf(
			'get_test_%s',
			$test['test']
		);

		if ( method_exists( $health, $test_function ) && is_callable( array( $health, $test_function ) ) ) {
			$result = $method->invoke( $health, array( $health, $test_function ) );
		}
	}
	else if ( is_callable( $test['test'] ) ) {
		$result = $method->invoke( $health, array( $test['test'] ) );
	}

	if($result['status'] != 'good') {
		$failed_tests[] = $name;
	}
	else {
		$successful_tests[] = $name;
	}
}

foreach ( $tests['async'] as $name => $test ) {
	if (in_array($name, $skipped_tests)) {
		continue;
	}
	if ( is_string( $test['test'] ) ) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $test['test']);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_USERPWD, "{$_SERVER['PHP_AUTH_USER']}:{$_SERVER['PHP_AUTH_PW']}");
		$response = curl_exec($ch);
		$status_code = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
		curl_close($ch);
		if($status_code < 200 || $status_code > 299) {
			$failed_tests[] = $name;
		}
		else {
			$result = json_decode($response);
			if($result->status != 'good') {
				$failed_tests[] = $name;
			}
			else {
				$successful_tests[] = $name;
			}
		}
	}
}

$response = array('tests' => array(
	'successful' => $successful_tests,
	'failed' => $failed_tests,
	'skipped' => $skipped_tests
));

header('Content-Type: application/json');
print(json_encode($response));
