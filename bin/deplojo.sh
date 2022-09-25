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
release=2g

# ni komprenas preparo | docker | servilo |index
# kaj supozas "docker", se nenio donita argumente
target="${1:-docker}"

case $target in

docker)
    araneo_id=$(docker ps --filter name=araneujo_araneo -q)

    todir=/usr/local/apache2/htdocs/revo
    docker cp revo/dlg/index-${release}.html ${araneo_id}:${todir}/dlg/
    docker cp revo/dlg/titolo-${release}.html ${araneo_id}:${todir}/dlg/
    docker cp revo/dlg/redaktilo-${release}.html ${araneo_id}:${todir}/dlg/
    docker cp revo/dlg/redaktmenu-${release}.html ${araneo_id}:${todir}/dlg/
    docker exec ${araneo_id} bash -c "chown root.root ${todir}/*; ls -l ${todir}/dlg"

    cgidir=/usr/local/apache2/cgi-bin
    perllib=/usr/local/apache2/cgi-bin/perllib/
    docker cp cgi/sercxu-json-${release}.pl ${araneo_id}:${cgidir}
    #docker cp cgi/traduku-uwn.pl ${araneo_id}:${cgidir}
    docker cp cgi/perllib/revo/checkxml.pm ${araneo_id}:${perllib}/revo/

    docker exec ${araneo_id} bash -c "chmod 755 ${cgidir}/*.pl; chown root.root ${cgidir}/*; ls -l ${cgidir}"
    ;;
esac
