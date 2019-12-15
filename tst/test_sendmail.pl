#!/usr/bin/perl

# Ubuntu:
#   apt install libemail-sender-perl perl-email-simple
# Alpine:
#   apk ... perl-email-simple perl-app-cpanminus
# && cpanm Email::Sender::Simple Email::Sender::Transport::SMTPS

use strict;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
 
my $email = Email::Simple->create(
  header => [
    To      => '<wolfram@steloj.de>',
    From    => '<revo-srv@steloj.de>',
    Subject => "testa mesaĝo",
  ],
  body => "Tio estas testo de retpoŝto.\n",
);
 
sendmail($email);


#use lib("../cgi/perllib","./cgi/perllib");
#use retposhto;
#
#%mail = (
#        To => 'wolfram@steloj.de',
#        Subject => 'Test message',
#        Smtp => 'localhost'
#    );
#retposhto::sendu(
#    \%mail,
#    'Tio estas testo de retpoŝto.pm.'
#);
