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

#use strict;
#use CGI qw(:standard);
#use CGI::Carp qw(fatalsToBrowser);
#use IO::Handle;
use XML::LibXML;
use File::Basename;

# propraj perl moduloj estas en:
use lib("/hp/af/ag/ri/files/perllib");
#use Unicode::String qw(utf8);
use utf8; binmode STDOUT, ":utf8";

my $homedir = "/hp/af/ag/ri";
#my $vikiref = "$homedir/www/revo/inx/vikiref.xml"
my $vikiref = "./tmp/vikiref.xml";
# PLIBONIGU: okaze ŝanĝu al https!
my $vpref = 'http://eo.wikipedia.org/wiki';

my $debug = 1;
my $verbose = 1;

my $modified;
my $doc; # la aktuala artikola DOM, globale ni ŝparas sub-argumenton plurloke...
local $XML::LibXML::setTagCompression = 1; # skribante <script .../> rezultas en nevalida HTML...
local $XML::LibXML::skipXMLDeclaration = 1;

@artikoloj = @ARGV;

# enlegu la antaŭpreparitan referencliston
my %refs; my $rcnt = load_vikiref();
die "$vikiref enhavas tro malmultajn elementojn!\n" unless($rcnt>10000);

# nun ni havas la indeksitan liston de ĉiuj referencoj kaj 
# trairas ĉiujn artikolojn por aldoni ankoraŭ mankantajn referencojn
for $art (@artikoloj) {
    process_art($art);
}

sub load_vikiref {
    my $count = 0;
    my $rdoc = XML::LibXML->load_xml(location => $vikiref, expand_entities=>0); 

    # nun ni povas uzi $rdoc (DOM) kiel klarigita en
    # https://metacpan.org/pod/distribution/XML-LibXML/lib/XML/LibXML/Document.pod
    # https://metacpan.org/pod/distribution/XML-LibXML/lib/XML/LibXML/Node.pod
    # https://metacpan.org/pod/distribution/libxml-enno/lib/XML/DOM/NamedNodeMap.pod

    #my $count = $rdoc->indexElements();

    for $r ($rdoc->findnodes('//vikiref/r')) {
        #print $r if ($debug);
        my $a = $r->attributes();
        my $mrk = $a->getNamedItem('r')->textContent();
        my $file = (split /\./, $mrk)[0];
        # ni kreas por ĉiu dosiero (parto de mrk antaŭ la punkto aŭ la tuta parto se ne enestas punkto)
        # indekserojn (mrk => viki)
        $refs->{$file}->{$mrk} = $a->getNamedItem('v')->textContent();
        $count++;        
    }
    print "### vikiref: $count referencoj ###\n" if ($verbose);
    return $count;
}    

sub process_art {
    my $artikolo = shift;
   
    my $file = (split /\./, basename($artikolo))[0];
    my $arefs = $refs->{$file};


    # TODO: provizore ni nur traktas la dosieron, se ni havas referencojn
    # poste ni devos ankaŭ forigi referencojn, kiuj ne plu ekzistas!
    return unless($arefs);    

    # ni reskribas ĉion al la sama artikolo, kiam ni
    # uzas git-versiadon!
    $modified = 0;
    my $artout = $artikolo; #.".out";

    print "### ",$artikolo," ###\n" if ($verbose);

    # load HTML
    # vd ankaŭ https://metacpan.org/pod/distribution/XML-LibXML/lib/XML/LibXML/Parser.pod#Parser-Options
    $doc = XML::LibXML->load_html(location => $artikolo, validation=>0, recover=>2, expand_entities=>0); #, keep_blanks=>1);

    # trovu art@mrk kaj altigu la version...
    #my $kapoj = $doc->findnodes('//section[@class="drv"]/h2');
    my $kapoj = $doc->findnodes('//section[@id="s_artikolo"]//h2');

    for $K (@$kapoj) { 
        kap_update($K,$arefs);
    }

    # nur skribu, se ni efektive aldonis tradukojn, ĉar
    # ankaŭ ŝanĝiĝas iom linirompado kaj kodado de unikodaj literoj en la XML
    if ($modified) {
        print "### skribas aktualigitan artikolon $artout...\n";
        open OUT, ">", $artout || die "Ne povas skribi al '$artout': $!\n";        
        print OUT $doc->toString();
        close OUT;
    } else {
        print "  # ne ŝanĝita\n" if ($verbose);
    }
}

sub kap_update {
    my ($K,$arefs) = @_;
    my $vref;

    # kolektu nur rektan tekstenhavon kaj ignoru subelementojn  
    my $kap; 
    for $ch ($K->childNodes) { 
        if ($ch->nodeType eq XML_TEXT_NODE || $ch->nodeType eq XML_ENTITY_REF_NODE) {
            $kap .= $ch->nodeValue(); 
        } elsif ( $ch->nodeType eq XML_ELEMENT_NODE 
          && $ch->nodeName() eq 'a'
          && $ch->hasAttribute('alt') ) {                
            # rigardu, ĉu tio estas Vikipedio-referenco kaj se jes elprenu href
            my $a = $ch->attributes();
            if ( $a->getNamedItem('alt')->textContent() eq 'Vikipedio') {
                $vref = $a->getNamedItem('href')->textContent();
            }
        }
    }
    $kap = trim($kap);

    # montru
    print "KAP: /$kap/\n[$K]\n" if ($debug);

    # PLIBONIGU: referencoj (markoj) montras foje al nura dosiero
    # tiam verŝajne ni rilatigu ilin al la unua derivaĵo de la artikolo...
    # ĉu ni ŝanĝu tie al konkreta derivaĵo aŭ ĉu ni aŭtomate ŝovu en la unuan de la artikolo?
    my $id = $K->attributes()->getNamedItem('id')->textContent();
    print "id: $id\n" if ($debug);
    my $v = $arefs->{$id};
    if ($v) { 
        print "viki: $v\n" if ($debug); 

        # se enestas $vref kaj tiu diferencas, ni plendu, en pli
        # posta prilaboro ni povus aktualigi, sed ni unue volas kontroli kiel
        # la nova skripto laboras...
        if ($vref && $vref ne "$vpref/$v") {
            print "malsama referenco: $vref != $v ($id)\n"
        } elsif (! $vref) {
            # enmetu novan Viki-referencon
            kreu_vref($K,$v);
            $modified = 1;
        }
    }
}

sub kreu_vref {
    my ($K,$vref) = @_;

    # PLIBONIGU: uzante SVG-fonon ni iam povos rezigni pri la bildeto, sed por ne konfuzi 
    # la malnovan artikolprezenton ni porvizore restas ĉe tio...
    my $img = make_el('img',(
        alt=>'Vikipedio', 
        src=>'../smb/vikio.png',
        title=>'Al Vikipedio',
        border=>'0'));
    my $a = make_el('a',(
        href=>"$vpref/$vref",
        target=>'_new'));
    $a->appendChild($img);
    $K->appendChild($a);
}


# kreu novan elementon inkl. de atributoj
sub make_el{
    my ($name,%attr) = @_;
    my $el = $doc->createElement($name);    
    while (($key, $val) = each %attr) {
        $el->setAttribute( $key, $val);
    }
    return $el;
}

# forigu spacojn komence kaj fine de signoĉeno
sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
