#!/usr/bin/perl

# 2008 Wieland Pusch
# 2020-2026 Wolfram Diestel

use warnings; use strict; use utf8;

use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);
use DBI();

# propraj perl moduloj estas en:
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/
use lib("/hp/af/ag/ri/files/perllib");
use revo::decode;
use revo::encode;
use revo::checkxml;
use revo::wrap;
use revodb;

#$| = 1;
my $debug = 0; #0|1;

my $xml_max_len = 500000;
my $art_max_len = 25;
my $red_max_len = 80;
my $sxg_max_len = 255;

# por testi vi povas aldoni simbolan ligon:  ln -s /home/revo /hp/af/ag/ri/www
my $homedir    = "/hp/af/ag/ri";
my $htmldir    = "$homedir/www";
my $revo_base  = "$homedir/www/revo";
my $xml_dir    = "$revo_base/xml";

my $revuloj_url = 'https://revuloj.github.io/respondoj.html';
my $mail_cmd    = '/usr/sbin/sendmail -t';
my $smlog       = "$homedir/files/log/sendmail.log"; #"$xml_dir/sendmail.log";
my $mail_from   = 'noreply@retavortaro.de';
my $mail_to     = 'revo@retavortaro.de';

local $ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
local $ENV{'PATH'} = "$ENV{'PATH'}:$homedir/files/bin";
local $ENV{'LOCPATH'} = "$homedir/files/locale";
#autoEscape(0);

my $enc = "utf-8";

## parametroj...
my $art = param('art');
my $xmlTxt = param('xmlTxt');
my $redaktanto = param('redaktanto');
#my $mrk = param('mrk');
my $sxangxo = Encode::decode($enc, param('sxangxo'));
my $command = param('command');

use open ':std', ':encoding(UTF-8)';
##binmode STDOUT, ":utf8";

print header(-charset=>'utf-8',
             -pragma => 'no-cache', '-cache-control' =>  'no-cache'),
      start_html(
             -lang=>'eo', 
             -title=>'vokomailx',
		         -encoding => 'UTF-8');

if ($debug) {
  print "<div id=\"params\">";
  print "art: $art\n";
  print "redaktanto: $redaktanto\n";
  print "sxangxo: $sxangxo\n";
  print "command: $command\n";
  print "xml: ".length($xmlTxt)."\n";
  print "</div>\n";
}


# ne faru ion ajn, se mankas la XML-teksto aŭ valida komando ...
check($xmlTxt && ($command eq 'nur_kontrolo' || $command eq 'forsendo'), "command");

## validigu la ceteran parametrojn...
check(length($xmlTxt) < $xml_max_len, "xmlTxt");
check(length($art) < $art_max_len, "art");
check(length($sxangxo) < $sxg_max_len, "sxangxo");
check(length($redaktanto) < $red_max_len, "redaktanto");
check($art =~ m{^
    [a-z0-9]+
  $}x, "art rx");

# tio ne estas tute preciza testo, sed poste ja ankaŭ trarigardas la liston...
# la preciza estas iom longa: http://www.ex-parrot.com/~pdw/Mail-RFC822-Address.html
check(! $redaktanto 
  || $redaktanto =~ m{^
    [\w\.-]+
    @[\w\.-]+
    \.\w{2,12}
  $}x, "red rx"); 

# Konektiĝu al la datumbazo...
# ni bezonos gin por kontroli redaktanton kaj referencojn
my $dbh = revodb::connect();

# ĉu la redaktanto, se donita estas registrita?
my $permeso = 0;

unless ($redaktanto) {
  print "<div id=\"red_err\" class=\"eraroj\">Averto: Por sendi vian redakton, vi devas ankoraŭ doni vian retadreson, ".
        "kun kiu vi registriĝis kiel redaktanto.</div>\n";
} else {
  $permeso = check_redaktanto($dbh,$redaktanto);

  if (!$permeso) {    
    print "<div id=\"red_err\" class=\"eraroj\">Averto: Vi ($redaktanto) ne estas registrita kiel redaktanto! ".
          "Bv. legi la informpaĝojn <a href=\"$revuloj_url\">pri la redaktoservo ".
          "kaj kiel registriĝi</a>. Sen tio viaj ŝanĝoj ne estos sendataj!</div>\n";
  }
}

my $xml=normigu_xml($xmlTxt);

## kontrolu, ĉu la XML havas ĝustan sintakson
my $xml_err = '';
$xml_err = revo::checkxml::check_xml($xml,$xml_dir) if $xml;
## no critic (RegularExpressions::RequireExtendedFormatting)
$xml_err =~ s/</&lt;/sg;
$xml_err =~ s/>/&gt;/sg;
$xml_err =~ s/\n(Atentu:|Eraro:)/<br>\n$1/sg;
## use critic
print "<div id=\"xml_err\" class=\"eraroj\">\n$xml_err\n</div>\n";

# FARENDA:
# la referencojn povus ekstrakti jam JS kaj voki apartan servilan skripton por kontroli ilin
# en la datumbazo...
#
# krome ni povas eble ekskuldi artikol-internajn referencojn, aŭ facile antaŭkontroli ilin...
my @ref_err;

my @refs;
while ($xml =~ m{
    <ref\s+[^>]*?
    cel="([^".]*)(\.)([^"]*?)"
    >
  }xgi) {
  my ($art_,$p,$rest) = ($1,$2,$3);
  push @refs, [$art_,$p,$rest];
}

if (@refs) {
  @ref_err = revo::checkxml::check_ref_cel($dbh,$xml_dir,@refs); 
}

print "<div id=\"ref_err\" class=\"eraroj\">\n".join("\n",@ref_err)."\n</div>\n";

# FARENDA: fakte kun la transiro al Git ni povas toleri
# ne-askiajn signojn en la ŝanĝ-priskribo, sed ni devas ankaŭ
# kontroli processmail.pl antaŭ forigi tie ĉi
my $flag = 0;
my $sxg_err;
## no critic (RegularExpressions::RequireExtendedFormatting)
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
## use critic

if ($sxangxo =~ s{
    ([\x{80}-\x{10FFFF}]+)
  }
  {<span style="color:red">$1</span>}xg) { # ruĝigu ne-askiajn signojn
  $sxg_err="Eraro: La ŝanĝoteksto enhavu ne-askiajn signojn: $sxangxo\n";

} elsif ($sxangxo =~ s{(--)}{<span style="color:red">$1</span>}xg) { # ruĝigu '--'
  $sxg_err="Eraro: '--' estas malpermesita en komento: $sxangxo\n";

} elsif (!param('nova')) {  
  my $sxangxo_tajpita = ($sxangxo ne "klarigo de la sxangxo");
  unless ($sxangxo and $sxangxo_tajpita)) {
    $sxg_err="Eraro: ŝanĝoteksto mankas.\n";
  }
}

if ($sxg_err) {
  print "<div id=\"sxg_err\" class=\"eraroj\">\n$sxg_err\n</div>\n";
}

# ĉu ni sendu la ŝanĝojn?
if ($command eq 'forsendo') {

  # ni faras tion nur ĉe registrita redaktanto kaj se ne enestas eraroj
  my $neniu_eraro = !$xml_err && !@ref_err && !$sxg_err;
  unless ($redaktanto && $permeso && $neniu_eraro) {
    print "<div id=\"malkonfirmo\" class=\"eraroj\">Pro trovitaj problemoj ni ankoraŭ ne sendis vian ŝanĝon ".
      "al la redaktoservo. Bv. korekti ilin unue.</div>\n";

  } else {
    if (send_xml($redaktanto,$art,$sxangxo,\$xml)) {
      print "<div id=\"konfirmo\">Bone: Via ŝanĝo sendiĝis al la redaktoservo.</div>\n";
    } else {
      print "<div id=\"malkonfirmo\" class=\"eraroj\">Pro problemo kun la retpoŝta servo, ni ne povis sendi vian ŝanĝon ".
        "al la redaktoservo. Bv. reprovi poste aŭ sendi la ŝanĝon per ordinara retpoŝto kaj averti administranton.</div>\n";
    }
  }
}

$dbh->disconnect() if $dbh;

print end_html();

#######################################################################################

sub check {
  my $cond = shift;

  ## if ($debug) {
  ##   print shift, ": ", $cond, "\n";
  ## }

  unless ($cond) {
    print end_html();
    exit;
  }
}   

sub check_redaktanto {
  my ($dbh_,$red_anto) = @_;
  my ($permes_, $red_id);

  if ($red_anto) {
      # ĉu iu redaktanto havas tiun retadreson? Kiu?
      my $sth = $dbh_->prepare("SELECT count(*), min(ema_red_id) FROM email WHERE LOWER(ema_email) = LOWER(?)");
      $sth->execute($red_anto);
      ($permes_, $red_id) = $sth->fetchrow_array();
      $sth->finish;

      # FARENDA: Ĉu ni bezonas la nomon entute? Se jes, ni povas aldoni ĝin tuj en la supra SQL per JOIN!
      # Kiel nomigxas la redaktanto?
      #$sth = $dbh_->prepare("SELECT red_nomo FROM redaktanto WHERE red_id = ?");
      #$sth->execute($red_id);
      #my ($red_nomo) = $sth->fetchrow_array();
      ##  print "red_nomo=$red_nomo\n";
      #$sth->finish;

  }

  return $permes_;
}

sub normigu_xml {
  my $xml_txt = shift;

  if ($xml_txt) {
    # normigu kodigon
    $xml_txt = Encode::decode($enc, $xml_txt);
    $xml_txt =~ s/\r\n/\n/xg;
    #$debugmsg .= "before wrap -> $xml_txt\n <- end wrap\n";

    # trovu la identigilon de la artikolo,
    # se ĝi rompiĝos ni devos restarigi gin malsupre...
    my $id;
    if ($xml_txt =~ s{"\$(Id:.*?)\$"}{"\$Id:\$"}x) {
      #$debugmsg .= "ID: $1-\n";
      $id = $1;
    }

    # rompu tro longajn liniojn kaj restarigu $Id...
    $xml_txt = revo::wrap::wrap($xml_txt);
    $xml_txt =~ s{"\$Id:\$"}{"\$$id\$"}x if $id;
  }

  # kodigu ne-askiajn signojn per literunuoj...
  return revo::encode::encode2($xml_txt, 20) if $xml_txt;
  return;
}

sub send_xml {
  my ($red_anto,$art_,$sxangx_,$xml_) = @_;

  my $name    = "\"Revo redaktu.pl $red_anto\"";
  $name =~ s/\@/_/xg;
  my (@to, $red_cmd);
  push @to, $red_anto; 
  push @to, $mail_to; 

  # unua linio de retpoŝto
  if (param('nova')) {
    $red_cmd = "aldono: $art_";
  } else {
    $red_cmd = "redakto: $sxangx_";
  }

  my $to = join(', ', @to);
  my $subject = "Revo redaktu.pl $art_";

  my $mailtext = <<'END_OF_MAIL';
From: $name <$mail_from>
To: $to
Reply-To: $red_anto
Subject: $subject
X-retadreso: $ENV{REMOTE_ADDR}

$red_cmd

$$xml_
END_OF_MAIL
  
  # konektiĝu al retpoŝtservo
  open my $sendmail, '|-', "$mail_cmd 2>&1 >$smlog" or do {
    warn("Ne povas voki $mail_cmd\n");
    return 0;
  };
  print {$sendmail} $mailtext;
  close $sendmail;
  return;
}
