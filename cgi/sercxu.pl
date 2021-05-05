#!/usr/bin/perl

#
# sercxu.pl
# 
# 2006-09-__ Wieland Pusch
# 2006-10-__ Bart Demeyere
# 2007-03-__ Wieland Pusch
#

use strict;

#use CGI qw(:standard *table -utf8);
use CGI qw(:standard *table);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
use URI::Escape;

use utf8;
#use feature 'unicode_strings';
use open ':std', ':encoding(UTF-8)';

#use open ':utf8';
#binmode STDOUT, ":utf8";
#binmode STDOUT, ':encoding(UTF-8)';

$| = 1;

my $LIMIT_eo = 50;
my $LIMIT_trd = 250;

my $verbose=0; # 1 = debugging...

#print "Content-type: text/html\n\n";

#### preparu stirantajn parametrojn  ####

my %unicode = ( cx => "ĉ", gx => "ĝ", hx => "ĥ", jx => "ĵ", sx => "ŝ", ux => "ŭ" );

my $sercxata = param('q2');
$sercxata = param('sercxata') if param('sercxata');
utf8::decode($sercxata);

my $cx2cx = param('x');
$cx2cx = "checked" if $cx2cx;
my $neniu_trafo = 1;

my $formato = param('formato');
my $param_lng = param('lng');
$param_lng = '' unless $param_lng;

my $pado = "..";
$pado = "/revo" if param('pado') eq 'revo';

my $kadroj = param('kadroj'); # uzata de kono.be/vivo

#### serĉformularo aperas en HTML-kadraro ... ####

if ($kadroj) {
  # uzata de kono.be/vivo
  print "Content-type: text/html; charset=utf-8\n\n";

  utf8::encode($sercxata);
  $sercxata = uri_escape($sercxata);

  $sercxata .= "&lng=".uri_escape(param('lng')) if param('lng');
  $sercxata .= "&trd=".uri_escape(param('trd')) if param('trd');
  $sercxata .= "&ans=".uri_escape(param('ans')) if param('ans');

  # kopiu index.html  
  open IN, "<../revo/index.html" or die "serĉo en kadroj ne eblas ĉar mankas dosiero 'index.html'";
  while (<IN>) {
    s/src="inx\/_eo.html"/src="sercxu.pl?cx=1&sercxata=$sercxata"/;
    s/src="titolo.html"/src="..\/revo\/titolo.html"/;
    print;
  }
  close IN;
  exit 1;
}

#utf8::decode($sercxata);

#### Javoskripto por la serĉormularo ####
my $JSCRIPT=<<END;
function xAlUtf8(t, nomo) {
  if (document.getElementById("x").checked) {
    t = t.replace(/c[xX]/g, "\\u0109");
    t = t.replace(/g[xX]/g, "\\u011d");
    t = t.replace(/h[xX]/g, "\\u0125");
    t = t.replace(/j[xX]/g, "\\u0135");
    t = t.replace(/s[xX]/g, "\\u015d");
    t = t.replace(/u[xX]/g, "\\u016d");
    t = t.replace(/C[xX]/g, "\\u0108");
    t = t.replace(/G[xX]/g, "\\u011c");
    t = t.replace(/H[xX]/g, "\\u0124");
    t = t.replace(/J[xX]/g, "\\u0134");
    t = t.replace(/S[xX]/g, "\\u015c");
    t = t.replace(/U[xX]/g, "\\u016c");
    if (t != document.getElementById(nomo).value) {
      document.getElementById(nomo).value = t;
    }
  }
}
function sf(){document.f.sercxata.focus();}
top.document.title = "Reta Vortaro, serĉo de \\\"$sercxata\\\"";
END

#### eltrovu preferatan lingvon de la uzanto laŭ la retumilo ####

#$ENV{HTTP_ACCEPT_LANGUAGE} = ''; # por testi

my $preferata_lingvo;
{
  my @a = split ",", $ENV{HTTP_ACCEPT_LANGUAGE};
  $preferata_lingvo = shift @a;
  $preferata_lingvo = shift @a if $preferata_lingvo =~ /^eo/;
  $preferata_lingvo =~ s/^([^;-]+).*/$1/;
#  $preferata_lingvo = 'nenio' if $preferata_lingvo eq '';
}

###################################################################
#  eligo de la rezulto laŭ diversaj formatoj                      #
###################################################################

#### kaplinioj de la rezultodokumento kaj eble la serĉormularo denove ####

if ($formato eq "txt") {
  print header( -type    => 'text/plain',
				-charset => 'utf-8',
  );
} 

elsif ($formato eq "idx") {

  print header(-charset=>'utf-8');
  my $t = <<EOD;
<html xmlns:xs="http://www.w3.org/2001/XMLSchema"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><title>esperanta indekso</title><link title="indekso-stilo" type="text/css" rel="stylesheet" href="$pado/stl/indeksoj.css"></head><body><table cellspacing="0"><tr><td class="aktiva"><a href="$pado/inx/_eo.html">Esperanto</a></td><td class="fona"><a href="$pado/inx/_lng.html">Lingvoj</a></td><td class="fona"><a href="../inx/_fak.html">Fakoj</a></td><td class="fona"><a href="../inx/_ktp.html">ktp.</a></td></tr>
EOD
  chomp $t;
  print "$t<tr><td colspan=\"4\" class=\"enhavo\">";
  my $aktiva;
  foreach (qw(a b c cx d e f g gx h hx i j jx k l m n o p r s sx t u v z)) {
    my $code = $_;
    $code = $unicode{$_} if exists $unicode{$_};
#print "code=$code, sercxata=$sercxata, _=$_\n";

    if ($sercxata eq "$code%") {
      print "<b class=\"elektita\">$code</b> ";
      $aktiva = $code;

    } else {
      print "<a href=\"kap_$_.html\">$code</a> " unless param('pado') eq 'revo';
      print "<a href=\"?sercxata=$code%&formato=idx&pado=".param('pado')."\">$code</a> " if param('pado') eq 'revo';
    }
  }

  print "<h1>esperanta $aktiva...</h1>\n";
#  print "</tr>\n";

} else {

  print header(-charset=>'utf-8'),
        start_html(
                 -dtd => ['-//W3C//DTD HTML 4.01 Transitional//EN',
                              'http://www.w3.org/TR/html4/loose.dtd'],
                 -lang => 'eo',
                 -title => 'Revo',
                 -style=>{-src=>'/revo/stl/indeksoj.css'},
                 -script=>$JSCRIPT,
                 -onLoad=>"sf()"
  );

  print start_table(-cellspacing=>0),
           Tr(
           [
              td({-class=>'aktiva'}, a({-href=>'/revo/inx/_eo.html'}, 'Esperanto')).
              td({-class=>'fona'}, [a({-href=>'/revo/inx/_lng.html'}, 'Lingvoj'),
				    a({-href=>'/revo/inx/_fak.html'}, 'Fakoj'),
				    a({-href=>'/revo/inx/_ktp.html'}, 'ktp.')]),
           ]
           );

print <<EOD;
<tr><td colspan="4" class="enhavo">
EOD

  if (param('ans')) {
    print "Altnivela serĉo";
  }

  print <<EOD;
<form method="post" action="" target="indekso" name="f">
<input type="text" id="sercxata" name="sercxata"  size="31" maxlength="255" 
  onKeyUp="xAlUtf8(this.value, 'sercxata')" value="$sercxata"  placeholder="Ĵokeroj: % (pluraj) kaj _ (unu)">
<input type="submit" value="trovu">
<br>
EOD

  if (!param('cx')) {
    print <<EOD;
<script type="text/javascript">
document.write("<input type=\\\"checkbox\\\" id=\\\"x\\\" name=\\\"x\\\" onClick=\\\"xAlUtf8(document.f.sercxata.value,'sercxata')\\\" $cx2cx>anstata&#365;igu cx, gx, ..., ux");</script>
<noscript><input type="hidden" id="cx" name="cx" value="1"></noscript>
EOD
  } else {
    print <<EOD;
<input type="hidden" id="cx" name="cx" value="1">
EOD
 }

  print <<EOD;
</form>
EOD
}

if ($sercxata eq "") {
  print "Bonvolu meti ion, kion serĉi";
  exit;
}

if ($sercxata eq "%") {
  print "Bonvolu ne serĉi \"%\".";
  exit;
}

print <<EOD if $formato ne "txt" and $formato ne "idx";
<script type="text/javascript">
document.write("<div id=\\\"atendu\\\" style=\\\"position:absolute; z-index:1\\\"><br><br><br><big>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Atendu iomete...</big><layer></layer></div>");
</script>
EOD

###################################################################
#  serĉo en datumbazo                                             #
###################################################################


# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use revodb;
#use eosort;

my $sercxata_eo = $sercxata;
if (param('cx')) {
  $sercxata_eo =~ s/c[xX]/ĉ/g;
  $sercxata_eo =~ s/g[xX]/ĝ/g;
  $sercxata_eo =~ s/h[xX]/ĥ/g;
  $sercxata_eo =~ s/j[xX]/ĵ/g;
  $sercxata_eo =~ s/s[xX]/ŝ/g;
  $sercxata_eo =~ s/u[xX]/ŭ/g;
  $sercxata_eo =~ s/C[xX]/Ĉ/g;
  $sercxata_eo =~ s/G[xX]/Ĝ/g;
  $sercxata_eo =~ s/H[xX]/Ĥ/g;
  $sercxata_eo =~ s/J[xX]/Ĵ/g;
  $sercxata_eo =~ s/S[xX]/Ŝ/g;
  $sercxata_eo =~ s/U[xX]/Ŭ/g;
}

# Connect to the database.
my $dbh = revodb::connect();

# necesas!
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

use Time::HiRes qw (gettimeofday tv_interval);
my %trovitajPagxoj;
my $regulira = $sercxata =~ /[.^$\[\(\|+?{\\]/;

if ($regulira) {
  Sercxu('REGEXP', $sercxata, $sercxata_eo, $preferata_lingvo);
} elsif ($sercxata =~ /[%_]/) {
  Sercxu('LIKE', $sercxata, $sercxata_eo, $preferata_lingvo);
} else {
  Sercxu('=', $sercxata, $sercxata_eo, $preferata_lingvo);
}

# se vi trovis nur unu rezulton, tuj malfermu gxin
if (scalar keys %trovitajPagxoj == 1 and $formato ne "txt") {
  print '<script type="text/javascript">' . "\n";
  print '<!--' . "\n";

  foreach my $pagxo (keys %trovitajPagxoj) {
    print "parent.precipa.location.href = '/revo/art/" . $pagxo
      . ".html#$trovitajPagxoj{$pagxo}';\n";
    last;
  }
  print '//-->' . "\n";
  print '</script>' . "\n";
}

$dbh->disconnect() or die "Malkonekto de la datumbazo ne funkciis";
  
#print h1("Fino.");
  print "<br>" if $neniu_trafo and $formato ne "txt";
  print "Neniu trafo..." if $neniu_trafo;

  print <<EOD if $formato ne "txt" and $formato ne "idx";

<script type="text/javascript">
<!--
var browserType;

if (document.layers) {browserType = "nn4"};
if (document.all) {browserType = "ie"};
if (window.navigator.userAgent.toLowerCase().match("gecko")) {
   browserType= "gecko";
}
  if (browserType == "gecko" )
     document.poppedLayer = 
         eval('document.getElementById(\\'atendu\\')');
  else if (browserType == "ie")
     document.poppedLayer = 
        eval('document.all[\\'atendu\\']');
  else
     document.poppedLayer =   
        eval('document.layers[\\'`atendu\\']');
  document.poppedLayer.style.visibility = "hidden";
//-->
</script>
EOD

print "</td></tr>", end_table(), end_html() if $formato ne "txt";;

exit;


###################################################################
# helpunkcioj por serĉo                                           #
###################################################################


sub Sercxu
{
  my ($komparo, $sercxata2, $sercxata2_eo, $preferata_lingvo) = @_;
  my $tempo = [gettimeofday];
  my $addqry = "";
  my ($sth, $sth2);

  #{
  #  my @fak = param("fak");
  #  foreach my $fak (@fak) {
  #    $addqry .= " and (".join(" or ", map {my $not=" not" if s/^!//; "d.drv_fak$not like '%\_$_\_%'"} split(/,#/, $fak)).")";
  #  }
  #}
#
  #{
  #  my @stl = param("stl");
  #  foreach my $stl (@stl) {
  #    $addqry .= " and (".join(" or ", map {my $not=" not" if s/^!//; "d.drv_stl$not like '%\_$_\_%'"} split(/,#/, $stl)).")";
  #  }
  #}

  # ni bezonas la lingvo-nomojn...
  my $lingvoj = $dbh->selectall_hashref("SELECT lng_kodo, lng_nomo FROM lng",'lng_kodo');


  if ($param_lng eq 'eo' or $param_lng eq '') {

    if (not $preferata_lingvo) {
      $sth = $dbh->prepare(
        "SELECT DISTINCT SUBSTRING_INDEX(mrk,'.',2), kap FROM ( "
          ."SELECT mrk,kap "
          ."FROM v3esperanto WHERE kap $komparo ? AND mrk IS NOT NULL "
        ."UNION "
          ."SELECT mrk, ekz AS kap "
          ."FROM v3traduko WHERE ekz $komparo ? AND mrk IS NOT NULL "
        .") AS u LIMIT $LIMIT_eo");


      eval {
        $sth->execute($sercxata2_eo, $sercxata2_eo);
      };   

    } else {
      # ni devas iom truki, por ricevi ankaŭ kapvortojn, kiuj ne havas tradukon
      # en $preferata_lingvo:
      # PLIBONIGU: ni devos movi la lingvo-filtradon el WHERE al ON, rezignante pri v3esperanto
      # por inkluzvi kapvortojn sen koncernaj tradukoj!
      $sth = $dbh->prepare(
         "SELECT DISTINCT SUBSTRING_INDEX(mrk,'.',2) AS drvmrk,kap,ekz,lng, "
        ."GROUP_CONCAT(DISTINCT CASE WHEN trd THEN trd ELSE ind END SEPARATOR ', ') AS trd "
        ."FROM ( "
              ."SELECT mrk, kap, ekz, lng, ind, trd "
              ."FROM v3esperanto  WHERE kap $komparo ? AND lng = ? AND mrk IS NOT NULL "
            ."UNION "
              ."SELECT mrk, ekz AS kap, ekz, lng, ind, trd "
              ."FROM v3traduko  WHERE ekz $komparo ? AND lng = ? AND mrk IS NOT NULL "
            ."UNION "
              ."SELECT mrk, kap, '' AS ekz, ? AS lng, null AS ind, null AS trd "
              ."FROM v3esperanto  WHERE kap $komparo ? AND mrk IS NOT NULL "
            ."UNION "
              ."SELECT mrk, ekz AS kap, '' AS ekz, ? AS lng, null AS ind, null AS trd "
              ."FROM v3traduko WHERE ekz $komparo ? AND mrk IS NOT NULL "
        .") AS u GROUP BY drvmrk,kap,ekz,lng LIMIT $LIMIT_eo");

      #      print $preferata_lingvo.
      #  "\nSELECT DISTINCT SUBSTRING_INDEX(mrk,'.',2) AS drvmrk,kap,ekz,lng, "
      #  ."GROUP_CONCAT(DISTINCT CASE WHEN trd THEN trd ELSE ind END SEPARATOR ', ') AS trd "
      #  ."FROM ( "
      #        ."SELECT mrk, kap, ekz AS ekz, lng, ind, trd "
      #        ."FROM v3esperanto  WHERE kap $komparo ? AND lng = ? AND mrk IS NOT NULL "
      #      ."UNION "
      #        ."SELECT mrk, ekz AS kap, ekz AS ekz1, lng, ind, trd "
      #        ."FROM v3traduko  WHERE ekz $komparo ? AND lng = ? AND mrk IS NOT NULL "
      #      ."UNION "
      #        ."SELECT mrk, kap, '' AS ekz, ? AS lng, null AS ind, null AS trd "
      #        ."FROM v3esperanto  WHERE kap $komparo ? AND mrk IS NOT NULL "
      #      ."UNION "
      #        ."SELECT mrk, ekz AS kap, '' AS ekz, ? AS lng, null AS ind, null AS trd "
      #        ."FROM v3traduko WHERE ekz $komparo ? AND mrk IS NOT NULL "
      #  .") AS u GROUP BY drvmrk,kap,ekz,lng LIMIT $LIMIT_eo" if ($verbose);

      eval {
        $sth->execute($sercxata2_eo, $preferata_lingvo, $sercxata2_eo, $preferata_lingvo,
          $preferata_lingvo, $sercxata2_eo, $preferata_lingvo, $sercxata2_eo);
      };        

    }

    $sth2 = undef; # ni ne plu bezonas...

    if ($@) {
      # $sth->err and $DBI::err will be true if error was from DBI
      if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
        print "Eraro: La rektaj krampoj ([ ]) ne kongruas.<br>\n";
      } else {
        print "Err ".$sth->err." - $@";
      }
    } else {

      my $first = 1;
      while (my $ref = $sth->fetchrow_hashref()) {
        if ($first) {
          if ($preferata_lingvo) {
            my $pnomo = $lingvoj->{$preferata_lingvo}->{lng_nomo} || $preferata_lingvo;
            print "<h1>esperanta ($pnomo)</h1>\n";
          } else {
            print "<h1>esperanta</h1>\n";
          }
          $first = 0;
        };

        my $href = $ref->{drvmrk}; $href =~ s|^([a-z0-9]+)\.|/revo/art/$1.html#$1.|;
        my $kap = $ref->{ekz}? $ref->{ekz} : $ref->{kap};
        my $klr = $ref->{trd}? ' ('.$ref->{trd}.')' : '';
        print a({href=>"$href", target=>"precipa"}, $kap), $klr, br();

        $neniu_trafo = 0;
      }
    }
  }


  if (($formato ne "txt" or $param_lng ne 'eo') and $formato ne "idx") {


    if ($param_lng) {	# nur unu lingvo
	    $preferata_lingvo = $param_lng;
      $sth = $dbh->prepare(
         "SELECT DISTINCT SUBSTRING_INDEX(mrk,'.',2) AS drvmrk, kap, lng, ind, trd, ekz "
        ."FROM v3traduko "
        ."WHERE ind $komparo ? AND lng = ? "
        ."ORDER BY lng, ind, kap "
        ."LIMIT $LIMIT_trd");

	  } else {			# cxiuj lingvojn
      $sth = $dbh->prepare(
         "SELECT DISTINCT SUBSTRING_INDEX(mrk,'.',2) AS drvmrk, kap, lng, ind, trd, ekz "
        ."FROM v3traduko "
        ."WHERE ind $komparo ? "
        ."ORDER BY ABS(STRCMP(lng, ?)), lng, ind, kap "
        ."LIMIT $LIMIT_trd");
	}

    eval {
      $sth->execute($sercxata2, $preferata_lingvo);
    };

    if ($@) {
      # $sth->err and $DBI::err will be true if error was from DBI
      if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
      } else {
        print "Err ".$sth->err." - $@";
      }
    } else {
      # MontruRezultojn($sth, $param_lng, $preferata_lingvo, $sth2);

      my $last_lng = 'eo';

      while (my $ref = $sth->fetchrow_hashref()) {
        my $lng = $ref->{lng};
        my $lng_nomo = $lingvoj->{$lng}->{lng_nomo} || $lng;

        # titolo ĉe nova lingvo en la listo...
        print "<br>\n" if $lng ne $last_lng;
        print "<h1>$lng_nomo</h1>\n" if $lng ne $last_lng;
        $last_lng = $lng;

        my $href = $ref->{drvmrk}; $href =~ s|^([a-z0-9]+)\.|/revo/art/$1.html#$1.|;
        my $klr = $ref->{ekz}? ' ('.$ref->{ekz}.')' : ($ref->{kap}? ' ('.$ref->{kap}.')' : '');
        my $trd = $ref->{trd}? $ref->{trd} : $ref->{ind};
        print a({href=>"$href\&lng=$lng", target=>"precipa"}, $trd), $klr, br();

        $neniu_trafo = 0;
      }
    }
  }
}
