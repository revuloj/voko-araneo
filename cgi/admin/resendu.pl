#!/usr/bin/perl

#
# resendu.pl
# 
# 2018-02-07 Wieland Pusch
#

use strict;

use CGI qw(:standard);
#use CGI::Carp qw(fatalsToBrowser);

print header(-type=>'text/plain', -charset=>'utf-8');

chdir("../../revo");

while (<art/*.html>) {
  print "$_\n" if -z $_;
}
