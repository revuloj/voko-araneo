#!/usr/bin/perl

## aktualigas la datumbazon el tez/*.json
## por unuopaj artikoloj, aŭ donitaj per parametro art=... (unu)
## aŭ arts=... (pluraj, maks. mil) aŭ prefix=... (ĉiuj komenciĝantaj tiel)
## Unuopa artikolo estas en-db-igita per la funkcioj en perllib/art_db.pm

#use strict;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use IO::Handle;
#use JSON;
#use Data::Dumper;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
#use Unicode::String qw(utf8);
use Encode;
use utf8; binmode STDOUT, ":utf8";
use revodb;
use art_db; # perllib/art_db.pm

my $debug = 0;
my $verbose = 1;

my $homedir = "/hp/af/ag/ri";
my $tezdir = "$homedir/www/revo/tez";
#my $json_parser = JSON->new->allow_nonref;

print header(-charset=>'utf-8'),
      start_html('aktualigu datumbazon kap,mrk,ref,trd el json'),
	  h2(scalar(localtime));

# ekstraktu la artikolojn el la parametro(j)
my @arts;
if (param('arts')) {
  @arts = sort split /\s+/,param('arts');
  die "Tro multaj artikoloj, maks. 1000\n" if ($#arts > 1000);

} elsif (param('art')) {
  push @arts, param('art');

} elsif (param('prefix')) {
  my $prefix = param('prefix');

  if ($prefix =~ /^[a-z0-9\[\]\-]{1,10}$/) {
    for $file (glob "$tezdir/$prefix*.json") {
      $file =~ /\/([a-z0-9]+)\.json/;
      print pre("glob: $1") if ($verbose);
      push @arts, $1;
    }
  }
}

# Konektiĝi kun la datumbazo kaj plenigi la tabelojn
my $dbh = revodb::connect();
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

my $cnt = art_db::process($dbh,\@arts,$verbose);

$dbh->disconnect() or die "Malkonektiĝi de DB ne funkciis.\n";

print pre("daŭro: ".(time - $^T)."s\nart: $cnt->{art}\nkap: $cnt->{kap}\n"
         ."mrk: $cnt->{mrk}\nref: $cnt->{ref}\ntrd: $cnt->{trd}\n");	
print end_html;
