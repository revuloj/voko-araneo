#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use IO::Handle;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
#use Unicode::String qw(utf8);
use utf8; binmode STDOUT, ":utf8";
use revodb;

my $homedir = "/hp/af/ag/ri";
# Ni legas el
my $viki_url = 'http://download.wikimedia.org/eowiki/latest/eowiki-latest-all-titles-in-ns0.gz';
# al
my $viki_local = "$homedir/files/eoviki.gz";

# La enhavon ni skribas al la sekva tabelo en la datumbazo
# 
# r2_vikititolo 
#      titolo = Titolo de la Viki-paĝo
#      titolo_lc = minuskla titolo

print header(-charset=>'utf-8'),
    start_html('elŝutu viki-titolojn'),
	  h2(scalar(localtime));

# Konektiĝu kun la datumbazo
my $dbh = revodb::connect();

# ?download=0 por testi 
# ?download=1 por vere elŝuti aktualan liston

if (param("download")) {	
  print pre(qx/pwd/);
  my $ret = qx/wget -nv $viki_url -O $viki_local 2>&1/;

  print h2("wget -> $ret");
  print pre($ret);
  
  # malpelnigu la viki-tabelopn antaŭ enmeti novajn...
  my $sth = $dbh->prepare("TRUNCATE TABLE r2_vikititolo") or die;
  $sth->execute();
}


my $sth_insert = $dbh->prepare(
  "INSERT INTO r2_vikititolo(titolo, titolo_lc) VALUES (?,?)") 
  or die;

### En %viki ni kolektas laŭ *Revo-dosiernomo*, la markojn kaj Viki-referencojn 

my $count = 0;
          
open IN, "gzip -d < $viki_local 2>&1 |" or die "Ni ne povas malpaki $viki_local";
<IN>;  # forjxetu unuan linion, estas nur titolo

while (my $orgviki = <IN>) {
  chomp $orgviki;

  #print pre("test: $_")."\n" if m/^$abak/i;
  next if $orgviki =~ m/["<>]/;		  # pro sekureco ni ignoras liniojn kun tiuj signoj: "<> 
  next unless $orgviki =~ m/[a-z]/;	# ignoru nur-majusklajn titolojn, temas pri mallongigo

  my $lc = lc $orgviki; 
  $lc =~ s/_/ /g;	# _ -> spaco

  $sth_insert->execute($orgviki, $lc) if param("download");
  $count++;
  }
}
close IN;
print pre("$count titoloj el Vikipedio");


$sth_insert->finish();
$dbh->disconnect() or die "Malkonekti de la datumbazo ne funkcias.";


print pre("daŭro: ".(time - $^T)."s");	# montru kiom longe daŭris
print end_html;
