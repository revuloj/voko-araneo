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

sub check_art_mrk {
    my ($dbh,$xml_dir,@refs) = @_;
    my @ref_err;

    my $sth = $dbh->prepare(
        "SELECT count(*) FROM art WHERE art_amrk = ?");
    my $sth2 = $dbh->prepare(
        "SELECT drv_mrk FROM drv WHERE drv_mrk = ? ".
        "UNION SELECT snc_mrk FROM snc WHERE snc_mrk = ? ".
        "UNION SELECT rim_mrk FROM rim WHERE rim_mrk = ?");
    
    for my ($art,$pkt,$rest) (@refs) {
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

check_redaktanto {
    my ($dbh,$redaktanto) = @_;

    if ($redaktanto) {
        # cxu iu redaktanto havas tiun retadreson? Kiu?
        my $sth = $dbh->prepare("SELECT count(*), min(ema_red_id) FROM email WHERE LOWER(ema_email) = LOWER(?)");
        $sth->execute($redaktanto);
        my ($permeso, $red_id) = $sth->fetchrow_array();
        $sth->finish;

        # FARENDA: Ĉu ni bezonas la nomon entute? Se jes, ni povas aldoni ĝin tuj en la supra SQL per JOIN!
        # Kiel nomigxas la redaktanto?
        my $sth = $dbh->prepare("SELECT red_nomo FROM redaktanto WHERE red_id = ?");
        $sth->execute($red_id);
        my ($red_nomo) = $sth->fetchrow_array();
        #  print "red_nomo=$red_nomo\n";
        $sth->finish;

        return ($permeso, $red_nomo);
    }

    return 0;
}



1;