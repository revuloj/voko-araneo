#!/usr/bin/perl

# 2008 Wieland Pusch
# 2020-2021 Wolfram Diestel


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
use lib("/hp/af/ag/ri/files/perllib");
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/

#use revo::decode;
use revo::encodex;
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
#my $mail_to     = 'revo@retavortaro.de';

$ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
$ENV{'PATH'} = "$ENV{'PATH'}:$homedir/files/bin";
$ENV{'LOCPATH'} = "$homedir/files/locale";
#autoEscape(0);

my $enc = "utf-8";

## parametroj...
my $art = param('art');
my $xmlTxt = param('xmlTxt');
my $redaktanto = param('redaktanto');
#my $mrk = param('mrk');
my $sxangxo = Encode::decode($enc, param('sxangxo'));
my $command = param('command');

binmode STDOUT, ":utf8";
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
check($art =~ /^[a-z0-9]+$/, "art rx");

# tio ne estas tute preciza testo, sed poste ja ankaŭ trarigardas la liston...
# la preciza estas iom longa: http://www.ex-parrot.com/~pdw/Mail-RFC822-Address.html
check(! $redaktanto || $redaktanto =~ /^[\w\.-]+@[\w\.-]+\.\w{2,12}$/, "red rx"); 

# Konektiĝu al la datumbazo...
# ni bezonos gin por kontroli redaktanton kaj referencojn
# kaj por submeti la redakton en la fino...
my $dbh = revodb::connect();

# ĉu la redaktanto, se donita estas registrita?
my $permeso = 0;

unless ($redaktanto) {
  print "<div id=\"red_err\" class=\"eraroj\">Averto: Por submeti vian redakton, vi devas ankoraŭ doni vian retadreson, ".
        "kun kiu vi registriĝis kiel redaktanto.</div>\n";
} else {
  $permeso = check_redaktanto($dbh,$redaktanto);

  if (!$permeso) {    
    print "<div id=\"red_err\" class=\"eraroj\">Averto: Vi ($redaktanto) ne estas registrita kiel redaktanto! ".
          "Bv. legi la informpaĝojn <a href=\"$revuloj_url/redinfo.html\">pri la redaktoservo ".
          "kaj kiel registriĝi</a>. Sen tio viaj ŝanĝoj ne estos sendataj!</div>\n";
  }
}

my $xml=normigu_xml($xmlTxt);

## kontrolu, ĉu la XML havas ĝustan sintakson
my $xml_err = revo::checkxml::check_xml($xml,$xml_dir) if $xml;
#$xml_err =~ s/\n/<br>\n/sg;
$xml_err =~ s/</&lt;/sg;
$xml_err =~ s/>/&gt;/sg;
$xml_err =~ s/\n(Atentu:|Eraro:)/<br>\n$1/sg;
print "<div id=\"xml_err\" class=\"eraroj\">\n$xml_err\n</div>\n";

# FARENDA:
# la referencojn povus ekstrakti jam JS kaj voki apartan servilan skripton por kontroli ilin
# en la datumbazo...
#
# krome ni povas eble ekskuldi artikol-internajn referencojn, aŭ facile antaŭkontroli ilin...
my @ref_err;

#if (!$err) { # ĉu ni kontrolu referencojn, ĉiam? Povizore ni faros nur se la XML-sintakso estas e.o.
  my @refs;
  while ($xml =~ /<ref [^>]*?cel="([^".]*)(\.)([^"]*?)">/gi) {
    my ($art,$p,$rest) = ($1,$2,$3);
    push @refs, [$art,$p,$rest];
  }

  if (@refs) {
    @ref_err = revo::checkxml::check_ref_cel($dbh,$xml_dir,@refs); 
  }

  print "<div id=\"ref_err\" class=\"eraroj\">\n".join("\n",@ref_err)."\n</div>\n";
#}

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
  $sxg_err="Eraro: La ŝanĝoteksto enhavas ne-askiajn signojn: $sxangxo\n";

} elsif ($sxangxo =~ s/(--)/<span style="color:red">$1<\/span>/g) { # forigu '--'
  $sxg_err="Eraro: '--' estas malpermesita en komento: $sxangxo\n";

} elsif (!param('nova')) {
  unless ($sxangxo and $sxangxo ne "klarigo de la sxangxo") {
    $sxg_err="Eraro: ŝanĝoteksto mankas.\n";
  }
}

if ($sxg_err) {
  print "<div id=\"sxg_err\" class=\"eraroj\">\n$sxg_err\n</div>\n";
}

# ĉu ni sendu la ŝanĝojn?
if ($command eq 'forsendo') {

  # ni faras tion nur ĉe registrita redaktanto kaj se ne enestas eraroj
  #  ni toleru referenc-erarojn: # && !@ref_err
  unless ($redaktanto && $permeso && !$xml_err && !$sxg_err) {
    print "<div id=\"malkonfirmo\" class=\"eraroj\">Pro trovitaj problemoj ni ankoraŭ ne submetis vian ŝanĝon ".
      "al la redaktoservo. Bv. korekti ilin unue.</div>\n";
  } else {
    # konservu la redakton en la datumbazo, tabelo "submeto"
    my $dbrezulto = submetu_xml($redaktanto,$art,$sxangxo,\$xml);
    if ($dbrezulto != 1) {
      print "<div id=\"malkonfirmo\" class=\"eraroj\">Pro problemo kun la datumbazo via redakto ne submetiĝis. ".
        #"Bv. reprovi poste aŭ sendi la ŝanĝon per ordinara retpoŝto kaj averti administranton. [".
        "Bv. averti administranton. [".
        $dbrezulto."]</div>\n";
    }
    # aldone sendu la redakton al la redaktinto kaj al revo...
    if (send_xml($redaktanto,$art,$sxangxo,\$xml)) {
      print "<div id=\"konfirmo\">Bone: Via ŝanĝo submetiĝis al la redaktoservo.</div>\n";
    } else {
      print "<div id=\"malkonfirmo\" class=\"eraroj\">Pro problemo kun la retpoŝta servo, ni ne povis submeti vian ŝanĝon ".
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
    #$debugmsg .= "before wrap -> $xmlTxt\n <- end wrap\n";

    # trovu la identigilon de la artikolo,
    # se ĝi rompiĝos ni devos restarigi ĝin malsupre...
    my $id;
    if ($xmlTxt =~ s/"\$(Id: .*?)\$"/"\$Id:\$"/) {
      #$debugmsg .= "ID: $1-\n";
      $id = $1;
    }

    # rompu tro longajn liniojn kaj restarigu $Id...
    $xmlTxt = revo::wrap::wrap($xmlTxt);
    $xmlTxt =~ s/"\$Id:\$"/"\$$id\$"/ if $id;
  }

  # kodigu ne-askiajn signojn per literunuoj...
  return revo::encodex::encode2($xmlTxt, 20) if $xmlTxt;
}

sub submetu_xml {
  my ($redaktanto,$art,$sxangxo,$xml) = @_;
  my $red_cmd = "redakto";
  if (param('nova')) {
    $red_cmd = "aldono";
  };

  # malŝaltu aŭtomatan eraro-ĵeton/-presadon
  $dbh->{PrintError} = 1;
  $dbh->{RaiseError} = 1;

  my $sth = $dbh->prepare("INSERT INTO submeto(sub_email,sub_cmd,sub_state,sub_desc,sub_fname,sub_content) VALUES (?,?,?,?,?,?)");
  $sth->bind_param(1,$redaktanto);
  $sth->bind_param(2,$red_cmd);
  $sth->bind_param(3,'nov'); 
  $sth->bind_param(4,$sxangxo);
  $sth->bind_param(5,$art);
  $sth->bind_param(6,$$xml);

  $sth->execute()  
    or return "Ne povis submeti redakton: $DBI::errstr\n"; 
}

sub send_xml {
  my ($redaktanto,$art,$sxangxo,$xml) = @_;

  my $name    = "\"Revo redaktu.pl $redaktanto\"";
  $name =~ s/\@/_/g;

  my (@to, $red_cmd);
  push @to, $redaktanto; 
  # ne plu sendu al redaktoservo: push @to, $mail_to; 

  # unua linio de retpoŝto
  if (param('nova')) {
    $red_cmd = "aldono: $art";
  } else {
    $red_cmd = "redakto: $sxangxo";
  }

  my $to = join(', ', @to);
  my $subject = "Revo redaktu.pl $art";
  
  # konektiĝu al retpoŝtservo
  unless (open SENDMAIL, "| $mail_cmd 2>&1 >$smlog") {
    print LOG "Ne povas voki $mail_cmd\n";
    return 0;
  } 
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
