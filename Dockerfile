FROM alpine:3.10 as builder

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

RUN apk --update --update-cache --upgrade add mysql-client perl-dbd-mysql fcgi libxslt \
    perl-cgi perl-fcgi perl-uri perl-unicode-string perl-datetime perl-xml-rss \
    perl-email-simple perl-email-address perl-extutils-config perl-sub-exporter perl-net-smtp-ssl \
    perl-app-cpanminus perl-extutils-installpaths make \
    curl unzip jq && rm -f /var/cache/apk/* \
    && cpanm Email::Sender::Simple Email::Sender::Transport::SMTPS \
    && sed -i -e "s/daemon:x:2/daemon:x:${DAEMON_UID}/" /etc/passwd

COPY --from=builder /usr/local/bin/rxp /usr/local/bin/
COPY --from=builder /usr/local/lib/librxp.* /usr/local/lib/

# mankas "rxp" pro Alpine. Vd.:
# http://www.cogsci.ed.ac.uk/~richard/rxp.html
# http://www.inf.ed.ac.uk/research/isdd/admin/package?view=1&id=145
# https://packages.debian.org/source/jessie/rxp
#
# alternative oni povus uzi https://pkgs.alpinelinux.org/package/edge/testing/x86/xerces-c

#    && install "shadow"... && usermod -u ${DAEMON_UID} daemon
    
#lighttpd perl perl-lwp-protocol-https perl-dbd-pg perl-dbd-mysql perl-dbd-sqlite 
# perl-cgi-psgi perl-cgi perl-fcgi perl-term-readkey perl-xml-rss perl-crypt-ssleay 
# perl-crypt-eksblowfish perl-crypt-x509 perl-html-mason-psgihandler perl-fcgi-procmanager
# perl-mime-types perl-list-moreutils perl-json perl-html-quoted perl-html-scrubber 
# perl-email-address perl-text-password-pronounceable perl-email-address-list 
# perl-html-formattext-withlinks-andtables perl-html-rewriteattributes 
# perl-text-wikiformat perl-text-quoted perl-datetime-format-natural 
# perl-date-extract perl-data-guid perl-data-ical perl-string-shellquote 
# perl-convert-color perl-dbix-searchbuilder perl-file-which perl-css-squish 
# perl-tree-simple perl-plack perl-log-dispatch perl-module-versions-report 
# perl-symbol-global-name perl-devel-globaldestruction perl-parallel-prefork
# perl-cgi-emulate-psgi perl-text-template perl-net-cidr perl-apache-session 
# perl-locale-maketext-lexicon perl-locale-maketext-fuzzy perl-regexp-common-net-cidr 
# perl-module-refresh perl-date-manip perl-regexp-ipv6 perl-text-wrapper 
# perl-universal-require perl-role-basic perl-convert-binhex perl-test-sharedfork 
# perl-test-tcp perl-server-starter perl-starlet make gnupg gcc perl-dev libc-dev 

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
  && curl -LO https://github.com/revuloj/voko-grundo/archive/master.zip \
  && unzip -q master.zip voko-grundo-master/xsl/* voko-grundo-master/dok/* \
  && rm master.zip \
  && mv voko-grundo-master/xsl /usr/local/apache2/htdocs/ \
  && mv -f voko-grundo-master/dok/* /usr/local/apache2/htdocs/revo/dok/ \
  && cp -r /usr/local/apache2/htdocs/xsl/inc /usr/local/apache2/htdocs/revo/xsl/ \
  && chmod +x /usr/local/apache2/cgi-bin/*.pl && chmod +x /usr/local/apache2/cgi-bin/admin/*.pl \
  && mkdir -p /var/www/web277/files/log && chown daemon.daemon /var/www/web277/files/log \
  && ln -sT /usr/local/apache2/cgi-bin/perllib /var/www/web277/files/perllib \
  && ln -sT /usr/local/apache2/htdocs /var/www/web277/html \
  && chown -R ${DAEMON_UID} /var/www/web277/html/revo

COPY sxangxoj.rdf /var/www/web277/html/
RUN chown ${DAEMON_UID} /var/www/web277/html/sxangxoj.rdf

#COPY sercho.xsl /var/www/web277/html/xsl/sercho.xsl

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
