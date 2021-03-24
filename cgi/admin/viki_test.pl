#!/usr/bin/perl

# (c) 2021 Wolfram Diestel
# laŭ GPL 2.0
#
# enmetas la tradukojn el tekstdosiero
# en la artikolojn ( nur por unufoja uzo :)
# la artikoloj estu en la aktuala dosierujo
#
# uzante XML::LibXML ĝi provas eviti la problemon kun pli frua
# merge_trd_cs.pl kiu akcidente forigis partojn de kelkaj artikoloj
#
# donu lingvokodon kaj CSV por tradukoj en la unua kaj dua argumentoj
# donu artikolojn adaptendajn en la cetero (uzante ĵokerojn):
#
#  perl merge_trd_xml.pl he tmp/hebrea_a.csv a*.xml

use XML::LibXML;

use utf8;
binmode(STDOUT, "encoding(UTF-8)");

$debug = 1;

@artikoloj = @ARGV;

for $art (@artikoloj) {
    process_art($art);
}


sub process_art {
    my $artikolo = shift;
    # ni reskribas ĉion al la sama artikolo, kiam ni
    # uzas git-versiadon!
    my $artout = $artikolo; #.".out";
    my $modified = 0;

    print "### ",uc($artikolo)," ###\n";

    # load HTML
    # vd ankaŭ https://metacpan.org/pod/distribution/XML-LibXML/lib/XML/LibXML/Parser.pod#Parser-Options
    $doc = XML::LibXML->load_html(location => $artikolo, validation=>0, recover=>2, expand_entities=>0); #, keep_blanks=>1);

    # nun ni povas uzi $doc (DOM) kiel klarigita en
    # https://metacpan.org/pod/distribution/XML-LibXML/lib/XML/LibXML/Document.pod
    # https://metacpan.org/pod/distribution/XML-LibXML/lib/XML/LibXML/Node.pod
    # https://metacpan.org/pod/distribution/libxml-enno/lib/XML/DOM/NamedNodeMap.pod

    print "DOM!\n";

    # trovu art@mrk kaj altigu la version...
    #my $kapoj = $doc->findnodes('//section[@class="drv"]/h2');
    my $kapoj = $doc->findnodes('//section[@id="s_artikolo"]//h2');

    for $k (@$kapoj) {      
        # kolektu nur rektan tekstenhavon kaj ignoru subelementojn  
        my $text; 
        for $c ($k->childNodes) { $text .= $c->nodeValue(); } 
        # montru
        print "KAP: $text\n$k\n" if ($debug);
    }

}