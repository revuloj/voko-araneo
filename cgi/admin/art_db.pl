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

my $debug = 1;
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

# preparu SQL
my $kap_del = $dbh->prepare("DELETE FROM r3kap WHERE mrk LIKE ?");
my $kap_ins = $dbh->prepare("INSERT INTO r3kap (kap,mrk,var,ofc) VALUES (?,?,?,?)");

my $mrk_del = $dbh->prepare("DELETE FROM r3mrk WHERE mrk LIKE ?");
my $mrk_ins = $dbh->prepare("INSERT INTO r3mrk (mrk,ele,num,drv) VALUES (?,?,?,?)");

my $ref_del = $dbh->prepare("DELETE FROM r3ref WHERE mrk LIKE ?");
my $ref_ins = $dbh->prepare("INSERT INTO r3ref (mrk,tip,cel,lst) VALUES (?,?,?,?)");


# legu la datumojn el JSON, 
# kaj metu en la datumbazon
my $art_cnt = 0;
my $mrk_cnt = 0;
my $kap_cnt = 0;
my $ref_cnt = 0;

for my $art (@arts) {
  if ($art =~ /^[a-z0-9]{1,30}$/) {

    print pre("$art...") if ($verbose);
    process_ref_json($art);
    $art_cnt++;
  }
}

$dbh->disconnect() or die "Malkonektiĝi de DB ne funkciis.\n";

print pre("daŭro: ".(time - $^T)."s\nart: $art_cnt\nkap: $kap_cnt\nmrk: $mrk_cnt\nref: $ref_cnt\n");	
print end_html;

###################

sub process_ref_json {
    my $art = shift;
    my $file = "$tezdir/$art.json";
    my $json = fileutil::read_json_file($file);

    if ($json && $json->{$art}) {
      process_kap($art,$json->{$art});
      process_mrk($art,$json->{$art});
      process_ref($art,$json->{$art});
    }
}

sub process_kap {
  my ($art,$json) = @_;

  $kap_del->execute("$art.");

  for my $k (@{$json->{kap}}) {
    my $kap = decode('UTF-8',$k->[0]);
    my $mrk = $k->[1];
    my $var = decode('UTF-8',$k->[2]); #? $k->[2] : undef;

    print pre("KAP art: $art, kap: $kap, mrk: $mrk, var: $var\n") if ($debug);

    if ( # kiel unua litero ni permesas ankaŭ ciferojn kaj * pro *-malforta, 3-dimensia...
      $kap =~ /^[\pL\d\*][- \pL]*$/ && 
      $mrk =~ /^\.[a-z0-9A-Z_\.]+$/ &&
      (!$var || $var =~ /^[\pL\d ]+$/) )
    {
      $mrk = "$art$mrk";
      $kap_ins->execute($kap,$mrk,$var,undef); # ofc: ni devos aldoni ankoraŭ en JSON!
    }
  }
}

sub process_mrk {
  my ($art,$json) = @_;

  $mrk_del->execute("$art.");

  # unue ni aldonas drv-mrk (el kap:)
  for my $k (@{$json->{kap}}) {
    my $mrk = $k->[1];

    if ( # kiel unua litero ni permesas ankaŭ ciferojn kaj * pro *-malforta, 3-dimensia...
      $mrk =~ /^\.[a-z0-9A-Z_\.]+$/ )
    {
      $mrk = "$art$mrk";
      $mrk_ins->execute($mrk,'drv',undef,$mrk); # ofc: ni devos aldoni ankoraŭ en JSON!

      $kap_cnt++;
    }
  }

  # sekve ni aldonas la aliajn (sub)snc-mrk el mrk: 
  for my $m (@{$json->{mrk}}) {
    my $mrk = $m->[0];
    my $ele = $m->[1];
    my $num = $m->[2]; #? $m->[2] : undef;
    my $drv = (split /\./, $mrk)[1];

    print pre("MRK art: $art, mrk: $mrk, ele: $ele, num: $num, drv: $drv\n") if ($debug);

    if ( # kiel unua litero ni permesas ankaŭ ciferojn kaj * pro *-malforta, 3-dimensia...
      $mrk =~ /^\.[a-z0-9A-Z_\.]+$/ &&
      $ele =~ /^(drv|subdrv|snc|subsnc|rim)$/ &&
      $drv =~ /^[a-z0-9A-Z_]+$/ &&
      (!$num || $num =~ /^[0-9a-z]+$/) )
    {
      $mrk = "$art$mrk";
      $drv = "$art.$mrk";
      $mrk_ins->execute($mrk,$ele,$num,$drv); # ofc: ni devos aldoni ankoraŭ en JSON!

      $mrk_cnt++;
    }
  }
}

sub process_ref {
  my ($art,$json) = @_;

  $ref_del->execute("$art.");
  
  for my $ref (@{$json->{ref}}) {
    my $mrk = $ref->[0];
    my $tip = $ref->[1];
    my $cel = $ref->[2];
    my $lst = decode('UTF-8',$ref->[3]); # ? $ref->[3]: undef;

    print pre("REF art: $art, mrk: $mrk, tip: $tip, cel: $cel, lst: $lst\n") if ($debug);

    if (
        $mrk =~ /^\.[a-z0-9A-Z_\.]+$/ &&
        $cel =~ /^[a-z0-9A-Z_\.]+$/ &&
        $tip =~ /^(sin|ant|hom|vid|sup|sub|prt|mal|ekz|lst)$/ &&
        (!$lst || $lst =~ /^\pL[\pL_]+$/) )
    {
      $mrk = "$art$mrk";
      $ref_ins->execute($mrk,$tip,$cel,$lst);

      $ref_cnt++;
    }
  }
}



