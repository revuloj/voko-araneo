#!/usr/bin/perl

# La aktualigaj tar-arĥivoj, kiujn ni sendas el redaktoservo (formiko) enhavas
# liston de dosieroj forigendajn: bv_forigu_tiujn.lst
# tiu-ĉi skripto malpkas nur tiun liston kaj forigas la listigitajn dosierojn

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use Cwd;
use IO::Handle;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");

my $exitcode;

print header,
      start_html('Sendu sxangxitajn pagxojn'),
      h1('fname='.param('fname'));

my $homedir = "/hp/af/ag/ri";
#print h1("homedir = $homedir");
      
open LOG, ">>$homedir/files/log/uprevo.log" or die("ne eblas skribi log");	
autoflush LOG 1;

my $fname = param('fname');


my $htmldir = "$homedir/www";

$ENV{'PATH'} = $ENV{'PATH'}.":$homedir/files/bin";

print LOG "uprevorm started at ".localtime()." with fname=$fname\n";
unless ($fname =~ /^revo-\d\d\d\d\d\d\d\d\.tgz$/) {
  print LOG "Nevalidaj parametroj\n\n";
  print h1("Nevalidaj parametroj"), end_html;
  exit 1;
}

my $ret;

chdir $htmldir or die "chdir ne funkciis";

$ret = `rm bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
print h2("rm -> $exitcode");
print pre($ret);

$ret = `tar -xvzf alveno/$fname bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
print h2("tar -xv -> $exitcode");
print pre($ret);

$ret = `ls -l bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
print h2("ls -> $exitcode");
#print LOG "cat -> $exitcode\n$ret";
print pre($ret);

$ret = `pwd 2>&1`;
$exitcode = $?;
print h2("pwd -> $exitcode");
#print LOG "cat -> $exitcode\n$ret";
print pre($ret);

if (open IN, "<bv_forigu_tiujn.lst") {
#  print h2("open true");
  my $count;
  while (<IN>) {
    chomp;
    if ((/^revo\// or /^tgz\//) and not /\.\./ and not / / and not /\*/ and not /\?/ and not /^$/) {
      print h2("forigi $_");

      $ret = `ls -l "$_" 2>&1`;
      print pre($ret);

      my $ret = unlink $_;
      $count += $ret;
      print h2("forigi $_ malsucesis") if !$ret;
    } else {
      print h2("nelegala $_");
    }
  }
  print h2("forigis $count");
  close IN;

}

$ret = `cat bv_forigu_tiujn.lst 2>&1`;
$exitcode = $?;
print h2("cat -> $exitcode");
print LOG "cat -> $exitcode\n$ret";
print pre($ret);

print LOG "normala fino de uprevorm.pl\n\n";
print end_html;

close LOG;

1;
