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
release=1b

scp n1b/dlg/redaktilo.html ${host}:/html/revo/dlg/
scp n1b/jsc/redaktilo-${release}.js ${host}:/html/revo/jsc/
scp n1b/stl/redaktilo-${release}.css ${host}:/html/revo/stl/

scp cgi/vokomailx.pl ${host}:/html/cgi-bin/
scp cgi/vokohtmlx.pl ${host}:/html/cgi-bin/

scp cgi/perllib/revo/checkxml.pm ${host}:/files/perllib/revo/


