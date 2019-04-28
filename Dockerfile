FROM httpd:2.4-alpine
MAINTAINER Wolfram Diestel

# see:
# https://hub.docker.com/_/httpd/
# https://github.com/docker-library/httpd/blob/b2e7d2868e2f92660469ac66187f8f83fe449c65/2.4/alpine/Dockerfile
# https://hub.docker.com/r/cloudposse/apache/~/dockerfile/
# https://hub.docker.com/r/cloudposse/apache-perl/~/dockerfile/
# https://github.com/avast/docker-alpine-perl/blob/master/Dockerfile
#
# https://medium.com/@lojorider/docker-with-cgi-perl-a4558ab6a329

COPY httpd.conf /usr/local/apache2/conf/httpd.conf

RUN apk --update add mysql-client perl-dbd-mysql fcgi libxslt \
    perl-cgi perl-fcgi perl-uri perl-unicode-string perl-datetime \
    curl unzip && rm -f /var/cache/apk/* 

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

ADD . ./

# en revodb.pm estas la konekto-parametroj...
RUN ./revo_download.sh && mv revo /usr/local/apache2/htdocs/ && mv cgi/* /usr/local/apache2/cgi-bin/ \
  && curl -LO https://github.com/revuloj/voko-grundo/archive/master.zip \
  && unzip -q master.zip voko-grundo-master/xsl/* && mv voko-grundo-master/xsl /usr/local/apache2/htdocs/ \
  && mv revodb.pm /usr/local/apache2/cgi-bin/perllib/ \
  && chmod +x /usr/local/apache2/cgi-bin/*.pl && chmod +x /usr/local/apache2/cgi-bin/admin/*.pl \
  &&  mkdir -p /var/www/web277/files && ln -sT /usr/local/apache2/cgi-bin/perllib /var/www/web277/files/perllib \
  &&  mkdir -p /var/www/web277 && ln -sT /usr/local/apache2/htdocs /var/www/web277/html

#COPY sercho.xsl /var/www/web277/html/xsl/sercho.xsl










