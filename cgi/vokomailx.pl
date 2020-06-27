#!/usr/bin/perl

# 2008 Wieland Pusch
# 2020 Wolfram Diestel


use strict;
use utf8;

#use CGI qw(:standard *table);
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
#use Encode;
#use Text::Tabs;
#use POSIX qw(strftime);

# propraj perl moduloj estas en:
use lib("/var/www/web277/files/perllib");
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /var/www/web277/files/

use revo::decode;
use revo::encode;
use revo::checkxml;
use revo::xml2html;
use revo::wrap;
use revodb;

$| = 1;

my $debug = 0;

# por testi vi povas aldoni simbolan ligon:  ln -s /home/revo /var/www/web277/html
my $homedir    = "/var/www/web277";
my $htmldir    = "$homedir/html";
my $revo_base  = "$homedir/html/revo";
my $xml_dir    = "$revo_base/xml";

my $revuloj_url = 'https://revuloj.github.io/respondoj.html';
my $mail_cmd    = '/usr/sbin/sendmail -t';
my $mail_from   = 'noreply@retavortaro.de';
my $mail_to     = 'revo@retavortaro.de';

$ENV{'LD_LIBRARY_PATH'} = '/var/www/web277/files/lib';
$ENV{'PATH'} = "$ENV{'PATH'}:/var/www/web277/files/bin";
$ENV{'LOCPATH'} = "$homedir/files/locale";
autoEscape(0);

my $enc = "utf-8";
my $debugmsg;

## parametroj...
my $art = param('art');
my $xmlTxt = param('xmlTxt');
my $redaktanto = param('redaktanto');
my $mrk = param('mrk');
my $sxangxo = Encode::decode($enc, param('sxangxo'));
$debugmsg .= "sxangxo=$sxangxo" if $debug;
my $command = param('button');

binmode STDOUT, ":utf8";
print header(-charset=>'utf-8',
             -pragma => 'no-cache', '-cache-control' =>  'no-cache'),
      start_html(
             -lang=>'eo', 
             -title=>'vokomailx',
		         -encoding => 'UTF-8');

# ne faru ion ajn, se mankas la XML-teksto...
# aŭ valida buton-komando
unless ($xmlTxt && ($command eq 'rigardo' || $command eq 'konservo')) {
  print end_html();
  exit;
}    

# Konektiĝu al la datumbazo...
# ni bezonos gin por kontroli redaktanton kaj referencojn
# konvx uzas la datumbazo por enŝovi tezaŭro-referencojn
my $dbh = revodb::connect();

# ĉu la redaktanto, se donita estas registrita?
my $permeso = 0;

unless ($redaktanto) {
  print "<div id=\"red_err\">Averto: Por sendi vian redakton, vi devas ankoraŭ doni vian retadreson, ".
        "kun kiu vi registriĝis kiel redaktanto.</div>";
} else {
  $permeso = check_redaktanto($dbh,$redaktanto);

  if (!$permeso) {    
    print "<div id=\"red_err\">Averto: Vi ($redaktanto) ne estas registrita kiel redaktanto! ".
          "Bv. legi la informpaĝojn <a href=\"$revuloj_url/redinfo.html\">pri la redaktoservo ".
          "kaj kiel registriĝi</a>. Sen tio viaj ŝanĝoj ne estos sendataj!</div>";
  }
}

#$debugmsg .= "art = $art\n";
my $xml=normigu_xml($xmlTxt);

## kontrolu, ĉu la XML havas ĝustan sintakson
my $xml_err = revo::checkxml::check_xml($xml,$xml_dir) if $xml;
print "<div id=\"xml_err\">\n$xml_err\n</div>";

# konvrtu XML al HTML por la antaŭrigardo...
my ($html, $err);
revo::xml2html::konvx($dbh, \$xml, \$html, \$err, $xml_dir);

print "<div id=\"html_rigardo\">\n$html\n<div>\n";


# FARENDA:
# la referencojn povus ekstrakti jam JS kaj voki apartan servilan skripton por kontroli ilin
# en la datumbazo...
#
# krome ni povas eble ekskuldi artikol-internajn referencojn, aŭ facile antaŭkontroli ilin...
my @ref_err;

if (!$err) { # ĉu ni kontrolu referencojn, ĉiam? Povizore ni faros nur se la XML-sintakso estas e.o.
  my @refs;
  while ($xml =~ /<ref [^>]*?cel="([^".]*)(\.)([^"]*?)">/gi) {
    my ($art,$p,$rest) = ($1,$2,$3);
    push @refs, [$art,$p,$rest];
  }

  if (@refs) {
    @ref_err = check_ref_cel($dbh,$xml_dir,@refs); 
  }

  print "<div id=\"ref_err\">\n".join("\n",@ref_err)."\n</div>";
}

# FARENDA: fakte kun la transiro al Git ni povas toleri
# ne-askiajn signojn en la ŝanĝ-priskribo, sed ni devas ankaŭ
# kontroli processmail.pl antaŭ forigi tie ĉi
my $flag = 0;
my $sxg_err;
$flag = $sxangxo =~ s/\x{0109}/cx/g || $flag;
$flag = $sxangxo =~ s/\x{0108}/Cx/g || $flag;
$flag = $sxangxo =~ s/\x{0135}/jx/g || $flag;
$flag = $sxangxo =~ s/\x{0134}/Jx/g || $flag;
$flag = $sxangxo =~ s/\x{0125}/hx/g || $flag;
$flag = $sxangxo =~ s/\x{0124}/Hx/g || $flag;
$flag = $sxangxo =~ s/\x{016D}/ux/g || $flag;
$flag = $sxangxo =~ s/\x{016C}/Ux/g || $flag;
$flag = $sxangxo =~ s/\x{015D}/sx/g || $flag;
$flag = $sxangxo =~ s/\x{015C}/Sx/g || $flag;
$flag = $sxangxo =~ s/\x{011D}/gx/g || $flag;
$flag = $sxangxo =~ s/\x{011C}/Gx/g || $flag;
### if ($flag) {
###   $sxg_err =  "Esperantaj signoj en ŝanĝoteksto malunikoditaj.\n";
### }

if ($sxangxo =~ s/([\x{80}-\x{10FFFF}]+)/<span style="color:red">$1<\/span>/g) { # forigu ne-askiajn signojn
  $sxg_err="Eraro: La ŝanĝoteksto enhavu ne-askiajn signojn: $sxangxo\n";

} elsif ($sxangxo =~ s/(--)/<span style="color:red">$1<\/span>/g) { # forigu '--'
  $sxg_err="Eraro: '--' estas malpermesita en komento: $sxangxo\n";

} elsif (!param('nova')) {
  unless ($sxangxo and $sxangxo ne "klarigo de la sxangxo") {
    $sxg_err="Eraro: ŝanĝoteksto mankas: $sxangxo\n";
  }
}

if ($sxg_err) {
  print "<div id=\"sxg_err\">\n$sxg_err\n</div>";
}

# ĉu ni sendu la ŝanĝojn?
if ($command eq 'konservo') {

  # ni faras tion nur ĉe registrita redaktanto kaj se ne enestas eraroj
  unless ($redaktanto && $permeso && !$xml_err && !@ref_err && !$sxg_err) {
    print "<div id=\"malkonfirmo\">Pro trovitaj problemoj ni ankoraŭ ne sendis vian ŝanĝon ".
      "al la redaktoservo. Bv. korekti ilin unue.</div>\n";
  } else {
    send_xml($redaktanto,$art,$sxangxo,\$xml);
    print "<div id=\"konfirmo\">Bone: Ni sendis vian ŝanĝon al la redaktoservo.</div>\n";
  }
}

$dbh->disconnect() if $dbh;

print end_html();

#######################################################################################

sub check_redaktanto {
  my ($dbh,$redaktanto) = @_;
  my ($permeso, $red_id);

  if ($redaktanto) {
      # ĉu iu redaktanto havas tiun retadreson? Kiu?
      my $sth = $dbh->prepare("SELECT count(*), min(ema_red_id) FROM email WHERE LOWER(ema_email) = LOWER(?)");
      $sth->execute($redaktanto);
      ($permeso, $red_id) = $sth->fetchrow_array();
      $sth->finish;

      # FARENDA: Ĉu ni bezonas la nomon entute? Se jes, ni povas aldoni ĝin tuj en la supra SQL per JOIN!
      # Kiel nomigxas la redaktanto?
      #$sth = $dbh->prepare("SELECT red_nomo FROM redaktanto WHERE red_id = ?");
      #$sth->execute($red_id);
      #my ($red_nomo) = $sth->fetchrow_array();
      ##  print "red_nomo=$red_nomo\n";
      #$sth->finish;

  }

  return $permeso;
}


sub normigu_xml {
  my $xmlTxt = shift;

  if ($xmlTxt) {
    # normigu kodigon
    $xmlTxt = Encode::decode($enc, $xmlTxt);
    $xmlTxt =~ s/\r\n/\n/g;
    $debugmsg .= "before wrap -> $xmlTxt\n <- end wrap\n";

    # trovu la identigilon de la artikolo,
    # se ĝi rompiĝos ni devos restarigi gin malsupre...
    my $id;
    if ($xmlTxt =~ s/"\$(Id: .*?)\$"/"\$Id:\$"/) {
      $debugmsg .= "ID: $1-\n";
      $id = $1;
    }

    # rompu tro longajn liniojn kaj restarigu $Id...
    $xmlTxt = revo::wrap::wrap($xmlTxt);
    $xmlTxt =~ s/"\$Id:\$"/"\$$id\$"/ if $id;
  }

  # kodigu ne-askiajn signojn per literunuoj...
  return revo::encode::encode2($xmlTxt, 20) if $xmlTxt;
}

sub send_xml {
  my ($redaktanto,$art,$sxangxo,$xml) = @_;

  my $name    = "\"Revo redaktu.pl $redaktanto\"";
  my (@to, $red_cmd);
  push @to, $redaktanto; 
  push @to, $mail_to; 

  # unua linio de retpoŝto
  if (param('nova')) {
    $red_cmd = "aldono: $art";
  } else {
    $red_cmd = "redakto: $sxangxo";
  }

  my $to = join(', ', @to);
  my $subject = "Revo redaktu.pl $art";
  my $smlog = "sendmail.log";

  # konektiĝu al retpoŝtservo
  open SENDMAIL, "| $mail_cmd 2>&1 >$smlog" 
    or print LOG "Ne povas voki $mail_cmd\n";
  print SENDMAIL <<END_OF_MAIL;
From: $name <$mail_from>
To: $to
Reply-To: $redaktanto
Subject: $subject
X-retadreso: $ENV{REMOTE_ADDR}

$red_cmd

$$xml
END_OF_MAIL

  close SENDMAIL;
}        