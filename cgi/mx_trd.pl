#!/usr/bin/perl

#
# mx_trd.pl
# 
# (c) laŭ permesilo GPL 2.0
# 2007 Wieland Pusch
# 2021 Wolfram Diestel

use strict;

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
use URI::Escape;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use revodb;

#$| = 1;

my $revo_dir = "/hp/af/ag/ri/www/revo";
my $redaktilo = "/cgi-bin/vokomail.pl?art=";
my $LIMIT = 20;

#my $sercxata = param('q2');

my $lng = param('lng');
my $refmrk = param('de') || param('ghis') || 'a';
my $komparo = param('ghis')? '<' : '>';
my $order = param('ghis')? 'DESC' : 'ASC';

print header(
  -charset => 'utf-8'),
  start_html(
    -title => "mankantaj tradukoj". ($lng? " por lingvo $lng" : ""),
	  -style =>{-src => '/revo/stl/indeksoj.css'}  
), "<article>";

unless ($lng) {
  my @pref_lng = preflng();
  my %lng; 
  my %pref;

  print h2("Elektu la lingvon:"),br;
  #open IN, "<../revo/cfg/lingvoj.xml" 

  # PLIBONIGU: lingvoliston ni bezonas ankaŭ en sercxu.pl, eble metu al iu util.pm
  # utila eble estus ankaŭ JSON anst. XML-dosiero
  open IN, "< $revo_dir/cfg/lingvoj.xml"
    or die "ne povas malfermi dosieron lingvoj.xml";

  while (<IN>) {
    if (/<lingvo kodo="([^"]+)">([^<]+)<\/lingvo>/) {
#      print "lng $1 -> $2".br."\n";
      if ($1 ne "eo") {
        if ( grep { $pref_lng[$_] ~~ $1 } @pref_lng ) {
          $pref{$2} = $1;
        } else {
          $lng{$2} = $1;
        }
      }
    }
  }
  close IN;

  foreach (sort keys %pref) {
    print a({href=>"?lng=$pref{$_}"}, "$_").br."\n";
  }

  print br."<p style='column-count: 3'>";

  #my $i;
  foreach (sort keys %lng) {
    #$i++;
    print a({href=>"?lng=$lng{$_}"}, "$_").br."\n";
  }

  print "</p>";

  exit 0;
}

$lng =~ /^[a-z]+$/ or die "Ne valida lingvo $lng";

print h2("mankantaj tradukoj [$lng]");


#use eosort;

# Malfermu la datumbazon
my $dbh = revodb::connect();

#$dbh->do("set names utf8");


#  "select t.trd_snc_id, a.art_amrk, d.drv_mrk, d.drv_teksto, s.snc_mrk, s.snc_numero from trd t, snc s, drv d, art a where a.art_id = d.drv_art_id and s.snc_drv_id = d.drv_id and t.trd_snc_id = s.snc_id and t.trd_snc_id > ? and t.trd_lng <> 'la' $kapsql group by t.trd_snc_id
#having min(if (t.trd_lng = ?, 1, 2)) = 2 and count(*) > 1 order by a.art_amrk, d.drv_teksto, s.snc_numero #limit $limit") or die "prepare sth";

# trovu snc, por kiu ne ekzistas traduko en specifa lingvo nek por la derivaĵo, en kiu aperas la senco
# se tia traduko mankas, LEFT JOIN ne funkcios kaj enhavas NULL por la kampoj de r3trd 

# select r3mrk.*, r3trd.mrk as tmrk, r3trd.lng, r3trd.ind from r3mrk
# left join r3trd on (r3trd.mrk = r3mrk.mrk or r3trd.mrk = r3mrk.drv) 
#   and lng='de'
# where r3mrk.mrk > 'a' and ele in ('snc','subsnc') and r3trd.mrk is NULL 
# order by r3mrk.mrk
# limit 270,30;

# limit ^^^ kun start estas malrapida, prefere uzu mrk > <art> - kio estas dekoble pli rapida

my $rows = $dbh->selectall_arrayref(
  "SELECT r3mrk.mrk, r3kap.kap, r3mrk.num FROM r3mrk "
 ."LEFT JOIN r3trd ON (r3trd.mrk = r3mrk.mrk or r3trd.mrk = r3mrk.drv) AND lng = ? "
 ."LEFT JOIN r3kap ON r3kap.mrk = r3mrk.drv "
 ."WHERE r3mrk.mrk $komparo ? AND ele = 'snc' AND r3trd.mrk IS NULL " 
 ."ORDER BY r3mrk.mrk $order LIMIT $LIMIT",{ Slice=>{} },$lng,$refmrk);

# por navigado ni markas la unuan markon kiel $ghis kaj la lastan kiel $de
my $ghis = $rows->[0]->{mrk} || 'zzzzzz';
my $de = $rows->[-1]->{mrk} || 'a';

# KOREKTU $de estas la unua kaj $ghis la lasta marko el la trovitaj db-horizontaloj
print_nav($de,$ghis,1);

# skribu la liston de artikoloj/sencoj sen traduko
my $num;

my $art_px = '/revo/art';
my $xml_px = '/revo/xml';

$rows = [reverse @$rows] if ($order eq 'DESC');

for my $row (@$rows) {
  $num++; print "$num. ";

  # print p(join(',',keys %$row));

  my $text = $row->{kap}.($row->{num}?sup(i($row->{num})):'');
  my $mrk = $row->{mrk};
  $mrk =~ /^([^\.]+)\./; my $art = $1;

  print a({
    href => "$xml_px/$art.xml",
    target=>"_blank"
    }, "$art.xml"), ' ';

  print a({
    href => "$redaktilo$art&mrk=$mrk"
    }, "[redakti]"),' ';

  print a({
    href => "$art_px/$art.html#$mrk"
    }, $text), br;
}

$dbh->disconnect() or die "DB disconnect ne funkcias";
  
print_nav($de,$ghis,0);
print "</article>";
print end_html();

#########################################################

sub print_nav {
  my ($de,$ghis,$head) = @_;

  print a({
    href => "?lng=$lng&ghis=$ghis"
    }, 
    '<<<'), 
    ' ',
    a({
      href => "?lng=$lng&de=$de"}, 
      '>>>'), 
      ' ';

  if ($head) {
    my $super = {
      'c' => 'ĉ', 'g' => 'ĝ', 'j' => 'ĵ', 
      'h' => 'ĥ', 's' => 'ŝ', 'u' => 'ŭ'
      };

    for my $l ('a'..'z') {
      if ('qwxy' !~ /$l/) {
        print a({
          href => "?lng=$lng&de=$l"
        }, "$l ")
      }
      # ĉ, ĝ...
      if ($super->{$l}) {
        my $lx = $l.'x';
        print a({
          href => "?lng=$lng&de=$lx"
        }, $super->{$l}." ")
      }
    }
  }

  print br;
}

sub preflng {
  my @preferataj_lingvoj;
  {
    my @a = split ",", $ENV{HTTP_ACCEPT_LANGUAGE};
    for my $l (@a) {
      #$preferata_lingvo = shift @a if $preferata_lingvo =~ /^eo/;
      $l =~ s/^([a-z]{2,3}).*$/$1/;
      unless (grep(/$l/,@preferataj_lingvoj)) {
        push @preferataj_lingvoj, ($l) if ( $l && $l ne 'eo' && not $l ~~ @preferataj_lingvoj );
      }
      #print "DEBUG ".$#preferataj_lingvoj." ".$LIMIT_lng;
      # last if (($#preferataj_lingvoj + 1) == $LIMIT_lng);
    #  $preferata_lingvo = 'nenio' if $preferata_lingvo eq '';
    }
  }

  #print "DEBUG ".join(',',@preferataj_lingvoj);
  #@preferataj_lingvoj = ('en') unless (@preferataj_lingvoj); 
  return @preferataj_lingvoj;
}



