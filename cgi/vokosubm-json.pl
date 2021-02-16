#!/usr/bin/perl

# (c) 2021 ĉe Wolfram Diestel
# laŭ GPL 2.0

use strict;
use utf8;

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI();

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/

use revodb;

my $debug = 0; #0|1;
my $max_results = 20;

print header(-type => 'application/json', -charset => 'utf-8');

my $dbh = revodb::connect();
$dbh->{'mysql_enable_utf8'}=1;
$dbh->do("set names utf8");

if (param('email')) {
    redakto_statoj();
} 

$dbh->disconnect() or die "Malkonekto de la datumbazo ne funkciis";


sub redakto_statoj {

    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov aŭ stato=ignor (por testo ni prenas 'ignor'...)
        my $select = $dbh->prepare("SELECT JSON_OBJECT('id', sub_id, 'fname', sub_fname, 'state', sub_state, 'time', "
            ."sub_time, 'desc', sub_desc,'result', sub_result) AS subm "
            ."FROM submeto WHERE sub_email=? ORDER BY sub_time DESC LIMIT ?");
        # PLIBONIGU: trovu ankaŭ samredaktorajn submetojn kun alternativaj retadresoj:
        # JOIN email ON sub_email = ema_email AND...?

        my $email = param('email');
        $select->execute($email,$max_results);

        print "[\n";
        my $submeto = $select->fetchrow_arrayref();
        my $first = 1;

        #print $submeto->[0];
        while ($submeto) {
            unless ($first) {
                print ",\n"
            } else {
                $first = 0;
            }
            # ial mysql aldonas en la linirompojn en la bas64-kodita kampo "results"
            $submeto->[0] =~ s/\n//g;
            print $submeto->[0];
            $submeto = $select->fetchrow_arrayref();
        }
        print "\n]\n";
    }; 
    
    if ($@) { 
        warn "Datumbaza eraro: $@"; 
        # eval { $dbh->rollback() }; # in case rollback() fails 
        # cleanup here 
    } 
}