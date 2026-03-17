#!/usr/bin/perl

# (c) 2023-2026 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0

use warnings; use strict;
use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);
#use lib("/hp/af/ag/ri/files/perllib");

print header(-charset=>'utf-8');

print "<pre>\n";
print "# PERL: ".$];
print "\n# CGI ENV\n";
foreach my $key (sort keys(%ENV)) {
  print "$key = $ENV{$key}\n";
}

print "\n\n";
print qx/find $_ -name "*.pm"/ foreach ( @INC );

print "</pre>\n";


