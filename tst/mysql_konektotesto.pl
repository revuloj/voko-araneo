#!/usr/bin/perl

use ExtUtils::Installed;

use lib("/hp/af/ag/ri/files/perllib");
use revodb;


my $installed = ExtUtils::Installed->new();
my @modules = $installed->modules();


print "# PERL: ".$]."\n";
print "Module\tVersion\n";
foreach (@modules) {
    print $_ . "\t" . $installed->version($_) . "\n";
}


# Connect to the database.
my $dbh = revodb::connect();


$dbh->{'mysql_enable_utf8'}=1;
# $dbh->do("set names utf8");


@SQL = (
   # SHOW VARIABLES;
    # show session variables;
    "show session variables where variable_name like 'character%'",
    "set names utf8mb4",
    "show session variables where variable_name like 'character%'",
    "SELECT d.mrk, d.kap FROM r3kap d WHERE LOWER(d.kap) LIKE 'ru_a'",
    "show session variables",
);

for $sql (@SQL) {
    print "\n# $sql\n";

    if ($sql =~ /^set/i) {
        $dbh->do($sql)
    } else {   

        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (my @vals = $sth->fetchrow_array()) {
            print join("; ",@vals);
            print "\n";
        }
    }
}

$dbh->disconnect() or die "DB disconnect ne funkcias";

