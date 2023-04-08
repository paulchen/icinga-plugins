#!/usr/bin/perl -w

use strict;
use LWP::Simple;
use JSON qw( decode_json );
use Monitoring::Plugin;
use Monitoring::Plugin::Getopt;
use Monitoring::Plugin::Threshold;
use Data::Dumper;

my $plugin = Monitoring::Plugin->new(shortname => "check_score");

my $options = Monitoring::Plugin::Getopt->new(
    usage => "Usage: %s [OPTIONS]",
    version => "1.0.0",
);
$options->arg(
    spec => "critical|c=i",
    help => "Score threshold for a critical warning",
    required => 0,
    default => 10,
);
$options->arg(
    spec => "warning|w=i",
    help => "Score threshold for a warning",
    required => 0,
    default => 12,
);
$options->arg(
    spec => "ip=s",
    help => "IP address of NTP server",
    required => 1,
);
$options->arg(
    spec => "monitor=s",
    help => "Name of the monitor to be checked",
    required => 0,
    default => "recentmedian",
);
                                        
$options->getopts();

my $threshold = Monitoring::Plugin::Threshold->set_thresholds(
    warning  => $options->warning . ":",
    critical => $options->critical . ":",
);

alarm $options->timeout;

my $url = sprintf("http://www.pool.ntp.org/scores/%s/json?limit=200&monitor=*",
                  $options->ip);
my $json = get($url);

$plugin->plugin_die("Unable to load monitoring data: $!") unless defined $json;

my $monitor_name = $options->monitor;
my $result = decode_json($json);
my $score;
my $monitors = $result->{'monitors'};
foreach my $item (@$monitors) {
	if ($item->{'name'} eq $monitor_name) {
		$score = $item->{'score'};
		last;
	}
}
if (not length $score) {
	$plugin->plugin_die("No score for monitor $monitor_name found");
}

my $code = $threshold->get_status($score);

$plugin->add_perfdata(
  label => "score",
  value => $result->{'history'}->[0]->{'score'},
  uom => "",
  threshold => $threshold
);

$plugin->plugin_exit($code, "current score: " . $result->{'history'}->[0]->{'score'});
