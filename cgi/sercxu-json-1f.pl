#!/usr/bin/perl 
#
# sercxu-json
# 
# (c) permesilo: GPL 2.0
# 2006__ Wieland Pusch, Bart Demeyere
# 2007__ Wieland Pusch
# 2012-2021 __ Wolfram Diestel

use strict;

#use CGI qw(:standard *table);
##use CGI qw(:standard -utf8);
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
use URI::Escape;

use utf8;
#use open ':std', ':encoding(UTF-8)';
binmode(STDOUT, ":utf8");

use JSON;
my $json_parser = JSON->new->allow_nonref;

#$| = 1;

my $debug = 0;
my $LIMIT_eo = 50;
my $LIMIT_lng = 3;
my $LIMIT_trd = 250;

#print "Content-type: text/html; charset=utf-8\n\n";

# testu ekz. per:
# perl sercxu-json.pl "sercxata=test%&cx=1&moktesto=0"


# komenco
print "Content-type: application/json; charset=utf-8\n\n";


#### preparu stirantajn parametrojn  ####

### my %unicode = ( cx => "ĉ", gx => "ĝ", hx => "ĥ", jx => "ĵ", sx => "ŝ", ux => "ŭ" );

my $max_entries = 100;
my $neniu_trafo = 1;
my $formato = "json";

# kion serĉi
#my $sercxata = param('q2');
my $sercxata = param('sercxata'); #if param('sercxata');
#? utf8::decode($sercxata);
 
# ĉu traduki cx al ĉ ktp.
my $cx2cx = param('cx');
#$cx2cx = "checked" if $cx2cx;

# ĉu serĉi en nur unu lingvo?
#my $param_lng = param('lng');
#$param_lng = '' unless $param_lng;

# pado al Revo-artikoloj
my $pado = "..";
$pado = "/revo" if param('pado') eq 'revo';

#$ENV{HTTP_ACCEPT_LANGUAGE} = ''; # por testi

#### eltrovu preferatan lingvon de la uzanto laŭ la retumilo ####
### PLIBONIGU: limigu preferatajn lingvojn al 3 aŭ 5!
my @preferataj_lingvoj;
{
  my @a = split ",", $ENV{HTTP_ACCEPT_LANGUAGE};
  for my $l (@a) {
    #$preferata_lingvo = shift @a if $preferata_lingvo =~ /^eo/;
    $l =~ s/^([a-z]{2,3}).*$/$1/;
    unless (grep(/$l/,@preferataj_lingvoj)) {
      push @preferataj_lingvoj, ($l) if ($l);
    }
    #print "DEBUG ".$#preferataj_lingvoj." ".$LIMIT_lng;
    last if (($#preferataj_lingvoj + 1) == $LIMIT_lng);
  #  $preferata_lingvo = 'nenio' if $preferata_lingvo eq '';
  }
}

#print "DEBUG ".join(',',@preferataj_lingvoj);

@preferataj_lingvoj = ('en') unless (@preferataj_lingvoj); 
my $pref_lng = "('".join("','",@preferataj_lingvoj)."')";

###################################################################
#  serĉo en datumbazo                                             #
###################################################################


# propraj perl moduloj estas en:
#use lib ("./perllib");
use lib("/hp/af/ag/ri/files/perllib");
use revodb;
#use eosort;

# serĉo en la datumbazo
my $dbh = revodb::connect();
# necesas!
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

#use Time::HiRes qw (gettimeofday tv_interval);
Sercxu($sercxata, $pref_lng);
$dbh->disconnect() or die "Malkonekto de la datumbazo ne funkciis";

# fino
#print "\n]\n";
exit;


###################################################################
# funkcioj por serĉo                                              #
###################################################################


sub Sercxu
{
  my ($sercxata, $pref_lng) = @_;
  #my $tempo = [gettimeofday];
  my ($sth);

  # $komparo estas unu el: =, LIKE, REGEXP
  my $komparo = '=';
  if ($sercxata =~ /[.^$\[\(\|+?{\\]/) {
    $komparo = 'REGEXP'
  } elsif ($sercxata =~ /[%_]/) {
    $komparo = 'LIKE';
  };

  my $QUERY =
      "SELECT mrk, kap, num, lng, trd " 
    ."FROM v3esperanto "
    ."WHERE kap $komparo ? AND lng IN $pref_lng "
    ."ORDER BY kap LIMIT $LIMIT_eo";
  $sth = $dbh->prepare($QUERY);

  # ekde mySQL 5.6. ni povus uzi GROUP_CONCAT por kunigi ĉiujn tradukojn
  # de unu lingvo en unu signoĉeno!      

  my $trovoj_eo;
  my $trovoj_trd;

  eval {
    print "\n\n$QUERY\n" if ($debug);
    print "serĉu: $sercxata\n" if ($debug);
    $sth->execute($sercxata);
    ###exit;
  };

  # kontrolu kaj eldonu erarojn, aliokaze la rezultojn
  # FARENDA: necesas adapti por json
  if ($@) {
    if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
      print "Eraro: La rektaj krampoj ([ ]) ne paras.<br>\n";
    } else {
      print "Err ".$sth->err." - $@";
    }
  } else {
    $trovoj_eo = $sth->fetchall_arrayref(); 
  }


  my $QUERY = 
      "SELECT mrk, kap, num, lng, ind, trd "
    ."FROM v3traduko "
    ."WHERE ind $komparo ? AND lng IN $pref_lng "
    ."ORDER BY ind LIMIT $LIMIT_trd";
  $sth = $dbh->prepare($QUERY);

  eval {
    print "\n\n$QUERY\n" if ($debug);
    print "serĉu: $sercxata\n" if ($debug);
    $sth->execute($sercxata);
  };

  # TODO: eligon de eraro adaptu por JSON
  if ($@) {
    # $sth->err and $DBI::err will be true if error was from DBI
    if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
    } else {
      print "Err ".$sth->err." - $@";
    }

  } else {
    $trovoj_trd = $sth->fetchall_arrayref();
  }

  print $json_parser->encode(
    {
      eo => $trovoj_eo,
      max_eo => $LIMIT_eo,
      trd => $trovoj_trd,
      max_trd => $LIMIT_trd
    }
  );

}


###################################################################
# funkcioj por eldono                                             #
###################################################################

#    my %trovo = (
#      art => $ref->{art_amrk},
#      $lng => {
#        mrk => 'lng_'.$ref->{trd_lng},
#        vrt => escape($ref->{trd_teksto})
#      },
#      eo => {
#        mrk => $ref->{drv_mrk},
#        vrt => escape($ref->{drv_teksto})
#      }
#    );

#    push @{$trovoj_lng{trovoj}}, \%trovo;
#
#  } # ...while
#
#
#  $res->finish();    

sub escape {
  my $str = shift;
  $str =~ s/\"/\\\"/g;
  $str =~ s/<[^>]+>//g;
  return $str;
}

