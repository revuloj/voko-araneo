#!/usr/bin/perl

# (c) 2023 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0
#
# importado de referencoj al Fundamento de Esperanto kaj Oficialaj Aldonoj
# el JSON-dosieroj al DB

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

$debug = 1;

my $homedir = "/hp/af/ag/ri";
my $fe_json = "$homedir/www/revo/inx/fundamento.json";
my $oa_json = "$homedir/www/revo/inx/ofcaldonoj.json";
# my $fe_prefix = "https://steloj.de/esperanto/fundamento/";
# my $oa_prefix = "https://steloj.de/esperanto/ofcaldonoj/";

print header(-charset=>'utf-8'),
      start_html('aktualigu fde/oa-ligojn'),
	  h2(scalar(localtime));

# unue legu la ofc-referencojn el JSON, ĉar se tio fiaskas, ni ne tuŝos la datumbazon!
my $fe_refs = fileutil::read_json_file($fe_json);
my $oa_refs = fileutil::read_json_file($oa_json);
#print Dumper $refs if ($debug);
my $count = scalar(keys %{$fe_refs}) + scalar(keys %{$oa_refs});
my $ncnt = 0;
die "Tro malmultaj referencoj ($count), verŝajne estas erara, ni ne daŭrigos...\n" unless ($count > 6000);

# Konektiĝi kun la datumbazo kaj malplenigi la tabelon
my $dbh = revodb::connect();
my $sth = $dbh->prepare("TRUNCATE TABLE r3ofc") or die;
$sth->execute();
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

# Nun ni trakuras la referencojn kaj enmetas ilin en la datumbazon.
# Kelkaj markoj povas duobliĝi, ekz-e ni havas ambaŭ abrikotujo kaj abrikotarbo,
# sed sufiĉas unu referenco al Vikipedio. Ni lasas trakti tion al la datumbazo 
# per ON DUPLICATE...
my $sth_insert = $dbh->prepare("INSERT INTO r3ofc (inx, fnt, dos, ref, skc) " 
    ."VALUES (?,?,?,?,?)") or die;

process("fe",$fe_refs);
process("oa",$oa_refs);

$sth_insert->finish();
$dbh->disconnect() or die "DB disconnect ne funkcias";

print pre("daŭro: ".(time - $^T)." sekundoj por $ncnt / $count referencoj");	
print end_html;

sub process {
    my ($fnt, $refs) = @_;

    for $r (keys %$refs) {
        my $irefs = $refs->{$r};
        # ial json_parser ne aŭtomate supozas UTF8!?
        my $inx = decode('UTF-8', $r);

        # la referencoj estas alternaj referenccelo kaj sekcinomo
        my $i = 0;

        # print("r: ".$r." ".$refs->{$r}) if ($debug);
        print("n: ".scalar @$irefs) if ($debug);

        while ($i < scalar @$irefs) {
            my $rr = $irefs->[$i];
            #my $skc = $irefs->[$i+1];
            my ($dos,$ref) = split('#',$rr);
            $dos =~ s/\.html$//;

            # ial json_parser ne aŭtomate supozas UTF8!?
            my $skc = decode('UTF-8', $irefs->[$i+1]);

            print("rr: ".$rr."\n") if ($debug);
            print("skc: ".$skc."\n") if ($debug);
            print("dos: ".$dos."\n") if ($debug);
            print("fnt: ".$fnt."\n") if ($debug);
            print("ref: ".$ref."\n") if ($debug);

            if ($inx && $skc) {            
                $sth_insert->execute($inx, $fnt, $dos, $ref, $skc);
                $ncnt++;
            }

            $i+=2;
        }
        print pre("$inx\n") if ($debug);
    }
}

