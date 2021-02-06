#!/usr/bin/perl

# 2008 Wieland Pusch
# 2020 Wolfram Diestel

use strict;
use utf8;

#use CGI qw(:standard *table);
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();

use IPC::Open3; # uzata de xml2html.pm
use Encode;

# propraj perl moduloj estas en:
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/
use lib("/hp/af/ag/ri/files/perllib");
### use revo::xml2html;
use revodb;

#$| = 1;
my $debug = 0;

# por testi vi povas aldoni simbolan ligon:  ln -s /home/revo /hp/af/ag/ri/www
my $homedir    = "/hp/af/ag/ri";
my $htmldir    = "$homedir/www";
my $revo_base  = "$homedir/www/revo";
my $xml_dir    = "$revo_base/xml";

my $xsltproc = "xsltproc --path $revo_base/cfg $homedir/files/xsl/revohtml.xsl -";

$ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
$ENV{'PATH'} = "$ENV{'PATH'}:$homedir/files/bin";
$ENV{'LOCPATH'} = "$homedir/files/locale";
#autoEscape(0);

## parametroj...
my $xmlTxt = param('xmlTxt');
#my $mrk = param('mrk');

# ne servu ion ajn, se mankas la XML-teksto...
unless ($xmlTxt) {
  exit;
}    

# Konektiĝu al la datumbazo...
# konvx uzas la datumbazon por enŝovi tezaŭro-referencojn
my $dbh = revodb::connect();

binmode STDOUT, ":utf8";
print header(-charset=>'utf-8',
             -pragma => 'no-cache', '-cache-control' =>  'no-cache');

# konvertu XML al HTML por la antaŭrigardo...
chdir($xml_dir) or die "Mi ne povas atingi dosierujon ".$xml_dir;
  #my $htm2;
  #if (revo::xml2html::konv($dbh, $xml, \$htm2, $err, $debug)) {
    #$htm2 =~ m/<body>(.*)<\/body>/s;
    #$$html = $1;
my ($html,$err);
### revo::xml2html::konv($dbh, \$xmlTxt, \$html, \$err, $debug);
konv($dbh, \$xmlTxt, \$html, \$err, $debug);

$err =~ s/^Warning[^\n]+\n//mg;

if ($err) { # ???
  print "<html><body><div>";
  print pre(escapeHTML($err));
  print "</div></body></html>\n"
} else {
  print $html;
}

$dbh->disconnect() if ($dbh);

###################################################################

sub konv {
  my ($dbh, $xml, $html, $err, $debug) = @_;

  if (not ref $xml) {
    open IN, "<", $xml or die;
    my $xmltmp = join "", <IN>;
    $xml = \$xmltmp;
    close IN;
  }
  
  my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                      "$xsltproc");
  print CHLD_IN $$xml;
  close CHLD_IN;

#  binmode CHLD_OUT, ":utf8";
  my $enc = "utf-8";
  $$html = Encode::decode($enc, join('', <CHLD_OUT>));
  close CHLD_OUT;
  $$err = join('', <CHLD_ERR>);
  close CHLD_ERR;

  {
    $$html =~ s#<!DOCTYPE .*?>##sm;
    my $sth = $dbh->prepare("SELECT count(*) FROM r2_tezauro WHERE tez_fontref = ? or (tez_celref = ? and tez_tipo in ('sin','vid'))");
    while ($$html =~ m#<!--\[\[\s*ref="(.*?)"\s*\]\]-->\s*#smg) {
        my $ref = $1;
        $sth->execute($1,$1);
        my ($tez_ekzistas) = $sth->fetchrow_array();
        
        if ($tez_ekzistas) {
          $ref =~ tr/./_/;
          $$html =~ s##<a href="/revo/tez/tz_$ref.html" target="indekso" class="tez-ref" title="al la tezaŭro">↝</a>#;
      } else {
          $$html =~ s###;
      }
    }
  }
  
  return 1;
} 
    