#!/usr/bin/perl

# (c) 2021 ĉe Wolfram Diestel
# laŭ GPL 2.0

use strict;
use utf8;

use CGI qw(:standard *pre *table);
use CGI::Carp qw(fatalsToBrowser);
use DBI();

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/

use revodb;

my $debug = 0; #0|1;
my $max_age = 200; # post kiom da tagoj ni forigos malnovajn per forigu_malnovajn()

#binmode STDOUT, ":utf8";

# ni povas postuli 'text', aliokaze redoniĝos html
my $format_text = (param('id') || param('forigo') || param('format') eq 'text');
if ($format_text) {
    print header(-type => 'text/plain', -charset => 'utf-8');
} else {
    print header(-charset=>'utf-8'),
        start_html(
            -dtd => ['-//W3C//DTD HTML 4.01 Transitional//EN','http://www.w3.org/TR/html4/loose.dtd'],
            -lang => 'eo',
            -title => 'submetoj');
}

unless(param('id') || param('forigo') || param('email')) {
    print "id;state;time;cmd;desc;fname\n";
}

my $dbh = revodb::connect();
$dbh->{mysql_enable_utf8} = 1;

if (param('id') && param('result') && param('state')) {
    submeto_rezulto();
} elsif (param('id')) {
    pluku_submeton();
} elsif (param('email')) {
    redakto_statoj();
} elsif (param('forigo')) {
    forigu_malnovajn();
} else {
    print start_pre() unless (param('format') eq 'text');
    listigu_novajn();
    print end_pre() unless (param('format') eq 'text');
};

$dbh->disconnect() if $dbh;

# finu HTML-on
unless ($format_text) {
    print end_html();
}    

##############################

sub listigu_novajn {
    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov 
        my $select = $dbh->prepare("SELECT sub_id,sub_state,sub_time,sub_cmd,sub_desc,sub_fname "
            ."FROM submeto WHERE sub_state = 'nov' AND sub_type='xml' LIMIT 200");

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

sub forigu_malnovajn {    
    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 1;

    eval { 
        # forigu pli malnovajn ol $max_age tagojn
        my $del = $dbh->prepare("DELETE FROM submeto WHERE TIMESTAMPDIFF(DAY,sub_time,NOW()) > ?;");
        my $rv = $del->execute($max_age);
        print "$rv\n" # 1..999 = tiom da forigitaj, 0E0 = neniu
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

        # elprenu unu submeton laŭ parametro 'id'
        #my $select = $dbh->prepare("SELECT sub_id,sub_email,sub_cmd,sub_desc,sub_fname,sub_content "
        my $select = $dbh->prepare("SELECT sub_id,sub_state,sub_email,sub_content "
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

        # aktualigu submeton kun stato=trakt al 'arkiv' aŭ 'erar' aldonante rezulto-mesaĝon
        my $upd = $dbh->prepare("UPDATE submeto SET sub_state=?,sub_result=? "
            ."WHERE sub_state = 'trakt' AND sub_id=?");

        #$upd->bind_param(1,param('state'));
        #$upd->bind_param(2,param('result'));
        #$upd->bind_param(2,param('id'));
        my $state = param('state');
        my $result = param('result');
        my $id = param('id');

        my $rv = $upd->execute($state,$result,$id);
        print "$rv\n" # 1 = aktualigita, 0E0 = ne aktualigita, pro nekongruo de sub_id aŭ sub_state
    }; 
    
    if ($@) { 
        warn "Datumbaza eraro: $@"; 
        # eval { $dbh->rollback() }; # in case rollback() fails 
        # cleanup here 
    } 
}

sub redakto_statoj {

    $dbh->{RaiseError} = 1;

    eval { 

        # elprenu unu submeton kun stato=nov aŭ stato=ignor (por testo ni prenas 'ignor'...)
        my $select = $dbh->prepare("SELECT sub_id,sub_fname,sub_state,sub_time,sub_desc,sub_result "
            ."FROM submeto WHERE sub_email=? ORDER BY sub_time DESC LIMIT 20");
        # PLIBONIGU: trovu ankaŭ samredaktorajn submetojn kun alternativaj retadresoj:
        # JOIN email ON sub_email = ema_email AND...?

        my $email = param('email');
        $select->execute($email);

        print start_table({-border=>1,-cellspacing=>0});
        #print "email: $email\n";
        my $submeto = $select->fetchrow_arrayref();

        #print $submeto->[0];
        while ($submeto) {
            #print join(';',@$submeto),"\n";
            print Tr(
              td({},$submeto->[0]),
              td({},$submeto->[1]),
              td({},$submeto->[2]),
              td({},$submeto->[3]),
              td({},$submeto->[4]),
              td({},$submeto->[5])
            );

            $submeto = $select->fetchrow_arrayref();
        }

        print end_table();
    }; 
    
    if ($@) { 
        warn "Datumbaza eraro: $@"; 
        # eval { $dbh->rollback() }; # in case rollback() fails 
        # cleanup here 
    } 
}
