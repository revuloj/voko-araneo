#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use Cwd;
use IO::Handle;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
use art_db; # r3 - tezaŭro
# use revorss;
use revodb;

my $exitcode;
my $db_verbose = 1;

print header,
      start_html('Sendu sxangxitajn pagxojn'),
      h1('fname='.param('fname'));


my $fname = param('fname');

my $homedir = "/hp/af/ag/ri";
#print h1("homedir = $homedir");
open LOG, ">>$homedir/files/log/uprevo.log" or die("ne eblas skribi log");	
autoflush LOG 1;

$ret = `du -sh $homedir`;
print LOG "du -> $exitcode\n$ret\n";
print pre($ret);

my $htmldir = "$homedir/www";
my $revodir = "$htmldir/revo";
my $xmldir = "$revodir/xml";

$ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
#print h1("LD_LIBRARY_PATH = ".$ENV{'LD_LIBRARY_PATH'});
$ENV{'PATH'} = $ENV{'PATH'}.":$homedir/files/bin";
#print h1("PATH = ".$ENV{'PATH'});

print LOG "uprevo started at ".localtime()." with fname=$fname\n";
unless ($fname =~ /^revo-\d\d\d\d\d\d\d\d_\d\d\d\d\d\d\.tgz$/) {
  print LOG "Nevalidaj parametroj\n\n";
  print h1("Nevalidaj parametroj"), end_html;
  exit 1;
}

my $dbfname = $fname;
$dbfname =~ s/^revo-(.*)_\d\d\d\d\d\d\.tgz$/revodb-$1.sql.gz/;
print LOG "dbfname -> $dbfname\n";

my $ret;

chdir $htmldir or die "chdir ne funkciis";

$ret = `rm bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
print LOG "rm bv_forigu_tiujn.lst -> $exitcode\n";

$ret = `tar -xvzf alveno/$fname revo/eta revo/dtd revo/art revo/hst tgz revo/xml revo/xsl revo/cfg revo/tez revo/bld revo/stl revo/jsc revo/smb revo/dok revo/inx revo/index.html revo/sercxo.html revo/titolo.html revo/revo.ico revo/revo.jpg revo/revo.gif revo/travidebla.gif bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
print h2("tar -xv -> $exitcode");
print LOG "tar -xv -> $exitcode\n$ret";
print pre($ret);
# revorss::write($ret, $htmldir, -1, 0);

chdir $xmldir or die "chdir revo ne funkciis";
my @arts;
while ($ret =~ m/revo\/xml\/([^.\s]+)\.xml/gm) {
  push @arts, $1;
}

# aktualigu la informojn pri la artikolo en la datumbazo
my $dbh = revodb::connect();
art_db::process($dbh,\@arts,$db_verbose);
$dbh->disconnect() or die "DB-fermo ne funkcias";

chdir $htmldir or die "chdir html ne funkciis";

########### forigi ##############

### PLIBONIGU: ankaŭ voku call forigu_art(*) por forigi ilin el la datumbazo!

$ret = `ls -l bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
#print h2("ls -> $exitcode");
print LOG "forigi: ls -> $exitcode\n$ret";
#print pre($ret);

$ret = `pwd 2>&1`;
$exitcode = $?;
#print h2("pwd -> $exitcode");
print LOG "pwd -> $exitcode\n$ret";
#print pre($ret);

if (open IN, "<bv_forigu_tiujn.lst") {
#  print h2("open true");
  my $count = 0;
  while (<IN>) {
    chomp;
    if ((/^revo\// or /^tgz\//) and not /\.\./ and not / / and not /\*/ and not /\?/ and not /^$/) {
      print h2("forigi $_");
      print LOG "forigi $_\n";
      my $ret = unlink $_;
      $count += $ret;
      print h2("forigi $_ malsukcesis") if !$ret;
      print LOG "forigi $_ malsukcesis\n" if !$ret;
    } else {
      print h2("nelegala $_");
      print LOG "nelegala $_\n";
    }
  }
  print h2("forigis: $count");
  print LOG "forigis: $count\n";
  close IN;

}

$ret = `cat bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
#print h2("cat -> $exitcode");
print LOG "cat -> $exitcode\n$ret";
print pre($ret);

print LOG "date: ".`date`."\n";

$ret = `du -sh $homedir`;
#print h2("du -> $exitcode");
print pre($ret);

my $findargs = "$htmldir/alveno -mtime +7 -name \\*gz";
$ret = `find $findargs`;
print LOG "find $findargs -> \n$ret\n";
$ret = `find $findargs | xargs rm`;
print LOG "find rm -> \n$ret\n";

$findargs = "$htmldir/alveno -mtime +2 -name revodb\\*gz";
$ret = `find $findargs`;
print LOG "find $findargs -> \n$ret\n",
$ret = `find $findargs | xargs rm`;
print LOG "find rm -> \n$ret\n";

print LOG "normala fino de uprevo.pl\n\n";
print end_html;

close LOG;

1;
