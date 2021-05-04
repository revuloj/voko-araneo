##### staĝo 1: certigu, ke vi antaŭe kompilis voko-grundo aŭ ŝargis de Github kiel pakaĵo
FROM voko-grundo as grundo 
  # ni bezonos la enhavon de voko-grundo build poste por kopi jsc, stl, dok

##### staĝo 2: Ni devas mem kompili rxp por Alpine
FROM alpine:3.12 as builder

# build and install rxp
RUN apk update \
  && apk upgrade \
  && apk add --no-cache \
          ca-certificates \
  && update-ca-certificates \
      \
  # Install tools for building
  && apk add --no-cache --virtual .tool-deps \
          curl coreutils autoconf g++ libtool make \
      \
  # Install  build dependencies
  && apk add --no-cache --virtual .build-deps \
          linux-headers \
      \
  # Download and prepare Postfix sources
  && curl -fL -o /tmp/rxp.tar.gz \
          http://deb.debian.org/debian/pool/main/r/rxp/rxp_1.5.0.orig.tar.gz \
  && (echo "	5f6c4cd741bbeaf77b5a5918cb26df2f  /tmp/rxp.tar.gz" \
          | md5sum -c -) \
  && tar -xzf /tmp/rxp.tar.gz -C /tmp/ \
  && cd /tmp/rxp-* \
  && ./configure && make install

##### staĝo 3: Nun ni havas ĉion por la fina procezumo kun Apache-httpd, Perl...
FROM httpd:2.4-alpine
LABEL Author=<diestel@steloj.de>

# see:
# https://hub.docker.com/_/httpd/
# https://github.com/docker-library/httpd/blob/b2e7d2868e2f92660469ac66187f8f83fe449c65/2.4/alpine/Dockerfile
# https://hub.docker.com/r/cloudposse/apache/~/dockerfile/
# https://hub.docker.com/r/cloudposse/apache-perl/~/dockerfile/
# https://github.com/avast/docker-alpine-perl/blob/master/Dockerfile
#
# https://medium.com/@lojorider/docker-with-cgi-perl-a4558ab6a329

COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# tio devas koincidi kun uzanto sesio de voko-sesio
ARG DAEMON_UID=13731
# normale: master aŭ v1e ks
ARG VG_BRANCH=v1e
# por brancoj kun nomo vXXX estas la problemo, ke GH en la ZIP-nomo kaj dosierujo forprenas la "v"
# do se VG_BRANCH estas "v1e", ZIP_SUFFIX estu "1e"
ARG ZIP_SUFFIX=1e
ARG REVO_VER=1e
ARG HOME_DIR=/hp/af/ag/ri
ARG HTTP_DIR=/hp/af/ag/ri/www

RUN apk --update --update-cache --upgrade add bash mysql-client perl-dbd-mysql fcgi libxslt \
    perl-cgi perl-fcgi perl-uri perl-unicode-string perl-json perl-datetime \
    perl-email-simple perl-email-address perl-extutils-config perl-sub-exporter perl-net-smtp-ssl \
    perl-app-cpanminus perl-extutils-installpaths make \
    sed curl wget unzip jq && rm -f /var/cache/apk/* \
    && cpanm Email::Sender::Simple Email::Sender::Transport::SMTPS \
    && sed -i -e "s/daemon:x:2/daemon:x:${DAEMON_UID}/" /etc/passwd

# ni bezonas GNU 'sed' por kompili CSS!

# aldonu memkompilitan "rxp" de Alpine. Vd.:
# http://www.cogsci.ed.ac.uk/~richard/rxp.html
# http://www.inf.ed.ac.uk/research/isdd/admin/package?view=1&id=145
# https://packages.debian.org/source/jessie/rxp
#
# alternative oni povus uzi https://pkgs.alpinelinux.org/package/edge/testing/x86/xerces-c

COPY --from=builder /usr/local/bin/rxp /usr/local/bin/
COPY --from=builder /usr/local/lib/librxp.* /usr/local/lib/
#COPY --from=metapost --chown=root:root voko-grundo-master/build/smb/*.svg /tmp/svg/

#ADD . ./
COPY bin/* /usr/local/bin/
COPY cgi/ /usr/local/apache2/cgi-bin/
COPY revodb.pm /usr/local/apache2/cgi-bin/perllib/

# Ni kopias la tutan Retan Vortaron de 
# https://api.github.com/repos/revuloj/revo-fonto/releases/latest
# (Alternativa ebleco estus, preni nur la XML kaj rekrei la tutan
# vortaron per voko-formiko, sed tio daŭras tro longe kaj Github 
# jam faras tion ĉiunokte...)
# Aliflanke nuntempe sargi ion el eldono de Github estas terure malrapida
# laŭ la sekva artikoloj, tio okazas ekster Usono kaj VPN povus helpi
# https://www.reddit.com/r/github/comments/ekvvff/extremely_slow_downloads_from_github/
# https://github.com/PostgresApp/PostgresApp/issues/349
# Do eble estus pli bone ĉiutage krei voko-araneo aŭtomate per Github-ago
# kaj preni ĝin komplete?
#
# en revodb.pm estas la konekto-parametroj...
WORKDIR /tmp
RUN /usr/local/bin/revo_download_gh.sh && mv revo /usr/local/apache2/htdocs/ \
  && curl -LO https://github.com/revuloj/voko-grundo/archive/${VG_BRANCH}.zip \
  && unzip -l ${VG_BRANCH}.zip \
  && unzip -q ${VG_BRANCH}.zip voko-grundo-${ZIP_SUFFIX}/xsl/* voko-grundo-${ZIP_SUFFIX}/dok/* \
     voko-grundo-${ZIP_SUFFIX}/cfg/* voko-grundo-${ZIP_SUFFIX}/dtd/* \
     # necesaj ankoraŭ por la malnova fasado:
     voko-grundo-${ZIP_SUFFIX}/smb/*.gif \
  && rm ${VG_BRANCH}.zip \
  && mkdir -p ${HOME_DIR}/files && mv voko-grundo-${ZIP_SUFFIX}/xsl ${HOME_DIR}/files/ \
# tion ni ne bezonos, post kiam korektiĝis eraro en voko-formiko, ĉar
# tiam la vinjetoj GIF kaj PNG ankaŭ estos en la ĉiutaga revohtml-eldono  
#  && cp voko-grundo-${VG_BRANCH}/smb/*.png /usr/local/apache2/htdocs/revo/smb/ \
  && cp voko-grundo-${ZIP_SUFFIX}/smb/*.gif /usr/local/apache2/htdocs/revo/smb/ \
  && cp -r voko-grundo-${ZIP_SUFFIX}/cfg/* /usr/local/apache2/htdocs/revo/cfg/ \
  && mv voko-grundo-${ZIP_SUFFIX}/dtd /usr/local/apache2/htdocs/revo/ \
  && mv -f voko-grundo-${ZIP_SUFFIX}/dok/* /usr/local/apache2/htdocs/revo/dok/ \
  && chmod 755 /usr/local/apache2/cgi-bin/*.pl && chmod 755 /usr/local/apache2/cgi-bin/admin/*.pl \
  && mkdir -p ${HOME_DIR}/files/log && chown daemon.daemon ${HOME_DIR}/files/log \
  && ln -sT /usr/local/apache2/cgi-bin/perllib ${HOME_DIR}/files/perllib \
  && ln -sT /usr/local/apache2/htdocs ${HTTP_DIR} \
  && mkdir -p ${HTTP_DIR}/tmp \
  && chown -R ${DAEMON_UID} ${HTTP_DIR}/revo \
  && rm -rf /tmp/*

COPY --from=grundo build/smb/ /usr/local/apache2/htdocs/revo/smb/
COPY --from=grundo build/jsc/ /usr/local/apache2/htdocs/revo/jsc/
COPY --from=grundo build/stl/ /usr/local/apache2/htdocs/revo/stl/
  
#   && cp -r /usr/local/apache2/htdocs/revo/xsl/inc /usr/local/apache2/htdocs/revo/xsl/ \

COPY sxangxoj.rdf ${HTTP_DIR}/
RUN chown ${DAEMON_UID} ${HTTP_DIR}/sxangxoj.rdf

#COPY sercho.xsl ${HOME_DIR}/files/xsl/sercho.xsl

COPY revo/ /usr/local/apache2/htdocs/revo/

# Ankoraŭ farenda
# certigu ke ne mankas dokumentoj en revo/dok - eble kreu per xsltproc + xsl ankoraŭ...
# oni povas kunmeti COPY+ADD kaj ambaŭ RUN per redukti tavolojn

# Basic Auth por cgi/admin
# https://tecadmin.net/setup-apache-basic-authentication/
# https://dzone.com/articles/apache-http-24-how-to-build-a-docker-image-for-ssl
# https://devops.ionos.com/tutorials/set-up-basic-authentication-in-apache-using-htaccess-on-centos-7/


USER root
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd-foreground"]