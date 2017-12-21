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
                                        
$options->getopts();

my $threshold = Monitoring::Plugin::Threshold->set_thresholds(
    warning  => $options->warning . ":",
    critical => $options->critical . ":",
);

alarm $options->timeout;

my $url = sprintf("http://www.pool.ntp.org/scores/%s/json?limit=1",
                  $options->ip);
my $json = get($url);

$plugin->plugin_die("Unable to load monitoring data: $!") unless defined $json;

my $result = decode_json($json);

my $code = $threshold->get_status($result->{'history'}->[0]->{'score'});

$plugin->add_perfdata(
  label => "score",
  value => $result->{'history'}->[0]->{'score'},
  uom => "",
  threshold => $threshold
);

$plugin->plugin_exit($code, "current score: " . $result->{'history'}->[0]->{'score'});
