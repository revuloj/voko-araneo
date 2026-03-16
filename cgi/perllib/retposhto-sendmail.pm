#!/usr/bin/perl

use strict;

sub sendu {
    my $header = shift;
    my $body = shift;

#    open $sendmail, '|-', "/usr/sbin/sendmail -t 2>&1 >$smlog" or print LOG "ne povas sendmail\n";
    open $sendmail, '|-', "/usr/sbin/sendmail -t" or die "Ne povas malfermi la programon 'sendmail': $!\n";
    while (my ($header, $value) = each %hash) {
        print $sendmail "$header: $value\n";
    }
    print $sendmail "\n";
    print $sendmail $body;
}
