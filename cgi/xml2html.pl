#!/usr/bin/perl

#
# xml2html.pl
# 
# 2008-11-19 Wieland Pusch
#
# testu ekz. per
# http://www.reta-vortaro.de/cgi-bin/xml2html.pl?art=test
# http://www.reta-vortaro.de/cgi-bin/xml2html.pl?art=v

use strict;

use CGI qw(:standard *table);
use CGI::Carp qw(fatalsToBrowser);
use IPC::Open3;

$| = 1;

my $homedir = "/var/www/web277";
my $revo_base    = "$homedir/html/revo";

$ENV{'LD_LIBRARY_PATH'} = '/var/www/web277/files/lib';
$ENV{'PATH'} = "$ENV{'PATH'}:/var/www/web277/files/bin";


my $debugmsg;
my $art = param('art');

print "Content-Type: text/html\n\n";

my $mb = " " x (1024 * 1024);
my $dummy = $mb x param('mb');
my $html;

if ($art) {
  my $xml;

  if ($art eq "v") {
    print "xalan:\n";
    my $r = `sh -c "ulimit -a" 2>&1`;
    print pre($r);
    exit;
#    my $r = `xalan -V 2>&1`;
#    print pre($r);
#    exit;
#    my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
#                      "xalan -V");
  } else {
    open IN, "<", "$homedir/html/revo/xml/$art.xml" or die "open";
    $xml = join '', <IN>;
    close IN;

    my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                      "xalan -XSL $homedir/html/revo/xsl/revohtml.xsl");
  }
  print CHLD_IN $xml;
  close CHLD_IN;
  my $err = join('', <CHLD_ERR>);
#  print pre("err=$err") if $err;
  close CHLD_ERR;
  $html = join('', <CHLD_OUT>);
  close CHLD_OUT;

  $html =~ s#href="../stl/#href="/revo/stl/#smg;
  $html =~ s#src="../smb/#src="/revo/smb/#smg;
  $html =~ s#src="../bld/#src="/revo/bld/#smg;
} else {
  $html = h2("kein art");
}

print $html;

