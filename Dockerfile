##### staĝo 1: certigu, ke vi antaŭe kompilis voko-grundo aŭ ŝargis de Github kiel pakaĵo

# VERSION povas esti ŝanĝita de ekstere per --build-arg, jam konsiderata en 'bin/eldono.sh kreo'
ARG VERSION=latest
FROM ghcr.io/revuloj/voko-grundo/voko-grundo:${VERSION} AS grundo 
  # ni bezonos la enhavon de voko-grundo build poste por kopi jsc, stl, dok


##### staĝo 2: Ni devas mem kompili rxp, perl-moduloj por Alpine
FROM alpine:3.23 AS builder
  # https://github.com/docker-library/httpd/blob/c9c8c54099b541910797a90ca9b406e76966902f/2.4/alpine/Dockerfile

# build and install rxp
RUN apk update && apk upgrade \
  && apk add --no-cache \
          ca-certificates \
  && update-ca-certificates \
      \
      \
  # Install tools for building
  && apk add --no-cache --virtual .tool-deps \
          curl file coreutils autoconf g++ libtool make \
          build-base \
      \
  # Install  build dependencies
  && apk add --no-cache --virtual .build-deps \
          linux-headers \
      \
  # Download and prepare rxp sources
  && curl -fL -o /tmp/rxp.tar.gz \
    https://www.inf.ed.ac.uk/research/isddarch/admin/rxp-1.5.2.tar.gz \
  && (echo "	b2a7dbe5350b15078979c63904157f42  /tmp/rxp.tar.gz" \
          | md5sum -c -) \
  && tar -xzf /tmp/rxp.tar.gz -C /tmp/ \
  && cd /tmp/rxp-* \
  && ./configure && make install

# instali kaj ruli perl test harness, perlcritic
RUN apk add --no-cache bash mysql-client perl-dbd-mysql fcgi libxslt \
    perl-cgi perl-fcgi perl-ipc-run perl-log-dispatch perl-uri perl-unicode-string perl-json perl-datetime \
    perl-email-simple perl-email-address perl-extutils-config perl-sub-exporter perl-net-smtp-ssl \
    perl-app-cpanminus perl-extutils-installpaths perl-http-message \
    perl-lwp-protocol-https perl-lwp-useragent-determined  \
    perl-dev openssl ca-certificates \
    # konflikto kun perl-utils (el perl-dev?): perl-test-harness-utils
    && update-ca-certificates \
    && cpanm --notest Email::Sender::Simple Email::Sender::Transport::SMTPS \
                      Log::Dispatch::FileRotate Perl::Critic Test::Perl::Critic
    #&& apk del build-base sed make perl-dev && rm -rf /root/.cpanm/work/*

##### staĝo 2a: Testi la CGI-skriptojn
## PLIBONIGU: ĉar la fina staĝo ne dependas de tiu ĝi docker normale transaltos ĝin
## FROM builder as perl-test

# por testi sintakson, perl-critic
COPY cgi/ /tmp/cgi/
COPY tst/ /tmp/tst/

WORKDIR /tmp

# bazaj testoj por la CGI-skriptoj (sintakso, perlcritic)
# /tmp/test_sukceso ni kopios en la fina staĝo, alie docker simple transsaltus ĝin!
RUN /usr/bin/prove -v /tmp/tst/cgi/0* && touch /tmp/test_sukceso

# kie estas Perl-moduloj instalitaj?
RUN perl -e'print join("\n", @INC, "")' \
  && perl -MLog::Dispatch::FileRotate -e 'print $INC{"Log/Dispatch/FileRotate.pm"} . "\n"' \
  && perl -MEmail::Sender::Simple -e 'print $INC{"Email/Sender/Simple.pm"} . "\n"' \
  && perl -MDBI -e 'print $INC{"DBI.pm"} . "\n"' \
  && perl -MDate::Manip -e 'print $INC{"Date/Manip.pm"} . "\n"'
# perl -MLog::Dispatch::FileRotate -e"print @INC"
#RUN ls -l /usr/lib/perl* && ls /usr/share/perl* \
#    # && ls -l /usr/lib/*/perl* && ls /usr/share/*/perl* \
#    && ls -l /usr/local/lib/perl* && ls /usr/local/share/perl*


##### staĝo 3: Nun ni havas ĉion por krei la finan procezujon kun Apache-httpd, Perl...
FROM httpd:2.4-alpine
LABEL Author=<diestel@steloj.de>
LABEL org.opencontainers.image.description DESCRIPTION

# REVO_FONTO povas esti ŝanĝita al revo-fonto-testo ekstere per --build-arg, jam konsiderata en 'bin/eldono.sh kreo-test'
ARG REVO_FONTO=revo-fonto

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

# certigu testoj estis faritaj kaj sukcesaj
## COPY --from=perl-test /tmp/test_sukceso /tmp/

# kopiu antaŭe faritajn perl-modulojn (cpanm)
COPY --from=builder /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=builder /usr/local/share/perl5 /usr/local/share/perl5

# kopiu antaŭe instalitajn perl-modulojn (apk)
# PLIBONIGU: se la Alpine-eldono de httpd:..-alpine kaj alpine:...
# diferencas, povus okazi problemoj kun *.so-dosieroj
# eble necesus tiujn reinstali aŭ alie certigi kompatibilecon
COPY --from=builder /usr/lib/perl5 /usr/lib/perl5
COPY --from=builder /usr/share/perl5 /usr/share/perl5

# mysql TLS atestilo problemo kun:  
# mariadb-connector-c perl-dev mariadb-connector-c-dev zlib-dev openssl-dev
RUN apk --update --update-cache --upgrade add \
    bash mysql-client perl-dbd-mysql fcgi libxslt \
    #perl-cgi perl-fcgi perl-ipc-run perl-log-dispatch perl-uri perl-unicode-string perl-json perl-datetime \
    #perl-email-simple perl-email-address perl-extutils-config perl-sub-exporter perl-net-smtp-ssl \
    #perl-app-cpanminus perl-extutils-installpaths perl-http-message \
    #perl-lwp-protocol-https perl-lwp-useragent-determined curl wget unzip jq \
    # perl-dev make build-base \
    perl curl wget unzip jq \
    sed openssl ca-certificates \
    && update-ca-certificates \
    #&& cpanm Email::Sender::Simple Email::Sender::Transport::SMTPS Log::Dispatch::FileRotate \
    && sed -i -e "s/daemon:x:2/daemon:x:${DAEMON_UID}/" /etc/passwd 
    #&& apk del build-base sed make perl-dev && rm -rf /root/.cpanm/work/*

COPY --from=builder /usr/local/bin/rxp /usr/local/bin/
COPY --from=builder /usr/local/lib/librxp.* /usr/local/lib/

COPY bin/* /usr/local/bin/
COPY cgi/ /usr/local/apache2/cgi-bin/

COPY tst/ /tmp/tst/

COPY etc/revodb.pm /usr/local/apache2/cgi-bin/perllib/

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

RUN /usr/local/bin/revo_download_gh.sh ${REVO_FONTO} && mv revo /usr/local/apache2/htdocs/ \
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
  && chmod 755 /usr/local/apache2/cgi-bin/*.pl && chmod 755 /usr/local/apache2/cgi-bin/admin/*.pl \
  && mkdir -p ${HOME_DIR}/files/log && chown daemon:daemon ${HOME_DIR}/files/log \
  && ln -sT /usr/local/apache2/cgi-bin/perllib ${HOME_DIR}/files/perllib \
  && ln -sT /usr/local/apache2/htdocs ${HTTP_DIR} \
  && mkdir -p ${HTTP_DIR}/tmp \
  && chown -R ${DAEMON_UID} ${HTTP_DIR}/revo/art ${HTTP_DIR}/revo/hst ${HTTP_DIR}/revo/xml \
                            ${HTTP_DIR}/revo/cfg ${HTTP_DIR}/revo/tez ${HTTP_DIR}/revo/bld ${HTTP_DIR}/revo/inx \
  && rm -rf /tmp/*

COPY sxangxoj.rdf ${HTTP_DIR}/
RUN chown ${DAEMON_UID} ${HTTP_DIR}/sxangxoj.rdf

#COPY sercho.xsl ${HOME_DIR}/files/xsl/sercho.xsl

COPY revo/ ${REVO_DIR}/
COPY revo/index.html /usr/local/apache2/htdocs/
COPY revo/manifest.json /usr/local/apache2/htdocs/
#COPY revo/sw.js /usr/local/apache2/htdocs/

# Basic Auth por cgi/admin
# https://tecadmin.net/setup-apache-basic-authentication/
# https://dzone.com/articles/apache-http-24-how-to-build-a-docker-image-for-ssl
# https://devops.ionos.com/tutorials/set-up-basic-authentication-in-apache-using-htaccess-on-centos-7/

USER root

# problemo en Apline 3.23 mysql-client,
# vd. https://gitlab.alpinelinux.org/alpine/aports/-/issues/17798
# kaj https://github.com/brianmario/mysql2/issues/1379
# por provizora solvo do:
ENV MARIADB_TLS_DISABLE_PEER_VERIFICATION=1
# aldone en bin/setup_cgi_user.sh ni certigas aldonante 
# PassEnv-agordon en httpd.con, ke la CGI-skripto vidas ĝin

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd-foreground"]