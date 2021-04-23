#!/usr/bin/perl 
#
# sercxu-json
# 
# (c) permesilo: GPL 2.0
# 2006-2007 __ Wieland Pusch, Bart Demeyere
# 2012-2021 __ Wolfram Diestel

use strict;

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
#use URI::Escape;

# propraj perl moduloj estas en:
#use lib ("./perllib");
use lib("/hp/af/ag/ri/files/perllib");
use revodb;
#use eosort;

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
print header(-type=>'application/json',-charset=>'utf-8');

# kion serĉi...
my $sercxata = param('sercxata');
exit unless($sercxata);

my $pref_lng = preflng();

###################################################################
#  serĉo en la datumbazo                                             #
###################################################################

# konektiĝo
my $dbh = revodb::connect();
# necesas por certigi aprioran signokodadon!
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");


### ni volas nur iun ajn arbitran artikolon ###
if ($sercxata eq '!iu ajn!') {
   # tio funkcius, sed ordigas unufoje la tutan tabelon (nur 0.2s, tamen nenecesa)
   # -- SELECT mrk FROM r3kap ORDER BY RAND() LIMIT 1;

  my $cnt = $dbh->selectrow_hashref("SELECT count(*) AS c FROM r3kap");
  my $rno = int(rand($cnt->{c}));
  my $hazarda = $dbh->selectrow_arrayref("SELECT mrk FROM r3kap LIMIT $rno,1");
  print $json_parser->encode({hazarda=>$hazarda});
  goto FINO;
}


# $komparo estas unu el: =, LIKE, REGEXP
my $komparo = '=';
  # se enestas iuj specialsignoj kiel: . ^ + ? aŭ malferma krampo
  # ni supozas regulesprimon!
  # ni ne testas *, ĉu ni aldonu?
if ($sercxata =~ /[.^$\[\(\|+?{\\]/) {
  $komparo = 'REGEXP'
  # se enestas % aŭ _ ni interpretas ilin kiel ĵokeroj kun LIKE
} elsif ($sercxata =~ /[%_]/) {
  $komparo = 'LIKE';
};


### serĉu esperantajn vortojn ###
my ($sth);

my $QUERY =
   "SELECT DISTINCT SUBSTRING_INDEX(mrk,'.',2) AS drvmrk, kap, lng, ind, trd " 
  ."FROM v3esperanto "
  ."WHERE kap $komparo ? AND lng IN $pref_lng "
  ."ORDER BY kap LIMIT $LIMIT_eo";
$sth = $dbh->prepare($QUERY);

# ekde mySQL 5.6. ni povus uzi GROUP_CONCAT por kunigi ĉiujn tradukojn
# de unu lingvo en unu signoĉeno!      

my $trovoj_eo;
my $trovoj_trd;

eval {
  #print "\n\n$QUERY\n" if ($debug);
  #print "serĉu: $sercxata\n" if ($debug);
  $sth->execute($sercxata);
};

# kontrolu kaj eldonu erarojn, aliokaze la rezultojn
# FARENDA: necesas adapti por json
if ($@) {
  print $json_parser->encode({
    eraro => $sth->err,
    msg => substr($@,0,81)
  });
  goto FINO;

  #if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
  #  print "Eraro: La rektaj krampoj ([ ]) ne paras.<br>\n";
  #} else {
  #  print "Err ".$sth->err." - $@";
  #}
} else {
  $trovoj_eo = $sth->fetchall_arrayref(); 
}

### serĉu tradukojn ###

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

# TODO: eligon de eraro adaptu por JSON...
if ($@) {
  print $json_parser->encode({
    eraro => $sth->err,
    msg => substr($@,0,81)
  });
  goto FINO;
  ## $sth->err and $DBI::err will be true if error was from DBI
  #if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
  #} else {
  #  print "Err ".$sth->err." - $@";
  #}

} else {
  $trovoj_trd = $sth->fetchall_arrayref();
}

# eligu la rezultojn kiel JSON-strukturo
print $json_parser->encode(
  {
    eo => $trovoj_eo,
    max_eo => $LIMIT_eo,
    trd => $trovoj_trd,
    max_trd => $LIMIT_trd
  }
);

FINO:
# fermu la datumbazon
$dbh->disconnect() or die "Malkonekto de la datumbazo ne funkciis";
exit;

#### eltrovu preferatan lingvon de la uzanto laŭ la retumilo ####

sub preflng {
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
  return "('".join("','",@preferataj_lingvoj)."')";
}


