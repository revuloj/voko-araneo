#!/bin/bash

# necesas antaŭe instali perl-critic, ekz-e per 
# sudo apt install libperl-critic-perl

PC=/usr/bin/perlcritic
SVR=4
VRB=8

${PC} --verbose ${VRB} --severity ${SVR} cgi/admin
${PC} --verbose ${VRB} --severity ${SVR} cgi/perllib
${PC} --verbose ${VRB} --severity ${SVR} cgi/*.pl
${PC} --verbose ${VRB} --severity ${SVR} etc/*.pm
