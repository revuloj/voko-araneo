#!/usr/bin/perl

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
      start_html('aktualigu viki-ligojn'),
	  h2(scalar(localtime));

# ekstraktu la artikolojn el la parametro(j)
my @arts;
if (param('arts')) {
  @arts = sort split /\r?\n/,param('arts');
  die "Tro multaj artikoloj, maks. 1000\n" if ($#arts > 1000);
} else {
  push @arts, param('art');
}

# Konektiĝi kun la datumbazo kaj malplenigi la tabelon
my $dbh = revodb::connect();
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

my $cnt = art_db::process($dbh,\@arts,$verbose);

$dbh->disconnect() or die "Malkonektiĝi de DB ne funkciis.\n";

print pre("daŭro: ".(time - $^T)."s\nart: $cnt->{art}\nkap: $cnt->{kap}\nmrk: $cnt->{mrk}\nref: $cnt->{ref}\n");	
print end_html;