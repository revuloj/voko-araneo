#!/usr/bin/perl

use strict;
#use Encode;
use utf8; binmode STDOUT, ":utf8";

use CGI qw(:standard escape);
use CGI::Carp qw(fatalsToBrowser);
#use JSON;

use HTTP::Request;
use LWP::UserAgent;

my $wiki_api_url = 'https://eo.wikipedia.org/w/api.php';

#my $json_parser = JSON->new->allow_nonref;
my $s = param('sercho');

print header(-type=>'application/json',-charset=>'utf-8');

# ni kontrolu la serĉatan vorton, sed ja permesu kelkajn apartajn signojn por
# permesi ion kiel (n,p)-matrico ks:
unless ($s =~ /^[\pL\d\*\(\-][-'\(\),!\.\h\pL]{0,50}$/) {
    exit 1;
}

# nun ni serĉu je interlingvaj ligoj de Vikipedio (langlinks)
my $sercho = escape($s);
my $header = ['Accept' => 'application/json'];
my $request = HTTP::Request->new(GET=>"$wiki_api_url?action=query&&titles=$sercho"
    ."&prop=langlinks&lllimit=500&format=json&rawcontinue",$header);

my $ua = LWP::UserAgent->new();
my $response = $ua->request($request);

if ($response->is_success) {
    print $response->decoded_content;
    # jam estas en JSON... my $hashref = $json_parser->decode($response->decoded_content);
} else {
    die $response->status_line;
}


