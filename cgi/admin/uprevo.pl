#!/usr/bin/perl

# (c) 2023-2026 ĉe Wolfram Diestel
# laŭ permesilo GPL 2.0

############################################
# Ŝanĝitaj / forigendaj dosieroj sendiĝas de Formiko 
# kiel tgz-arĥivo. Poste ĝi vokas per HTTP tiun ĉi skripton por malpaki ĉiujn kaj
# eventuale forigi dosierojn en listo bv_forigu_tiujn.lst
# vd. (voko-formiko/ant/spegulo.xml:revo-upload2)
#
# En la fino ni ankoraŭ forigos ĉiujn arĥivojn pli malnovajn ol 7 tagojn
#
# kun kmd=nur_listigu la enhavo de la arĥivo estas listigita, sed ne malpakita
# kun kmd=nur_forigu ni ne malpakas novajn/ŝanĝitaj dosierojn, sed nur forigas dosierojn de la listo bv_forigu_tiujn.lst

use warnings; use strict;
use CGI qw(:standard); use CGI::Carp qw(fatalsToBrowser);
use Cwd;
use IO::Handle;

# debian/ubuntu: libipc-run-perl
use IPC::Run qw(run); 

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");

# apt install liblog-dispatch-perl liblog-dispatch-filerotate-perl
use Log::Dispatch; use Log::Dispatch::FileRotate;

use art_db; # r3 - tezaŭro
# use revorss;
use revodb;

my $loglevel = 'info';
my $db_verbose = 1;

my $homedir = "/hp/af/ag/ri";
my $htmldir = "$homedir/www";
my $revodir = "$htmldir/revo";
my $xmldir = "$revodir/xml";

my $log = make_log();

### tgz-arĥivo traktenda
my $fname = param('fname');
# kontrolu ĉu la malpakenda arĥivdosiero ekzistas
if (! -s "$htmldir/alveno/$fname") {
  print header(-status => '404 Not Found', -type => 'text/html');
  exit;
}

# povas esti alternative nur_listigu | nur_forigu
my $kmd = param('kmd') || 'malpaku';
my @ujoj = qw(revo/art revo/hst revo/xml revo/cfg revo/tez revo/bld revo/inx); # malpaku nur tiujn
my @tar_cmd = (qw(/bin/tar -xvzf), "alveno/$fname", @ujoj);

if ($kmd eq 'nur_listigu') {
  @tar_cmd = (qw(/bin/tar -tvzf), "alveno/$fname"); # listigu ĉion
  @ujoj = (); 
}

print header,
      start_html('Sendu sxangxitajn pagxojn'),
      h1('fname='.param('fname'));

#print h1("homedir = $homedir");

local $ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
#print h1("LD_LIBRARY_PATH = ".$ENV{'LD_LIBRARY_PATH'});
local $ENV{'PATH'} = $ENV{'PATH'}.":$homedir/files/bin";
#print h1("PATH = ".$ENV{'PATH'});

$log->info(">>> EKO de uprevo.pl JE ".localtime()." kun fname=$fname\n");

disk_usage();
check_fname($fname);

# montru/malpaku la tar-arĥivon
chdir $htmldir
  or die "'chdir $htmldir' ne funkciis\n";

my $tar_out = sys_run(@tar_cmd);

print h2(join(' ',@tar_cmd));
print pre($tar_out);

# traktu JSON-dosierojn samnomajn kiel XML-dosierojn
# kaj aktualigu per ili la enhavon de la datumbazo 
if ($kmd eq 'malpaku' && $tar_out) {
  art_db($tar_out);
}

# forigu dosierojn el la listo
if ($kmd eq 'malpaku' || $kmd eq 'nur_forigu') {
  bv_forigu();
}

$log->info("dato: ".sys_run_nolog('date'));

### forigu arĥivojn malnovajn je pli ol 7 tagoj
if ($kmd eq 'malpaku' || $kmd eq 'nur_forigu') {
  forigu_malnovajn();
  disk_usage();
}

$log->info("<<< FINO de uprevo.pl\n\n");
print end_html;

#############################

sub make_log {

  my $logger = Log::Dispatch->new(
      outputs => [
          #[ 'File', min_level => $loglevel, filename => "$homedir/files/log/uprevo.log" ]
          #[ 'Screen', min_level => $loglevel ],
      ],
  );
  $logger->add(Log::Dispatch::FileRotate->new(
      name      => 'uprevo.log',
      min_level => $loglevel,
      filename  => "$homedir/files/log/uprevo.log",
      mode      => 'append' ,
      TZ        => 'UTC',
      DatePattern => 'yyyy-dd-HH'),
      max       => 31,
      size      => 10 * 1024 * 1024
  ) or die("Ne eblas skribi protokolon 'uprevo.log'\n");

  return $logger;
}

sub disk_usage {
  my $du_out = sys_run(qw(du -sh), $homedir);
  print pre($du_out);
  return;
}

sub check_fname {
  my $fn = shift;

  unless ($fn =~ m{^
      revo-
      \d\d\d\d\d\d\d\d_ # dato
      \d\d\d\d\d\d      # tempo
      \.tgz
    $}x) {
    $log->error("Nevalidaj parametroj\n\n");
    print h1("Nevalidaj parametroj"), end_html;
    exit 1;
  }

  return;
}

sub art_db {
  my $files = shift;

  chdir $xmldir
    or die "'chdir $xmldir' ne funkciis\n";

  # por ĉiuj XML-dosieroj en la tar-arĥivo ni traktas ankaŭ 
  # samnoman JSON-dosieron por aktualigi la datumbazon.  
  my @arts;
  while ($files =~ m{
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
  return;
}

sub bv_forigu {

  chdir $htmldir or die "'chdir $htmldir' ne funkciis\n";

  ########### forigi ##############

  ### PLIBONIGU: ankaŭ voku call forigu_art(*) por forigi ilin el la datumbazo!

  my $pwd_out = sys_run('pwd');  
  my $forigendaj = sys_run(qw(/bin/tar -xOzf), "alveno/$fname", 'bv_forigu_tiujn.lst');

#  print h2("open true");
  my $count = 0;
  for ( split(/\n/x, $forigendaj) ) {
    chomp;
    if (m{^revo/}x # forigu nur en dosierujoj ./revo/
    and not m{(?:
        \.\.        # ne permesu forigi en parencaj dosierujoj
        |[\s\*\?]   # ne permesu spacojn aŭ ĵokerojn de forigendaj dosiernomoj
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
  return;
}

sub forigu_malnovajn {
  my @find_cmd = ('/usr/bin/find',"$htmldir/alveno",qw(-mtime +7 -name \\*gz));

  my $find_out = sys_run(@find_cmd);

  # forigi dosierojn listigitajn en $find_out
  for ( split(/\n/x,$find_out) ) {
    chomp;
    unlink $_;
  }
  return;
}

sub sys_run {
  my @command = @_;

  my ($out, $err);
  run \@command, \undef, \$out, \$err or do {
    $log->error('['.join(' ',@command). "]: $!\n$err\n");
  };
  my $exit_code = $? >> 8;
  $log->info('['.join(' ',@command). "]:$out\n") unless ($exit_code);
  return $out;
}


sub sys_run_nolog {
  my @command = @_;

  my ($out, $err);
  run \@command, \undef, \$out, \$err or do {
    $log->error(join(' ',@command). ": $!\n$err\n");
  };
  return $out;
}