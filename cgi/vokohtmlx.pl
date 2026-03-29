#!/usr/bin/perl

# 2008 Wieland Pusch
# 2020-2026 Wolfram Diestel

use warnings; use strict; use utf8;

use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);

use IPC::Open3; # uzata de xml2html.pm
use Encode;

my $debug = 0;

# por testi vi povas aldoni simbolan ligon:  ln -s /home/revo /hp/af/ag/ri/www
my $homedir    = "/hp/af/ag/ri";
my $htmldir    = "$homedir/www";
my $revo_base  = "$homedir/www/revo";
my $xml_dir    = "$revo_base/xml";

my $xsltproc = "xsltproc --path $revo_base/cfg $homedir/files/xsl/revohtml.xsl -";

# ni uzas meminstalitan xsltproc, kiu bezonas trovi siajn partojn
# laŭ apartaj padoj:
local $ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
local $ENV{'PATH'} = "$ENV{'PATH'}:$homedir/files/bin";
local $ENV{'LOCPATH'} = "$homedir/files/locale";

## parametroj...
my $xmlTxt = param('xmlTxt');

# ne servu ion ajn, se mankas la XML-teksto...
unless ($xmlTxt) {
  exit;
}    

use open ':std', ':encoding(UTF-8)';
## binmode STDOUT, ":utf8";

print header(-charset=>'utf-8',
             -pragma => 'no-cache', '-cache-control' =>  'no-cache');

# konvertu XML al HTML por la antaŭrigardo...
chdir($xml_dir) or die "Mi ne povas atingi dosierujon $xml_dir: $!\n";
my ($html,$err);
konv(\$xmlTxt, \$html, \$err, $debug);

$err =~ s{
  ^Warning[^\n]+\n
}{}mgx;

if ($err) { # ???
  print "<html><body><div>";
  print pre(escapeHTML($err));
  print "</div></body></html>\n"
} else {
  print $html;
}


###################################################################

sub konv {
  my ($xml, $html_, $err_, $dbg) = @_;

  if (not ref $xml) {
    open my $in, "<", $xml or die "Ne povis malfermi $xml: $!\n";
    my $xmltmp = do { local $/ = undef; <$in> };
    $xml = \$xmltmp;
    close $in;
  }
  
  my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                      "$xsltproc");
  binmode(CHLD_IN, ":encoding(UTF-8)");               
  print CHLD_IN $$xml;
  close CHLD_IN;

#  binmode CHLD_OUT, ":utf8";
  my $enc = "utf-8";
  $$html_ = Encode::decode($enc, do { local $/ = undef; <CHLD_OUT>});
  close CHLD_OUT;
  $$err_ = do { local $/ = undef; <CHLD_ERR>};
  close CHLD_ERR;

  {
    $$html_ =~ s{<!DOCTYPE\s+.*?>}{}smx;
  }
  
  return 1;
} 
    