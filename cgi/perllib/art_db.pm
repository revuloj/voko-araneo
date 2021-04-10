#!/usr/bin/perl

use strict;
package art_db;

# legu la datumojn el artikollisto sub tez/*.json, 
# kaj metu en la datumbazon...

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

my $debug = 0;
my $verbose = 1;

my $homedir = "/hp/af/ag/ri";
my $tezdir = "$homedir/www/revo/tez";
#my $json_parser = JSON->new->allow_nonref;

# SQL-komandoj
my $kap_del;
my $kap_ins;
my $mrk_del;
my $mrk_ins;
my $ref_del;
my $ref_ins;

my $counter;


sub process {
  my ($dbh,$arts,$vrb) = @_;
  $verbose = $vrb;

  # preparu SQL
  $kap_del = $dbh->prepare("DELETE FROM r3kap WHERE mrk LIKE ?");
  $kap_ins = $dbh->prepare("INSERT INTO r3kap (kap,mrk,var,ofc) VALUES (?,?,?,?)");
  $mrk_del = $dbh->prepare("DELETE FROM r3mrk WHERE mrk LIKE ?");
  $mrk_ins = $dbh->prepare("INSERT INTO r3mrk (mrk,ele,num,drv) VALUES (?,?,?,?)");
  $ref_del = $dbh->prepare("DELETE FROM r3ref WHERE mrk LIKE ?");
  $ref_ins = $dbh->prepare("INSERT INTO r3ref (mrk,tip,cel,lst) VALUES (?,?,?,?)");

  # nuligu nombrilojn
  $counter = {
    art => 0,
    mrk => 0,
    kap => 0,
    ref => 0
  };  

  for my $art (@$arts) {
    if ($art =~ /^[a-z0-9]{1,30}$/) {
      print pre("$art...") if ($verbose);
      process_ref_json($art);
      $counter->{art}++;
    }
  }

  return $counter;
}

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

  $kap_del->execute("$art.%");

  for my $k (@{$json->{kap}}) {
    my $kap = decode('UTF-8',$k->[0]);
    my $mrk = $k->[1];
    my $var = decode('UTF-8',$k->[2]?$k->[2]:'');

    print pre("KAP art: $art, kap: $kap, mrk: $mrk, var: $var\n") if ($debug);

    if ( # kiel unua litero ni permesas ankaŭ ciferojn kaj * pro *-malforta, 3-dimensia...
      $kap =~ /^[\pL\d\*][- \pL]*$/ && 
      $mrk =~ /^\.[a-z0-9A-Z_\.]+$/ &&
      (!$var || $var =~ /^[\pL\d ]+$/) )
    {
      $mrk = "$art$mrk";
      $kap_ins->execute($kap,$mrk,$var,''); # ofc: ni devos aldoni ankoraŭ en JSON!

      $counter->{kap}++;
    }
  }
}

sub process_mrk {
  my ($art,$json) = @_;

  $mrk_del->execute("$art.%");

  # unue ni aldonas drv-mrk (el kap:), pro variaĵoj ni povus havi
  # duoblajn, do ni devas memori ilin por eviti tion
  my $drv_mrk = {};

  for my $k (@{$json->{kap}}) {
    my $mrk = $k->[1];

    #print "MRK $mrk".$drv_mrk->{$mrk} if ($debug);

    unless ($drv_mrk->{$mrk}) {
      $drv_mrk->{$mrk} = 1;
      print pre("MRK art: $art, mrk: $mrk\n") if ($debug);

      if ( # kiel unua litero ni permesas ankaŭ ciferojn kaj * pro *-malforta, 3-dimensia...
        $mrk =~ /^\.[a-z0-9A-Z_\.]+$/ )
      {
        $mrk = "$art$mrk";
        $mrk_ins->execute($mrk,'drv','',$mrk); # ofc: ni devos aldoni ankoraŭ en JSON!

        $counter->{mrk}++;
      }
    }
  }

  # sekve ni aldonas la aliajn (sub)snc-mrk el mrk: 
  for my $m (@{$json->{mrk}}) {
    my $mrk = $m->[0];
    my $ele = $m->[1];
    my $num = $m->[2]?$m->[2]:'';
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

      $counter->{mrk}++;
    }
  }
}

sub process_ref {
  my ($art,$json) = @_;

  $ref_del->execute("$art.%");
  
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

      $counter->{ref}++;
    }
  }
}

1;