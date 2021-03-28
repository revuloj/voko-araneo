#!/usr/bin/perl

#use strict;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use IO::Handle;
use JSON;
#use Data::Dumper;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
#use Unicode::String qw(utf8);
use utf8; binmode STDOUT, ":utf8";
use revodb;

$debug = 1;

my $homedir = "/hp/af/ag/ri";
my $vikiref = "$homedir/www/revo/inx/vikiref.json";
my $json_parser = JSON->new->allow_nonref;

print header(-charset=>'utf-8'),
      start_html('aktualigu viki-ligojn'),
	  h2(scalar(localtime));

# unue legu la viki-referencojn el JSON, ĉar se tio fiaskas, ni ne tuŝos la datumbazon!
my $refs = read_json_file($vikiref);
#print Dumper $refs if ($debug);
my $count = scalar(@{$refs});
die "Tro malmultaj referencoj ($count), verŝajne estas erara, ni ne daŭrigos...\n" unless ($count > 10000);

# Konektiĝi kun la datumbazo kaj malplenigi la tabelon
my $dbh = revodb::connect();
my $sth = $dbh->prepare("TRUNCATE TABLE r2_vikicelo") or die;
$sth->execute();

# nun ni trakuras la referencojn kaj enmetas en la datumbazon
my $sth_insert = $dbh->prepare("INSERT INTO r2_vikicelo (vik_celref, vik_artikolo) VALUES (?,?)") or die;

for $ref (@$refs) {
    my $v = $ref->[0];
    my $r = $ref->[1];
    $sth_insert->execute($r, $v);
}

$sth_insert->finish();
$dbh->disconnect() or die "DB disconnect ne funkcias";

print pre("daŭro: ".(time - $^T)." sekundoj por $count referencoj");	
print end_html;

################# helpaj funkcioj ###################

# legi JSON-dosieron
sub read_json_file {
	my $file = shift;
  	my $j = read_file($file);

	print ("json file: $file\n") if ($debug);

	unless ($j) {
		warn("Malplena aŭ mankanta JSON-dosiero '$file'\n");
		return;
	}
    print(substr($j,0,20)."...\n") if ($debug);

    my $parsed;
	eval {
    	$parsed = $json_parser->decode($j);
    	1;
	} or do {
  		my $error = $@;
		die("Ne eblis analizi enhavon de JSON-dosiero '$file': $error\n");
	};

	return $parsed;	  
}


# legi dosieron
sub read_file {
	my $file = shift;
	unless (open FILE, $file) {
		warn("Ne povis malfermi '$file': $!\n"); return;
	}
	my $text = join('',<FILE>);
	close FILE;
	return $text;
}