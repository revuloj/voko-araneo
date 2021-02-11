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

print header(-type => 'text/plain', -charset => 'utf-8');

my $dbh = revodb::connect();
pluku_submeton();
$dbh->disconnect() if $dbh;

##############################

sub pluku_submeton {
    # malŝaltu aŭtomatan eraro-presadon(?)
    #$dbh->{PrintError} = 1;

    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov aŭ stato=ignor (por testo ni prenas 'ignor'...)
        my $select = $dbh->prepare("SELECT sub_id,sub_email,sub_cmd,sub_desc,sub_fname,sub_content "
            ."FROM submeto where sub_state IN ('nov','ignor') AND sub_type='xml' LIMIT 1");

        $select->execute();
        my $submeto = $select->fetchrow_hashref();
        print "From: ".$submeto->{'sub_email'}."\n\n";
        if ($submeto->{'sub_cmd'} eq 'aldono') {
            print $submeto->{'sub_cmd'}.": ".$submeto->{'sub_fname'}."\n\n";
        } else {
            print $submeto->{'sub_cmd'}.": ".$submeto->{'sub_desc'}."\n\n";
        }
        print $submeto->{'sub_content'};

        # marku la submeton por traktado
        if ($submeto->{"sub_state"} eq 'nov') {
            my $upd = $dbh->prepare("UPDATE submeto set sub_state='trakt' WHERE sub_id=?");
            $upd->execute($submeto->{'sub_id'});               
        }

        $dbh->commit(); 
    }; 
    
    if ($@) { 
        warn "Transaction aborted: $@"; 
        eval { $dbh->rollback() }; # in case rollback() fails 
        # do your application cleanup here 
    } 
}
