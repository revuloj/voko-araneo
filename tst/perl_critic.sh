#!/bin/bash

# necesas antaŭe instali perl-critic, ekz-e per 
# sudo apt install libperl-critic-perl

PC=/usr/local/bin/perlcritic

${PC} cgi/admin
${PC} cgi/perllib
${PC} cgi/*.pl
