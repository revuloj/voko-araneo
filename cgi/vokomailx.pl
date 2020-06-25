#!/usr/bin/perl

#
# redaktu.pl
# 
# 2008 Wieland Pusch
# 2020 Wolfram Diestel
#

use strict;
use utf8;

use CGI qw(:standard *table);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
use Encode;
use Text::Tabs;
use POSIX qw(strftime);

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
my $xml_dir    =  "$revo_bazo/xml";

# FARENDA: pli bone kontrolu tion per JS en la retumilo!
my $lng_xml    = "$revo_base/cfg/lingvoj.xml";
my $fak_xml    = "$revo_base/cfg/fakoj.xml";
my $stl_xml    = "$revo_base/cfg/stiloj.xml";

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

#$debugmsg .= "art = $art\n";
my $xml;

if ($xmlTxt) {
  # normigu kodigon
  $xmlTxt = Encode::decode($enc, $xmlTxt);
  $xmlTxt =~ s/\r\n/\n/g;
  $debugmsg .= "before wrap -> $xmlTxt\n <- end wrap\n";

  # trovu la identigilon de la artikolo
  my $id;
  if ($xmlTxt =~ s/"\$(Id: .*?)\$"/"\$Id:\$"/) {
    $debugmsg .= "ID: $1-\n";
    $id = $1;
  }

  # rompu tro longajn liniojn
  $xmlTxt = revo::wrap::wrap($xmlTxt);
  $xmlTxt =~ s/"\$Id:\$"/"\$$id\$"/ if $id;
#  $debugmsg .= "wrap -> $xmlTxt\n <- end wrap\n";
}

# kodigu ne-askiajn signojn per literunuoj...
$xml = revo::encode::encode2($xmlTxt, 20) if $xmlTxt;

## kontrolu, ĉu la XML havas ĝustan sintakson
my ($pos, $line, $lastline) = (0, 0, 1);
my ($prelines, $postlines);
my ($checklng, $checkxml, $errline, $errchar);
($checkxml, $errline, $errchar) = revo::checkxml::scheckxml($xml,$xml_dir) if $xml2;
#$debugmsg .= "errline = $errline\n";

my $ne_konservu;

if ($errline) {
  $errline--;
  $errchar--;
  if ($xml =~ m/^([^\n]*\n){$errline}[^\n]{$errchar}/smg) {
    my @prelines = split "\n", $&;
    $postlines = split "\n", $';

    my @pre = Text::Tabs::expand(@prelines);
    $pos = length(join "\n", @pre);
    $prelines = $#prelines;

    $line = $prelines - 10;
    $lastline = $prelines + $postlines + 30 - 25;
  } else {
#    $debugmsg .= "Ne trovis linio/pos $errline/$errchar\n";
    $line = $lastline = 100;
    my @prelines = split "\n", $xml;
    my @pre = Text::Tabs::expand(@prelines);
    $pos = length(join "\n", @pre);
  }

} else {
  ($checklng, $errline, $errchar) = revo::checkxml::checklng($xml,$lng_xml) if $xml;
}

binmode STDOUT, ":utf8";
print header(-charset=>'utf-8',
             -pragma => 'no-cache', '-cache-control' =>  'no-cache'),
      start_html(-title=>"redakti $art",
                 -lang=>'eo', #'de',
		             -encoding => 'UTF-8',
		             -head => [ 
                   '<meta http-equiv="Cache-Control" content="no-cache">'
			           ]
);


# Connect to the database.
my $dbh = revodb::connect();

#print pre('dbconnect'." size=".length($xml2)) if $debug;

print pre('button='.Encode::decode($enc, param('button'))."   ".(Encode::is_utf8(param('button')))."-".(Encode::is_utf8("antaŭrigardu"))) if $debug;
if (Encode::decode($enc, param('button')) eq "antaŭrigardu" or param('button') eq 'konservu') {

print <<'EOD';
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>Anta&#365;rigardo</b></span></p>
EOD
#  if ($debug) {
#    print pre('open xalan');
#    autoEscape(1);
#    print pre(escapeHTML("xml2=\n$xml2"));
#    autoEscape(0);
#  }
  chdir($revo_base."/xml") or die "chdir";
  
  my ($html, $err);
  revo::xml2html::konv($dbh, \$xml2, \$html, \$err, $debug);
#  $html = Encode::decode($enc, $html);
  if ($html and $debug) {
    open HTML, ">:utf8", "../art2/$art.html" or die "open write html";
	print HTML $html;
    close HTML;
  }

  $html =~ s#href="../stl/#href="/revo/stl/#smg;
  $html =~ s#src="../smb/#src="/revo/smb/#smg;
  $html =~ s#src="../bld/#src="/revo/bld/#smg;
  $html =~ s#<span class="redakto">.*$##sm;
  $html =~ s#href="(?!http://)([a-z])#href="/revo/art/\1#smg;

  print $html;
#  print pre('close xalan') if $debug;

print <<'EOD';
</div><br>
EOD


print <<'EOD';
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>
EOD
  print $checkxml.br."\n";

  print $checklng.br.br."\n" if $checklng;

  { my $x = $xml2;		# cxu cxio trd havas lng aux estas en trdgrp kun lng?
    autoEscape(1);
#    print pre(escapeHTML("x=$x\n"));
    $x =~ s/<trdgrp\s+lng\s*=.*?<\/trdgrp>\s*//smig;	# forigo de bonaj trdgrpoj
    $x =~ s/<trd\s+lng\s*=.*?<\/trd>\s*//smig;		    # forigo de bonaj trdoj
#    print pre(escapeHTML("x=$x\n"));
	if ($x =~ /(<trd.*?<\/trd>)/) {					# se restas trd, estas malbona
	  print escapeHTML("Traduko $1")." ne havas lingvon.<br>\n";
      $ne_konservu = 11;
	}
    autoEscape(0);
  }
  
  while ($xml2 =~ /<ref([^g>][^>]*)>/gi) {
    my $ref = $1;
#    print "ref = $ref<br>\n" if $debug;
    if ($ref !~ /cel\s*=\s*"([^"]+?)"/i) {
      autoEscape(1);
      print escapeHTML("Referenco <ref$ref>")." ne havas cel a&#365; la celo estas malplena.<br>\n";
      autoEscape(0);
#      print "ref = $ref<br>\n";
#      $ne_konservu = 9;
    }
  }

  my $sth = $dbh->prepare("SELECT count(*) FROM art WHERE art_amrk = ?");
  my $sth2 = $dbh->prepare("SELECT drv_mrk FROM drv WHERE drv_mrk = ? union SELECT snc_mrk FROM snc WHERE snc_mrk = ? union SELECT rim_mrk FROM rim WHERE rim_mrk = ?");
  while ($xml2 =~ /<ref [^>]*?cel="([^".]*)(\.)([^"]*?)">/gi) {
    my ($art, $mrk) = ($1, "$1$2$3");
    $sth->execute($art);
    my ($art_ekzistas) = $sth->fetchrow_array();
    if (!$art_ekzistas) {
#      print "ref = $1-$2 $art-$mrk<br>\n" if $debug;
      print "Referenco celas al dosiero \"$art.xml\", kiu ne ekzistas.<br>\n";
#      $ne_konservu = 7;
    } elsif ($2) {
      $sth2->execute($mrk, $mrk, $mrk);
      my ($mrk_ekzistas) = $sth2->fetchrow_array();
      if (!$mrk_ekzistas) {
#        print "ref: art=$art mrk=$mrk<br>\n" if $debug;
        # eble temas pri marko de subsenco?
        open IN, "<", "$homedir/html/revo/xml/$art.xml";
        my $celxml = join '', <IN>;
        close IN;
        if ($celxml !~ /<subsnc\s+mrk="$mrk">/) {
          print "Referenco celas al \"$mrk\", kiu ne ekzistas en dosiero \"".a({href=>"?art=$art"}, "$art.xml")."\".<br>\n";
#          $ne_konservu = 8;
        }
      }
    }
  }
  $sth->finish;

  # FARENDA: pli bone faru rekte en JS!
  checkfak($xml,$fak_xml);
  checkstl($xml,$stl_xml);
  checkmrk($xml);

  my $flag = 0;
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
  if ($flag) {
    print "Esperantaj signoj en ŝanĝoteksto malunikoditaj.<br>\n";
  }
  if ($sxangxo =~ s/([\x{80}-\x{10FFFF}]+)/<span style="color:red">$1<\/span>/g) { # forigu ne-askiajn signojn
    print "Eraro: La ŝanĝoteksto enhavas ne-askiajn signojn: $sxangxo".br."\n";
    $ne_konservu = 3;
  } elsif ($sxangxo =~ s/(--)/<span style="color:red">$1<\/span>/g) { # forigu '--'
    print "Eraro: '--' estas malpermesita en komento: $sxangxo".br."\n";
    $ne_konservu = 3;
  } elsif (!param('nova')) {
    if ($sxangxo and $sxangxo ne "klarigo de la sxangxo") {
      print "Ŝanĝoteksto en ordo: $sxangxo".br."\n";
    } else {
      print "Eraro: ŝanĝoteksto mankas: $sxangxo".br."\n";
      $ne_konservu = 4;
    }
  }
print <<'EOD';
</div><br>
EOD
}

if ($redaktanto) {
  # cxu iu redaktanto havas tiun retadreson? Kiu?
  my $sth = $dbh->prepare("SELECT count(*), min(ema_red_id) FROM email WHERE LOWER(ema_email) = LOWER(?)");
  $sth->execute($redaktanto);
  my ($permeso, $red_id) = $sth->fetchrow_array();
  $sth->finish;
  # Kiel nomigxas la redaktanto?
  my $sth = $dbh->prepare("SELECT red_nomo FROM redaktanto WHERE red_id = ?");
  $sth->execute($red_id);
  my ($red_nomo) = $sth->fetchrow_array();
#  print "red_nomo=$red_nomo\n";
  $sth->finish;

  if (!$permeso) {
    $ne_konservu = 2;

    print <<"EOD";
<div class="averto">
Vi ($redaktanto) ne estas registrita kiel redaktanto !<br>
Legu <a href="http://www.reta-vortaro.de/revo/dok/redinfo.html">&#265;i tie</a> kaj 
  <a href="http://www.reta-vortaro.de/revo/dok/revoserv.html">&#265;i tie</a> kiel registri&#285;i.<br>
Sen tio viaj &#349;an&#285;oj ne estos konservitaj !
</div><br>
EOD
  }

  if (param('button') eq 'konservu') {
    print <<'EOD';
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>
EOD
    print "Konservo</b></span></p>\n";
    # $xml2
    if ($ne_konservu) {
      print "ne konservita";
    } else {
      my $from    = 'noreply@retavortaro.de';
      my $name    = "\"Revo redaktu.pl $redaktanto\"";
      my (@to, $sxangxo2);
      push @to, $redaktanto; # if param('sendu_al_tio');
      push @to, 'revo@retavortaro.de'; # if not $debug or param('sendu_al_revo');
#      push @to, 'wieland@wielandpusch.de'; # if param('sendu_al_admin');  # revodb::mail_to
      if (param('nova')) {
        $sxangxo2 = "aldono: $art";
      } else {
        $sxangxo2 = "redakto: $sxangxo";
      }
      if (my $to = join(', ', @to)) {
        my $subject = "Revo redaktu.pl $art";

    my $header = [
      To => $to,
      From => "$name <$from>",
      "Reply-To" => $redaktanto,
      Subject => $subject,
      X-retadreso: $ENV{REMOTE_ADDR}
    ];
    retposhto::sendu(
      \%mail,
      "$sxangxo2\n\n$xml2");

        print "sendita al $to";
			
      } else {
        print "ne sendita, elektu adreson sube";
      }
    }
    print <<'EOD';
</div><br>
EOD
  }
}

$dbh->disconnect() if $dbh;

# por ke la formulara ne konvertas &lt; al < ktp.
$xml =~ s/&lt;/&amp;lt;/g;
$xml =~ s/&gt;/&amp;gt;/g;

#$xml = Encode::encode($enc, $xml) if $xml2;
if (param('xmlTxt')) {
  param(-name=>'xmlTxt', -value => $xml);
}
param(-name=>'sxangxo', -value => $sxangxo);

print start_form(-id => "f", -name => "f");

my @fakoj = sort keys %fak;
my @stiloj = sort keys %stl;
#print 
#      "&nbsp;".textarea(-id    => 'xmlTxt', -name    => 'xmlTxt',
#               -rows    => 25,
#               -columns => 80,
#	           -default => $xml,
#               -onkeypress => "return klavo(event)",
#      ) if $art;
#if (param('nova') or param('button') eq 'kreu') {
#  print hidden(-name=>'nova', -default=>1);
#} else {
#  print br."\n&nbsp;&#348;an&#285;o: ".textfield(
#       -name => 'sxangxo',
#       -value => Encode::decode($enc, cookie(-name=>'sxangxo')) || 'klarigo de la &#349;an&#285;o',
#       -title => "Klarigu la ŝanĝon ĉi tie.",
#       -size => 70,
#       -maxlength => 80);
#}
#print br."\n&nbsp;Retpo&#349;ta adreso:".textfield(-name=>'redaktanto',
#                    -size      => 70,
#                    -maxlength => 80,
#                    -title     => "Skribu vian registritan retadreson ĉi tie.",
#                    -value     => (cookie(-name=>'redaktanto') || 'via retadreso')
#      ),
#      br."\n",
#      submit(-name => 'button', -label => 'antaŭrigardu'),
#      submit(-name => 'button', -label => 'konservu') if $art;
#print checkbox(-name    => 'sendu_al_revo',
#               -checked => 1,
#               -value   => '1',
#               -label   => 'sendu al ReVo') if $art and $debug and 0;
#print end_form if $art;

#print start_form(-id => "n", -name => "n");
#print "&nbsp;Preparu novan artikolon: ".textfield(-name=>'art', -size=>20, -maxlength=>20)."&nbsp;";
#print submit(-name => 'button', -label => 'kreu')."&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/revoserv.html'}, "[helpo]")."\n";
#print end_form;

#print p('<!-- svn versio: $Id: vokomail.pl 1142 2018-02-10 12:48:25Z wdiestel $'.br.
#	'hg versio: $HgId: vokomail.pl 62:d81c22cbe76e 2010/04/21 17:24:51 Wieland $ -->');

print end_html();


### checkxml: kontrolas la sintakson de XML kaj redonas erarojn okaze de nevalida sintakson
### 

