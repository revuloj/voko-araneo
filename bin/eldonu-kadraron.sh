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
release=2a

# poste la plusendan index.html ni havu ankaŭ rekte sub /revo...
scp revo/dlg/index-${release}.html ${revo}/dlg/
scp -r revo/dlg/titolo-${release}.html ${revo}/dlg/
scp revo/dlg/redakt*-${release}.html ${revo}/dlg/
## scp -r revo/dlg/404.html ${revo}/dlg/
scp cgi/sercxu-json-${release}.pl ${cgibin}/


#scp revo/index.html ${revo}/
#scp revo/index.html ${host}:www/

## sendu malnovajn versiojn al la nova...
#scp revo/index.html ${revo}/dlg/index-1c.html
#scp revo/index.html ${revo}/dlg/index-1d.html
#scp revo/index.html ${revo}/dlg/index-1e.html


#scp revo/smb/revo.svg ${host}:/html/favicon.ico
#scp revo/smb/revo64.png ${host}:/html/favicon.ico

# cgi-bin/admin
#scp cgi/admin/* ${cgibin}/admin/
#scp cgi/admin/.ht* ${cgibin}/admin/
#scp cgi/admin/checkversioj.pl ${cgibin}/admin/
#scp cgi/perllib/art_db.pm ${perllib}/

#scp cgi/admin/up* ${cgibin}/admin/
#scp cgi/admin/upviki.pl ${cgibin}/admin/
#scp cgi/perllib/parse* ${perllib}/

#scp cgi/vokosubmx.pl ${cgibin}/
#scp cgi/vokosubm-json.pl ${cgibin}/
#scp cgi/admin/submeto.pl ${cgibin}/admin/
#scp cgi/mrk_eraroj.pl ${cgibin}/

#scp cgi/admin/uprevo.pl ${cgibin}/admin/

## # malnovaj
## 
## # novaj
#scp cgi/sercxu-json-${release}.pl ${cgibin}/
#scp cgi/vokoref-json.pl ${cgibin}/
## scp cgi/vokomailx.pl ${cgibin}/
## scp cgi/vokohtmlx.pl ${cgibin}/
## scp cgi/hazarda_art.pl ${cgibin}/
## scp cgi/mx_trd.pl ${cgibin}/
#
# scp cgi/vokomail.pl ${cgibin}/
#scp cgi/sercxu.pl ${cgibin}/
#scp cgi/sercxu-vivo.pl ${cgibin}/
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
# scp cgi/vokohtmlx.pl ${cgibin}/
## scp cgi/hazarda_art.pl ${cgibin}/
#scp cgi/mx_trd.pl ${cgibin}/
#


#scp revo/dlg/index-${release}.html ${revo}/dlg/
#scp revo/dlg/titolo-${release}.html ${revo}/dlg/
#scp revo/dlg/redakt*-${release}.html ${revo}/dlg/
#scp revo/dlg/404.html ${revo}/dlg/
