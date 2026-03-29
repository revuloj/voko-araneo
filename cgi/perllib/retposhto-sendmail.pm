#!/usr/bin/perl

use warnings; use strict;

sub sendu {
    my $header = shift;
    my $body = shift;

#    open $sendmail, '|-', "/usr/sbin/sendmail -t 2>&1 >$smlog" or print LOG "ne povas sendmail\n";
    open my $sendmail, '|-', "/usr/sbin/sendmail -t" 
        or die "Ne povas malfermi la programon 'sendmail': $!\n";
    #while (my ($head, $val) = each %$header) {
    #    print {$sendmail} "$head: $val\n";
    #} 
    
    print {$sendmail} $header; 
    print {$sendmail} "\n";
    print {$sendmail} $body;
    close $sendmail;

    return;
}
