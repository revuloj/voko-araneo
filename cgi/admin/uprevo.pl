#!/usr/bin/perl

# (c) 2023-2026 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0

############################################
# Ŝanĝitaj / forigendaj dosieroj sendiĝas de Formiko (voko-formiko/ant/spegulo.xml)
# kiel tgz-arĥivo. Poste ĝi vokas per HTTP tiun ĉi skripton por malpaki ĉiujn kaj
# eventuale forigi dosierojn en listo bv_forigu_tiujn.lst
# En la fino ni ankoraŭ forigos ĉiujn arĥivojn pli malnovajn ol 7 tagojn

use warnings; use strict;
use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);
use Cwd;
use IO::Handle;
use Log::Dispatch; use Log::Dispatch::FileRotate;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use art_db; # r3 - tezaŭro
# use revorss;
use revodb;

my $exitcode;
my $loglevel = 'info';
my $db_verbose = 1;

my $homedir = "/hp/af/ag/ri";
my $htmldir = "$homedir/www";
my $revodir = "$htmldir/revo";
my $xmldir = "$revodir/xml";

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

my $fname = param('fname');
# kontrolu ĉu la malpakenda arĥivdosiero ekzistas
if (! -s "$htmldir/alveno/$fname") {
  print header(-status => '404 Not Found', -type => 'text/html');
  exit;
}

print header,
      start_html('Sendu sxangxitajn pagxojn'),
      h1('fname='.param('fname'));

#print h1("homedir = $homedir");

local $ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
#print h1("LD_LIBRARY_PATH = ".$ENV{'LD_LIBRARY_PATH'});
local $ENV{'PATH'} = $ENV{'PATH'}.":$homedir/files/bin";
#print h1("PATH = ".$ENV{'PATH'});

#open my $log, '>>', "$homedir/files/log/uprevo.log" or die("Ne eblas skribi protokolon 'uprevo.log'\n");
#autoflush $log 1;

## no critic (InputOutput::ProhibitBacktickOperators)
$ret = `du -sh $homedir`;

#print $log "du -> $exitcode\n$ret\n";
$log->info("### du -> $exitcode\n$ret\n");


print pre($ret);

$log->info(">>> EKO de uprevo.pl JE ".localtime()." kun fname=$fname\n");
unless ($fname =~ m{^
    revo-
    \d\d\d\d\d\d\d\d_ # dato
    \d\d\d\d\d\d      # tempo
    \.tgz
  $}x) {
  $log->error("Nevalidaj parametroj\n\n");
  print h1("Nevalidaj parametroj"), end_html;
  exit 1;
}

my $dbfname = $fname;
$dbfname =~ s{^
  revo-(.*)_
  \d\d\d\d\d\d
  \.tgz
  $}
  {revodb-$1.sql.gz}x;
$log->info("dbfname -> $dbfname\n");

my $ret;

chdir $htmldir
  or die "'chdir $htmldir' ne funkciis\n";

$ret = `rm bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
$log->info("rm bv_forigu_tiujn.lst -> $exitcode\n");

$ret = `tar -xvzf alveno/$fname revo/eta revo/dtd revo/art revo/hst tgz revo/xml revo/xsl revo/cfg revo/tez revo/bld revo/stl revo/jsc revo/smb revo/dok revo/inx revo/index.html revo/sercxo.html revo/titolo.html revo/revo.ico revo/revo.jpg revo/revo.gif revo/travidebla.gif bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
print h2("tar -xv -> $exitcode");
$log->info("tar -xv -> $exitcode\n$ret");
print pre($ret);
# revorss::write($ret, $htmldir, -1, 0);

chdir $xmldir
  or die "'chdir $xmldir' ne funkciis\n";
my @arts;
while ($ret =~ m{
    revo/xml/
    ([^.\s]+)
    \.xml
  }gmx) {
  push @arts, $1;
}

# aktualigu la informojn pri la artikolo en la datumbazo
my $dbh = revodb::connect();
art_db::process($dbh,\@arts,$db_verbose);
$dbh->disconnect() or die "DB-fermo ne funkcias\n";

chdir $htmldir or die "'chdir $htmldir' ne funkciis\n";

########### forigi ##############

### PLIBONIGU: ankaŭ voku call forigu_art(*) por forigi ilin el la datumbazo!

$ret = `ls -l bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
#print h2("ls -> $exitcode");
$log->info("forigi: ls -> $exitcode\n$ret");
#print pre($ret);

$ret = `pwd 2>&1`;
$exitcode = $?;
#print h2("pwd -> $exitcode");
$log->info("pwd -> $exitcode\n$ret");
#print pre($ret);

if (open my $in, '<', "bv_forigu_tiujn.lst") {
#  print h2("open true");
  my $count = 0;
  while (<$in>) {
    chomp;
    if (m{^(?:
        revo|tgz
      )/}x
    and not m{(?:
      \.\.
      |[\s\*\?]
    )}x and not m{^$}x) {

      print h2("forigi $_");
      $log->info("forigi $_\n");

      my $for = unlink $_;
      $count += $for;
      print h2("forigi $_ malsukcesis") if !$for;
      $log->warn("forigi $_ malsukcesis\n") if !$for;

    } else {
      print h2("ne permesita $_");
      $log->warn("ne permesita $_\n");
    }
  }
  close $in;

  print h2("forigis: $count");
  $log->info("forigis: $count\n");
}

$ret = `cat bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
#print h2("cat -> $exitcode");
$log->info("cat -> $exitcode\n$ret");
print pre($ret);

$log->info("date: ".`date`."\n");

$ret = `du -sh $homedir`;
#print h2("du -> $exitcode");
print pre($ret);

### forigu arĥivojn malnovajn je pli ol 7 tagoj
my $findargs = "$htmldir/alveno -mtime +7 -name \\*gz";
$ret = `find $findargs`;
$log->info("find $findargs -> \n$ret\n");

$ret = `find $findargs | xargs rm`;
$log->info("find rm -> \n$ret\n");

### forigu arĥivojn revodb*.gz malnovajn je pli ol 3 tagoj
# (tio ne plu devus okazi!)
#$findargs = "$htmldir/alveno -mtime +2 -name revodb\\*gz";
#$ret = `find $findargs`;
#$log->info("find $findargs -> \n$ret\n");
#
#$ret = `find $findargs | xargs rm`;
#$log->info("find rm -> \n$ret\n");

$log->info("<<< FINO de uprevo.pl\n\n");
print end_html;

1;
