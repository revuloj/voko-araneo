#!/usr/bin/perl

#
# sercxu.pl
# 
# 2006-2007 Wieland Pusch
# 2006 Bart Demeyere
# 2021 Wolfram Diestel
#
# (c) laŭ permesilo GPL 2.0

use strict;

#use CGI qw(:standard *table -utf8);
use CGI qw(:standard *table);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
use URI::Escape;

use utf8;
#use feature 'unicode_strings';
use open ':std', ':encoding(UTF-8)';

my $LIMIT_lng = 7;
my $LIMIT_rec = 100;

#$| = 1;
## my $verbose=1; # 1 = debugging...

#if ($formato eq "txt") {
  print header( 
    -type => 'text/plain',
		-charset => 'utf-8'
  );
#} 


my $sercxata = param('sercxata') if param('sercxata'); utf8::decode($sercxata);
my $lng = param('lng') || ''; # serĉlingvo
my @lingvoj = ();
my $trdlng = trdlng(); # aldonaj traduklingvoj ('en','fr'...) aŭ ('')

#debug: print $trdlng,"\n";

if ($sercxata eq "") {
  print "Bonvolu meti ion, kion serĉi";
  exit;
}

if ($sercxata eq "%") {
  print "Bonvolu ne serĉi \"%\".";
  exit;
}


###################################################################
#  serĉo en datumbazo                                             #
###################################################################


# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use revodb;

# Malfermu la datumbazon
my $dbh = revodb::connect();

# necesas!
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set names utf8");
$dbh->do('SET SESSION group_concat_max_len = 4048');

my $regulira = $sercxata =~ /[.^$\[\(\|+?{\\]/;
my $komparo = '=';

if ($regulira) {
  $komparo = 'REGEXP';

} elsif ($sercxata =~ /[%_]/) {
  $komparo = 'LIKE';
}

my $sth;


# lng = eo || ''
if ($lng eq 'eo' or $lng eq '') {

    $sth = $dbh->prepare(
      "SELECT GROUP_CONCAT(DISTINCT kap SEPARATOR ', ') AS kap, r3kap.mrk, "
        ."GROUP_CONCAT(DISTINCT CONCAT(lng,':',CASE WHEN trd THEN trd ELSE ind END) "
          ."ORDER BY lng SEPARATOR '|') AS trd "
      ."FROM r3kap "
      ."LEFT JOIN r3mrk ON r3mrk.drv = r3kap.mrk "
      ."LEFT JOIN r3trd ON r3trd.mrk = r3mrk.mrk AND r3trd.lng IN $trdlng "
      ."WHERE kap $komparo ? GROUP BY r3kap.mrk LIMIT $LIMIT_rec");

    eval {
      #print $trdlng;
      $sth->execute($sercxata);
    };      

# $lng != eo...
} else {

    $sth = $dbh->prepare(
      "SELECT GROUP_CONCAT(DISTINCT v3traduko.ind SEPARATOR ', ') AS kap, v3traduko.mrk, "
        ."CONCAT('eo:',GROUP_CONCAT(DISTINCT kap SEPARATOR ', ')) AS eo, "
        ."GROUP_CONCAT(DISTINCT CONCAT(r3trd.lng,':',r3trd.ind) ORDER BY r3trd.lng SEPARATOR '|') AS trd "
      ."FROM v3traduko "
      ."LEFT JOIN r3trd ON r3trd.mrk = v3traduko.mrk AND r3trd.lng IN $trdlng "
      ."WHERE v3traduko.lng = ? AND v3traduko.ind $komparo ? " 
      ."GROUP BY v3traduko.mrk LIMIT $LIMIT_rec");

    eval {
      $sth->execute($lng,$sercxata);
    };      
}

if ($@) {
  # $sth->err and $DBI::err will be true if error was from DBI
  if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
    print "Eraro: La rektaj krampoj ([ ]) ne kongruas.\n";
  } else {
    print "Err ".$sth->err." - $@";
  }
} else {

  my $neniu_trafo = 1;
  # ni ricevis rezulton, kiun ni devas aranĝo laŭlinie ...
  while (my $ref = $sth->fetchrow_hashref()) {
    skribu_linion($ref);
    $neniu_trafo = 0;
  }
  
  print "Neniu trafo..." if $neniu_trafo;

}

$dbh->disconnect() or die "Ni ne povis fermi la datumbazon!";
exit;




###################################################################
# helpunkcioj por serĉo                                           #
###################################################################

sub skribu_linion {
  my $ref = shift;
  my $tradukoj = {};

  # transformu mrk al href
  my $href = $ref->{mrk}; $href =~ s|^([a-z0-9]+)\.|/revo/art/$1.html#$1.|;

  # kunkolektu la unuopajn tradukoj laŭ lingvo
  if ($ref->{eo}) {
    my @s = split ':', $ref->{eo};
    @{$tradukoj->{eo}} = splice(@s, 1, 1);
  }

  for my $trd (split '\|', $ref->{trd}) {
    my ($l,$t) = split ':', $trd;
    $tradukoj->{$l} = () unless $tradukoj->{$l};
    push @{$tradukoj->{$l}}, $t;
  }

  # ordigu la tradukojn laŭ la ordo de petitaj trd-lingvoj
  my @trd_lst = ();
  for my $lng (@lingvoj) {
    if ($tradukoj->{$lng}) {
      push @trd_lst, join(',',@{$tradukoj->{$lng}});
    } else {
      push @trd_lst, '';
    }
  }

  print join('|',$ref->{kap}.', '.$href,@trd_lst), "\n";
}

sub trdlng {
  # my @lingvoj;
  {
    my @a = split ",", param('trd');
    for my $l (@a) {
      $l =~ s/^([a-z]{2,3}).*$/$1/;
      #unless (grep(/$l/,@preferataj_lingvoj)) {
      push @lingvoj, ($l);
      #}
      #print "DEBUG ".$#preferataj_lingvoj." ".$LIMIT_lng;
      last if (($#lingvoj + 1) == $LIMIT_lng);
    #  $preferata_lingvo = 'nenio' if $preferata_lingvo eq '';
    }
  }

  #print "DEBUG ".join(',',@preferataj_lingvoj);
  # @lingvoj = ('en') unless (@lingvoj); 
  return "('".join("','",@lingvoj)."')";
}
