#!/usr/bin/perl
package revo::xml2html;

#
# revo::xml2html.pm
# 
# 2009 Wieland Pusch
# 2021 - 2026 Wolfram Diestel

use warnings; use strict;

use CGI qw(:standard);  # por trovi erarojn (escapeHTML)
use Encode;

######################################################################

my $xsldir = "/hp/af/ag/ri/files/xsl";
my $homedir    = "/hp/af/ag/ri";
my $htmldir    = "$homedir/www";
my $revo_base  = "$homedir/www/revo";

sub konv {
  my ($xml, $html, $err, $debug) = @_;

#  print "<pre>xml ".(ref $xml)."</pre>\n";
  if (not ref $xml) {
    open my $in, "<", $xml 
      or die "Ne povas legi $xml: $!\n";
    my $xmltmp = do { local $/ = undef; <$in>};
    $xml = \$xmltmp;
    close $in;
  }
#  print "<pre>xml= $xml\n</pre>\n";
  
  my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
#                      "xalan -XSL ../xsl/revohtml.xsl");
                      "xsltproc --path $revo_base/cfg $xsldir/revohtml.xsl -");
  print CHLD_IN $$xml;
  close CHLD_IN;
#  binmode CHLD_OUT, ":utf8";
  my $enc = "utf-8";
  $$html = Encode::decode($enc, do { local $/ = undef; <CHLD_OUT>});
  close CHLD_OUT;
#  print "<pre>html= ".escapeHTML($$html)."\n</pre>\n" if $debug;
  $$err = do { local $/ = undef;  <CHLD_ERR> };
  print "<pre>err=$$err</pre>\n" if $$err and $debug;
  close CHLD_ERR;

  waitpid($pid, 0); # altenative metu $SIG{CHLD} = 'IGNORE'; 
  # my $exit_code = $?; # >> 8;

#  open IN, "<", "$homedir/html/revo/art/$art.html" or die "open";
#  my $html = join '', <IN>;
#  close IN;

  {
    $$html =~ s{<!DOCTYPE.*?>}{}smx;
  }
  
  # nur por beligi
  $$html =~ s{</title>\n<script}{</title><script}smx;
  $$html =~ s{</script>\n</head>}{</script></head>}smx;
  $$html =~ s{<(h1|h2|dl|dd)>\n<}{<$1><}smxg;
  $$html =~ s{</(h1|h2|h3)>\s+}{</$1>}smxg;
  $$html =~ s{</(span)>\s+<}{</$1><}smxg;
  $$html =~ s{</(dd|dl)>\s+<a}{</$1><a}smxg;
  $$html =~ s{\n(\ +<a\s+href="\#lng_)}{\n   $1}smx;
  $$html =~ s{<br>\n</div>}{<br></div>}smx;
  $$html =~ s{</pre>\n</div>}{</pre></div>}smx;
  $$html =~ s{<hr>\n<span\s+class="redakto">}{<hr><span class="redakto">}smx;
  $$html =~ s{<br>\s+</body>}{<br></body>}smx;
  $$html =~ s{</html>\n}{</html>}smx;

  return 1;
} 
    
######################################################################

1;

