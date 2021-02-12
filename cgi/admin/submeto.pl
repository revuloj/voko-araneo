#!/usr/bin/perl

# (c) 2021 ĉe Wolfram Diestel
# laŭ GPL 2.0

use strict;
use utf8;

use CGI qw(:standard *pre);
use CGI::Carp qw(fatalsToBrowser);
use DBI();

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/

use revodb;

my $debug = 0; #0|1;

# ni povas postuli 'text', aliokaze redoniĝos html
if (param('id') || param('type') eq 'text') {
    print header(-type => 'text/plain', -charset => 'utf-8');
} else {
    print header(-charset=>'utf-8'),
        start_html(
            -dtd => ['-//W3C//DTD HTML 4.01 Transitional//EN','http://www.w3.org/TR/html4/loose.dtd'],
            -lang => 'eo',
            -title => 'submetoj'),
        start_pre(),
        "id;state;cmd;desc;fname\n";
}


my $dbh = revodb::connect();

if (param('id')) {
    pluku_submeton(param('id'));
} else {
    listigu_novajn();
};

$dbh->disconnect() if $dbh;


# finu HTML-on
if (param('id') || param('type') ne 'text') {
    print end_pre(), end_html();
}    

##############################

sub listigu_novajn {
    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov aŭ stato=ignor (por testo ni prenas 'ignor'...)
        my $select = $dbh->prepare("SELECT sub_id,sub_state,sub_cmd,sub_desc,sub_fname "
            ."FROM submeto where sub_state IN ('nov','ignor') AND sub_type='xml' LIMIT 200");

        $select->execute();
        my $submeto = $select->fetchrow_arrayref();
        while ($submeto) {

            if (param('type') eq 'text') {
                print join(';',@$submeto);
            } else {
                my $id = $submeto->[0];
                print qq(<a href="submeto.pl?id=$id">$id</a>;),join(';',splice @$submeto,1);
            }
            $submeto = $select->fetchrow_arrayref();
        }
    }; 
    
    if ($@) { 
        warn "Transaction aborted: $@"; 
        eval { $dbh->rollback() }; # in case rollback() fails 
        # do your application cleanup here 
    } 
}

sub pluku_submeton {
    my $id = shift;

    # malŝaltu aŭtomatan eraro-presadon(?)
    #$dbh->{PrintError} = 1;

    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov aŭ stato=ignor (por testo ni prenas 'ignor'...)
        my $select = $dbh->prepare("SELECT sub_id,sub_email,sub_cmd,sub_desc,sub_fname,sub_content "
            ."FROM submeto where sub_id=? FOR UPDATE");

        $select->execute($id);
        my $submeto = $select->fetchrow_hashref();

        if ($submeto) {
            print "From: ".$submeto->{'sub_email'}."\n\n";
            if ($submeto->{'sub_cmd'} eq 'aldono') {
                print $submeto->{'sub_cmd'}.": ".$submeto->{'sub_fname'}."\n\n";
            } else {
                print $submeto->{'sub_cmd'}.": ".$submeto->{'sub_desc'}."\n\n";
            }
            print $submeto->{'sub_content'};

            # marku la submeton por traktado
            if ($submeto->{"sub_state"} eq 'nov') {
                my $upd = $dbh->prepare("UPDATE submeto set sub_state='trakt' WHERE sub_state='nov' AND sub_id=?");
                $upd->execute($id);               
            }
        }

        $dbh->commit(); 
    }; 
    
    if ($@) { 
        warn "Transaction aborted: $@"; 
        eval { $dbh->rollback() }; # in case rollback() fails 
        # do your application cleanup here 
    } 
}
