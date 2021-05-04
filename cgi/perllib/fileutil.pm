#!/usr/bin/perl

#
# parseart.pm
# 
# 2021 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0
#
# funkcioj por enlegi kompletan dosiero, JSON-dosieron...

use strict;
package fileutil;

use JSON;
my $json_parser = JSON->new->allow_nonref;

my $debug = 0;


# legi JSON-dosieron
sub read_json_file {
	my $file = shift;
  	my $j = read_file($file);

	print ("json file: $file\n") if ($debug);

	unless ($j) {
		warn("Malplena aŭ mankanta JSON-dosiero '$file'\n");
		return;
	}
    print(substr($j,0,20)."...\n") if ($debug);

    my $parsed;
	eval {
    	$parsed = $json_parser->decode($j); 1;
	} or do {
  		my $error = $@;
		die("Ne eblis analizi enhavon de JSON-dosiero '$file': $error\n");
	};

	return $parsed;	  
}


# legi dosieron
sub read_file {
	my $file = shift;
	unless (open FILE, $file) {
		warn("Ne povis malfermi '$file': $!\n"); return;
	}
	my $text = join('',<FILE>);
	close FILE;
	return $text;
}

1;