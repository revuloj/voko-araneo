#!/usr/bin/perl

# (c) 2021 - Wolfram Diestel.
# laŭ GPL2.0

# ni uzas tiun skripton por kompili JSON-dosierojn el XML-fontoj de Revo
# la JSON-dosierojn ni bezonos poste por plenigi la datumbazon

use File::stat;

my $verbose = 1;

my $xmldir = "revo-fonto/revo";
my $vokodir = "voko-grundo";
my $jsondir = "json"; mkdir($jsondir);
my $xsltproc = "xsltproc --path $vokodir/dtd $vokodir/xsl/revo_json.xsl";

# transformu ciujn XML-dosierojn al JSON

print "$xmldir -> $jsondir, daŭras eble 2min...\n" if ($verbose);
my $arts = 0;
for $xml (glob "$xmldir/*.xml") {
    my $json = $xml;
    $json =~ s|^.*/revo/(.*)\.xml|$jsondir/$1.json|;

    if ( ! -e $json || stat($xml)->mtime > stat($json)->mtime) {
        #print "$xml -> $json...\n" if ($verbose);
        $arts++;
        qx($xsltproc $xml > $json);
    }
}

print "daŭro: ".(time - $^T)."s\nart: $arts\n" if ($verbose);
     
