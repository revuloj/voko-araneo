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

host=retavortaro.de
release=1c

# poste la plusendan index.html ni havu ankaŭ rekte sub /revo...
scp n${release}/index.html ${host}:/html/revo/dlg/
scp n${release}/index.html ${host}:/html/revo/
##
scp n${release}/dlg/index-${release}.html ${host}:/html/revo/dlg/
#scp n${release}/dlg/titolo-${release}.html ${host}:/html/revo/dlg/
## ###scp n${release}/dlg/titolo.jpg ${host}:/html/revo/dlg/
#scp n${release}/dlg/redaktilo-${release}.html ${host}:/html/revo/dlg/
#scp n${release}/dlg/redaktmenu-${release}.html ${host}:/html/revo/dlg/
#scp n${release}/dlg/zamenhof_legas.jpg ${host}:/html/revo/dlg/
##scp n${release}/dlg/404.html ${host}:/html/revo/dlg/

#scp n${release}/smb/duckduckgo.svg ${host}:/html/revo/smb/
#scp n${release}/smb/ecosia.svg ${host}:/html/revo/smb/
#scp n${release}/smb/revo.svg ${host}:/html/revo/smb/

#scp n${release}/smb/revo.svg ${host}:/html/favicon.ico
#scp n${release}/smb/revo64.png ${host}:/html/favicon.ico

#scp cgi/sercxu-json-${release}.pl ${host}:/html/cgi-bin/
#scp cgi/vokomailx.pl ${host}:/html/cgi-bin/
#scp cgi/vokohtmlx.pl ${host}:/html/cgi-bin/
#scp cgi/hazarda_art.pl ${host}:/html/cgi-bin/
#
#scp cgi/perllib/revo/checkxml.pm ${host}:/files/perllib/revo/


