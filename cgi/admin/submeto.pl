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

my $debug = 1; #0|1;

#binmode STDOUT, ":utf8";

# ni povas postuli 'text', aliokaze redoniĝos html
if (param('id') || param('format') eq 'text') {
    print header(-type => 'text/plain', -charset => 'utf-8');
} else {
    print header(-charset=>'utf-8'),
        start_html(
            -dtd => ['-//W3C//DTD HTML 4.01 Transitional//EN','http://www.w3.org/TR/html4/loose.dtd'],
            -lang => 'eo',
            -title => 'submetoj'),
        start_pre()
}

unless(param('id')) {
    print "id;state;time;cmd;desc;fname\n";
}

my $dbh = revodb::connect();
$dbh->{mysql_enable_utf8} = 1;

if (param('id') && param('result') && param('state')) {
    submeto_rezulto();
} elsif (param('id')) {
    pluku_submeton();
} else {
    listigu_novajn();
};

$dbh->disconnect() if $dbh;

# finu HTML-on
if ((not param('id')) && (param('format') ne 'text')) {
    print end_pre(), end_html();
}    

##############################

sub listigu_novajn {
    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov aŭ stato=ignor (por testo ni prenas 'ignor'...)
        my $select = $dbh->prepare("SELECT sub_id,sub_state,sub_time,sub_cmd,sub_desc,sub_fname "
            ."FROM submeto WHERE sub_state IN ('nov','ignor') AND sub_type='xml' LIMIT 200");

        $select->execute();
        my $submeto = $select->fetchrow_arrayref();
        while ($submeto) {
            #if ($debug) { print "id:".$submeto->[0]."\n" };
            # protektu specialajn signojn en desc
            my $desc=4;
            $submeto->[$desc] =~ s/\n/\\n/g;
            $submeto->[$desc] =~ s/\r/\\r/g;
            $submeto->[$desc] =~ s/\t/\\t/g;
            $submeto->[$desc] =~ s/"/""/g;
            $submeto->[$desc] = '"'.$submeto->[$desc].'"';
            if (param('format') eq 'text') {
                print join(';',@$submeto),"\n";
            } else {
                my $id = $submeto->[0];
                print qq(<a href="submeto.pl?id=$id">$id</a>;),join(';',splice @$submeto,1),"\n";
            }
            $submeto = $select->fetchrow_arrayref();
        }
    }; 
    
    if ($@) { 
        warn "Datumbaza eraro: $@"; 
        # eval { $dbh->rollback() }; # in case rollback() fails 
        # cleanup here 
    } 
}

sub pluku_submeton {
    my $id = param('id');

    # malŝaltu aŭtomatan eraro-presadon(?)
    #$dbh->{PrintError} = 1;

    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov aŭ stato=ignor (por testo ni prenas 'ignor'...)
        #my $select = $dbh->prepare("SELECT sub_id,sub_email,sub_cmd,sub_desc,sub_fname,sub_content "
        my $select = $dbh->prepare("SELECT sub_id,sub_email,sub_content "
            ."FROM submeto where sub_id=? FOR UPDATE");

        $select->execute($id);
        my $submeto = $select->fetchrow_hashref();

        if ($submeto) {
            print "From: ".$submeto->{'sub_email'}."\n\n";
            #if ($submeto->{'sub_cmd'} eq 'aldono') {
            #    print $submeto->{'sub_cmd'}.": ".$submeto->{'sub_fname'}."\n\n";
            #} else {
            #    print $submeto->{'sub_cmd'}.": ".$submeto->{'sub_desc'}."\n\n";
            #}
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
        warn "Datumbaza eraro: $@"; 
        eval { $dbh->rollback() }; # in case rollback() fails 
        # cleanup here 
    } 
}

sub submeto_rezulto {

    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov aŭ stato=ignor (por testo ni prenas 'ignor'...)
        my $upd = $dbh->prepare("UPDATE submeto SET sub_state=?,sub_result=? "
            ."WHERE sub_state = 'trakt' AND sub_id=?");

        $upd->bind_param(1,param('state'));
        $upd->bind_param(2,param('result'));
        $upd->bind_param(2,param('id'));

        my $rv = $upd->execute();
        print "$rv\n" # 1 = aktualigita, 0E0 = ne aktualigita, pro nekongruo de sub_id aŭ sub_state
    }; 
    
    if ($@) { 
        warn "Datumbaza eraro: $@"; 
        # eval { $dbh->rollback() }; # in case rollback() fails 
        # cleanup here 
    } 
}
