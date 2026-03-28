#!/usr/bin/perl
package revo::checkxml;

#
# revo::checkxml.pm
# 
# 2008 Wieland Pusch
# 2021 Wolfram Diestel
#

use strict; use warnings;

use utf8;
use IPC::Open3;

my $rxp_cmd_line = 'rxp -Vs >/dev/null';
my $red_url = '/revo/dlg/redaktilo.html';

sub check_xml {
    my ($teksto, $xml_dir) = @_;
    chdir($xml_dir) or die "mi ne povas atingi dosierujon ".$xml_dir;
    my @rez = rxp_cmd($teksto);
    return $rez[1];
}

sub check_xml_rc {
    my ($teksto, $xml_dir) = @_;
    chdir($xml_dir) or die "mi ne povas atingi dosierujon ".$xml_dir;
    my @rez = rxp_cmd($teksto);
    return $rez[0];
}

sub check_xml_2 {
    my ($teksto, $xml_dir) = @_;
    chdir($xml_dir) or die "mi ne povas atingi dosierujon ".$xml_dir;
    return rxp_cmd($teksto);
}

sub rxp_cmd {
    my $teksto = shift;
    my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                    $rxp_cmd_line);
    print CHLD_IN $teksto;
    close CHLD_IN;

    my $err = do { local $/; <CHLD_ERR> };
    #my $err = join('', <CHLD_ERR>);
    close CHLD_ERR;
    close CHLD_OUT;

    waitpid($pid, 0);
    my $exit_code = $? >> 8;

    ### rxp raportas erarojn en tiu formo:
    # Warning: Content model for art does not allow element rad here
    #  in unnamed entity at line 7 char 7 of {file:///...xml|<stdin>}
    # Warning: Content model for art does not allow PCDATA
    #  in unnamed entity at line 7 char 25 of {file:///...xml|<stdin>}
    # Error: Mismatched end tag: expected </art>, got </kap>
    #  in unnamed entity at line 8 char 6 of {file:///...xml|<stdin>}

    if ($err) {
      $err =~ s/^Warning: /Atentu: /smg;
      $err =~ s/^Error: /Eraro: /smg;
      $err =~ s/ of <stdin>$//smg;
      $err =~ s/^ in unnamed entity//smg;
      $err =~ s/Start tag for undeclared element ([^\n]*)/Ne konata elementokomenco $1/smg;
      $err =~ s/End tag ([^\n]*) outside of any element/Elementofino $1 ekster iu elemento/smg;
      $err =~ s/Undeclared attribute ([^ \n]*) for element/Nedeklarita atributo $1 por elemento/smg;
      $err =~ s/Content model for ([^ \n]*) does not allow element ([^ \n]*) here$/Reguloj por $1 malpermesas $2 ĉi tie/smg;
      $err =~ s/Mismatched end tag: expected ([^,\n]*), got ([^ \n]*)$/Malkongrua elementofino: anstataŭ $1 troviĝis $2/smg;
      $err =~ s/^ at line (\d+) char (\d+)$/ ĉe pozicio $1:$2/smg;
      $err =~ s/Document contains multiple elements/Artikolo enhavas pli ol unu elementon (kaj tio devas esti <vortaro>)/smg;
      $err =~ s/Root element is ([^ ,\n]*), should be ([^ \n]*)/Radika elemento estas $1, devus esti $2/smg;
      $err =~ s/Content model for ([^ \n]*) does not allow PCDATA/Kruda teksto kiel enhavo de elemento $1 estas malpermesita/smg;
      $err =~ s/The attribute ([^ \n]*) of element ([^ \n]*) is declared as ENUMERATION but is empty/La atributo $1 de la elemento $2 mankas/smg;
      $err =~ s/In the attribute ([^ \n]*) of element ([^ \n]*), ([^ \n]*) is not one of the allowed values/Ĉe la atributo $1 de la elemento $2, $3 ne estas permesata./smg;
      $err =~ s/Document ends too soon/Dokumento finiĝis antaŭ kompletiĝo/smg;
      $err =~ s/Value of attribute is unquoted/Mankas citiloj por la valoro de la atributo/smg;
      $err =~ s/Illegal character ([^ \n]*) in attribute value/Malpermesita signo $1 en atributa valoro/smg;
      $err =~ s/Expected whitespace or tag end in start tag/Atendas spacon aŭ elementofinon en elementokomenco/smg;
      $err =~ s/Expected name, but got ([^ \n]*) for attribute/Atendas nomon, sed trovis $1 kiel atributo/smg;
      $err =~ s/Expected ([^ \n]*) after attribute name, but got ([^ \n]*)/Atendas $1 post atributnomo, sed trovis $2/smg;
      $err =~ s/Expected ([^ \n]*) after name in end tag, but got ([^ \n]*)/Atendas $1 post nomo en elementfino, sed trovis $2/smg;
      $err =~ s/The attribute ([^ \n]*) of element ([^ \n]*) is declared as ID but contains a character which is not a name character/La atributo $1 de la elemento $2 enhavas malpermesitan karakteron./smg;
    }

    return ($exit_code,$err);
}

sub check_ref_cel {
    my ($dbh,$xml_dir,@refs) = @_;
    my @ref_err;

    my $sth = $dbh->prepare(
        "SELECT mrk FROM r3mrk WHERE mrk = ?");
    
    for my $ref (@refs) {
        # por abel.0ujo.HOR - ni havas la tri argumentojn:
        # "abel" "." "0ujo.HOR"
        my ($art,$pkt,$rest) = (@$ref);
        my $mrk = "$art$pkt$rest";

        # ĉu la referencita marko ekzistas
        $sth->execute($mrk);
        my ($cel_ekzistas) = $sth->fetchrow_array();

        if (!$cel_ekzistas) {
            #      print "ref = $1-$2 $art-$mrk<br>\n" if $debug;
            push @ref_err, "Referenco celas al marko \"$mrk\", kiu ne ekzistas.\n";
            #      $ne_konservu = 7;
        }
    }

    return @ref_err;
}

1;