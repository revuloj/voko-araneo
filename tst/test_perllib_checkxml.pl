#!/usr/bin/perl -w
use utf8;
use open ':std', ':encoding(UTF-8)';

use Test::More tests => 8;
# or
#use Test::More skip_all => $reason;

use lib("../cgi/perllib","./cgi/perllib");
use Cwd;

my $xml_dir = getcwd().'/xml';
my $rc;
my $err;

require_ok( 'revo::checkxml' );

# https://hexmos.com/freedevtools/man-pages/user-commands/text-processing/rxp/
# If the -V flag is given, and the document is well-formed but not valid, 2 is returned.  
# If  the  document is  not well-formed, or a system error occurs, 1 is returned.  
# Otherwise 0 is returned. 

my $VALIDA = 0;
my $NEBONFORMA = 1;
my $NEVALIDA = 2;

#is(revo::checkxml::check_xml('<xml version="1.0"></xml>',$xml_dir),0, 'nur <xml...>');
#my ($rc,$out) = revo::checkxml::check_xml_2('<xml version="1.0"</xml>',$xml_dir);
#is($rc,19,'nevalida <xml...') or diag($out);
my $small_xml = <<'END_SMALL_XML';
<?xml version="1.0"?>
<!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd">
<vortaro><art></art></vortaro>
END_SMALL_XML

($rc,$out) = revo::checkxml::check_xml_2($small_xml,$xml_dir);
# mankas atributo mrk => 2
is($rc,2,'<vortaro>...') or diag($out);

my $valid_xml = <<'END_VAL_XML';
<?xml version="1.0"?>
<!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd">

<vortaro>
<art mrk="$Id: artefakt.xml,v 1.1 2018/04/04 10:10:16 revo Exp $">
<kap>
  <rad>artefakt</rad>/o <fnt><bib>SPIV</bib></fnt>
</kap>
<drv mrk="artefakt.0o">
  <kap><tld/>o</kap>
  <snc mrk="artefakt.0o.ARKE">
    <uzo tip="fak">ARKE</uzo>
    <dif>
      <ref tip="dif" cel="art.0efaritajxo.KOMUNE">Artefarita&jcirc;o</ref>,
      objekto prilaborita por iu celo a&ubreve; uzo
      kontraste al a&jcirc;o rezultanta de natura procezo:
      <ekz>
        ritaj <tld/>oj el tombo 268 de la tombejo &Gcirc;arkutan 4B
        <fnt>
          <aut>V. I. Ionesov</aut>
          <vrk><url
          ref="http://www.eventoj.hu/steb/arkeologio/baktrio/baktrio2.htm">
          Kulturo kaj socio de Norda Baktrio</url></vrk>
          <lok>Scienca Revuo, 1992:1 (43), p. 3a-8a</lok>
        </fnt>.
      </ekz>
    </dif>
  </snc>
  <trd lng="fr">artefact</trd>
</drv>
</art>

<!--
$Log$
-->
</vortaro>
END_VAL_XML

($rc,$err) = xml_test($valid_xml);
is($rc,$VALIDA,'neniu eraro en valida XML artefakt...')
  or diag($err);

# nun enŝovu erarojn en XML...
my $invalid_xml = $valid_xml;
$invalid_xml =~ s/<vortaro>//;

($rc,$err) = xml_test($invalid_xml);
my @lines = split(/\n/,$err);
is($rc,$NEBONFORMA,'nebonforma XML artefakt...') 
# Atentu: Radika elemento estas art, devus esti vortaro
#  ĉe pozicio 5:5
&& like($lines[0], qr/^Atentu: Radika elemento.*art.*vortaro/, 'averto ĉe 5:5 en artefakt...')
&& like($lines[1], qr/^\s*ĉe pozicio 5:5$/, 'averto ĉe 5:5 en artefakt...')
# Eraro: Elementofino </vortaro> ekster iu elemento
#  ĉe pozicio 36:10
&& like($lines[2], qr/^Eraro: Elementofino.*<\/vortaro>/, 'eraro ĉe 36:10 en artefakt...')
&& like($lines[3], qr/^\s*ĉe pozicio 36:10$/, 'eraro ĉe 36:10 en artefakt...')
  or diag("redonita: ".$err);


sub xml_test {
  my $xml = shift;
  my ($rc,$err) = revo::checkxml::check_xml_2($xml,$xml_dir);
  return ($rc,$err);
}
