#!/bin/bash

# eldonas kadrajn paĝojn, sendante ilin al la publika servilo
# tio estas iom provizora solvo, kiun necesas plibonigi poste:
#
# la kadraj paĝoj prefere ankaŭ aperu en la ĉiutagaj eldonoj de la vortaro,
# almenaŭ dum eblas uzi la vortaron loke per statikaj paĝoj....
# Tamen ni ne volas ilin inkluzivi en voko-grundo, voko-formiko dum ni
# iom pli multe prilaboras ilin, por eviti ĉiufoje krei novan procezumon voko-formiko

# jen kelkaj informoj kiel eviti plurfoje doni la pasvorton por scp:
# https://linux.101hacks.com/unix/ssh-controlmaster/
# + ControlPersist 2m
# http://blogs.perl.org/users/smylers/2011/08/ssh-productivity-tips.html

# aldonu en /etc/hosts!
host=revo
revo=${host}:www/revo
cgibin=${host}:www/cgi-bin
perllib=${host}:files/perllib
release=1c

# poste la plusendan index.html ni havu ankaŭ rekte sub /revo...
#scp -r revo/ ${revo}/

#scp revo/smb/revo.svg ${host}:/html/favicon.ico
#scp revo/smb/revo64.png ${host}:/html/favicon.ico

# malnovaj
scp cgi/vokomail.pl ${cgibin}/
scp cgi/sercxu.pl ${cgibin}/

# novaj
scp cgi/sercxu-json-${release}.pl ${cgibin}/
scp cgi/vokomailx.pl ${cgibin}/
scp cgi/vokohtmlx.pl ${cgibin}/
scp cgi/hazarda_art.pl ${cgibin}/
scp cgi/mx_trd.pl ${cgibin}/
#

#scp cgi/perllib/*.pm ${perllib}/
#scp cgi/perllib/revo/*.pm ${perllib}/revo/


