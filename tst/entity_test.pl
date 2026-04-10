#!/usr/bin/perl

# 2008 Wieland Pusch
# 2020-2021 Wolfram Diestel


use strict;
use utf8;

# propraj perl moduloj estas en:
use lib("cgi/perllib");
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/

use revo::decode;
use revo::encode;
use revo::encodex;

print revo::decode::rvdecode("dec: &leftquot;&scirc;i&rightquot;\n",20,1);
print revo::encode::encode2("enc: ŝi\n",20,1);
print revo::encodex::xencode2("enc2: ŝi\n",20,1);
      