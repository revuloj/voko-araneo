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

my $rxp_cmd_line = 'rxp -Vs >/dev/null';

sub check_xml {
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
    my $err = join('', <CHLD_ERR>);
    close CHLD_ERR;
    close CHLD_OUT;

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
      $err =~ s/Start tag for undeclared element ([^\n]*)/Ne konata lementokomenco $1/smg;
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
      $err =~ s/The attribute ([^ \n]*) of element ([^ \n]*) is declared as ID but contains a character which is not a name character/La atributo $1 de la elemento $2 enhavas malpermesitan karakteron./smg;
    }

    return $err;
}

sub check_art_mrk {
    my ($dbh,$xml_dir,@refs) = @_;
    my @ref_err;

    my $sth = $dbh->prepare(
        "SELECT count(*) FROM art WHERE art_amrk = ?");
    my $sth2 = $dbh->prepare(
        "SELECT drv_mrk FROM drv WHERE drv_mrk = ? ".
        "UNION SELECT snc_mrk FROM snc WHERE snc_mrk = ? ".
        "UNION SELECT rim_mrk FROM rim WHERE rim_mrk = ?");
    
    for my $ref (@refs) {
        my ($art,$pkt,$rest)= (@$ref);
        my $mrk = "$art$pkt$rest";

        # ĉu la referencita artikolo ekzistas
        $sth->execute($art);
        my ($art_ekzistas) = $sth->fetchrow_array();

        if (!$art_ekzistas) {
            #      print "ref = $1-$2 $art-$mrk<br>\n" if $debug;
            push @ref_err, "Referenco celas al dosiero \"$art.xml\", kiu ne ekzistas.\n";
            #      $ne_konservu = 7;

        # ĉu la markoj ne la celata artikolo ekzistas
        } elsif ($pkt) {

            $sth2->execute($mrk, $mrk, $mrk);
            my ($mrk_ekzistas) = $sth2->fetchrow_array();

            # se la marko ne celas konatan drv, snc, rim
            # eble ĝi referencas subsnc - ni ne havas en la datumbazo,
            # do ni devas malfermi la XML por rigardi...
            # FARENDA: estonte ni havu ĉiujn ref-cel/mrk en la datumbazo
            # por eviti malfermi nombron da XML-dosieroj sur la servilo!
            if (! $mrk_ekzistas) {
                #        print "ref: art=$art mrk=$mrk<br>\n" if $debug;
                # eble temas pri marko de subsenco?
                open IN, "<", "$xml_dir";
                my $celxml = join '', <IN>;
                close IN;

                if ($celxml !~ /<subsnc\s+mrk="$mrk">/) {
                    push @ref_err, "Referenco celas al \"$mrk\", kiu ne ekzistas en dosiero \""
                    .a({href=>"?art=$art"}, "$art.xml")."\".\n";
        #          $ne_konservu = 8;
                }
            }
        }
    }
    $sth->finish;
    $sth2->finish;
}

1;