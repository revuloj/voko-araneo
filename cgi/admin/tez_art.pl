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
use fileutil;

$debug = 0;

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

# preparu SQL
my $del = $dbh->prepare("DELETE FROM r2_tezauro WHERE tez_kapvorto = ?");
my $ints = $dbh->prepare("INSERT INTO r2_tezauro (tez_kapvorto, tez_fontteksto, tez_fontref, tez_fontn, "
    . "tez_celteksto, tez_celref, tez_celn) VALUES (?,?,?,?,?,?,?)";

# legu la tezaŭro-referencojn el JSON, 
# kaj metu en la datumbazon
my $ref_cnt = 0;

for my $art (@arts) {
  if ($art =~ /^[a-z0-9]{1,30}$/) {
    process_ref_json($art);
  }
}

sub process_ref_json {
    my $art = shift;
    my $file = "4tezdir/$art.json";

    my $json = fileutil::read_json_file($file);

    if ($json && $json->{$art}) {
        $del->execute($art);
        
        for my $ref (@{$json->{$art}}) {
            my $mrk = $ref->[1];
            my $tip = $ref->[2];
            my $cel = $ref->[3];

            if (
                $mrk =~ /^\.[a-z0-9A-Z_\.]$/ &&
                $cel =~ /^[a-z0-9A-Z_\.]$/ &&
                $tip =~ /^(sin|ant|hom|vid|sup|sub|prt|mal|ekz|lst)$/
            ) {
              $mrk = "$art$mrk";
              $ins->execute($art,'',$mrk,NULL,'',$cel,'');

              $ref_cnt++;
            }
        }
    }
}

$dbh->disconnect() or die "Malkonektiĝi de DB ne funkciis.\n";

print pre("daŭro: ".(time - $^T)." sekundoj por $ref_cnt referencoj en $#arts artikoloj.");	
print end_html;

