#!/usr/bin/perl

#
# revo::checkxml.pm
# 
# 2008 Wieland Pusch
# 2020 Wolfram Diestel
#

use strict;
#use warnings;

use utf8;
use IPC::Open3;

#use CGI qw(pre escapeHTML autoEscape);

package revo::checkxml;

sub checkxml {
    my ($teksto, $xml_dir) = @_;
    my ($err, $konteksto, $line, $char);

    chdir($xml_dir) or die "mi ne povas atingi dosierujon ".$xml_dir;
#    $debugmsg .= "checkxml: teksto = $teksto\n";
    my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                    'rxp -Vs >/dev/null');
    print CHLD_IN $teksto;
    close CHLD_IN;
    $err = join('', <CHLD_ERR>);
#    $debugmsg .= "checkxml: err = $err\n";
    close CHLD_ERR;
    close CHLD_OUT;

    # legu la erarojn
#    open ERR,"$tmp/xml.err";
#    $err=join('',<ERR>);
#    close ERR;
#    unlink("$tmp/xml.err");

    if ($err) {
      #$ne_konservu = 1;
      $err =~ s/^Warning: /Atentu: /smg;
      $err =~ s/^Error: /Eraro: /smg;
      $err =~ s/ of <stdin>$//smg;
      $err =~ s/^ in unnamed entity//smg;
      $err =~ s/Start tag for undeclared element ([^\n]*)/Ne konata komencokodero $1/smg;
      $err =~ s/Content model for ([^ \n]*) does not allow element ([^ \n]*) here$/Reguloj por $1 malpermesas $2 cxi tie/smg;
      $err =~ s/Mismatched end tag: expected ([^,\n]*), got ([^ \n]*)$/Malkongrua finokodero: atendis $1, trovis $2/smg;
      $err =~ s/^ at line (\d+) char (\d+)$/ cxe linio $1 pozicio $2/smg;
      $err =~ s/Document contains multiple elements/Artikolo enhavas pli ol unu elementon (kaj tio devas esti <vortaro>)/smg;
      $err =~ s/Root element is ([^ ,\n]*), should be ([^ \n]*)/Radika elemento estas $1, devus esti $2/smg;
      $err =~ s/Content model for ([^ \n]*) does not allow PCDATA/Enhavo de elemento $1 estas malpermesita/smg;
      $err =~ s/The attribute ([^ \n]*) of element ([^ \n]*) is declared as ENUMERATION but is empty/La atributo $1 de la kodero $2 mankas/smg;
      $err =~ s/In the attribute ([^ \n]*) of element ([^ \n]*), ([^ \n]*) is not one of the allowed values/Cxe la atributo $1 de la kodero $2, $3 ne estas permesata./smg;
      $err =~ s/Document ends too soon/Dokumento finis, sed mankis finkodero/smg;
      $err =~ s/Value of attribute is unquoted/Mankas citiloj por la valoro de la atributo/smg;
      $err =~ s/Illegal character ([^ \n]*) in attribute value/Malpermesita signo $1 en atributa valoro/smg;
      $err =~ s/Expected whitespace or tag end in start tag/Atendas spacon aux koderfinon en komencokodero/smg;
      $err =~ s/Expected name, but got ([^ \n]*) for attribute/Atendas nomon, sed trovis $1 kiel atributo/smg;
      $err =~ s/The attribute ([^ \n]*) of element ([^ \n]*) is declared as ID but contains a character which is not a name character/La atributo $1 de la kodero $2 enhavas malpermesitan karakteron./smg;

      #autoEscape(1);
      ($konteksto, $line, $char) = xml_context($err, $teksto);
      $err .= "kunteksto de unua eraro:\n$konteksto";
      #$err = "XML kontrolo malsukcesis - Eraro" . CGI::pre(CGI::escapeHTML("XML-eraroj:\n$err\n")); # if ($verbose);      
      #autoEscape(0);
    }
    return ($err, $line, $char);
}

### xml_context: donas detalojn, kie aperas sintakseraro en la XML-teksto
###

sub xml_context {
    my ($err, $teksto) = @_;
    my ($line, $char, $result, $n, $txt);

    if ($err =~ /linio\s+([0-9]+)\s+pozicio\s+([0-9]+)\s+/s) {
      $line = $1;
      $char = $2;
#      $debugmsg .= "context: line = $line, char = $char, err = $err\n";

      my @a = split "\n", $teksto;

      # la linio antaux la eraro
      if ($line > 1) {
          $result .= ($line-1).": $a[$line - 2]\n";
      }
      $result .= "$line: $a[$line - 1]\n";
      $result .= "-" x ($char + length($line) + 1) . "^\n";

      if (exists($a[$line])) {
          $result .= ($line+1).": $a[$line]";
      }

      return ($result, $line, $char);
    }

    return ('', 0, 0);
}

sub checklng {
    my ($xml,$lng_xml) = @_;
    my ($check_lng, $line);
    my %lng;

    open IN, "<$lng_xml" 
        or die "Ne povas malfermi lingvoj.xml";

    while (<IN>) {
        if (/<lingvo kodo="([^"]+)">([^<]+)<\/lingvo>/) {
    #      $debugmsg .= "lng $1 -> $2\n";
        $lng{$1} = 1;
        }
    }
    close IN;

    while ($xml =~ m/(<(?:trd|trdgrp) lng=")(.*?)">/smg) {
        if (!exists($lng{$2})) {
        $checklng = "Nekonata lingvo $2.";
        $ne_konservu = 10;
    #      $debugmsg .= "lng = $2\n";
        my @prelines = split "\n", "$`$1$2";
        $postlines = split "\n", $';

        my @pre = Text::Tabs::expand(@prelines);
        $pos = length(join "\n", @pre);
        $prelines = $#prelines;
        $line = $prelines - 20;
        $lastline = $prelines + $postlines + 20 - 25;
        last;
        }
    }

    if (!$pos and $xml =~ m/<(snc|drv)( mrk="$mrk".*?)(\n?\s*<\/\1>)/smg) {
        my @prelines = split "\n", "$`$1$2";
        $postlines = split "\n", "$3$'";

        my @pre = Text::Tabs::expand(@prelines);
        $pos = length(join "\n", @pre);
        $prelines = $#prelines;
    #    $debugmsg .= "prelines = $prelines\n";

        $pos++;
        $line = $prelines - 20;
        $lastline = $prelines + $postlines + 20 - 25;
    }

    $line = 0 if $line < 0;
    $line = $lastline if $line > $lastline;
    $lastline = 1 unless $lastline;
    #$debugmsg .= "line = $line\n";

    return($check_lng,$line)
}

sub checkfak {
    my ($xml,$fak_xml) = @_;

    my (%fak, %stl);
    if ($art) {
        %fak = ('' => '');
        open IN, "<$fak_xml" or die "ne povas malfermi fakoj.xml";
        while (<IN>) {
            if (/<fako kodo="([^"]+)"[^>]*>([^<]+)<\/fako>/i) {
        #      $debugmsg .= "fak $1 -> $2\n";
        #      print "fak $1 $2<br>\n";
            $fak{$1} = Encode::decode($enc, "$1-$2");
            }
        }
        close IN;
    }

    while ($xml =~ /<uzo tip="fak">(.*?)<\/uzo>/gi) {
    my $fako = $1;
    if (! exists($fak{$fako})) {
      print "Fako $fako estas nekonata.<br>\n";
      #$ne_konservu = 6;
    }
  }

}

sub checkstl {
    my ($xml,$stl_xml) = @_;

    %stl = ('' => '');
    open IN, "<$stl_xml" or die "ne povas malfermi stiloj.xml";
    while (<IN>) {
        if (/<stilo kodo="([^"]+)"[^>]*>([^<]+)<\/stilo>/i) {
    #      $debugmsg .= "stl $1 -> $2\n";
    #      print "stl $1 $2<br>\n";
        $stl{$1} = Encode::decode($enc, "$1-$2");
        }
    }
    close IN;
}

sub checkmrk {  
  while ($xml2 =~ /<(drv|snc) mrk="(.*?)">/gi) {
    my $mrk = $2;
    if ($mrk !~ /^$art\.[^.0]*0/) {
      print "La marko \"$mrk\" ne komenciĝas per \"$art.\" a&#365; poste ne havas 0.<br>\n";
      $ne_konservu = 5;
    }
  }
}


1;