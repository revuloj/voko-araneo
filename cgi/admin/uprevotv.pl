#!/usr/bin/perl

# (c) 2023-2026 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0

# Tiu-ĉi skripto listigas la enhavon de la aktualigaj tar-arĥivoj, kiujn ni sendas (tar -tv ...)
# sen malpaki la enhavon

use warnings; use strict;

use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);
use Cwd;
use IO::Handle;

use Log::Dispatch; use Log::Dispatch::FileRotate;

# propraj perl moduloj estas en:
##use lib("/hp/af/ag/ri/files/perllib");

my $exitcode;
my $loglevel = 'info';

print header,
      start_html('Sendu sxangxitajn pagxojn'),
      h1('fname='.param('fname'));

my $homedir = "/hp/af/ag/ri";
#print h1("homedir = $homedir");


my $log = Log::Dispatch->new(
    outputs => [
        #[ 'File', min_level => $loglevel, filename => "$homedir/files/log/uprevo.log" ]
        #[ 'Screen', min_level => $loglevel ],
    ],
);
# apt install liblog-dispatch-filerotate-perl
$log->add(Log::Dispatch::FileRotate->new(
    name      => 'uprevo.log',
    min_level => $loglevel,
    filename  => "$homedir/files/log/uprevo.log",
    mode      => 'append' ,
    TZ        => 'UTC',
    DatePattern => 'yyyy-dd-HH'),
    max       => 31,
    size      => 10 * 1024 * 1024
) or die("Ne eblas skribi protokolon 'uprevo.log'\n");

my $fname = param('fname');

## no critic (InputOutput::ProhibitBacktickOperators)

my $ret = `du -sh $homedir`;
print h2("du -> $exitcode");
print pre($ret);

my $htmldir = "$homedir/www";

#$ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
#print h1("LD_LIBRARY_PATH = ".$ENV{'LD_LIBRARY_PATH'});
local $ENV{'PATH'} = $ENV{'PATH'}.":$homedir/files/bin";
#print h1("PATH = ".$ENV{'PATH'});

$log->info(">>> EKO uprevotv.pl je ".localtime()." with fname=$fname\n");
unless ($fname =~ m{^
    revo-
    \d{8} # dato
    _\d{6} # tempo
    \.tgz$
  }x) {
  $log->error("Nevalidaj parametroj\n");
  print h1("Nevalidaj parametroj"), end_html;
  exit 1;
}

chdir $htmldir or die "'chdir $htmldir' ne funkciis: $!\n";

## $ret = `tar -tvzf alveno/$fname revo/art revo/hst revo/xml revo/cfg revo/tez revo/bld revo/inx 2>&1`;
## $exitcode = $?;
## print h2("tar -tv alveno/$fname revo/art revo/hst revo/xml revo/cfg revo/tez revo/bld revo/inx -> $exitcode");
## $log->info("tar -tv -> $exitcode\n$ret");
## print pre($ret);

$ret = `tar -tvzf alveno/$fname 2>&1`;
$exitcode = $?;
print h2("tar -tv -> $exitcode");
$log->info("tar -tv -> $exitcode\n$ret");
print pre($ret);

$log->info("<<< FINO de uprevotv.pl\n");
print end_html;

1;
