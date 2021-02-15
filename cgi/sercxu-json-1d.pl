#!/usr/bin/perl 
#
# sercxu.pl
# 
# (c) GPL 2.0
# 2006__ Wieland Pusch, Bart Demeyere
# 2007__ Wieland Pusch
# 2012-2020 __ Wolfram Diestel

use strict;

#use CGI qw(:standard *table);
##use CGI qw(:standard -utf8);
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
use URI::Escape;

use utf8;
#use open ':std', ':encoding(UTF-8)';
binmode(STDOUT, ":utf8");

use JSON;
my $json_parser = JSON->new->allow_nonref;

#$| = 1;

my $debug = 0;
my $LIMIT = 50;
my $LIMIT_lng = 3;

#print "Content-type: text/html; charset=utf-8\n\n";

# testu ekz. per:
# perl sercxu-json.pl "sercxata=test%&cx=1&moktesto=0"


# komenco
print <<EOT;
Content-type: application/json; charset=utf-8

[
EOT


#### preparu stirantajn parametrojn  ####

### my %unicode = ( cx => "ĉ", gx => "ĝ", hx => "ĥ", jx => "ĵ", sx => "ŝ", ux => "ŭ" );

my $max_entries = 100;
my $neniu_trafo = 1;
my $formato = "json";

# kion serĉi
#my $sercxata = param('q2');
my $sercxata = param('sercxata'); #if param('sercxata');
#? utf8::decode($sercxata);
 
# ĉu traduki cx al ĉ ktp.
my $cx2cx = param('cx');
#$cx2cx = "checked" if $cx2cx;

# ĉu serĉi en nur unu lingvo?
#my $param_lng = param('lng');
#$param_lng = '' unless $param_lng;

# pado al Revo-artikoloj
my $pado = "..";
$pado = "/revo" if param('pado') eq 'revo';

#$ENV{HTTP_ACCEPT_LANGUAGE} = ''; # por testi

#### eltrovu preferatan lingvon de la uzanto laŭ la retumilo ####
### PLIBONIGU: limigu preferatajn lingvojn al 3 aŭ 5!
my @preferataj_lingvoj;
{
  my @a = split ",", $ENV{HTTP_ACCEPT_LANGUAGE};
  for my $l (@a) {
    #$preferata_lingvo = shift @a if $preferata_lingvo =~ /^eo/;
    $l =~ s/^([a-z]{2,3}).*$/$1/;
    unless (grep(/$l/,@preferataj_lingvoj)) {
      push @preferataj_lingvoj, ($l) if ($l);
    }
    #print "DEBUG ".$#preferataj_lingvoj." ".$LIMIT_lng;
    last if (($#preferataj_lingvoj + 1) == $LIMIT_lng);
  #  $preferata_lingvo = 'nenio' if $preferata_lingvo eq '';
  }
}

#print "DEBUG ".join(',',@preferataj_lingvoj);

@preferataj_lingvoj = ('en') unless (@preferataj_lingvoj); 
my $pref_lng = "('".join("','",@preferataj_lingvoj)."')";

###################################################################
#  serĉo en datumbazo                                             #
###################################################################


# propraj perl moduloj estas en:
#use lib ("./perllib");
use lib("/hp/af/ag/ri/files/perllib");
use revodb;
use eosort;

# serĉo en la datumbazo
my $dbh = revodb::connect();
# necesas!
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

use Time::HiRes qw (gettimeofday tv_interval);
Sercxu($sercxata, $pref_lng);
$dbh->disconnect() or die "Malkonekto de la datumbazo ne funkciis";

# fino
print "\n]\n";
exit;


###################################################################
# funkcioj por serĉo                                              #
###################################################################


sub Sercxu
{
  my ($sercxata, $pref_lng) = @_;
  my $tempo = [gettimeofday];
  my ($sth, $sth2);

  # $komparo estas unu el: =, LIKE, REGEXP
  my $komparo = '=';
  if ($sercxata =~ /[.^$\[\(\|+?{\\]/) {
    $komparo = 'REGEXP'
  } elsif ($sercxata =~ /[%_]/) {
    $komparo = 'LIKE';
  };

  # por ricevi ĝustan ordigadon en diversaj lingvoj ni
  # uzas normigitan askiigitan formon (_ci) por serĉi en la datumbazo
  my ($sercxata2,$sercxata2_eo) = normiguSercxon($sercxata);

  # serĉo en Esperanto aŭ sen difinita lingvo
  #if ($param_lng eq 'eo' or $param_lng eq '') {

    my $QUERY_eo =  
    "SELECT DISTINCT d.drv_mrk, d.drv_teksto, d.drv_id, a.art_amrk, v.var_teksto, 
       LOWER(d.drv_teksto) " . $komparo . " LOWER(?) AS drv_match
    FROM art a, drv d LEFT OUTER JOIN var v ON d.drv_id = v.var_drv_id
    WHERE (LOWER(d.drv_teksto) " . $komparo . " LOWER(?) or LOWER(v.var_teksto) " . $komparo . " LOWER(?))
      AND a.art_id = d.drv_art_id 
    ORDER BY d.drv_teksto collate utf8_esperanto_ci, a.art_amrk 
    LIMIT ".$LIMIT;

    # ekde mySQL 5.6. ni povus uzi GROUP_CONCAT por kunigi ĉiujn tradukojn
    # de unu lingvo en unu signoĉeno!
    my $QUERY_eo_trd = 
    "SELECT DISTINCT t.trd_lng, t.trd_teksto
    FROM trd t, snc s
    WHERE s.snc_drv_id = ?
      AND t.trd_snc_id = s.snc_id
      AND t.trd_lng IN $pref_lng
    ORDER BY t.trd_lng, t.trd_teksto collate utf8_unicode_ci
    LIMIT ".$LIMIT;

    $sth2 = $dbh->prepare($QUERY_eo_trd);
    $sth = $dbh->prepare($QUERY_eo);

    eval {
      print "$QUERY_eo\n" if ($debug);
      print "$QUERY_eo_trd\n" if ($debug);
      print "serĉu: $sercxata2_eo\n" if ($debug);
      $sth->execute($sercxata2_eo, $sercxata2_eo, $sercxata2_eo);
      ###exit;
    };

    # kontrolu kaj eldonu erarojn, aliokaze la rezultojn
    # TODO: necesas adapti por json
    if ($@) {
      if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
        print "Eraro: La rektaj krampoj ([ ]) ne kongruas.<br>\n";
      } else {
        print "Err ".$sth->err." - $@";
      }
    } else {
      MontruRezultojn_eo($sth, $sth2);
    }
  #}

  # serĉo en aliaj lingvoj ol Esperanto
##  } else 

  {
    
    $sth2 = undef;
    if (param("trd")) {
      my $QUERY_lng_trd =
      "SELECT t.*
      FROM trd t
      WHERE t.trd_lng IN $pref_lng
      AND t.trd_snc_id = ?
      ORDER BY t.trd_teksto_ci
      LIMIT ".$LIMIT;
	  
      $sth2 = $dbh->prepare($QUERY_lng_trd);
    }

    my $QUERY_lng = 
      "SELECT t.trd_lng, t.trd_teksto, s.snc_mrk, s.snc_numero, 
                d.drv_mrk, d.drv_teksto, a.art_amrk, l.lng_nomo
      FROM trd t
      LEFT JOIN snc s ON t.trd_snc_id = s.snc_id
      LEFT JOIN drv d ON d.drv_id = s.snc_drv_id
      LEFT JOIN art a ON a.art_id = d.drv_art_id
      LEFT JOIN lng l ON t.trd_lng = l.lng_kodo ";

  # nur unu lingvo
  #  if ($param_lng) { 
#
  #    $preferata_lingvo = $param_lng;
  #    $QUERY_lng .=
  #    "WHERE LOWER(t.trd_teksto) " . $komparo . " LOWER(?)
  #    AND t.trd_lng = ?
  #    ORDER BY l.lng_nomo, t.trd_teksto, d.drv_teksto collate utf8_esperanto_ci, s.snc_numero
  #    LIMIT ".$LIMIT;
#
  ## cxiuj lingvojn, sed preferata unue
  #  } else { 

      $QUERY_lng.=
      "WHERE LOWER(t.trd_teksto) " . $komparo . " LOWER(?)
      ORDER BY l.lng_nomo, t.trd_teksto collate utf8_unicode_ci, 
        d.drv_teksto collate utf8_esperanto_ci, s.snc_numero
      LIMIT ".$LIMIT;
  #  }

    $sth = $dbh->prepare($QUERY_lng);
    eval {
      print "$QUERY_lng\n" if ($debug);
      print "serĉu: $sercxata2\n" if ($debug);
      $sth->execute($sercxata2);
    };

    # TODO: eligon de eraro adaptu por JSON
    if ($@) {
      # $sth->err and $DBI::err will be true if error was from DBI
      if ($sth->err == 1139) {	# Got error 'brackets ([ ]) not balanced
      } else {
        print "Err ".$sth->err." - $@";
      }

    } else {
      MontruRezultojn_trd($sth);
    }
  }
}

sub normiguSercxon {
  my $sercxata = shift @_;
  my $sercxata_eo = $sercxata;

  if ($cx2cx) {
    $sercxata_eo =~ s/c[xX]/ĉ/g;
    $sercxata_eo =~ s/g[xX]/ĝ/g;
    $sercxata_eo =~ s/h[xX]/ĥ/g;
    $sercxata_eo =~ s/j[xX]/ĵ/g;
    $sercxata_eo =~ s/s[xX]/ŝ/g;
    $sercxata_eo =~ s/u[xX]/ŭ/g;
    $sercxata_eo =~ s/C[xX]/Ĉ/g;
    $sercxata_eo =~ s/G[xX]/Ĝ/g;
    $sercxata_eo =~ s/H[xX]/Ĥ/g;
    $sercxata_eo =~ s/J[xX]/Ĵ/g;
    $sercxata_eo =~ s/S[xX]/Ŝ/g;
    $sercxata_eo =~ s/U[xX]/Ŭ/g;
  }

  #my $sorter = new eosort;
  
  #if ($sercxata_eo eq $sercxata) {
  #  $sercxata = $sorter->remap_ci($sercxata);
  #  $sercxata_eo = $sercxata;
  #} else {
  #  $sercxata = $sorter->remap_ci($sercxata);
  #  $sercxata_eo = $sorter->remap_ci($sercxata_eo);
  #}

  return ($sercxata_eo,$sercxata_eo);
}


###################################################################
# funkcioj por eldono                                             #
###################################################################


sub MontruRezultojn_eo
{
  my ($res, $sth2) = @_;
  my $num = 0;

  # trakuru ĉiujn DB-serĉrezultojn...
  while (my $ref = $res->fetchrow_hashref()) {

    $num++;

    if ($num == 1) {
      #print " ]\n },\n {" unless ($num==1);

      json_obj_start({
        "lng"=>"eo",
        "max"=>$LIMIT,
        "titolo"=>"esperanta"
      });

      print " \"trovoj\": [\n";
      #$last_lng = $lng;
    } else {
      print ",\n";
    }

    json_obj_start({
      "art"=>$$ref{'art_amrk'}
    });

    print "\"eo\":";
    #json_obj(
    print $json_parser->encode({
      "mrk"=>$$ref{'drv_mrk'},
      "vrt"=>$$ref{'drv_match'}?
          escape($$ref{'drv_teksto'}) : escape($$ref{'var_teksto'})
    });


    ### aldonu tradukojn en preferataj lingvoj
    $sth2->execute($$ref{'drv_id'});
    my $tradukoj=''; 
    my $sep='';
    my $last_lng= '';

    while (my $ref2 = $sth2->fetchrow_hashref()) {

      my $lng = $$ref2{'trd_lng'};

      # ĉe komenco de nova lingvo...
      unless ($last_lng) { # unua
        print ",\n  \"$lng\":{";

      } elsif ($lng ne $last_lng) { # plia
        attribute("vrt",$tradukoj,1);
        print "},\n  \"$lng\":{";
        $tradukoj = '';
      }
      # en ambaŭ supraj kazoj
      if ($lng ne $last_lng) {
        attribute("mrk","lng_$lng");
        $sep = '';
      }

      $last_lng = $lng; 

      # kunigu ĉiujn tradukojn de unu lingvo...
      $tradukoj .= $sep.escape($$ref2{'trd_teksto'});
      #print "DBTRD: ".$tradukoj;

      $sep = ", ";
    }

    # eligu la reston
    if ($last_lng) {
        attribute("vrt",$tradukoj,1);
        print "}\n";
    }

    print "}";

  } # ...while
  $res->finish();
    
  if ($num) {
    $neniu_trafo = 0;
    print "\n]}\n";
  }
}



sub MontruRezultojn_trd
{
  my ($res) = @_;
  my $num = 0;
  my $sep = '';
  my $last_lng;


  # trakuru ĉiujn DB-serĉrezultojn...
  while (my $ref = $res->fetchrow_hashref()) {

    $num++;
    if ($num == 1) {
      # se ni trovis tradukojn kaj jam skribis "eo", ni bezonas komon...
      print ",\n" unless ($neniu_trafo); #($lng eq 'eo' or $neniu_trafo);
    }

    my $lng = $$ref{'trd_lng'};

    # trovoj estas ordigitaj laŭ lingvo,
    # ĉe komenco de nova lingvo, finu alineon kaj skribu enkondukon por nova
    if ($lng ne $last_lng) {
      print "]},\n" if ($last_lng);

      json_obj_start({
        "lng"=>$lng,
        "max"=>$LIMIT,
        "titolo"=>$$ref{'lng_nomo'}
      });
      print " \"trovoj\": [\n";
      $last_lng = $lng;
    } else {
      print $sep;
    }

    json_obj_start({
      "art"=>$$ref{'art_amrk'}
    });

    print "\"$lng\":";
    print $json_parser->encode({
      "mrk"=>'lng_'.$$ref{'trd_lng'},
      "vrt"=>escape($$ref{'trd_teksto'})
    });

    #json_obj({
    #  "mrk"=>'lng_'.$$ref{'trd_lng'},
    #  "vrt"=>escape($$ref{'trd_teksto'})
    #});

    print ",\"eo\":";
    #json_obj(
    print $json_parser->encode({
      "mrk"=>$$ref{'drv_mrk'},
      "vrt"=>escape($$ref{'drv_teksto'})
    });
  
    print "}\n"; 
    $sep = ",\n";

  } # ...while


  $res->finish();
    
  if ($num) {
    print "]}\n";
  #  #$neniu_trafo = 0;
  }
}

sub json_obj_start {
  my $hash_ref = shift;
  my $size = scalar keys %{$hash_ref};
  my $n = 0;
  print "{";
  while (my ($key, $value) = each %{$hash_ref}) {
    attribute($key, $value)
  }
}

#sub json_obj {
#  my $hash_ref = shift;
#  my $size = scalar keys %{$hash_ref};
#  my $n = 0;
#  print "{";
#  while (my ($key, $value) = each %{$hash_ref}) {
#    attribute($key, $value, ++$n >= $size)
#  }
#  print "}"; 
#}

sub attribute {
  my ($name,$value,$last) = @_;
  print "\"$name\":\"$value\"";
  print "," unless ($last);
}

sub escape {
  my $str = shift;
  $str =~ s/\"/\\\"/g;
  $str =~ s/<[^>]+>//g;
  return $str;
}

