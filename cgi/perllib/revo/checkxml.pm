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
    chdir($xml_dir) or die "mi ne povas atingi dosierujon $xml_dir\n";
    my @rez = rxp_cmd($teksto);
    return $rez[1];
}

sub check_xml_rc {
    my ($teksto, $xml_dir) = @_;
    chdir($xml_dir) or die "mi ne povas atingi dosierujon $xml_dir\n";
    my @rez = rxp_cmd($teksto);
    return $rez[0];
}

sub check_xml_2 {
    my ($teksto, $xml_dir) = @_;
    chdir($xml_dir) or die "mi ne povas atingi dosierujon $xml_dir\n";
    return rxp_cmd($teksto);
}

sub rxp_cmd {
    my $teksto = shift;
    my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                    $rxp_cmd_line);
    print CHLD_IN $teksto;
    close CHLD_IN;
    my $err = do { local $/ = undef; <CHLD_ERR> };
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

    ## no critic (RegularExpressions::ProhibitComplexRegexes)
    if ($err) {
      $err =~ s{^Warning:\s}
        {Atentu: }xsmg;
      $err =~ s{^Error:\s}
        {Eraro: }xsmg;
      $err =~ s{\sof\s<stdin>$}
        {}xsmg;
      $err =~ s{^\sin\sunnamed\sentity}
        {}xsmg;
      $err =~ s{
            Start\stag\sfor\sundeclared\selement\s
            ([^\n]*)
        }
        {Ne konata elementokomenco $1}xsmg;
      $err =~ s{
            End\stag\s
            ([^\n]*)\s
            outside\sof\sany\selement
        }
        {Elementofino $1 ekster iu elemento}xsmg;
      $err =~ s{
            Undeclared\sattribute\s
            ([^\s\n]*)\s
            for\selement
        }
        {Nedeklarita atributo $1 por elemento}xsmg;
      $err =~ s{
            Content\smodel\sfor\s
            ([^\s\n]*)\s
            does\snot\sallow\selement\s
            ([^\s\n]*)\s
            here$
        }
        {Reguloj por $1 malpermesas $2 ĉi tie}xsmg;
      $err =~ s{
            Mismatched\send\stag:\sexpected\s
            ([^,\n]*),\sgot\s
            ([^\s\n]*)$
        }
        {Malkongrua elementofino: anstataŭ $1 troviĝis $2}xsmg;
      $err =~ s{^
            \sat\sline\s
            (\d+)\s
            char\s
            (\d+)$
        }
        { ĉe pozicio $1:$2}xsmg;
      $err =~ s{Document\scontains\smultiple\selements}
        {Artikolo enhavas pli ol unu elementon (kaj tio devas esti <vortaro>)}xsmg;
      $err =~ s{
            Root\selement\sis\s
            ([^\s,\n]*),\sshould\sbe\s
            ([^\s\n]*)
        }
        {Radika elemento estas $1, devus esti $2}xsmg;
      $err =~ s{
            Content\smodel\sfor\s
            ([^\s\n]*)\s
            does\snot\sallow\sPCDATA
        }
        {Kruda teksto kiel enhavo de elemento $1 estas malpermesita}xsmg;
      $err =~ s{
            The\sattribute\s
            ([^\s\n]*)\sof\selement\s
            ([^\s\n]*)\sis\sdeclared\sas\s
            ENUMERATION\sbut\sis\sempty
        }
        {La atributo $1 de la elemento $2 mankas}xsmg;
      $err =~ s{
            In\sthe\sattribute\s
            ([^\s\n]*)\sof\selement\s
            ([^\s\n]*),\s([^\s\n]*)\s
            is\snot\sone\sof\sthe\sallowed\svalues
        }
        {Ĉe la atributo $1 de la elemento $2, $3 ne estas permesata.}xsmg;
      $err =~ s{Document\sends\stoo\ssoon}
        {Dokumento finiĝis antaŭ kompletiĝo}xsmg;
      $err =~ s{Value\sof\sattribute\sis\sunquoted}
        {Mankas citiloj por la valoro de la atributo}xsmg;
      $err =~ s{
            Illegal\scharacter\s
            ([^\s\n]*)\s
            in\sattribute\svalue
        }
        {Malpermesita signo $1 en atributa valoro}xsmg;
      $err =~ s{Expected\swhitespace\sor\stag\send\sin\sstart\stag}
        {Atendas spacon aŭ elementofinon en elementokomenco}xsmg;
      $err =~ s{
            Expected\sname,\sbut\sgot\s
            ([^\s\n]*)\s
            for\sattribute
        }
        {Atendas nomon, sed trovis $1 kiel atributo}xsmg;
      $err =~ s{
            Expected\s([^\s\n]*)\s
            after\sattribute\sname,\sbut\s
            got\s([^\s\n]*)
        }
        {Atendas $1 post atributnomo, sed trovis $2}xsmg;
      $err =~ s{
            Expected\s([^\s\n]*)\s
            after\sname\sin\send\stag,\sbut\s
            got\s([^\s\n]*)
        }
        {Atendas $1 post nomo en elementfino, sed trovis $2}xsmg;
      $err =~ s{
            The\sattribute\s([^\s\n]*)\s
            of\selement\s([^\s\n]*)\s
            is\sdeclared\sas\sID\sbut\scontains\s
            a\scharacter\swhich\sis\s
            not\sa\sname\scharacter
        }
        {La atributo $1 de la elemento $2 enhavas malpermesitan karakteron.}xsmg;
    }
    ## use critic

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