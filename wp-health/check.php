<?php

chdir(dirname(__FILE__));

require_once('config.php');

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "$wp_root/wp-health.php");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_USERPWD, "$wp_username:$wp_password");
$response = curl_exec($ch);
if(!$response) {
	echo "UNKNOWN: invalid response\n";
	die(3);
}
$status_code = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
curl_close($ch);
if($status_code < 200 || $status_code > 299) {
	echo "UNKNOWN: http status code $status returned\n";
	die(3);
}

$result = json_decode($response);
if(!$result || !isset($result->tests, $result->tests->successful, $result->tests->failed)) {
	echo "UNKNOWN: invalid JSON response\n";
	die(3);
}

$successful = count($result->tests->successful);
$failed = count($result->tests->failed);
$total = $successful + $failed;

if($failed > 0) {
	echo "CRITICAL: $failed/$total test(s) failed\n";
	die(2);
}

echo "OK: 0/$total tests failed\n";

