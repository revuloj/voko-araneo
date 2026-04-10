#!/usr/bin/perl

# checkencode.pl
# 
# 2008-03-24 Wieland Pusch
# ..2026 Wolfram Diestel

# Kontrolu, ĉu artikoloj estas ĝuste koditaj laŭ liternomoj 
# (vd. voko-grundo/dtd/vokosgn.dtd kaj perllib/revo/voko_entities.pm)

use warnings; use strict;

use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);
use DBI();

print header(-charset=>'utf-8'),
      start_html(-title => 'Enhavo de '.param('art').".xml");

## no critic (RegularExpressions::RequireExtendedFormatting)

if (param('arts')) {
  param('art', join('#', split /\r*\n/,param('arts')));

} elsif (!param('art')) {
  print h1('arts = '.param('arts'));
  print h2('arts = '.join('#', split /\r*\n/,param('arts')));
  print start_form();
  print textarea(-name=>'arts',
                 -rows=>10,
                 -columns=>50),
        hidden(-name=>'verbose',
               -default=>param('verbose'));
  print br, submit(-name=>'button');
  print endform;
  print end_html();
  exit 1;
}

print h1('Enhavo de '.param('art').".xml");

my $homedir = "/hp/af/ag/ri";
print h1("homedir = $homedir");

my $start_time = time();

my $xmldir = "$homedir/www/revo/xml";

local $ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
#print h1("LD_LIBRARY_PATH = ".$ENV{'LD_LIBRARY_PATH'});
local $ENV{'PATH'} = $ENV{'PATH'}.":$homedir/files/bin";
#print h1("PATH = ".$ENV{'PATH'});

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use revo::encode;
use revo::decode;

my @arts;
if (param('arts')) {
  @arts = sort split /\r*\n/,param('arts');
} else {
  push @arts, param('art');
}

my $verbose = param('verbose');
#$verbose = 0 unless $verbose;

my $art_count;
my $last_art;
foreach my $artikolo (@arts) {
  if ($artikolo && $artikolo ne $last_art) {
    $art_count += checkencode($artikolo);
    $last_art = $artikolo;
  }
}
  
print h2("Tuta daŭro: ".(time() - $start_time)." sekundoj por $art_count artikoloj.");
print h1("Fino.");

print end_html();

sub checkencode {
  my $art = shift;
  my $num;
  print "art=$art xmldir=$xmldir<br>\n";

  foreach my $fname (glob("$xmldir/$art.xml")) {
#    print "fname = $fname<br>\n";
    $num++;

    open my $in, "<", $fname 
      or die "Ne povas legi $fname: $!\n";
    my $xml = do { local $/ = undef; <$in> };
    close $in;

    my $xml2 = revo::decode::rvdecode($xml);
    my $xml3 = revo::encode::encode2($xml2, 20, 0);

    my %map = (
    '&#8211;' => '&ndash;',
    '&#259;'  => '&abreve;',
    '&#355;'  => '&tcedil;',
    '&#225;'  => '&aacute;',
    '&#7944;' => '&Alfa_psili;',
    '&#244;'  => '&ocirc;',
    '&#237;'  => '&iacute;',
    '&#365;'  => '&ubreve;',
    '&#233;'  => '&eacute;',
    '&#232;'  => '&egrave;',

    '&#8211;' => '&ndash;',
    '&#259;' => '&abreve;', 
    '&#355;' => '&tcedil;', 
    '&#225;' => '&aacute;', 
    '&#7944;' => '&Alfa_psili;', 
    '&#244;' => '&ocirc;', 
    '&#237;' => '&iacute;', 
    '&#365;' => '&ubreve;', 
    '&#233;' => '&eacute;', 
    '&#232;' => '&egrave;', 
    '&#322;' => '&lstroke;', 
    '&#231;' => '&ccedil;', 
    '&#227;' => '&atilde;', 
    '&#8166;' => '&ypsilon_circ;', 
    '&#x103;' => '&abreve;', 
    '&#1576;' => '&ba;', 
    '&#1607;' => '&ha;', 
    '&#1610;' => '&ya;', 
    '&#1605;' => '&mim;', 
    '&#1608;' => '&waw;', 
    '&#1579;' => '&tha;', 
    '&#1578;' => '&ta;', 

    '&#234;' => '&ecirc;', 
    '&#x2192;' => '&#8594;', 
    '&#1632;' => '&ar_0;',
    '&#1633;' => '&ar_1;',
    '&#1634;' => '&ar_2;',
    '&#1635;' => '&ar_3;',
    '&#1636;' => '&ar_4;',
    '&#1637;' => '&ar_5;',
    '&#1638;' => '&ar_6;',
    '&#1639;' => '&ar_7;',
    '&#1640;' => '&ar_8;',
    '&#1641;' => '&ar_9;', 
    '&#x2286;' => '&#8838;', 
    '&#x2124;' => '&#8484;', 
    '&#243;' => '&oacute;', 
    '&#226;' => '&acirc;', 
    '&#250;' => '&uacute;', 
    '&#160;' => '&nbsp;', 
    '&#252;' => '&uuml;', 
    '&#1585;' => '&ra;', 
    '&#1606;' => '&nun1;', 
    '&#224;' => '&agrave;', 
    '&#x15F;' => '&scedil;', 
    '&#349;' => '&scirc;', 
    '&#201;' => '&Eacute;', 
    '&#7988;' => '&jota_psili_acute;', 
    '&#x221e;' => '&#8734;', 
    '&#8150;' => '&jota_circ;', 
    '&#8212;' => '&mdash;', 
    '&#942;' => '&eta_ton;', 
    '&#x2264;' => '&#8804;', 
    '&#x451;' => '&c_jo;', 
    '&#1111;' => '&c_ji;', 
    '&#x2282;' => '&#8834;', 
    '&#x2201;' => '&#8705;', 
    '&#x2228;' => '&#8744;', 
    '&#x2227;' => '&#8743;', 
    '&#x2261;' => '&#8801;', 
    '&#60;' => '&lt;', 
    '&#62;' => '&gt;', 
    '&#285;' => '&gcirc;', 
    '&#x163;' => '&tcedil;', 
    '&#x2116;' => '&#8470;', 
    '&#xd7;' => '&#215;', 
    '&#x2219;' => '&#8729;', 
    '&#x2020;' => '&#8224;', 
    '&#x2666;' => '&#9830;', 
    '&#x672C;' => '&#26412;', 
    '&#x307B;' => '&#12411;', 
    '&#x3093;' => '&#12435;', 
    '&#318;' => '&lcaron;', 
    '&#1108;' => '&c_jeu;', 
    '&#x305;' => '&#773;', 
    '&#x117;' => '&#279;', 
    '&#x2208;' => '&#8712;', 
    '&#182;' => '&para;', 
    '&#324;' => '&nacute;', 
    '&#263;' => '&cacute;', 
    '&#382;' => '&zcaron;', 
    '&#1118;' => '&c_w;',
    '&#x30A2;' => '&#12450;', 
    '&#x30EA;' => '&#12522;', 
    '&#x3042;' => '&#12354;', 
    '&#x308A;' => '&#12426;', 
    '&#x306E;' => '&#12398;', 
    '&#x5DE3;' => '&#24035;', 
    '&#x306E;' => '&#12398;', 
    '&#x3059;' => '&#12377;', 
    '&#351;' => '&scedil;'
    );

    my $regex = join '|', map { quotemeta } keys %map;
    $xml =~ s{($regex)}{$map{$1}}xg;

    if (param('samsignifa')) {

      my %map2 = (
      'ŭ' => '&ubreve;', 
      'ĉ' => '&ccirc;', 
      'ŝ' => '&scirc;', 
      '―' => '&dash;', 
      'Ĉ' => '&Ccirc;', 
      '„' => '&leftquot;', 
      '“' => '&rightquot;', 
      'И' => '&c_I;',
      'л' => '&c_l;',
      'ь' => '&c_mol;',
      'я' => '&c_ja;',
      'ć' => '&cacute;', 
      'ĝ' => '&gcirc;', 
      'н' => '&c_n;', 
      'а' => '&c_a;', 
      'с' => '&c_s;', 
      'т' => '&c_t;', 
      'ñ' => '&ntilde;', 
      'ν' => '&ny;', 
      'ο' => '&omikron;', 
      'σ' => '&sigma;', 
      'τ' => '&tau;', 
      'α' => '&alfa;', 
      'λ' => '&lambda;', 
      'γ' => '&gamma;', 
      'ί' => '&jota_ton;', 
      'á' => '&aacute;', 
      'г' => '&c_g;', 
      'і' => '&c_ib;', 
      'ê' => '&ecirc;', 
      'ó' => '&oacute;', 
      'и' => '&c_i;', 
      'ч' => '&c_ch;', 
      'о' => '&c_o;', 
      'ы' => '&c_y;', 
      'е' => '&c_je;', 
      'к' => '&c_k;', 
      'й' => '&c_j;', 
      'з' => '&c_z;', 
      'ф' => '&c_f;', 
      'у' => '&c_u;', 
      'р' => '&c_r;', 
      'ő' => '&odblac;', 
      'ç' => '&ccedil;', 
      'в' => '&c_v;', 
      'д' => '&c_d;', 
      'м' => '&c_m;', 
      'х' => '&c_h;', 
      'ü' => '&uuml;', 
      'ĵ' => '&jcirc;', 
      'ш' => '&c_sh;', 
      'б' => '&c_b;', 
      'п' => '&c_p;', 
      'э' => '&c_e;', 
      'ж' => '&c_zh;', 
      'é' => '&eacute;', 
      'ë' => '&euml;', 
      'ё' => '&c_jo;', 
      'ц' => '&c_c;', 
      'í' => '&iacute;', 
      'ö' => '&ouml;', 
      'ą' => '&aogonek;', 
      'ä' => '&auml;', 
      'ю' => '&c_ju;', 
      'щ' => '&c_shch;', 
      'ű' => '&udblac;', 
      'ú' => '&uacute;', 
      'è' => '&egrave;', 
      'à' => '&agrave;', 
      'ô' => '&ocirc;', 
      'ĥ' => '&hcirc;', 
      'ž' => '&zcaron;', 
      'ў' => '&c_w;', 
      'Ŝ' => '&Scirc;', 
      'â' => '&acirc;', 
      'ζ' => '&zeta;', 
      'ι' => '&jota;', 
      'ť' => '&tcaron;', 
      'ã' => '&atilde;', 
      'κ' => '&kappa;', 
      'ς' => '&sigma_fina;', 
      'ý' => '&yacute;', 
      '∅' => '&#8709;', 
      'ł' => '&lstroke;', 
      'Ä' => '&Auml;', 
      'ę' => '&eogonek;', 
      'Ĝ' => '&Gcirc;', 
      'î' => '&icirc;', 
      'ß' => '&szlig;', 
      'ń' => '&nacute;', 
      'ś' => '&sacute;', 
      'ż' => '&zdot;', 
      'Å' => '&Aring;', 
      '¶' => '&para;', 
      'π' => '&pi;', 
      'υ' => '&ypsilon;', 
      'ε' => '&epsilon;', 
      'μ' => '&my;', 
      'ώ' => '&omega_ton;', 
      'ω' => '&omega;', 
      'ά' => '&alfa_ton;', 
      'δ' => '&delta;', 
      'θ' => '&theta;', 
      'š' => '&scaron;', 
      'β' => '&beta;', 
      'ό' => '&omikron_ton;', 
      'ή' => '&eta_ton;', 
      'æ' => '&aelig;', 
      'ř' => '&rcaron;', 
      'ъ' => '&c_malmol;'
      );
      my $regex2 = join '|', map { quotemeta } keys %map2;
      $xml =~ s{($regex2)}{$map2{$1}}xg;
    }
  
    my @xml = split '\n', $xml;
    my @xml2 = split '\n', $xml2;
    my @xml3 = split '\n', $xml3;

    print "$#xml - $#xml3<br>\n" if $#xml != $#xml3;
    for my $i (0 .. $#xml) {
      # montru evtl. diferencojn
      print pre(escapeHTML("$fname:\n$xml[$i]\n$xml3[$i]\n$xml2[$i]\n")) if ($xml[$i] ne $xml3[$i]);
    }
  }

  return $num;
};

1;
