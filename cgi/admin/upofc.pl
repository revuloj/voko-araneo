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
my $rv_json = "$homedir/www/revo/inx/inx_ofc.json";
my $fe_json = "$homedir/www/revo/inx/fundamento.json";
my $oa_json = "$homedir/www/revo/inx/ofcaldonoj.json";
# my $fe_prefix = "https://steloj.de/esperanto/fundamento/";
# my $oa_prefix = "https://steloj.de/esperanto/ofcaldonoj/";

print header(-charset=>'utf-8'),
      start_html('aktualigu fde/oa-ligojn'),
	  h2(scalar(localtime));

# unue legu la ofc-referencojn el JSON, ĉar se tio fiaskas, ni ne tuŝos la datumbazon!
my $rv_inx = fileutil::read_json_file($rv_json);
my $fe_refs = fileutil::read_json_file($fe_json);
my $oa_refs = fileutil::read_json_file($oa_json);
#print Dumper $refs if ($debug);
my $count = scalar(keys %{$fe_refs}) + scalar(keys %{$oa_refs});
my $icnt = scalar(keys %{$fe_refs}) + scalar(keys %{$inx_ofc});
my $ncnt = 0;

die "Tro malmultaj indekseroj ($icnt), verŝajne estas erara, ni ne daŭrigos...\n" unless ($icnt > 4000);
die "Tro malmultaj referencoj ($count), verŝajne estas erara, ni ne daŭrigos...\n" unless ($count > 6000);

# Preparu la indekson de Revo-oficialecoj por rapida aliro
my $inx_ofc = {};
inx_prep();

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
my $sth_insert = $dbh->prepare("INSERT INTO r3ofc (inx, mrk, fnt, dos, ref, skc) " 
    ."VALUES (?,?,?,?,?,?)") or die;

## kelkaj testoj...
if ($debug) {
    my $test = ref_mrk("absolut'","oa","oa_1");
    print "\nTEST - absolut': $test\n";
    my $test = ref_mrk("fruktaĵo","fe","UV");
    print "\nTEST - fruktaĵo: $test\n";
    my $test = ref_mrk("persvad'i","oa","oa_9");
    print "\nTEST - persvad'i: $test\n";
}

# traktu fundamentajn kaj poste oficialigitajn...
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
        print("n: ".scalar @$irefs."\n") if ($debug);

        while ($i < scalar @$irefs) {
            my $rr = $irefs->[$i];
            #my $skc = $irefs->[$i+1];
            my ($dos,$ref) = split('#',$rr);
            $dos =~ s/\.html$//;

            # ial json_parser ne aŭtomate supozas UTF8!?
            my $skc = decode('UTF-8', $irefs->[$i+1]);

            # eltrovu mrk el Revo-listo
            my $mrk = ref_mrk($inx,$fnt,$dos);

            print("rr: ".$rr."\n") if ($debug);
            print("skc: ".$skc."\n") if ($debug);
            print("dos: ".$dos."\n") if ($debug);
            print("fnt: ".$fnt."\n") if ($debug);
            print("ref: ".$ref."\n") if ($debug);
            print("mrk: ".$mrk."\n") if ($debug);

            if ($inx && $skc) {            
                $sth_insert->execute($inx, $mrk, $fnt, $dos, $ref, $skc);
                $ncnt++;
            }

            $i+=2;
        }
        print pre("$inx\n") if ($debug);
    }
}

sub inx_prep {
    for my $ofc (keys(%$rv_inx)) {
        $lst = $rv_inx->{$ofc};

        print "preparante indekson..." if ($debug);

        $inx_ofc->{$ofc} = {} if (! defined $inx_ofc->{$ofc});

        for my $i (@$lst) {
            # $i: [mrk,vrt] - ni renversigos kaj akceptos,
            # ke ni konservas nur po unu por vorto, se estas pluraj
            # ni ĉiuokaze skribos nur unu mrk al la datumbazo
            my $v = decode('UTF-8', $i->[1]);
            $inx_ofc->{$ofc}->{$v} = $i->[0];
        }
    }
}

sub ref_mrk {
    my ($inx,$fnt,$dos) = @_;
    my $ofc, $mrk = '';

    print "\n$inx $fnt $dos\n" if ($debug); 

    # en kiu parto (FdE, OA..) serĉi?
    if ($fnt eq 'fe') {
        $ofc = '*';
    } else {
        $dos =~ /oa_(\d)/;
        $ofc = $1;
    }

    # normigu divid-strekojn
    $inx =~ s/[’'|\/]/'/g;

    # trovu la indekseron en la oficialecoj de Revo
    if (index($inx,"'") == length($inx)-1) {
        # se inx havas solan finan apostrofon, temas pri radiko
        $mrk = rv_rad($ofc,substr($inx,0,length($inx)-1));       
    } elsif (index($inx,"'")<0) {
        # se inx havas neniun apostrofon, temas pri derivaĵo
        $mrk = rv_drv($ofc,$inx);       
    } elsif (rindex($inx,"'") == length($inx)-2) {
        # se apostrofo/streko estas antaŭlasta, ni forpurigu ilin antaŭ serĉi je derivaĵo
        $inx =~ s/'//g;
        $mrk = rv_drv($ofc,$inx);       
    }

    return $mrk;
}

sub rv_rad {
    my ($ofc,$rad) = @_;

    print "rad? $ofc $rad\n" if ("$debug");
    #print join(' ',keys(%$inx_ofc)) if ($debug);

    # trovu indekseron por radiko el Revo-listo (ofc: *, 1..9, 19xx)
    my $r = $inx_ofc->{$ofc};
    my $mrk = $r->{$rad};
    #print "\nr: @{$r->[0]}\n" if ($debug);

    return $mrk if (
        index($mrk,'.') < 0 # radikreferenco ne enhavu punkton
    );
}

sub rv_drv {
    my ($ofc,$drv) = @_;

    print "drv? $ofc $rad\n" if ("$debug");
    #print join(' ',keys(%$inx_ofc)) if ($debug);

    # trovu indekseron por derivaĵo el Revo-listo (ofc: *, 1..9, 19xx)
    my $r = $inx_ofc->{$ofc};
    my $mrk = $r->{$drv};
    #print "\nr: @{$r->[0]}\n" if ($debug);

    return $mrk if (
        index($mrk,'.') >= 0 # drv-referenco enhavu punkton
    );
}

