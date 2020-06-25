#!/usr/bin/perl -w

use Test::More tests => 6;
# or
#use Test::More skip_all => $reason;

use lib("../cgi/perllib","./cgi/perllib");
use Cwd;

my $xml_dir = getcwd().'/xml';

require_ok( 'revo::checkxml' );

# http://xmlsoft.org/XSLT/xsltproc.html
# xsltproc's return codes 
# 0: normal
# 1: no argument
# 2: too many parameters
# 3: unknown option
# 4: failed to parse the stylesheet
# 5: error in the stylesheet
# 6: error in one of the documents
# 7: unsupported xsl:output method
# 8: string parameter contains both quote and double-quotes
# 9: internal processing error
# 10: processing was stopped by a terminating message
# 11: could not write the result to the output file

# kio do estas rezultkodo "19"?

is(revo::checkxml::checkxml('<xml version="1.0"></xml>',$xml_dir),0, 'nur <xml...>');
is(revo::checkxml::checkxml('<xml version="1.0"</xml>',$xml_dir),19, 'nevalida <xml...');

is(revo::checkxml::checkxml('<xml version="1.0"><vortaro></vortaro></xml>',$xml_dir),0,
     '<vortaro>...');


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

my @v = xml_test($valid_xml);
print "V: [[".join(';',@v)."]]\n";
print @v.'--';
is(@v,(0,0,0),'neniu eraro en valida XML artefakt...');

# nun enŝovu erarojn en XML...
my $invalid_xml = $valid_xml;
$invalid_xml =~ s/<vortaro>//;

my @i = xml_test($invalid_xml);
print "I: [[".join(';',@i)."]]\n";
is(($i[1],$i[2]),(5,5),'eraro ĉe 5:5 en nevalida XML artefakt...');     




sub xml_test() {
    my $xml = shift;
    my @r = revo::checkxml::checkxml($xml,$xml_dir);
    return @r;
}

