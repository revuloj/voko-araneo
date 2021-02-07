#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use ExtUtils::Installed;

use lib("/hp/af/ag/ri/files/perllib");
use revodb;

print header(-charset=>'utf-8');

my $installed = ExtUtils::Installed->new();
my @modules = $installed->modules();


print "<pre>";
print "# PERL: ".$]."\n";
print "Module\tVersion\n";
foreach (@modules) {
    print $_ . "\t" . $installed->version($_) . "\n";
}


# Connect to the database.
my $dbh = revodb::connect();

# https://rolfrost.de/dbiutf8.html
# https://stackoverflow.com/questions/1650591/whether-to-use-set-names
# https://medium.com/@manish_demblani/breaking-out-from-the-mysql-character-set-hell-24c6a306e1e5
# https://medium.com/@adamhooper/in-mysql-never-use-utf8-use-utf8mb4-11761243e434

# https://jira.mariadb.org/browse/MDEV-18281
# https://stackoverflow.com/questions/2880971/connection-reset-on-mysql-query

$dbh->{'mysql_enable_utf8'}=1;
# $dbh->do("set names utf8");

#(2)No such file or directory: AH01620: Could not open password file: /var/www/web277/html/cgi-bin/admin/.htpasswd

@SQL = (
   # SHOW VARIABLES;
    # show session variables;
    "show session variables where variable_name like 'character%'",
    "set names utf8mb4",
    "show session variables where variable_name like 'character%'",
    "SELECT d.drv_mrk, d.drv_teksto FROM drv d WHERE LOWER(d.drv_teksto) LIKE 'ru_a'",
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

print "</pre>";