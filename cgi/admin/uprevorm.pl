#!/usr/bin/perl

# (c) 2023-2026 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0

# La aktualigaj tar-arĥivoj, kiujn ni sendas el redaktoservo (formiko) enhavas
# liston de dosieroj forigendajn: bv_forigu_tiujn.lst
# tiu-ĉi skripto malpkas nur tiun liston kaj forigas la listigitajn dosierojn

use warnings; use strict;
use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);
use Cwd;
use IO::Handle;

use Log::Dispatch; use Log::Dispatch::FileRotate;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");

my $exitcode;
my $loglevel = 'info';

print header,
      start_html('Sendu shanghitajn paghojn'),
      h1('fname='.param('fname'));

my $homedir = "/hp/af/ag/ri";
#print h1("homedir = $homedir");

my $log = Log::Dispatch->new(
    outputs => [
        #[ 'File', min_level => $loglevel, filename => "$homedir/files/log/uprevo.log" ]
        #[ 'Screen', min_level => $loglevel ],
    ],
);
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

#open my $log, '>>', "$homedir/files/log/uprevo.log" or die("ne eblas skribi log");	
#autoflush $log 1;

my $fname = param('fname');
my $htmldir = "$homedir/www";

local $ENV{'PATH'} = $ENV{'PATH'}.":$homedir/files/bin";

$log->info(">>> EKO DE uprevorm.pl je ".localtime()." with fname=$fname\n");
unless ($fname =~ m{^
    revo-
    \d{8} # dato
    \.tgz
  $}x) {
  $log->error("Nevalidaj parametroj\n");
  print h1("Nevalidaj parametroj"), end_html;
  exit 1;
}

my $ret;

chdir $htmldir or die "'chdir $htmldir' ne funkciis\n";


########### forigi ##############

### PLIBONIGU: ankaŭ voku call forigu_art(*) por forigi ilin el la datumbazo!

$ret = `pwd 2>&1`;
$exitcode = $?;
#print h2("pwd -> $exitcode");
$log->info("pwd -> $exitcode\n$ret");
#print pre($ret);

if (open my $in, '-|', "tar", "-xOzf","alveno/$fname","bv_forigu_tiujn.lst") {
  my @forigendaj = <$in>;
  close $in;

#  print h2("open true");
  my $count = 0;
  for (@forigendaj) {
    chomp;
    if (m{^(?:
        revo|tgz
      )/}x
    and not m{(?:
        \.\.
        |[\s\*\?]
      )}x 
    and not m{^$}x) {

      print h2("forigi $_");
      $log->info("forigi $_\n");

      my $for = unlink $_;
      $count += $for;
      print h2("forigi $_ malsukcesis: $!") if !$for;
      $log->warn("forigi $_ malsukcesis: $!\n") if !$for;

    } else {
      print h2("ne permesita $_");
      $log->warn("ne permesita $_\n");
    }
  }

  print h2("forigis: $count");
  $log->info("forigis: $count\n");
}

$log->info("<<< FINO de uprevorm.pl\n");
print end_html;

close $log;

1;
