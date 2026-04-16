#!/usr/bin/perl

#
# sercxu.pl
# 
# (c) laŭ permesilo GPL 2.0
# 2006-2007 Wieland Pusch
# 2006 Bart Demeyere
# 2021-2026 Wolfram Diestel
#

use warnings; use strict;

use CGI qw(:standard *table); use CGI::Carp qw(fatalsToBrowser);
use DBI();
use URI::Escape;

use utf8; use open ':std', ':encoding(UTF-8)';


my $LIMIT_eo = 50;
my $LIMIT_trd = 250;

my $verbose=0; # 1 = debugging...


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
  kadraro();
  exit 1;
}

#utf8::decode($sercxata);
#$ENV{HTTP_ACCEPT_LANGUAGE} = ''; # por testi

###################################################################
#  eligo de la rezulto laŭ diversaj formatoj                      #
###################################################################

#### kaplinioj de la rezultodokumento kaj eble la serĉormularo denove ####

print header(-charset   =>'utf-8'),
  start_html(
    -dtd    => ['-//W3C//DTD HTML 4.01 Transitional//EN',
                'http://www.w3.org/TR/html4/loose.dtd'],
    -lang   => 'eo',
    -title  => 'Revo',
    -style  => {-src=>'/revo/stl/indeksoj.css'},
    -script => js_literoj(),
    -onLoad => "sf()"
);

print start_table(-cellspacing=>0),
  Tr(
    [
      td({-class =>'aktiva'}, 
        a({-href => '/revo/inx/_eo.html'}, 'Esperanto')
      ).
      td({-class =>'fona'}, [
        a({-href => '/revo/inx/_lng.html'}, 'Lingvoj'),
        a({-href =>'/revo/inx/_fak.html'}, 'Fakoj'),
        a({-href =>'/revo/inx/_ktp.html'}, 'ktp.')
      ]),
    ]
  );

print <<'EOD';
<tr><td colspan="4" class="enhavo">
EOD

print_form();


if ($sercxata eq "") {
  print "Bonvolu meti ion, kion serĉi";
  exit;
}

if ($sercxata eq "%") {
  print "Bonvolu ne serĉi \"%\".";
  exit;
}

print_atendu_script();

###################################################################
#  serĉo en datumbazo                                             #
###################################################################


# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use revodb;

my $sercxata_eo = $sercxata;
if (param('cx')) {
  ## no critic (RegularExpressions::RequireExtendedFormatting)
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
  ## use critic
}

# Connect to the database.
my $dbh = revodb::connect();

# necesas!
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

my %trovitajPagxoj;
my $regulira = $sercxata =~ m{
    [.^\$\[\(\|+?{\\] #..}
  }x;

## no critic (RegularExpressions::RequireExtendedFormatting)
my $preferata_lingvo = preferata_lingvo();

if ($regulira) {
  Sercxu('REGEXP', $sercxata, $sercxata_eo, $preferata_lingvo);
} elsif ($sercxata =~ /[%_]/) {
  Sercxu('LIKE', $sercxata, $sercxata_eo, $preferata_lingvo);
} else {
  Sercxu('=', $sercxata, $sercxata_eo, $preferata_lingvo);
}
## use critic

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

$dbh->disconnect() 
  or die "Malkonekto de la datumbazo ne funkciis.\n";

#print h1("Fino.");
print "<br>" 
if ($neniu_trafo and $formato ne "txt");

print "Neniu trafo..." 
if ($neniu_trafo);

print_atendu_kasxu();

print 
  "</td></tr>", 
  end_table(), 
  end_html() 
if ($formato ne "txt");

exit;
#####


###################################################################
# helpunkcioj por serĉo                                           #
###################################################################

sub kadraro {
  # uzata de kono.be/vivo
  print "Content-type: text/html; charset=utf-8\n\n";

  utf8::encode($sercxata);
  $sercxata = uri_escape($sercxata);

  $sercxata .= "&lng=".uri_escape(param('lng')) if param('lng');
  $sercxata .= "&trd=".uri_escape(param('trd')) if param('trd');

  # kopiu index.html  
  open my $in, '<', "../revo/index.html" 
    or die "serĉo en kadroj ne eblas ĉar mankas dosiero 'index.html'\n";
  while (<$in>) {
    s{src="inx/_eo.html"}
      {src="sercxu.pl?cx=1&sercxata=$sercxata"}x;
    s{src="titolo.html"}
      {src="../revo/titolo.html"}x;
    print;
  }
  close $in;
  return;
}

sub preferata_lingvo {
  my $pref_lingvo;
  {
    my @a = split ",", $ENV{HTTP_ACCEPT_LANGUAGE};
    $pref_lingvo = shift @a;
    $pref_lingvo = shift @a if $pref_lingvo =~ /^eo/x;
    $pref_lingvo =~ s{^
      ([^;-]+).*
    }{$1}x;
  #  $pref_lingvo = 'nenio' if $pref_lingvo eq '';
  }
  return $pref_lingvo;
}

#### Javoskripto por la serĉformularo ####
sub js_literoj {
  return<<'END';
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
}

## eligu la serĉformularon
sub print_form {

  print <<"EOD";
<form method="post" action="" target="indekso" name="f">
<input type="text" id="sercxata" name="sercxata"  size="31" maxlength="255" 
  onKeyUp="xAlUtf8(this.value, 'sercxata')" value="$sercxata"  placeholder="Ĵokeroj: % (pluraj) kaj _ (unu)">
<input type="submit" value="trovu">
<br>
EOD

  if (!param('cx')) {
    print <<"EOD";
<script type="text/javascript">
document.write("<input type=\\\"checkbox\\\" id=\\\"x\\\" name=\\\"x\\\" onClick=\\\"xAlUtf8(document.f.sercxata.value,'sercxata')\\\" $cx2cx>anstata&#365;igu cx, gx, ..., ux");</script>
<noscript><input type="hidden" id="cx" name="cx" value="1"></noscript>
EOD
  } else {
    print <<'EOD';
<input type="hidden" id="cx" name="cx" value="1">
EOD
  }

  print <<'EOD';
</form>
EOD

  return;
}

sub print_atendu_script {
  print <<"EOD" if $formato ne "txt" and $formato ne "idx";
<script type="text/javascript">
document.write("<div id=\\\"atendu\\\" style=\\\"position:absolute; z-index:1\\\"><br><br><br><big>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Atendu iomete...</big><layer></layer></div>");
</script>
EOD
return;
}

sub print_atendu_kasxu {
  print <<'EOD' if $formato ne "txt" and $formato ne "idx";
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
         eval('document.getElementById(\'atendu\')');
  else if (browserType == "ie")
     document.poppedLayer = 
        eval('document.all[\'atendu\']');
  else
     document.poppedLayer =   
        eval('document.layers[\'atendu\']');
  document.poppedLayer.style.visibility = "hidden";
//-->
</script>
EOD
  return;
}

## no critic (Subroutines::ProhibitExcessComplexity)
sub Sercxu
{
  my ($komparo, $sercxata2, $sercxata2_eo, $pref_lng) = @_;
  my $addqry = "";
  my $sth;

  # ni bezonas la lingvo-nomojn...
  my $lingvoj = $dbh->selectall_hashref("SELECT lng_kodo, lng_nomo FROM lng",'lng_kodo');


  if ($param_lng eq 'eo' or $param_lng eq '') {

    if (not $pref_lng) {
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
      } or do {
        warn "Ne eblis elekti datumojn el v3esperanto kaj v3traduko.\n"
      };

    } else {
      # ni devas iom truki, por ricevi ankaŭ kapvortojn, kiuj ne havas tradukon
      # en $pref_lng:
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

      eval {
        $sth->execute($sercxata2_eo, $pref_lng, $sercxata2_eo, $pref_lng,
          $pref_lng, $sercxata2_eo, $pref_lng, $sercxata2_eo);
      } or do {
        warn "Ne eblis elekti datumojn el v3esperanto kaj v3traduko.\n"
      };

    }

    if ($@) {
      # $sth->err and $DBI::err will be true if error was from DBI
      if ($sth->err == 1139) { # eraro 1139: "Got error 'brackets ([ ]) not balanced"
        print "Eraro: La rektaj krampoj ([ ]) ne kongruas.<br>\n";
      } else {
        print "Err ".$sth->err." - $@";
      }
    } else {

      my $first = 1;
      while (my $ref = $sth->fetchrow_hashref()) {
        if ($first) {
          if ($pref_lng) {
            my $pnomo = $lingvoj->{$pref_lng}->{lng_nomo} || $pref_lng;
            print "<h1>esperanta ($pnomo)</h1>\n";
          } else {
            print "<h1>esperanta</h1>\n";
          }
          $first = 0;
        };

        my $href = $ref->{drvmrk}; 
        $href =~ s{^
          ([a-z0-9]+)\.
          }{/revo/art/$1.html#$1.}x;

        my $kap = $ref->{ekz}? $ref->{ekz} : $ref->{kap};
        my $klr = $ref->{trd}? ' ('.$ref->{trd}.')' : '';
        print a({href=>"$href", target=>"precipa"}, $kap), $klr, br();

        $neniu_trafo = 0;
      }
    }
  }


  if ($param_lng ne 'eo') {

    if ($param_lng) {  # nur unu lingvo
	    $pref_lng = $param_lng;
      $sth = $dbh->prepare(
         "SELECT DISTINCT SUBSTRING_INDEX(mrk,'.',2) AS drvmrk, kap, lng, ind, trd, ekz "
        ."FROM v3traduko "
        ."WHERE ind $komparo ? AND lng = ? "
        ."ORDER BY lng, ind, kap "
        ."LIMIT $LIMIT_trd");

	  } else {  # cxiuj lingvojn
      $sth = $dbh->prepare(
         "SELECT DISTINCT SUBSTRING_INDEX(mrk,'.',2) AS drvmrk, kap, lng, ind, trd, ekz "
        ."FROM v3traduko "
        ."WHERE ind $komparo ? "
        ."ORDER BY ABS(STRCMP(lng, ?)), lng, ind, kap "
        ."LIMIT $LIMIT_trd");
	  }

    eval {
      $sth->execute($sercxata2, $pref_lng);
    } or do {
      warn "Ne eblis elekti datumojn de v3traduko\n";
    };

    if ($@) {
      # $sth->err and $DBI::err will be true if error was from DBI
      if ($sth->err == 1139) { # eraro 1139: "Got error 'brackets ([ ]) not balanced"
      } else {
        print "Err ".$sth->err." - $@";
      }
    } else {

      my $last_lng = 'eo';

      while (my $ref = $sth->fetchrow_hashref()) {
        my $lng = $ref->{lng};
        my $lng_nomo = $lingvoj->{$lng}->{lng_nomo} || $lng;

        # titolo ĉe nova lingvo en la listo...
        print "<br>\n" if $lng ne $last_lng;
        print "<h1>$lng_nomo</h1>\n" if $lng ne $last_lng;
        $last_lng = $lng;

        my $href = $ref->{drvmrk}; 
        $href =~ s{^
          ([a-z0-9]+)\.
        }{/revo/art/$1.html#$1.}x;

        my $klr = $ref->{ekz}? ' ('.$ref->{ekz}.')' : ($ref->{kap}? ' ('.$ref->{kap}.')' : '');
        my $trd = $ref->{trd}? $ref->{trd} : $ref->{ind};
        print a({href=>"$href\&lng=$lng", target=>"precipa"}, $trd), $klr, br();

        $neniu_trafo = 0;
      }
    }
  }
  return;
}
