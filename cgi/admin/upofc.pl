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

$debug = 0;
$test = 1;

my $homedir = "/hp/af/ag/ri";
my $rv_json = "$homedir/www/revo/inx/inx_ofc.json";
my $fe_json = "$homedir/www/revo/inx/fundamento.json";
my $oa_json = "$homedir/www/revo/inx/ofcaldonoj.json";
# my $fe_prefix = "https://steloj.de/esperanto/fundamento/";
# my $oa_prefix = "https://steloj.de/esperanto/ofcaldonoj/";

my @sufiksoj = qw(ad aĵ at an ant ar ĉj ec ej eg em er et id ig iĝ il in ing int ist it nj obl on ont op ot uj um ul);
my @prefiksoj = qw(bo dis ek mal ge pra re);
my @finajhoj = qw(as is os us i u o a e n j);

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

## kelkaj testoj...
if ($test || $debug) {
    my $test = ref_mrk("absolut'","oa","oa_1");
    print "\nTEST - absolut': $test\n";
    my $test = ref_mrk("fruktaĵo","fe","UV");
    print "\nTEST - fruktaĵo: $test\n";
    my $test = ref_mrk("persvad'i","oa","oa_9");
    print "\nTEST - persvad'i: $test\n";
    my $test = ref_mrk("aer'um'","fe","");
    print "\nTEST - aer'um': $test\n";
    my $test = ref_mrk("advent'","oa","oa_1");
    print "\nTEST - advent': $test\n";
    my $test = ref_mrk("dis-","fe","UV");
    print "\nTEST - dis-': $test\n";
    my $test = ref_mrk("ge","fe","UV");
    print "\nTEST - ge: $test\n";
    my $test = ref_mrk("teokratri'o","oa","oa_2");
    print "\nTEST - teokratri'o: $test\n";   
    my $test = ref_mrk("epifani'o","oa","oa_2");
    print "\nTEST - epifani'o: $test\n";       
#exit;
}

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
    print "preparante indekson..." if ($debug);

    for my $ofc (keys(%$rv_inx)) {
        $lst = $rv_inx->{$ofc};

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

    # specialaj kazoj
    return 'auxgus1' if ($inx eq "Aŭgust'" && $dos eq 'oa_7');
    return 'auxgus1' if ($inx eq "Aŭgusto" && $dos eq 'ekz_22');
    return 'analog'  if ($inx eq "analog'");
    return 'analog1' if ($inx eq "analogi'");
    return 'koncen1' if ($inx eq "koncentr'");
    return 'dekor' if ($inx eq "dekori");
    return 'konvers' if ($inx eq "konversi");
    return 'centr.sam0a' if ($inx eq "samcentra");
    return 'arhxitekt' if ($inx eq "arĥitekt', arkitekt'");
    return 'katehx2' if ($inx eq "kateĥiz', katekiz'");
    return 'katehx1' if ($inx eq "kateĥist', katekist'");
    return 'oligark' if ($inx eq "oligarĥ', oligark'");
    return 'oligar' if ($inx eq "oligarĥi', oligarki'");
    return 'hierar' if ($inx eq "hierarĥi', hierarki'");
    return 'arkeol' if ($inx eq "arĥeolog', arkeolog'");
    return 'arkeol1' if ($inx eq "arĥeologi', arkeologi'");
    return 'anarhx' if ($inx eq "anarĥi', anarki'");
    return 'arkipe' if ($inx eq "arĥipelag', arkipelag'");
    return 'tehxnik' if ($inx eq "teĥnik', teknik'");
    return 'mehxan1' if ($inx eq "mekanismo/meĥanismo" || $inx eq "meĥanism'o, mekanism'o");
    return 'arhxiv' if ($inx eq "arĥiv', arkiv'");
    return 'arhxaik' if ($inx eq "arĥaik', arkaik'");
    return 'hxirur' if ($inx eq "kirurgi'o, (ĥirurgi'o)");
    return 'hxirurg' if ($inx eq "kirurg'o, (ĥirurg'o)");
    return 'monarh1' if ($inx eq "monarki'o, (monarĥi'o)" || $inx eq "monarĥio/monarkio");    
    return 'gujav.0arbo' if ($inx eq "gujav'uj'o, gujav'arb'o");
    return 'mang.0arbo' if ($inx eq "mang'uj'o, mang'arb'o");
    return 'avokad.0ujo' if ($inx eq "avokad'uj'o, avokad'arb'o");
    return 'mandar1.0arbo' if ($inx eq "mandarin'uj'o, mandarin'arb'o");
    return 'zamenhof' if ($inx eq "Zamenhof");

    # en kiu parto (FdE, OA..) serĉi?
    if ($fnt eq 'fe') {
        $ofc = '*';
    } else {
        $dos =~ /oa_(\d)/;
        $ofc = $1;
    }

    # normigu divid-strekojn
    $inx =~ s/[’'|\/]/'/g;
    $inx =~ s/!$//g;
    my $i1 = $inx;

    # trovu la indekseron en la oficialecoj de Revo
    if (index($i1,"'") == length($i1)-1) {
        # se inx havas solan finan apostrofon, temas pri radiko
        $mrk = rv_rad($ofc,substr($i1,0,length($i1)-1));       
    } elsif (index($i1,"'") < 0) {
        # se inx havas neniun apostrofon, verŝajne temas pri derivaĵo
        $mrk = rv_drv($ofc,$i1);       
    } elsif (rindex($i1,"'") == length($i1)-2) {
        # se apostrofo/streko estas antaŭlasta, ni forpurigu ilin antaŭ serĉi je derivaĵo
        $i1 =~ s/'//g;
        $mrk = rv_drv($ofc,$i1);       
    }

    # se mrk ne troviĝis ni povas provi ankoraŭ forigi aŭ aldoni finaĵon kaj reserĉi
    if (! $mrk) {
        my $i2 = lc($inx);
        my $I2 = uc(substr($i2,0,1)).substr($i2,1);
        $I2 =~ s/'//g;

        my $afks = $i2; $afks =~ s/'$//;
        my ($suf) = grep { $sufiksoj[$_] ~~ $afks } 0 .. $#sufiksoj;
        my ($pref) = grep { $prefiksoj[$_] ~~ $afks } 0 .. $#prefiksoj;
        my ($fin) = grep { $finajhoj[$_] ~~ $afks } 0 .. $#finajhoj;

        print "afikso? $suf $pref $fin\n" if ($debug);

        if ($fnt eq 'fe' && $suf ne '') {
            $mrk = rv_drv($ofc,'-'.$afks);
        } elsif ($fnt eq 'fe' && $fin ne '') {
            $mrk = rv_drv($ofc,'-'.$afks);
        } elsif ($fnt eq 'fe' && $pref ne '') {
            $mrk = rv_drv($ofc,$afks.'-');

        } elsif (rindex($i2,"'") == length($i2)-2) {
            # se apostrofo/streko estas antaŭlasta, ni forpurigu ilin antaŭ serĉi je derivaĵo
            $i2 =~ s/'[oaie]$//;
            $i2 =~ s/'//g;
            $I2 =~ s/[oaie]$//;
            $mrk = rv_rad($ofc,$i2) || rv_rad($ofc,$I2);   
        } elsif (rindex($i2,"'") == length($i2)-1) {
            # se apostrofo estas lasta, ni povas provi alpendigi finaĵon por trovi drv-on
            $i2 =~ s/'//g;
            $mrk = rv_drv($ofc,$i2.'o') || rv_drv($ofc,$i2.'a')
                || rv_drv($ofc,$i2.'i') || rv_drv($ofc,$i2.'e')
                || rv_drv($ofc,$I2.'o') || rv_drv($ofc,$I2.'a')
                || rv_drv($ofc,$I2.'i') || rv_drv($ofc,$I2.'e');
        } elsif ($i2 =~ /[aioe]$/) {
            # se finiĝas je [eaio], ni provu forigi la finaĵon kaj serĉi la radikan parton
            $i2 =~ s/[aioe]$//;
            $mrk = rv_rad($ofc,$i2);
        }
    }

    unless ($mrk) {
        warn "Ne povas trovi mrk por: $inx $fnt $dos\n";
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

    print "drv? $ofc $drv\n" if ("$debug");
    #print join(' ',keys(%$inx_ofc)) if ($debug);

    # trovu indekseron por derivaĵo el Revo-listo (ofc: *, 1..9, 19xx)
    my $r = $inx_ofc->{$ofc};
    my $mrk = $r->{$drv};
    #print "\nr: @{$r->[0]}\n" if ($debug);

    return $mrk if (
        index($mrk,'.') >= 0 # drv-referenco enhavu punkton
    );
}

