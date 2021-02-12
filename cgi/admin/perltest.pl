#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
#use lib("/var/www/vhosts/web277.cyberwebserver-21.de/files/perllib");

print header(-charset=>'utf-8');

print "<pre>\n";
print "# PERL: ".$];
print "\n# CGI ENV\n";
foreach $key (sort keys(%ENV)) {
  print "$key = $ENV{$key}\n";
}

print "\n\n";
print qx/find $_ -name "*.pm"/ foreach ( @INC );

print "</pre>\n";


