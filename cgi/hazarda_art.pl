#!/usr/bin/perl

# hazarda_art.pl
# 
# 2008-01-__ Wieland Pusch
# ...2026 Wolfram Diestel
#
# Elektas kaj redonas arbitran artikolon el Revo.
# En la nuna fasado tio okazas per JSON kaj fona ŝargado
# tra sercxu-json-xx.pl
# Tiu ĉi skripto okaze plu uziĝas kun la mlanova fasado.
# revo/index-malnova.html

use warnings; use strict;

use CGI qw(:standard *table); use CGI::Carp qw(fatalsToBrowser);
use DBI();
use URI::Escape;

use utf8; use open ':std', ':encoding(UTF-8)';

use IO::Handle;
STDOUT->autoflush(1);

# $| = 1;

my $revo_dir = '/hp/af/ag/ri/www/revo';

my $senkadroj = param('senkadroj');
unless ($senkadroj) {
  print "Content-type: text/html\n\n";

  # anstataŭigu la enhavon de la kadraro (HTML frameset)
  open my $in, '<', "$revo_dir/index.html" 
    or die "Hazarda artikolo ne eblas pro manko de indekso.\n";
  my @index = <$in>; close $in;

  for (@index) {
    s{
      src="inx/_eo.html"
    }
    {src="hazarda_art.pl?senkadroj=1"}x;

    s{
      src="titolo.html"
    }
    {src="hazarda_art.pl?senkadroj=2#toptop"}x;
    print;
  }
  exit 1;
}

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri//files/perllib");
use revodb;
use eosort;

# Connect to the database.
my $dbh = revodb::connect();

#$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

my $cnt = $dbh->selectrow_hashref("SELECT count(*) AS c FROM r3kap");
my $rno = int(rand($cnt->{c}));
my ($hazarda_mrk) = $dbh->selectrow_array("SELECT mrk FROM r3kap LIMIT $rno,1");

my $art = '';
if ($hazarda_mrk =~ 
  m{^
    ([a-z0-9]+)
    \.
  }x) {
   $art = $1;
}

# tio legas kaj redonas adaptite la artikolon...
# estonte ni ne plu uzos tion, sed ŝargos la artikolon per JS HTTPRequest.
if ($senkadroj == 2 && $art) 
{
  print header(-charset=>'utf-8');

  open my $in, '<', "$revo_dir/art/$art.html" 
    or die "Ne eblas malfermi: '$art'\n";
  my @artikolo = <$in>; close $in;

  while (@artikolo) {
    s{
      (\[<a\s+
        class="redakto"\s+
        href="/cgi-bin/vokomail)
      (\.pl
       \?art=[a-z0-9]+">)
      (redakti)
      (\.\.\.<\/a>\])
    }
    {$1\l$2$3$4\n$1\l2$2traduki$4}x;
    ## use critic 

    s{
      ="\.\./ #"
    }
    {="../revo/}xg; #"

    s{
      (href=")
      ([^#./](?!ttp://))
    }
    {$1../revo/art/$2}xg;

    print;
  }

  exit 1;
}

my $JSCRIPT=<<'END';
top.document.title = "Reta Vortaro, hazarda artikolo";
END

print header(-charset=>'utf-8'),
  start_html(-style=>{-src=>'/revo/stl/indeksoj.css'},
             -script=>$JSCRIPT
);

print start_table(-cellspacing=>0),
  Tr(
  [
    td({-class=>'aktiva'}, a({-href=>'/revo/inx/_eo.html'}, 'Esperanto')).
    td({-class=>'fona'}, [a({-href=>'/revo/inx/_lng.html'}, 'Lingvoj'),
  a({-href=>'/revo/inx/_fak.html'}, 'Fakoj'),
  a({-href=>'/revo/inx/_ktp.html'}, 'ktp.')]),
  ]
  );

#
print <<'EOD';
<td colspan="4" class="enhavo">
<a href="/revo/art/$art.html" target="precipa">Hazarda artikolo.</a>
</td>
EOD

print <<'EOD';
<script type="text/javascript">
<!--
open('/revo/art/$art.html', 'precipa');
//-->
</script>
EOD

$dbh->disconnect() or die "DB-malkonekto ne funkcias.\n";
  
print end_table();
print end_html();

