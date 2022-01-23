#!/usr/bin/perl

use strict;
#use Encode;
use utf8; binmode STDOUT, ":utf8";
use JSON;

use HTTP::Request;
use LWP::UserAgent;

my $json_parser = JSON->new->allow_nonref;

my $sercxu_url = 'https://reta-vortaro.de/cgi-bin/sercxu-json-1f.pl';
#my $sercxu_url = 'http://0.0.0.0:8088/cgi-bin/sercxu-json-1f.pl';
#my $sercxu_url = 'http://0.0.0.0:8088/cgi-bin/admin/perltest.pl';
my $header = ['Accept' => 'application/json', 'Accept-Language' => 'en,de,fr,nl'];
my $request = HTTP::Request->new(GET=>"$sercxu_url?sercxata=kubo",$header);

my $ua = LWP::UserAgent->new();
my $response = $ua->request($request);

if ($response->is_success) {
    print $response->decoded_content;
    my $hashref = $json_parser->decode($response->decoded_content);

    # nun ni povas uzi $hashref kiel kutime en Perlo:
    # print join(",", keys %$hashref),"\n";
    # print join(",", values %$hashref);

    # tamen por la testo ni retradukas al JSON kaj skribas tiel:
    print $json_parser->encode($hashref);
}
else {
    die $response->status_line;
};