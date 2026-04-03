# Testskriptoj por perl `prove`

ekz-e:

~~~sh
prove [-v] tst/cgi/0*
~~~

- 0x - testskriptoj loke plenumeblaj
- 1x - testskriptoj kiuj bezonas procezujon voko-araneo
- 2x - testskriptoj kuj bezonas medion araneujo (revo-medioj/araneujo-s)
- 2x_adm - testskriptoj por la protektiaj administraj skriptoj

Por kelkaj testoj pri submeto vi devas doni retpoŝtadreson de valida redaktanto. Por faciligi vi povas aldoni tion kiel medivariablojn 
en via .profile / .bashrc / sistemvariablolisto - depende de uzata operaciumo.

~~~sh
    TEST_RETADRESO='redaktanto@valida.org' prove [-v] tst/cgi/*_vokosubm*
~~~

Por _adm_ vi devas doni medivariablojn $CGI_USER && $CGI_PWD:

~~~sh
    CGI_USR=<admin> CGI_PWD=<sekreto> prove [-v] tst/cgi/22_adm*
~~~