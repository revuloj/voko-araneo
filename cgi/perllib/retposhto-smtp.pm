#!/usr/bin/perl

use strict;

# https://stackoverflow.com/questions/3945583/how-can-i-conditionally-use-a-module-in-perl

use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
 
#my $email = Email::Simple->create(
#  header => [
#    To      => '<wolfram@steloj.de>',
#    From    => '<revo-srv@steloj.de>',
#    Subject => "testa mesaĝo",
#  ],
#  body => "Tio estas testo de retpoŝto.\n",
#);
 
sendu($$) {
    my $header = shift;
    my $body = shift;

    $email = Email::Simple->create(
        header => $header,
        body => $body
    );

    sendmail($mail);
};