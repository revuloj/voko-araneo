#!/usr/bin/perl

use strict;

sub sendu($$) {
    my $header = shift;
    my $body = shift;

#    open SENDMAIL, "| /usr/sbin/sendmail -t 2>&1 >$smlog" or print LOG "ne povas sendmail\n";
    open SENDMAIL, "| /usr/sbin/sendmail -t" or die "Ne povas malfermi la programon 'sendmail': $!\n";
    while (my ($header, $value) = each %hash) {
        print SENDMAIL "$header: $value\n";
    }
    print SENDMAIL "\n";
    print SENDMAIL $body;
}
