#!/usr/bin/perl

# (c) 2023-2026 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0

use warnings; use strict;
use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);

use IO::Handle;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");

use Encode; use utf8; use open ':std', ':encoding(UTF-8)';

use revodb;
use fileutil;

my $debug = 0;

my $homedir = "/hp/af/ag/ri";
my $vikiref = "$homedir/www/revo/inx/vikiref.json";

print header(-charset=>'utf-8'),
      start_html('aktualigu viki-ligojn'),
	  h2(scalar(localtime));

# unue legu la viki-referencojn el JSON, ĉar se tio fiaskas, ni ne tuŝos la datumbazon!
my $refs = fileutil::read_json_file($vikiref);
#print Dumper $refs if ($debug);
my $count = scalar(@{$refs});

# sekurkontrolo: ĉu ni ricevas sufiĉe da viki-eroj
die "Tro malmultaj referencoj ($count), verŝajne estas erara, ni ne daŭrigos...\n" if ($count < 10000);

# Konektiĝi kun la datumbazo kaj malplenigi la tabelon
my $dbh = revodb::connect();
my $sth = $dbh->prepare("TRUNCATE TABLE r2_vikicelo") or die "Ne eblis malplinigi tabelon r2_vikicelo: $!\n";
$sth->execute();
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

# Nun ni trakuras la referencojn kaj enmetas ilin en la datumbazon.
# Kelkaj markoj povas duobliĝi, ekz-e ni havas ambaŭ abrikotujo kaj abrikotarbo,
# sed sufiĉas unu referenco al Vikipedio. Ni lasas trakti tion al la datumbazo 
# per ON DUPLICATE...
my $sth_insert = $dbh->prepare("INSERT INTO r2_vikicelo (vik_celref, vik_artikolo) " 
    ."VALUES (?,?) ON DUPLICATE KEY UPDATE vik_artikolo = vik_artikolo") 
        or  die "Ne eblis prepari enig-komandon por r2_vikicelo\n";

for my $ref (@$refs) {
    # ial json_parser ne aŭtomate supozas UTF8!?
    my $v = decode('UTF-8', $ref->[0]);
    my $r = decode('UTF-8', $ref->[1]);
    print pre("$v\n") if ($debug);
    $sth_insert->execute($r, $v) if ($r);
}

$sth_insert->finish();
$dbh->disconnect() or die "DB-malkonekto ne funkcias\n";

print pre("daŭro: ".(time - $^T)." sekundoj por $count referencoj");
print end_html;
