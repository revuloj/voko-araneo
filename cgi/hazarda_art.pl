#!/usr/bin/perl

#
# hazarda_art.pl
# 
# 2008-01-__ Wieland Pusch
#

use strict;

use CGI qw(:standard *table);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
use URI::Escape;

use utf8;
#use open ':std', ':encoding(UTF-8)';
binmode(STDOUT, ":utf8");

$| = 1;

my $senkadroj = param('senkadroj');
if (!$senkadroj) {
  print "Content-type: text/html\n\n";

  # anstataŭigu la enhavo de la kadraro (HTML frameset)
  open IN, "<../revo/index.html" or die "hazarda artikolo ne eblas cxar mankas indekso";
  while (<IN>) {
    s/src="inx\/_eo.html"/src="hazarda_art.pl?senkadroj=1"/;
    s/src="titolo.html"/src="hazarda_art.pl?senkadroj=2#toptop"/;
    print;
  }
  close IN;
  exit 1;
}

# propraj perl moduloj estas en:
use lib("/var/www/web277/files/perllib");
use revodb;
use eosort;

# Connect to the database.
my $dbh = revodb::connect();

#$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

my $sth = $dbh->prepare("SELECT floor(rand() * count(*)) FROM art");
$sth->execute();
my ($row) = $sth->fetchrow_array();
$sth->finish();

$sth = $dbh->prepare("SELECT art_amrk FROM art LIMIT $row,1");
$sth->execute();
my ($art) = $sth->fetchrow_array();
$sth->finish();

# tio legas kaj redonas adaptite la artikolon...
# estonte ni ne plu uzos tion, sed ŝargos la artikolon per JS HTTPRequest.
if ($senkadroj == 2) 
{
  print header(-charset=>'utf-8');

  open IN, "<", "../revo/art/$art.html" or die "open html";
  while (<IN>) {
#    s/<\/title>/<\/title><script type="text\/javascript"><!--\nscroll(0,0);\n\/\/--><\/script>/;
     s/(\[<a class="redakto" href="\/cgi-bin\/vokomail)(\.pl\?art=[a-z0-9]+">)(redakti)(\.\.\.<\/a>\])/$1\l$2$3$4\n$1\l2$2traduki$4/;
    s/="\.\.\//="..\/revo\//g;
#    s/(href=")(#)/$1..\/revo\/art\/$art.html$2/g;
    s/(href=")([^#.\/](?!ttp:\/\/))/$1..\/revo\/art\/$2/g;
    print;
  }
  close IN;
  exit 1;
}

my $JSCRIPT=<<END;
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
print <<EOD;
<td colspan="4" class="enhavo">
<a href="/revo/art/$art.html" target="precipa">Hazarda artikolo.</a>
</td>
EOD

print <<"EOD";
<script type="text/javascript">
<!--
open('/revo/art/$art.html', 'precipa');
//-->
</script>
EOD

$dbh->disconnect() or die "DB-malkonekto ne funkcias";
  
print end_table();
print end_html();

