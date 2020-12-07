##### staĝo 1: Ni devas mem kompili rxp por Alpine
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

# chekote/gulp
#FROM node:alpine as minifier # or :slim
#RUN npm install gulp -g
#ENTRYPOINT ["/bin/bash", "-c"]

###### staĝo 2: Ni bezonas TeX kaj metapost por konverti simbolojn al SVG
# (PNG ni ricevos el la ĉiutaga eldono)
FROM silkeh/latex:small as metapost
LABEL Author=<diestel@steloj.de>
RUN apk --update add curl unzip librsvg --no-cache && rm -f /var/cache/apk/* 
RUN curl -LO https://github.com/revuloj/voko-grundo/archive/master.zip \
   && unzip master.zip voko-grundo-master/bin/mp2png_svg.sh \
   && unzip master.zip voko-grundo-master/smb/*.mp
RUN cd voko-grundo-master && mkdir -p build/smb && bin/mp2png_svg.sh #&& cd ${HOME}


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
# normale: master
ARG VG_BRANCH=master 
ARG REVO_VER=1c

RUN apk --update --update-cache --upgrade add mysql-client perl-dbd-mysql fcgi libxslt \
    perl-cgi perl-fcgi perl-uri perl-unicode-string perl-datetime perl-xml-rss \
    perl-email-simple perl-email-address perl-extutils-config perl-sub-exporter perl-net-smtp-ssl \
    perl-app-cpanminus perl-extutils-installpaths make \
    sed curl unzip jq && rm -f /var/cache/apk/* \
    && cpanm Email::Sender::Simple Email::Sender::Transport::SMTPS \
    && sed -i -e "s/daemon:x:2/daemon:x:${DAEMON_UID}/" /etc/passwd

# ni bezonas GNU sed por kompili CSS!

# aldonu memkompilitan "rxp" de Alpine. Vd.:
# http://www.cogsci.ed.ac.uk/~richard/rxp.html
# http://www.inf.ed.ac.uk/research/isdd/admin/package?view=1&id=145
# https://packages.debian.org/source/jessie/rxp
#
# alternative oni povus uzi https://pkgs.alpinelinux.org/package/edge/testing/x86/xerces-c

COPY --from=builder /usr/local/bin/rxp /usr/local/bin/
COPY --from=builder /usr/local/lib/librxp.* /usr/local/lib/
COPY --from=metapost --chown=root:root voko-grundo-master/build/smb/*.svg /tmp/svg/

#ADD . ./
COPY bin/* /usr/local/bin/
COPY cgi/ /usr/local/apache2/cgi-bin/
COPY revodb.pm /usr/local/apache2/cgi-bin/perllib/

# Ni kopias la tutan Retan Vortaron de 
# https://api.github.com/repos/revuloj/revo-fonto/releases/latest
# (Alternativa ebleco estus, preni nur la XML kaj rekrei la tutan
# vortaron per voko-formiko, sed tio daŭras tro longe kaj Github 
# jam faras tion ĉiunokte...)
#
# en revodb.pm estas la konekto-parametroj...
WORKDIR /tmp
RUN /usr/local/bin/revo_download_gh.sh && mv revo /usr/local/apache2/htdocs/ \
  && curl -LO https://github.com/revuloj/voko-grundo/archive/${VG_BRANCH}.zip \
  && unzip -q ${VG_BRANCH}.zip voko-grundo-${VG_BRANCH}/xsl/* voko-grundo-${VG_BRANCH}/dok/* \
     voko-grundo-${VG_BRANCH}/cfg/* voko-grundo-${VG_BRANCH}/dtd/* \
     voko-grundo-${VG_BRANCH}/jsc/* voko-grundo-${VG_BRANCH}/stl/* \
     voko-grundo-${VG_BRANCH}/smb/* voko-grundo-${VG_BRANCH}/bin/compile* \
     voko-grundo-${VG_BRANCH}/bin/svg2css.sh \
  && rm ${VG_BRANCH}.zip \
  && mkdir /usr/local/apache2/htdocs/revo/jsc \
  # provizore ni nur kunigas JS, poste uzu google-closure-compiler / compile-js.sh
  && cat voko-grundo-${VG_BRANCH}/jsc/util.js voko-grundo-${VG_BRANCH}/jsc/transiroj.js \
         voko-grundo-${VG_BRANCH}/jsc/kadro.js voko-grundo-${VG_BRANCH}/jsc/artikolo.js \
         voko-grundo-${VG_BRANCH}/jsc/redaktilo.js \
      > /usr/local/apache2/htdocs/revo/jsc/revo-${REVO_VER}.js \
#  && cp voko-grundo-${VG_BRANCH}/stl/* /usr/local/apache2/htdocs/revo/stl/ \
  # kombinu kaj malgrandigu CSS-dosierojn
  && cd voko-grundo-${VG_BRANCH} && mkdir -p build/smb && cp /tmp/svg/* ./build/smb/ \
  && mkdir -p build/stl \
  #&& ./bin/compile-css.sh  > /usr/local/apache2/htdocs/revo/stl/revo-${REVO_VER}-min.css \
  && ./bin/compile-css.sh && mv build/stl/* /usr/local/apache2/htdocs/revo/stl/ \
  && cd .. \
# debug:  && ls voko-grundo-${VG_BRANCH}/* \
  && mv voko-grundo-${VG_BRANCH}/xsl /usr/local/apache2/htdocs/revo/ \
#  && mv voko-grundo-${VG_BRANCH}/jsc /usr/local/apache2/htdocs/revo/ \
# tion ni ne bezonos, post kiam korektiĝis eraro en voko-formiko, ĉar
# tiam la vinjetoj GIF kaj PNG ankaŭ estos en la ĉiutaga revohtml-eldono  
#  && cp voko-grundo-${VG_BRANCH}/smb/*.png /usr/local/apache2/htdocs/revo/smb/ \
  && cp voko-grundo-${VG_BRANCH}/smb/*.gif /usr/local/apache2/htdocs/revo/smb/ \
  && cp -r voko-grundo-${VG_BRANCH}/cfg/* /usr/local/apache2/htdocs/revo/cfg/ \
  && mv voko-grundo-${VG_BRANCH}/dtd /usr/local/apache2/htdocs/revo/ \
  && mv -f voko-grundo-${VG_BRANCH}/dok/* /usr/local/apache2/htdocs/revo/dok/ \
  && chmod 755 /usr/local/apache2/cgi-bin/*.pl && chmod 755 /usr/local/apache2/cgi-bin/admin/*.pl \
  && mkdir -p /var/www/web277/files/log && chown daemon.daemon /var/www/web277/files/log \
  && ln -sT /usr/local/apache2/cgi-bin/perllib /var/www/web277/files/perllib \
  && ln -sT /usr/local/apache2/htdocs /var/www/web277/html \
  && mkdir -p /var/www/web277/html/tmp \
  && chown -R ${DAEMON_UID} /var/www/web277/html/revo \
  && rm -rf /tmp/*


  
#   && cp -r /usr/local/apache2/htdocs/revo/xsl/inc /usr/local/apache2/htdocs/revo/xsl/ \

COPY sxangxoj.rdf /var/www/web277/html/
RUN chown ${DAEMON_UID} /var/www/web277/html/sxangxoj.rdf

#COPY sercho.xsl /var/www/web277/html/xsl/sercho.xsl

COPY n${REVO_VER}/ /usr/local/apache2/htdocs/revo/

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