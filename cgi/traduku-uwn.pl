#!/usr/bin/perl

use strict;
#use Encode;
use utf8; binmode STDOUT, ":utf8";

use CGI qw(:standard escape);
use CGI::Carp qw(fatalsToBrowser);

use HTTP::Request;
use LWP::UserAgent;

use JSON;
my $json_parser = JSON->new->allow_nonref;

my $uwn_url = 'http://www.lexvo.org';

# wiktionary-serĉo eblas per:
# http://www.lexvo.org/data/term/epo/kuri

# ekz-e 
# /uwn/entity/epo/kuri
# /uwn/entity/s/v1926311

my $lingvoj = { 
 af => 'afrikaans',
 sq => 'albanian',
 am => 'amharic',
 hy => 'armenian',
 az => 'azerbaijani',
 eu => 'basque',
 be => 'belarusian',
 bs => 'bosnian',
 bg => 'bulgarian',
 ca => 'catalan',
 ceb => 'cebuano',
 ny => 'chichewa',
 zh => 'chinese',
 co => 'corsican',
 hr => 'croatian',
 cs => 'czech',
 da => 'danish',
 nl => 'dutch',
 eo => 'esperanto',
 es => 'estonian',
 tl => 'filipino',
 fi => 'finnish',
 fr => 'french',
 fy => 'frisian',
 gl => 'galician',
 ka => 'georgian',
 de => 'german',
 el => 'greek',
 ht => 'haitian',
 ha => 'hausa',
 haw => 'hawaiian',
 he => 'hebrew',
 hmn => 'hmong',
 hu => 'hungarian',
 is => 'icelandic',
 ig => 'igbo',
 id => 'indonesian',
 ga => 'irish',
 it => 'italian',
 ja => 'japanese',
 jw => 'javanese',
 kk => 'kazakh',
 km => 'khmer',
 ko => 'korean',
 kmr => 'kurmanji',
 ky => 'kyrgyz',
 lo => 'lao',
 lat => 'latin',
 lv => 'latvian',
 lt => 'lithuanian',
 lb => 'luxembourgish',
 mk => 'macedonian',
 mg => 'malagasy',
 ml => 'malayalam',
 mt => 'maltese',
 mi => 'maori',
 mn => 'mongolian',
 my => 'burmese',
 no => 'norwegian',
 ps => 'pashto',
 fa => 'persian',
 po => 'polish',
 pt => 'portuguese',
 ro => 'romanian',
 ru => 'russian',
 sm => 'samoan',
 sr => 'serbian',
 sn => 'shona',
 sd => 'sindhi',
 si => 'sinhala',
 sk => 'slovak',
 sl => 'slovenian',
 so => 'somali',
 hi => 'spanish',
 su => 'sundanese',
 sw => 'swahili',
 sv => 'swedish',
 tg => 'tajik',
 tr => 'turkish',
 uk => 'ukrainian',
 ur => 'urdu',
 uz => 'uzbek',
 vi => 'vietnamese',
 xh => 'xhosa',
 yi => 'yiddish',
 yo => 'yoruba',
 zu => 'zulu',
 bn => 'bangla',
 hi => 'hindi',
 ta => 'tamil',
 te => 'telugu',
 gu => 'gujarati',
 mr => 'marathi',
 kn => 'kannada',
 th => 'thai',
 cy => 'welsh',
 ar => 'arabic',
 ms => 'malay',
 ne => 'nepali',
 pa => 'punjabi'
};

#my $json_parser = JSON->new->allow_nonref;
my $s = param('sercho');
my $results = {};

#print header(-type=>'application/json',-charset=>'utf-8');
print header(-type=>'application/json',-charset=>'utf-8');

# ni kontrolu la serĉatan vorton, sed ja permesu kelkajn apartajn signojn por
# permesi ion kiel (n,p)-matrico ks:
unless ($s =~ /^[\pL\-\+]{0,50}$/) {
    exit 1;
}

# nun ni serĉu je interlingvaj ligoj de Vikipedio (langlinks)
my $sercho = escape($s);
my $res = get_page("/uwn/entity/epo/$sercho");

    # en lexvo/uwn ŝajne ne eblas RDF, sed nur HTML, do ni devos serĉi rezultojn tiajn
    #        <tr class="r2">
    #            <td width="15%" valign="top">means</td>
    #            <td><a href="/uwn/entity/s/n8873622;jsessionid=node017m52ejacszdz13l869ir21w3111378327.node0">(noun) the
    #                    capital and largest city of England; located on the Thames in southeastern England; financial
    #                    and industrial and cultural center<br />British capital, London, Greater London, capital of the
    #                    United Kingdom</a></td>
    #        </tr>
    #        <tr class="r1">
    #            <td width="15%" valign="top">means</td>
    #            <td><a href="/uwn/entity/e/GBLON;jsessionid=node017m52ejacszdz13l869ir21w3111378327.node0">e/GBLON</a>
    #            </td>
    #        </tr>
    #        <tr class="r2">
    #            <td width="15%" valign="top">means</td>
    #            <td><a href="/uwn/entity/e/London%20ontario;jsessionid=node017m52ejacszdz13l869ir21w3111378327.node0">e/London
    #                    ontario</a></td>
    #        </tr>

#print "$result\n\n";
$res =~ s/<td[^>]*>means<\/td>\s*<td>(.*?)<\/td>/process($1)/sieg;

print $json_parser->encode($results);

#########################################################

my $desc;
my $lex;


sub process {
    my $a = shift;

    #print "A: $a\n";

    $desc = [];
    $lex = {};

    if ($a =~ /<a\s+href="([^"]+)">(.*?)<\/a>/) {
        my $url = $1;
        my $dsc = $2;
        my $data = get_page($1);

        #print "RES: $dsc $url\n";

    # tradukoj aperas tiel nun en la datumoj
    # <td width="15%" valign="top">lexicalization</td>
    # <td><a href="/uwn/entity/afr/Londen;jsessionid=node01ba7g9hdd2gilp7cx7guz5i4v11381783. #node0"
    #    >afr: <span lang="af">Londen</span></a>
    # </td>
    # ...
    # <td width="15%" valign="top">has gloss</td>
    # <td>epo: <span lang="eo">Londono (angle: London) estas urbo en suda Ontario (Kanado). Norde de la urbo-centro troviĝas
    #         la Universitato de Okcidenta Ontario, la trie plej granda universitato de Ontario.</span></td>
    # ...
    #     <td width="15%" valign="top">lexicalization</td>
    #     <td><a href="/uwn/entity/epo/Londono%2C%20Ontario;jsessionid=node01ba7g9hdd2gilp7cx7guz5i4v11381783.node0">epo:
    #             <span lang="eo">Londono, Ontario</span></a></td>
    # ...
    #     <td width="15%" valign="top">lexicalization</td>
    #     <td><a href="/uwn/entity/epo/Londono;jsessionid=node01ba7g9hdd2gilp7cx7guz5i4v11381783.node0">epo: <span
    #                 lang="eo">Londono</span></a></td>

        #print "DATA: $data\n\n\n";


        $data =~ s/<td[^>]*>has gloss<\/td>\s*<td>epo:\s*(.*?)<\/td>/epo_desc($1)/sieg;
        $data =~ s/<td[^>]*>lexicalization<\/td>\s*<td>(.*?)<\/td>/lex($1)/sieg;

        my $r = (split /;/, $url)[0]; 
        $results->{$r} = {
            dsc => $dsc,
            dif => $desc,
            trd => $lex
        }
    }

    sub epo_desc {
        my $s = shift;
        if ($s =~ /<span[^>]*>(.*?)<\/span/) {
            #print "DIF: $1\n";
            push @$desc, $1;
        }
    }

    sub lex {
        my $a = shift;
        if ($a =~ /<a\s+href="([^"]+)">([a-z]{3}):\s+<span[^>]*>([^<]+)<\//) {
            #print "$2: $3\n";
            $lex->{$2} = $3;
        }
    }
}


sub get_page {
    my $page = shift;
    my $request = HTTP::Request->new(GET=>$uwn_url.$page);

    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);

    if ($response->is_success) {
        return $response->decoded_content;
    } else {
        die $response->status_line;
    }
}
