##### staĝo 1: certigu, ke vi antaŭe kompilis voko-grundo aŭ ŝargis de Github kiel pakaĵo

# VERSION povas esti ŝanĝita de ekstere per --build-arg, jam konsiderata en 'bin/eldono.sh kreo'
ARG VERSION=latest
FROM ghcr.io/revuloj/voko-grundo/voko-grundo:${VERSION} as grundo 
  # ni bezonos la enhavon de voko-grundo build poste por kopi jsc, stl, dok


##### staĝo 2: Ni devas mem kompili rxp por Alpine
FROM alpine:3.15 as builder
   # atentu: alpine:3.15 bezonas almenaŭ docker 20.10!

# build and install rxp
RUN apk update \
  && apk upgrade \
  && apk add --no-cache \
          ca-certificates \
  && update-ca-certificates \
      \
  # Install tools for building
  && apk add --no-cache --virtual .tool-deps \
          curl file coreutils autoconf g++ libtool make \
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


##### staĝo 3: Nun ni havas ĉion por krei la finan procezujon kun Apache-httpd, Perl...
FROM httpd:2.4-alpine
LABEL Author=<diestel@steloj.de>
LABEL org.opencontainers.image.description DESCRIPTION

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
# normale: master aŭ v1e ks, 'bin/eldono.sh kreo' metas tion de ekstere per --build-arg
# ARG VG_TAG=master
# por etikedoj kun nomo vXXX estas la problemo, ke GH en la ZIP-nomo kaj dosierujo forprenas la "v"
# do se VG_TAG estas "v1e", ZIP_SUFFIX estu "1e", en 'bin/eldono.sh kreo' tio estas jam konsiderata
#ARG ZIP_SUFFIX=master
#ARG REVO_VER=2f
ARG HOME_DIR=/hp/af/ag/ri
ARG HTTP_DIR=/hp/af/ag/ri/www
ARG VOKO_TMP=/tmp/voko
ARG REVO_DIR=/usr/local/apache2/htdocs/revo

RUN apk --update --update-cache --upgrade add bash mysql-client perl-dbd-mysql fcgi libxslt \
    perl-cgi perl-fcgi perl-uri perl-unicode-string perl-json perl-datetime \
    perl-email-simple perl-email-address perl-extutils-config perl-sub-exporter perl-net-smtp-ssl \
    perl-app-cpanminus perl-extutils-installpaths perl-http-message perl-lwp-protocol-https perl-lwp-useragent-determined curl wget unzip jq \
    sed perl-dev make build-base \
    && cpanm Email::Sender::Simple Email::Sender::Transport::SMTPS \
    && sed -i -e "s/daemon:x:2/daemon:x:${DAEMON_UID}/" /etc/passwd \
    && apk del build-base sed make perl-dev && rm -f /var/cache/apk/*

# ni bezonas GNU 'sed' por kompili CSS!

# aldonu memkompilitan "rxp" de Alpine. Vd.:
# http://www.cogsci.ed.ac.uk/~richard/rxp.html
# http://www.inf.ed.ac.uk/research/isdd/admin/package?view=1&id=145
# https://packages.debian.org/source/jessie/rxp
#
# alternative oni povus uzi https://pkgs.alpinelinux.org/package/edge/testing/x86/xerces-c

COPY --from=builder /usr/local/bin/rxp /usr/local/bin/
COPY --from=builder /usr/local/lib/librxp.* /usr/local/lib/
#COPY --from=json-builder json/* ${HTTP_DIR}/revo/tez/
#COPY --from=metapost --chown=root:root voko-grundo-master/build/smb/*.svg /tmp/svg/

#ADD . ./
COPY bin/* /usr/local/bin/
COPY cgi/ /usr/local/apache2/cgi-bin/
COPY revodb.pm /usr/local/apache2/cgi-bin/perllib/

COPY --from=grundo build/ ${VOKO_TMP}/

# Ni kopias la tutan Retan Vortaron de 
# https://api.github.com/repos/revuloj/revo-fonto/releases/latest
# (Alternativa ebleco estus, preni nur la XML kaj rekrei la tutan
# vortaron per voko-formiko, sed tio daŭras tro longe kaj Github 
# jam faras tion ĉiunokte...)
# Aliflanke okaze ŝargi ion el eldono de Github estas tre malrapida
# laŭ la sekva artikoloj, tio okazas ekster Usono kaj VPN povus helpi
# https://www.reddit.com/r/github/comments/ekvvff/extremely_slow_downloads_from_github/
# https://github.com/PostgresApp/PostgresApp/issues/349
# Do eble estus pli bone ĉiutage krei voko-araneo aŭtomate per Github-ago
# kaj preni ĝin komplete?
#
# en revodb.pm estas la konekto-parametroj...
WORKDIR /tmp
RUN /usr/local/bin/revo_download_gh.sh && mv revo /usr/local/apache2/htdocs/ \
#  && curl -LO https://github.com/revuloj/voko-grundo/archive/${VG_TAG}.zip \
#  && unzip -l ${VG_TAG}.zip \
#  && unzip -q ${VG_TAG}.zip voko-grundo-${ZIP_SUFFIX}/dok/* \
#     voko-grundo-${ZIP_SUFFIX}/cfg/* voko-grundo-${ZIP_SUFFIX}/dtd/* \
#     # necesaj ankoraŭ por la malnova fasado:
#     voko-grundo-${ZIP_SUFFIX}/smb/*.gif \
#  && rm ${VG_TAG}.zip \
  && mkdir -p ${HOME_DIR}/files \
  # ni uzas provizore -k pro atestilo-problemo kun Let's Encrypt - okaze forigu post kiam refunkcias en Alpine+curl (2021-10-09)
  # && curl -k -Lo ${HOME_DIR}/files/eoviki.gz http://download.wikimedia.org/eowiki/latest/eowiki-latest-all-titles-in-ns0.gz \
  && curl -k -Lo ${HOME_DIR}/files/eoviki.gz http://download.wikimedia.org/eowiki/latest/eowiki-latest-all-titles-in-ns0.gz \
  && cp ${VOKO_TMP}/smb/* ${REVO_DIR}/smb/ \
  && cp -r ${VOKO_TMP}/cfg/* ${REVO_DIR}/cfg/ \
  && cp ${VOKO_TMP}/dok/* ${REVO_DIR}/dok/ \
  && cp ${VOKO_TMP}/stl/* ${REVO_DIR}/stl/ \
  && mv ${VOKO_TMP}/dtd ${REVO_DIR}/ \
  && mv ${VOKO_TMP}/jsc ${REVO_DIR}/ \
  && mv ${VOKO_TMP}/xsl ${HOME_DIR}/files/xsl/ \
#  && cp voko-grundo-${ZIP_SUFFIX}/smb/*.gif /usr/local/apache2/htdocs/revo/smb/ \
#  && cp -r voko-grundo-${ZIP_SUFFIX}/cfg/* /usr/local/apache2/htdocs/revo/cfg/ \
#  && mv voko-grundo-${ZIP_SUFFIX}/dtd /usr/local/apache2/htdocs/revo/ \
#  && mv -f voko-grundo-${ZIP_SUFFIX}/dok/* /usr/local/apache2/htdocs/revo/dok/ \
  && chmod 755 /usr/local/apache2/cgi-bin/*.pl && chmod 755 /usr/local/apache2/cgi-bin/admin/*.pl \
  && mkdir -p ${HOME_DIR}/files/log && chown daemon.daemon ${HOME_DIR}/files/log \
  && ln -sT /usr/local/apache2/cgi-bin/perllib ${HOME_DIR}/files/perllib \
  && ln -sT /usr/local/apache2/htdocs ${HTTP_DIR} \
  && mkdir -p ${HTTP_DIR}/tmp \
  && chown -R ${DAEMON_UID} ${HTTP_DIR}/revo \
  && rm -rf /tmp/*

COPY sxangxoj.rdf ${HTTP_DIR}/
RUN chown ${DAEMON_UID} ${HTTP_DIR}/sxangxoj.rdf

#COPY sercho.xsl ${HOME_DIR}/files/xsl/sercho.xsl

COPY revo/ {REVO_DIR}/
COPY revo/index.html /usr/local/apache2/htdocs/
COPY revo/manifest.json /usr/local/apache2/htdocs/
COPY revo/sw.js /usr/local/apache2/htdocs/


# Basic Auth por cgi/admin
# https://tecadmin.net/setup-apache-basic-authentication/
# https://dzone.com/articles/apache-http-24-how-to-build-a-docker-image-for-ssl
# https://devops.ionos.com/tutorials/set-up-basic-authentication-in-apache-using-htaccess-on-centos-7/


USER root
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd-foreground"]