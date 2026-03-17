#!/bin/bash

# necesas antaŭe instali perl-critic, ekz-e per 
# sudo apt install libperl-critic-perl

PC=/usr/bin/perlcritic
SVR=4

${PC} --severity ${SVR} cgi/admin
${PC} --severity ${SVR} cgi/perllib
${PC} --severity ${SVR} cgi/*.pl
${PC} --severity ${SVR} etc/*.pm
