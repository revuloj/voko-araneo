#!/usr/bin/perl

# 2008 Wieland Pusch
# 2020-2021 Wolfram Diestel


use strict;
use utf8;

# propraj perl moduloj estas en:
use lib("cgi/perllib");
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/

#use revo::decode;
use revo::encodex;

print revo::encodex::encode2("ŝi\n",20,1);
      