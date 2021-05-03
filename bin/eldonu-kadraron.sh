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
release=1f

# poste la plusendan index.html ni havu ankaŭ rekte sub /revo...

#scp revo/smb/revo.svg ${host}:/html/favicon.ico
#scp revo/smb/revo64.png ${host}:/html/favicon.ico

# cgi-bin/admin
#scp cgi/admin/* ${cgibin}/admin/
#scp cgi/admin/.ht* ${cgibin}/admin/

#scp cgi/admin/up* ${cgibin}/admin/
#scp cgi/admin/upviki.pl ${cgibin}/admin/
#scp cgi/perllib/parse* ${perllib}/

#scp cgi/sercxu-json-${release}.pl ${cgibin}/
#scp cgi/vokosubmx.pl ${cgibin}/
#scp cgi/vokosubm-json.pl ${cgibin}/
#scp cgi/admin/submeto.pl ${cgibin}/admin/

#scp cgi/admin/uprevo.pl ${cgibin}/admin/

## # malnovaj
# scp cgi/vokomail.pl ${cgibin}/
#scp cgi/sercxu.pl ${cgibin}/
## 



#scp cgi/perllib/*.pm ${perllib}/

#scp cgi/perllib/revo/encodex.pm ${perllib}/revo/
#scp cgi/perllib/revo/voko_entities.pm ${perllib}/revo/
#scp cgi/perllib/revo/checkxml.pm ${perllib}/revo/
#scp cgi/perllib/revo/xml2html.pm ${perllib}/revo/


## # novaj
#scp cgi/sercxu-json-${release}.pl ${cgibin}/
#scp cgi/vokoref-json.pl ${cgibin}/
## scp cgi/vokomailx.pl ${cgibin}/
scp cgi/vokohtmlx.pl ${cgibin}/
## scp cgi/hazarda_art.pl ${cgibin}/
#scp cgi/mx_trd.pl ${cgibin}/
#
#scp -r revo/dlg/index-${release}.html ${revo}/dlg/
#scp -r revo/dlg/titolo-${release}.html ${revo}/dlg/
#scp -r revo/dlg/redakt*-${release}.html ${revo}/dlg/
#scp -r revo/dlg/404.html ${revo}/dlg/
