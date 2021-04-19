#!/usr/bin/perl

#
# revo::encode.pm
# 
# 2008-02-09 Wieland Pusch
#

use strict;
#use warnings;

package revo::encodex;

use utf8;
use Encode;
use HTML::Entities;
use lib("/hp/af/ag/ri/files/perllib");
use revo::voko_entities;

use CGI qw(:standard); 	# nur por verbose

######################################################################
sub encode($$;$) {
  my $str = shift @_;
  my $verbose = shift @_;
  return encode2($str, 0, $verbose);
}

######################################################################
sub encode2 {
  my $str = shift @_;
  my $flag = shift @_;
  my $verbose = shift @_;

  my $enc = "utf-8";
  # $str = Encode::decode($enc, $str) unless Encode::is_utf8($str);

  # <!-- diversaj -->
  if ($flag<10) {
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
  #  $str =~ s/'/&apos;/g;
  #  $str =~ s/'/&minute;/g;
    $str =~ s/"/&quot;/g;
  }

  my @res = split('', $str);

  my $n=0;
  my $map = revo::voko_entities::entities;
  for my $chr (@res) {
    if (ord($chr) > 127) {
      my $ent = $map->{$chr};
      if ($ent) {
        $res[$n] = "&$ent;";
      } else {
        $res[$n] = "&#".ord($chr).";";
      }
    }
    $n++;
  } # ..for

  return join('',@res);
}

1;

