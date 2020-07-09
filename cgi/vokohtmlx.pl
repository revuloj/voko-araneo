#!/usr/bin/perl

# 2008 Wieland Pusch
# 2020 Wolfram Diestel

use strict;
use utf8;

#use CGI qw(:standard *table);
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();

# propraj perl moduloj estas en:
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /var/www/web277/files/
use lib("/var/www/web277/files/perllib");
use revo::xml2html;
use revodb;

#$| = 1;
#my $debug = 1;

# por testi vi povas aldoni simbolan ligon:  ln -s /home/revo /var/www/web277/html
my $homedir    = "/var/www/web277";
my $htmldir    = "$homedir/html";
my $revo_base  = "$homedir/html/revo";
my $xml_dir    = "$revo_base/xml";

$ENV{'LD_LIBRARY_PATH'} = '/var/www/web277/files/lib';
$ENV{'PATH'} = "$ENV{'PATH'}:/var/www/web277/files/bin";
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

# konvertu XML al HTML por la antaŭrigardo...
#my ($html, $err);
#konvx($dbh, \$xmlTxt, \$html, \$err, $xml_dir);
#print $html;
#konvx($dbh, \$xmlTxt, \STDOUT, \$err, $xml_dir);
chdir($xml_dir) or die "Mi ne povas atingi dosierujon ".$xml_dir;
  #my $htm2;
  #if (revo::xml2html::konv($dbh, $xml, \$htm2, $err, $debug)) {
    #$htm2 =~ m/<body>(.*)<\/body>/s;
    #$$html = $1;
my ($err);
revo::xml2html::konv($dbh, \$xmlTxt, \STDOUT, \$err, $debug));

if ($err) { # ???
  print "<div>$err</div>"
}

$dbh->disconnect() if $dbh;

