#!/usr/bin/perl

#
# redaktu.pl
# 
# 2008-10-30 Wieland Pusch
# 2026 Wolfram Diestel
#
# Malnova skripto de Revo-redaktilo:
# Ĝi kreas la formularon por redaktado
# kaj ĉe "konservu" kontrolas la XML-tekston kaj 
# forsendas al redaktoservo kaj la redaktanto,
# se ĉio estas en ordo.

use warnings; use strict; 
use utf8; use open ':std', ':encoding(UTF-8)';

use CGI qw(:standard *table); use CGI::Carp qw(fatalsToBrowser);
use DBI();

use IO::Handle;
use IPC::Open3; local $SIG{CHLD} = 'IGNORE'; # alternative uzu waitpid kun open3
# use Encode;

use Text::Tabs;
use POSIX qw(strftime);

# propraj perl moduloj estas en:
# por testi loke vi povas aldoni simbolan ligon: ln -s /home/revo/voko/cgi/perllib /hp/af/ag/ri/files/
use lib("/hp/af/ag/ri/files/perllib");
use revo::decode; use revo::encode;
use revo::xml2html; use revo::checkxml;
use revodb; use revo::wrap;

STDOUT->autoflush(1);
# $| = 1;

# por testi vi povas aldoni simbolan ligon:  ln -s /home/revo /hp/af/ag/ri/www
my $homedir = "/hp/af/ag/ri";
my $htmldir    = "$homedir/www";
my $revo_base    = "$homedir/www/revo";
my $xml_dir    = "$revo_base/xml";
my $smlog = "$homedir/files/log/sendmail.log";

local $ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
local $ENV{'PATH'} = "$ENV{'PATH'}:$homedir/files/bin";
local $ENV{'LOCPATH'} = "$homedir/files/locale";
autoEscape(0);

my $xml_max_len = 500000;
my $art_max_len = 25;
my $red_max_len = 80;
my $sxg_max_len = 255;

# my $enc = "utf-8";

my $debugmsg;
my $art = param('art');
#$debugmsg .= "art = $art\n";
my $mrk = param('mrk');

my $redaktanto = param('redaktanto') || cookie(-name=>'redaktanto') || 'via registrita retadreso';
my $debug = $redaktanto eq 'Wieland@wielandpusch.de';

my $sxangxo = param('sxangxo'); #Encode::decode($enc, param('sxangxo'));
$debugmsg .= "sxangxo=$sxangxo" if $debug;

# akiru XML por redaktado (el parametro, ŝablono, ekzistanta artikolo)
my $xmlTxt = param('xmlTxt');

my $xml;

my $xml2 = '';
if ($xmlTxt) {
  $xml2 = normigu_xml($xmlTxt)
}

#$debugmsg .= "xmlTxt = $xmlTxt\n";

# redaktata artikolo
if ($xml2) {
  $xml = $xmlTxt; # nenormigita xml
#  $debugmsg .= "1 xml=\n$xml" if $debug;

# nova artikolo
} elsif (param('button') eq 'kreu') {
  $xml2 = xml_nova_art();

# elŝutu XML por artikolo
} elsif ($art) {
  $xml = elshutu_xml($art);

}

# flago metita laŭ rezultoj en trakti_sxangxon, redaktanto_permeso...
my $ne_konservu;

my ($checklng, $checkxml, $errline, $errchar);
($checkxml, $errline, $errchar) = checkxml($xml2) 
  if ($xml2);
#$debugmsg .= "errline = $errline\n";

my ($prelines, $postlines);
my ($pos, $line, $lastline) = position($errline,$errchar);


use open ':std', ':encoding(UTF-8)';
## binmode STDOUT, ":utf8";

my @coky = cookies();

print_html_start();


## print <<'EOD' if 0;
## <div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
## <p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>Provversio</b></span></p>
## <p>Momente tiu pa&#x011D;o estas nur por elprovi</p>
## <p><i>Viaj &#349;an&#x011D;oj momente estas sendataj al vi kaj al la a&#x016d;toro (sendepende de la subaj butonoj) !</i></p>
## </div><br>
## EOD

my (%fakoj, %stiloj);

if ($art) {
  %fakoj = fak_listo();
  %stiloj = stl_listo();
}

# ne faru ion ajn, se mankas la XML-teksto aŭ valida komando ...
check(param('xmlTxt'),"xmlTxt");
# check(param('button') eq 'konservu' || param('button') eq 'antaŭrigardu' || param('button') eq 'kreu'), "button");

## validigu la ceteran parametrojn...
check(length(param('xmlTxt')) < $xml_max_len, "xmlTxt");
check(length(param('art')) < $art_max_len, "art");
check(length(param('sxangxo')) < $sxg_max_len, "sxangxo");
check(length(param('redaktanto')) < $red_max_len, "redaktanto");
check(param('art') =~ m{^[a-z0-9]+$}x, "art rx");

# tio ne estas tute preciza testo, sed poste ja ankaŭ trarigardas la liston...
# la preciza estas iom longa: http://www.ex-parrot.com/~pdw/Mail-RFC822-Address.html
check(! param('redaktanto') 
  || param('redaktanto') =~ m{^
    [\w\.-]+
    @[\w\.-]+
    \.\w{2,12}
  $}x, 
  "red rx"); 

# Konektiĝu kun la datumbazo
my $dbh = revodb::connect();

#print pre('dbconnect'." size=".length($xml2)) if $debug;
#print pre('button='.Encode::decode($enc, param('button'))."   ".(Encode::is_utf8(param('button')))."-".(Encode::is_utf8("antaŭrigardu"))) if $debug;

#if (Encode::decode($enc, param('button')) eq "antaŭrigardu" or param('button') eq 'konservu') {
if ( param('button') eq "antaŭrigardu" or param('button') eq 'konservu') {

  chdir($revo_base."/xml") or die "Ne eblas 'chdir' al xml/: $!\n";    
  xml2html_print(\$xml2);

  #### kontroloj...
  # xml
  print $checkxml.br."\n";
  # lingoj
  print $checklng.br.br."\n" if ($checklng);
  # tradukoj
  trd_kontrolo(\$xml2);
  # referencoj
  my @ref_err = ref_kontrolo(\$xml);
  # fakoj
  fak_kontrolo(\$xml2);
  # markoj
  mrk_kontrolo(\$xml2);
  # ŝanĝindiko de la redaktanto
  $sxangxo = trakti_sxangxon($sxangxo);

  print <<'EOD';
</div><br>
EOD

}

my $sth;

if ($redaktanto) {

  redaktanto_permeso();

  if (param('button') eq 'konservu') {
    konservu();
  }
}

$dbh->disconnect() if $dbh;

# por ke la formularo ne konvertu &lt; al < ktp.

## no critic (RegularExpressions::RequireExtendedFormatting)
$xml =~ s/&lt;/&amp;lt;/g;
$xml =~ s/&gt;/&amp;gt;/g;
## use critic

#$xml = Encode::encode($enc, $xml) if $xml2;
if (param('xmlTxt')) {
  param(-name=>'xmlTxt', -value => $xml);
}
param(-name=>'sxangxo', -value => $sxangxo);

print_formularo();

print_klarigojn();

print end_html();

#################################################################
# Helpfunkcioj

sub normigu_xml {
  my $xml_ = shift;
  #$xml_ = Encode::decode($enc, $xml_);

  $xml_ =~ s{\r\n}{\n}xg;
  $debugmsg .= "vor wrap -> $xml_\n <- end wrap\n";
  my $id;
  if ($xml_ =~ s{"\$(Id:.*?)\$"}{"\$Id:\$"}x) {
    $debugmsg .= "ID: $1-\n";
    $id = $1;
  }
  $xml_ = revo::wrap::wrap($xml_);
  $xml_ =~ s{"\$Id:\$"}{"\$$id\$"}x if $id;
  # $debugmsg .= "wrap -> $xml_\n <- end wrap\n";

  return revo::encode::encode2($xml_, 20) 
}

sub elshutu_xml {
  my $art_ = shift;

  # $debugmsg .= "open\n";
  open my $in, "<", "$homedir/www/revo/xml/$art_.xml" 
    or die "Ne povas legi $art_.xml: $!\n";

  my $xml_ = do { local $/ = undef; <$in>};
  close $in;

  return revo::decode::rvdecode($xml_);
  #$xml = Encode::decode($enc, $xml);
}

sub css_stiloj {
  return<<'EOD';
a.butono1 {
  background-color: LightGray;
  font-family: monospace;
  font-size: 90%;
  letter-spacing: -0,1pt;
  padding: 0px 1px 0px 1px;
}
a.butono1:link, a.butono1:visited {
  border: 1px outset black;
  line-height:150%;
  color: #000;
  text-decoration: none;
  text-align: center;
}
a.butono1:hover {
 border-color: red;
 color: red;
}
.averto {
  border: 2px solid #E0E0A0;
  font-style: italic;
  padding: 0.3em 0.5em;
  width: 66%;
}
input {
  margin: 3px 1px 0px 1px;
}
.rubriko {
  text-align: right;
}
textarea {
  margin: 3px 1px 0px 1px;
}
.piedlinio {color: #104040; text-align: center}
.kuketoaverto { position: fixed; bottom: 0px; left: 5%; width: 90%; min-height:7em;
		background-color: #c0c090; margin: 0; display: none;
		border-radius: 5px 5px 0 0; border: 1px solid #303030; border-bottom: none
	      }
.kuketoaverto P { text-align:center }
.kuketoaverto FORM { text-align:center }
EOD
}

sub js_skripto {
  return<<'END';
function str_repeat(rStr, rNum) {
 var nStr="";
 for (var x=1;x<=rNum;x++) {nStr+=rStr;}
 return nStr;
} 

function showhide(id){
  if (document.getElementById){
    obj = document.getElementById(id);
    objb = document.getElementById(id+"b");
    if (obj.style.display == "none"){
      obj.style.display = "";
      objb.style.display = "none";
    } else {
      obj.style.display = "none";
      objb.style.display = "";
    }
  }
} 

function get_ta() {
  var txtarea;
  if (document.f) {
    txtarea = document.f.xmlTxt;
  } else {
	// some alternate form? take the first one we can find
	var areas = document.getElementsByTagName('textarea');
	txtarea = areas[0];
  }
  return txtarea;
}

function str_indent() {
  var txtarea = get_ta();
  var indent = 0;
  if (document.selection  && document.selection.createRange) { // IE/Opera
	var range = document.selection.createRange();
	range.moveStart('character', - 200); 
	var selText = range.text;
	var linestart = selText.lastIndexOf("\n");
	while (selText.charCodeAt(linestart+1+indent) == 32) {indent++;}
  } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
	var startPos = txtarea.selectionStart;
	var linestart = txtarea.value.substring(0, startPos).lastIndexOf("\n");
	while (txtarea.value.substring(0, startPos).charCodeAt(linestart+1+indent) == 32) {indent++;}
  }
  return (str_repeat(" ", indent));
}

function cxigi(b, key) {
  var n="";
  var k=String.fromCharCode(key);

       if (b=='s'     ) n='\u015D';
  else if (b=='\u015D') n='s'+k;
  else if (b=='S'     ) n='\u015C';
  else if (b=='\u015C') n='S'+k;

  else if (b=='c'     ) n='\u0109';
  else if (b=='\u0109') n='c'+k;
  else if (b=='C'     ) n='\u0108';
  else if (b=='\u0108') n='C'+k;

  else if (b=='h'     ) n='\u0125';
  else if (b=='\u0125') n='h'+k;
  else if (b=='H'     ) n='\u0124';
  else if (b=='\u0124') n='H'+k;

  else if (b=='g'     ) n='\u011D';
  else if (b=='\u011D') n='g'+k;
  else if (b=='G'     ) n='\u011C';
  else if (b=='\u011C') n='G'+k;

  else if (b=='u'     ) n='\u016D';
  else if (b=='\u016D') n='u'+k;
  else if (b=='U'     ) n='\u016C';
  else if (b=='\u016C') n='U'+k;

  else if (b=='j'     ) n='\u0135';
  else if (b=='\u0135') n='j'+k;
  else if (b=='J'     ) n='\u0134';
  else if (b=='\u0134') n='J'+k;

  return n;
}

function klavo(event) {
  var key = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
//  alert(key);
  if (key == 13) {
    var txtarea = get_ta();
    var selText, isSample = false;

    if (document.selection  && document.selection.createRange) { // IE/Opera
      //save window scroll position
      if (document.documentElement && document.documentElement.scrollTop)
	var winScroll = document.documentElement.scrollTop
      else if (document.body)
	var winScroll = document.body.scrollTop;
      //get current selection  
      txtarea.focus();
      var range = document.selection.createRange();
      selText = range.text;

      range.text = "\n" + str_indent();
      //mark sample text as selected
      range.select();   
      //restore window scroll position
      if (document.documentElement && document.documentElement.scrollTop)
	document.documentElement.scrollTop = winScroll
      else if (document.body)
	document.body.scrollTop = winScroll;
      return false;
    } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
      //save textarea scroll position
      var textScroll = txtarea.scrollTop;
      //get current selection
      txtarea.focus();
      var startPos = txtarea.selectionStart;
      var endPos = txtarea.selectionEnd;
      var tmpstr = "\n" + str_indent();
      txtarea.value = txtarea.value.substring(0, startPos)
			+ tmpstr
			+ txtarea.value.substring(endPos, txtarea.value.length);
      txtarea.selectionStart = startPos + tmpstr.length;
      txtarea.selectionEnd = txtarea.selectionStart;
      //restore textarea scroll position
      txtarea.scrollTop = textScroll;
      return false;
    }
  } else if (key == 88 || key == 120) {   // X or x
    if (event.altKey) {	// shortcut alt-x  --> toggle cx
      document.f.cx.checked = !document.f.cx.checked;
      return false;
    }

    if (!document.f.cx.checked) return true;
    var txtarea = get_ta();
    if (document.selection  && document.selection.createRange) { // IE/Opera
      //save window scroll position
      if (document.documentElement && document.documentElement.scrollTop)
	var winScroll = document.documentElement.scrollTop
      else if (document.body)
	var winScroll = document.body.scrollTop;
      //get current selection  
      txtarea.focus();
      var range = document.selection.createRange();
      var selText = range.text;
      if (selText != "") return true;
      range.moveStart('character', - 1); 
      var before = range.text;
      var nova = cxigi(before, key);
      if (nova != "") {
        range.text = nova;
        return false;
      }
    } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
      var startPos = txtarea.selectionStart;
      var endPos = txtarea.selectionEnd;
      if (startPos != endPos || startPos == 0) { return true; }
      var before = txtarea.value.substring(startPos - 1, startPos);
      var nova = cxigi(before, key);
      if (nova != "") {
	//save textarea scroll position
	var textScroll = txtarea.scrollTop;
	txtarea.value = txtarea.value.substring(0, startPos - 1)
		+ nova
		+ txtarea.value.substring(endPos, txtarea.value.length);
	txtarea.selectionStart = startPos + nova.length - 1;
	txtarea.selectionEnd = txtarea.selectionStart;
	//restore textarea scroll position
	txtarea.scrollTop = textScroll;
        return false;
      }
    }
  } else if (key == 84 || key == 116 || key == 1090 || key == 1058) {   // T or t or kir-t or kir-T
    if (event.altKey) {	// shortcut alt-t  --> trd
      insertTags2('<trd lng="',document.getElementById('trdlng').value,'">','</trd>','');
    }
  }
}

function insertTags2(tagOpen, tagAttr, tagEndOpen, tagClose, sampleText) {
  if (tagAttr == "") {
    insertTags(tagOpen, tagEndOpen+tagClose, sampleText)
  } else {
    insertTags(tagOpen+tagAttr+tagEndOpen, tagClose, sampleText)
  }
}

function indent(offset) {
  var txtarea = get_ta();
  var selText, isSample=false;

  if (document.selection  && document.selection.createRange) { // IE/Opera
    alert("tio ankoraux ne funkcias.");
  } else if (txtarea.selectionStart || txtarea.selectionStart==0) { // Mozilla

    //save textarea scroll position
    var textScroll = txtarea.scrollTop;
    //get current selection
    txtarea.focus();
    var startPos = txtarea.selectionStart;
	if (startPos > 0) {
	  startPos--;
	}
    var endPos = txtarea.selectionEnd;
	if (endPos > 0) {
	  endPos--;
	}
    selText = txtarea.value.substring(startPos, endPos);
    if (selText=="") {
      alert("Marku kion vi volas en-/elsxovi.");
    } else {
      var nt;
      if (offset == 2)
        nt = selText.replace(/\n/g, "\n  ");
      else 
        nt = selText.replace(/\n  /g, "\n");
      txtarea.value = txtarea.value.substring(0, startPos)
			+ nt
			+ txtarea.value.substring(endPos, txtarea.value.length);
      txtarea.selectionStart = startPos+1;
      txtarea.selectionEnd = startPos + nt.length+1;

      //restore textarea scroll position
      txtarea.scrollTop = textScroll;
    }
  } 
}

// apply tagOpen/tagClose to selection in textarea,
// use sampleText instead of selection if there is none
function insertTags(tagOpen, tagClose, sampleText) {
  var txtarea = get_ta();
  var selText, isSample=false;

  if (document.selection  && document.selection.createRange) { // IE/Opera
    //save window scroll position
    if (document.documentElement && document.documentElement.scrollTop)
      var winScroll = document.documentElement.scrollTop
    else if (document.body)
      var winScroll = document.body.scrollTop;
    //get current selection  
    txtarea.focus();
    var range = document.selection.createRange();
    selText = range.text;
    //insert tags
    checkSelectedText();
    range.text = tagOpen + selText + tagClose;
    //mark sample text as selected
    if (isSample && range.moveStart) {
      if (window.opera)
	tagClose = tagClose.replace(/\n/g,'');
	range.moveStart('character', - tagClose.length - selText.length); 
	range.moveEnd('character', - tagClose.length); 
      }
      range.select();   
      //restore window scroll position
      if (document.documentElement && document.documentElement.scrollTop)
	document.documentElement.scrollTop = winScroll
      else if (document.body)
	document.body.scrollTop = winScroll;

  } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla

    //save textarea scroll position
    var textScroll = txtarea.scrollTop;
    //get current selection
    txtarea.focus();
    var startPos = txtarea.selectionStart;
    var endPos = txtarea.selectionEnd;
    selText = txtarea.value.substring(startPos, endPos);
    //insert tags
    checkSelectedText();
    txtarea.value = txtarea.value.substring(0, startPos)
			+ tagOpen + selText + tagClose
			+ txtarea.value.substring(endPos, txtarea.value.length);
    //set new selection
    if (isSample) {
      txtarea.selectionStart = startPos + tagOpen.length;
      txtarea.selectionEnd = startPos + tagOpen.length + selText.length;
    } else {
      txtarea.selectionStart = startPos + tagOpen.length + selText.length + tagClose.length;
      txtarea.selectionEnd = txtarea.selectionStart;
    }
    //restore textarea scroll position
    txtarea.scrollTop = textScroll;
  } 

  function checkSelectedText(){
    if (!selText) {
      selText = sampleText;
      isSample = true;
    } else if (selText.charAt(selText.length - 1) == ' ') { //exclude ending space char
      selText = selText.substring(0, selText.length - 1);
      tagClose += ' '
    } 
  }
}

function lines(str){try {return((str.match(/[^\n]*\n[^\n]*/gi).length));} catch(e) {return 0;}}

function nextTag(tag, dir) {
  var txtarea = get_ta();
  if (document.selection  && document.selection.createRange) { // IE/Opera
    alert("tio ankoraux ne funkcias.");
  } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
    var startPos = txtarea.selectionStart;
    var t;
    var pos;
    if (dir > 0) {
      t = txtarea.value.substring(startPos+1);
      pos = startPos + 1 + t.indexOf(tag);
    }
    if (dir < 0) {
      t = txtarea.value.substring(0, startPos);
      pos = t.lastIndexOf(tag);    
    }
    txtarea.selectionStart = pos;
    txtarea.selectionEnd = pos;
    txtarea.focus();
    var line = lines(txtarea.value.substring(0,pos))-10;
    var lastline = lines(txtarea.value.substring(pos))+line+10;
    if (line < 0) line = 0;
    if (line > lastline) line = lastline;
    txtarea.scrollTop = txtarea.scrollHeight * line / lastline;   

//    alert("tio baldaux funkcias. tag="+tag+" pos="+pos+" line="+line+ " lastline="+lastline);
//    alert("scrollTop="+txtarea.scrollTop+" scrollHeight="+txtarea.scrollHeight);
  }
}

function sf(pos, line, lastline) {
  document.f.xmlTxt.focus();
  var txtarea = get_ta();
  if (document.selection  && document.selection.createRange) { // IE/Opera
    var range = document.selection.createRange();
    range.moveEnd('character', pos); 
    range.moveStart('character', pos); 
    range.select();
    range.scrollIntoView(true);
  } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
    txtarea.selectionStart = pos;
    txtarea.selectionEnd = txtarea.selectionStart;
    var scrollTop = txtarea.scrollHeight * line / lastline;
//    alert("scrollTop="+scrollTop);
    txtarea.scrollTop = scrollTop;
  }

  checkCookieConsent();
}

function checkCookieConsent() {
    var cookies = document.cookie;
    var found = cookies.indexOf('revo-konsento=jes');
    if (found >= 0) {
	document.getElementById('kuketoaverto').style.display = 'none'; 
    } else {
	document.getElementById('kuketoaverto').style.display = 'block'; 
    }
}

function setCookieConsent() {
    var CookieDate = new Date;
    var ExpireDate = new Date; ExpireDate.setFullYear(CookieDate.getFullYear() + 50);
    document.cookie = 'revo-konsento=jes ' + CookieDate.toISOString() +'; expires=' + ExpireDate.toUTCString() + '; path=/;';
    document.getElementById('kuketoaverto').style.display = 'none'; 
}    
END
}

sub xml_nova_art {
  my $xml_ =<<'EOD';
<?xml version="1.0"?>
<!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd">

<vortaro>
<art mrk="\$Id\$">
<kap>
    <rad>$art</rad>/o <fnt><bib>PIV1</bib></fnt>
</kap>
<drv mrk="$art.0o">
  <kap><tld/>o</kap>
  <snc mrk="$art.0o.SNC">
    <uzo tip="fak"></uzo>
    <dif>
      <tld/>o estas:
      <ekz>
        ...
        <fnt><bib></bib>, <lok></lok></fnt>
      </ekz>
    </dif>
  </snc>
  <trd lng=""></trd>
</drv>
</art>
</vortaro>
EOD
  return revo::encode::encode2($xml_, 20);
}

sub cookies {

  my @cookies;
  my $konsento = substr(cookie(-name=>'revo-konsento')||'',0,3) eq 'jes';

  if ($konsento) {
      push @cookies, cookie(-name=>'redaktanto', -value => param('redaktanto'), -path => '/cgi-bin/') if param('redaktanto');
      push @cookies, cookie(-name=>'trdlng',     -value => param('trdlng'), -path => '/cgi-bin/')     if param('trdlng');
      push @cookies, cookie(-name=>'klrtip',     -value => param('klrtip'), -path => '/cgi-bin/')     if param('klrtip');
      push @cookies, cookie(-name=>'reftip',     -value => param('reftip'), -path => '/cgi-bin/')     if param('reftip');
      push @cookies, cookie(-name=>'sxangxo',    -value => param('sxangxo'), -path => '/cgi-bin/')    if param('sxangxo');
      push @cookies, cookie(-name=>'cx',         -value => param('cx') || 0 , -path => '/cgi-bin/');
  }

  return @cookies;
}

sub fak_listo {
  # legu la fakoliston
  my %fak = ('' => '');
  open my $FAK, '<:encoding(UTF-8)', "$revo_base/cfg/fakoj.xml" 
    or die "Ne povas malfermi dosieron fakoj.xml\n";
  my @fakoj_ = <$FAK>; close $FAK;

  for (@fakoj_) {
    if (m{
        <fako\s+
        kodo="([^"]+)"
        [^>]*
        >([^<]+)</fako>
      }xi) {
      $fak{$1} = "$1-$2"; #Encode::decode($enc, "$1-$2");
    }
  }

  return %fak;
}

sub stl_listo {
  # legu la stiloliston
  my %stl = ('' => '');
  open my $STL, '<:encoding(UTF-8)', "$revo_base/cfg/stiloj.xml" 
    or die "Ne povas malfermi dosieron stiloj.xml\n";
  my @stiloj_ = <$STL>; close $STL;

  for (@stiloj_) {
    if (m{
      <stilo\s+
      kodo="([^"]+)"
      [^>]*
      >([^<]+)</stilo>
    }xi) {
      $stl{$1} = "$1-$2"; #Encode::decode($enc, "$1-$2");
    }
  }

  return %stl;
}

sub lng_listo {
  # legu la lingvoliston
  my %lng;
  open my $in, '<:encoding(UTF-8)', "$revo_base/cfg/lingvoj.xml" 
        or die "Ne povas malfermi dosieron lingvoj.xml\n";
  my @lingvoj = <$in>; close $in;

  for (@lingvoj) {
    if (m{
      <lingvo\s+
      kodo="([^"]+)"
      >[^<]+</lingvo>
    }x) {
      $lng{$1} = 1;
    }
  }

  return %lng;
}

sub trakti_sxangxon {
  my $sxg = shift;

  my $flag = 0;
  ## no critic (RegularExpressions::RequireExtendedFormatting)
  $flag = $sxg =~ s/\x{0109}/cx/g || $flag;
  $flag = $sxg =~ s/\x{0108}/Cx/g || $flag;
  $flag = $sxg =~ s/\x{0135}/jx/g || $flag;
  $flag = $sxg =~ s/\x{0134}/Jx/g || $flag;
  $flag = $sxg =~ s/\x{0125}/hx/g || $flag;
  $flag = $sxg =~ s/\x{0124}/Hx/g || $flag;
  $flag = $sxg =~ s/\x{016D}/ux/g || $flag;
  $flag = $sxg =~ s/\x{016C}/Ux/g || $flag;
  $flag = $sxg =~ s/\x{015D}/sx/g || $flag;
  $flag = $sxg =~ s/\x{015C}/Sx/g || $flag;
  $flag = $sxg =~ s/\x{011D}/gx/g || $flag;
  $flag = $sxg =~ s/\x{011C}/Gx/g || $flag;
  ## use critic

  if ($flag) {
    print "Esperantaj signoj en ŝanĝoteksto malunikoditaj.<br>\n";
  }
  if ($sxg =~ s{
      ([\x{80}-\x{10FFFF}]+) 
      }{<span style="color:red">$1<\/span>}xg) { # ruĝigu ne-askiajn signojn
    print "Eraro: La ŝanĝoteksto enhavas ne-askiajn signojn: $sxg".br."\n";
    $ne_konservu = 3;

  } elsif ($sxg =~ s{
    (--)
    }{<span style="color:red">$1<\/span>}xg) {  # ruĝigu '--'
    print "Eraro: '--' estas malpermesita en komento: $sxg".br."\n";
    $ne_konservu = 3;

  } elsif (!param('nova')) {
    if ($sxg and $sxg ne "klarigo de la sxangxo") {
      print "Ŝanĝoteksto en ordo: $sxg".br."\n";
    } else {
      print "Eraro: ŝanĝoteksto mankas: $sxg".br."\n";
      $ne_konservu = 4;
    }
  }

  return $sxg;
}

sub trd_kontrolo { 
  my $x = shift; # $xml2; 
   # cxu cxiu <trd...> havas lng aux estas en trdgrp kun lng?
  autoEscape(1);
#    print pre(escapeHTML("x=$x\n"));
  $$x =~ s{
    <trdgrp\s+
    lng\s*=.*?
    </trdgrp>\s*
    }{}xsmig;   # forigo de bonaj trdgrpoj

  $$x =~ s{
    <trd\s+
    lng\s*=.*?
    </trd>\s*
  }{}xsmig;   # forigo de bonaj trdoj

#    print pre(escapeHTML("x=$x\n"));
	if ($$x =~ m{
      (<trd.*?</trd>)
      }x) {   # se restas trd, estas malbona
	  print escapeHTML("Traduko $1")." ne havas lingvon.<br>\n";
    $ne_konservu = 11;
	}
  autoEscape(0);

  return;
}
  
sub ref_kontrolo {

  my $xml_ = shift;
  my @ref_err;

  while ($$xml_ =~ m{
    <ref([^g>][^>]*)>
  }xgi) {
    my $ref = $1;
#    print "ref = $ref<br>\n" if $debug;
    if ($ref !~ m{
      cel\s*=\s*"[^"]+"
    }xi) {
      autoEscape(1);
      print escapeHTML("Referenco <ref$ref>")." ne havas cel a&#365; la celo estas malplena.<br>\n";
      autoEscape(0);
#      print "ref = $ref<br>\n";
#      $ne_konservu = 9;
    }
  }  

  #if (!$err) { # ĉu ni kontrolu referencojn, ĉiam? Povizore ni faros nur se la XML-sintakso estas e.o.
  my @refs;
  while ($$xml_ =~ m{
      <ref\s+[^>]*?
      cel="([^".]*)(\.)([^"]*?)"
      >}xgi
  ) {
    my ($art_,$p,$rest) = ($1,$2,$3);
    push @refs, [$art_,$p,$rest];
  }

  if (@refs) {
    @ref_err = revo::checkxml::check_ref_cel($dbh,$xml_dir,@refs); 

    if (@ref_err) {
      print "<div id=\"ref_err\" class=\"eraroj\">\n".join("\n",@ref_err)."\n</div>\n";
    }
  }

  return @ref_err
}

sub fak_kontrolo {
  my $xml_ = shift;
  while ($$xml_ =~ m{
    <uzo\s+
    tip="fak"
    >(.*?)</uzo>}xgi
  ) {
    my $fako = $1;
    if (! exists($fakoj{$fako})) {
      print "Fako $fako estas nekonata.<br>\n";
      $ne_konservu = 6;
    }
  }

  return;
}

sub mrk_kontrolo {
  my $xml_ = shift;
  while ($$xml_ =~ m{
      <(drv|snc)\s+
      mrk="(.*?)"
      >}xgi
  ) {
    $mrk = $2;
    if ($mrk !~ m{
        ^$art\.
        [^.0]*0
      }x) {
      print "La marko \"$mrk\" ne komenciĝas per \"$art.\" a&#365; poste ne havas 0.<br>\n";
      $ne_konservu = 5;
    }
  }

  return;
}

sub checkxml {
    my $teksto = shift;
    my ($err, $konteksto, $ln, $char);

    chdir($revo_base."/xml") 
      or die "chdir al xml/ ne funkciis\n";
#    $debugmsg .= "checkxml: teksto = $teksto\n";
    my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                    'rxp -Vs >/dev/null');
    print CHLD_IN $teksto;
    close CHLD_IN;
    
    $err = do { local $/ = undef; <CHLD_ERR>};
#    $debugmsg .= "checkxml: err = $err\n";
    close CHLD_ERR;
    close CHLD_OUT;

    if ($err) {
      $ne_konservu = 1;
      my $ret = "XML kontrolo malsukcesis - Eraro";

      ## no critic (RegularExpressions::ProhibitComplexRegexes)
      $err =~ s{^Warning:\s}
        {Atentu: }xsmg;
      $err =~ s{^Error:\s}
        {Eraro: }xsmg;
      $err =~ s{\sof\s<stdin>$}
        {}xsmg;
      $err =~ s{^\sin\sunnamed\sentity}
        {}xsmg;
      $err =~ s{Start\stag\sfor\sundeclared\selement\s([^\n]*)}
        {Ne konata komencokodero $1}xsmg;
      $err =~ s{
        Content\smodel\sfor\s([^\s\n]*)
        \sdoes\snot\sallow\selement\s([^\s\n]*)\shere$}
        {Reguloj por $1 malpermesas $2 cxi tie}xsmg;
      $err =~ s{
        Mismatched\send\stag: expected\s([^,\n]*),
        \sgot\s([^\s\n]*)$}
          {Malkongrua finokodero: atendis $1, trovis $2}xsmg;
      $err =~ s{^\sat\sline\s(\d+)\schar\s(\d+)$}
        { ĉe linio $1 pozicio $2}xsmg;
      $err =~ s{Document\scontains\smultiple\selements}
        {Artikolo enhavas pli ol unu elemento (kaj tio devas esti <vortaro>)}xsmg;
      $err =~ s{Root\selement\sis\s([^\s,\n]*),\sshould\sbe\s([^\s\n]*)}
        {Radika elemento estas $1, devus esti $2}xsmg;
      $err =~ s{Content\smodel\sfor ([^\s\n]*)\sdoes\snot\sallow\sPCDATA}
        {Enhavo de elemento $1 estas malpermesita}xsmg;
      $err =~ s{
        The\sattribute\s([^\s\n]*)
        \sof\selement\s([^\s\n]*)
        \sis\sdeclared\sas
        \sENUMERATION\sbut\sis\sempty
      }
        {La atributo $1 de la kodero $2 mankas}xsmg;
      $err =~ s{
        In\sthe\sattribute
        \s([^\s\n]*)\sof\selement
        \s([^\s\n]*),
        \s([^\s\n]*)
        \sis\snot\sone\sof
        \sthe\sallowed\svalues
      }
        {Ĉe la atributo $1 de la kodero $2, $3 ne estas permesata.}xsmg;
      $err =~ s{Document\sends\stoo\ssoon}
        {Dokumento finis, sed mankis finkodero}xsmg;
      $err =~ s{Value\sof\sattribute\sis\sunquoted}
        {Mankas citiloj por la valoro de la atributo}xsmg;
      $err =~ s{Illegal\scharacter\s([^\s\n]*)\sin\sattribute\svalue}
        {Malpermesita signo $1 en atributa valoro}xsmg;
      $err =~ s{Expected\swhitespace\sor\stag\send\sin\sstart\stag}
        {Atendas spacon aux koderfinon en komencokodero}xsmg;
      $err =~ s{Expected\sname,\sbut\sgot ([^\s\n]*)\sfor\sattribute}
        {Atendas nomon, sed trovis $1 kiel atributo}xsmg;
      $err =~ s{
        The\sattribute
        \s([^\s\n]*)\sof
        \selement\s([^\s\n]*)
        \sis\sdeclared\sas\sID
        \sbut\scontains\sa\scharacter
        \swhich\sis\snot
        \sa\sname\scharacter
      }
        {La atributo $1 de la kodero $2 enhavas malpermesitan karakteron.}xsmg;
      ## use critic

      autoEscape(1);
      ($konteksto, $ln, $char) = xml_context($err, $teksto);
      $err .= "kunteksto de unua eraro:\n$konteksto";
      $ret .= pre(escapeHTML("XML-eraroj:\n$err\n")); # if ($verbose);
      autoEscape(0);
      $ret .= "&nbsp;&nbsp;&nbsp;&nbsp; * se vi trovas anglan mesagxon aux malbonan erarmesagxon, skribu al wieland(cxe)wielandpusch.de";
      $err = $ret;
    } else {
      $err = "XML en ordo</b></span></p>\n";
    }
    return ("Kontrolo</b></span></p>\n$err", $ln, $char);
}

sub position{
  my ($eline,$echr) = @_;
  my ($pos_, $ln_, $lastln_) = (0, 0, 1);

  if ($eline) {
    $eline--;
    $echr--;
    if ($xml =~ m{^
      ([^\n]*\n)
      {$eline}
      [^\n]
      {$echr}
    }xsmgp) {
      my @prelines = split "\n", ${^MATCH};
      $postlines = split "\n", ${^POSTMATCH};

      my @pre = Text::Tabs::expand(@prelines);
      $pos_ = length(join "\n", @pre);
      $prelines = $#prelines;

      $ln_ = $prelines - 10;
      $lastln_ = $prelines + $postlines + 30 - 25;

    } else {
  #    $debugmsg .= "Ne trovis linio/pos $eline/$echr\n";
      $ln_ = $lastln_ = 100;
      my @prelines = split "\n", $xml;
      my @pre = Text::Tabs::expand(@prelines);
      $pos_ = length(join "\n", @pre);
    }

  } else {

    my %lingvoj = lng_listo();

    # kontrolu la lingvojn en la XML
    while ($xml =~ m{
      (<(?:trd|trdgrp)
      \s+lng=")(.*?)"
    }xsmgp) {
      if (!exists($lingvoj{$2})) {
        $checklng = "Nekonata lingvo $2.";
        $ne_konservu = 10;
  #      $debugmsg .= "lng = $2\n";
        my @prelines = split "\n", "$`$1$2";
        $postlines = split "\n", ${^POSTMATCH};

        my @pre = Text::Tabs::expand(@prelines);
        $pos_ = length(join "\n", @pre);
        $prelines = $#prelines;
        $ln_ = $prelines - 20;
        $lastln_ = $prelines + $postlines + 20 - 25;
        last;
      }
    }

    # apartigu snc/drv-elementojn
    if (!$pos_ && $xml =~ m{
      <(snc|drv)
      (\s+mrk="$mrk".*?)
      (\n?\s*</\1>)
    }xsmg) {
      my @prelines = split "\n", "$`$1$2";
      $postlines = split "\n", "$3$'";

      my @pre = Text::Tabs::expand(@prelines);
      $pos_ = length(join "\n", @pre);
      $prelines = $#prelines;
  #    $debugmsg .= "prelines = $prelines\n";

      $pos_++;
      $ln_ = $prelines - 20;
      $lastln_ = $prelines + $postlines + 20 - 25;
    }
  }
  $ln_ = 0 if $ln_ < 0;
  $ln_ = $lastln_ if $ln_ > $lastln_;
  $lastln_ = 1 unless $lastln_;
  #$debugmsg .= "line = $ln_\n";

  return ($pos_, $ln_, $lastln_);
}

sub xml_context {
    my ($err, $teksto) = @_;
    my ($ln, $char, $result);

    if ($err =~ m{
        linio\s+
        ([0-9]+)\s+
        pozicio\s+
        ([0-9]+)\s+
      }sx) {
      $ln = $1;
      $char = $2;
#      $debugmsg .= "context: line = $line, char = $char, err = $err\n";

      my @a = split "\n", $teksto;

      # la linio antaux la eraro
      if ($ln > 1) {
          $result .= ($ln-1).": $a[$ln - 2]\n";
      }
      $result .= "$ln: $a[$ln - 1]\n";
      $result .= "-" x ($char + length($ln) + 1) . "^\n";

      if (exists($a[$ln])) {
          $result .= ($ln+1).": $a[$ln]";
      }

      return ($result, $ln, $char);
    }

    return ('', 0, 0);
}

sub xml2html_print {
  my $xmlref = shift;
  my ($html,$err);

  print <<'EOD';
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>Anta&#365;rigardo</b></span></p>
EOD
   
  revo::xml2html::konv($xmlref, \$html, \$err, $debug);
  #  $html = Encode::decode($enc, $html);
  if ($html and $debug) {
    open my $ht, '>:encoding(UTF-8)', "../art2/$art.html" or die "Ne povas skribi al $art.html: $!\n";
    print $ht $html;
    close $ht;
  }

  $html =~ s{href="../stl/}{href="/revo/stl/}smgx;
  $html =~ s{src="../smb/}{src="/revo/smb/}smgx;
  $html =~ s{src="../bld/}{src="/revo/bld/}smgx;
  $html =~ s{<span\s+class="redakto">.*$}{}smx;
  $html =~ s{href="(?!http://)([a-z])}{href="/revo/art/$1}smgx;

  print $html;
  #  print pre('close xalan') if $debug;

  print <<'EOD';
</div><br>
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>
EOD

  return;
}

sub print_html_start {
  print 
    header(
    -charset=>'utf-8',
    -pragma => 'no-cache', '-cache-control' =>  'no-cache',
    -cookie => \@coky
    ),
        
    start_html(
      -style => {
        -src=>'/revo/stl/artikolo.css',
        -code  => css_stiloj()
      },
      -title => "redakti $art",
      -lang  => 'eo', #'de',
      -encoding => 'UTF-8',
      -head => [ 
        '<meta http-equiv="Cache-Control" content="no-cache">'
      ],
      -script => js_skripto(),
      -onLoad=>"sf($pos, $line, $lastline)"
    );

  if ($art) {
    print h1("Redakti ".a({href=>"/revo/art/$art.html"}, $art));
  }
  #my $referer =$ENV{HTTP_REFERER};
  #print pre("pos=$pos, referer=$referer\n") if $debug;
  #print pre("pre=".escapeHTML($prelines)."  post=".escapeHTML($postlines)."  lines=".($prelines + $postlines));
  #print pre("pre=".escapeHTML($line)."  post=".escapeHTML($lastline)."  div=".($line / $lastline));

  if ($debug and $debugmsg) {
    autoEscape(1);
  #  $debugmsg .= "4 xml=\n$xml";
    print pre(escapeHTML($debugmsg));
    autoEscape(0);
  }
  return;
}

sub print_formularo {
  print start_form(-id => "f", -name => "f");

  my @fakoj = sort keys %fakoj;
  my @stiloj = sort keys %stiloj;

  print "\n&nbsp;prilabori:\n".
        " <a class=\"butono1\" onclick=\"indent(2);return false\" href=\"#\" title=\"Ŝovu la markitan tekston dekstren.\">&gt;&gt;</a>\n".
        " <a class=\"butono1\" onclick=\"indent(-2);return false\" href=\"#\" title=\"Ŝovu la markitan tekston maldekstren.\">&lt;&lt;</a>\n".
        "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ".
        checkbox(-name      => 'cx',
                -checked   => defined(cookie(-name=>'cx')) ? cookie(-name=>'cx') : 1,
                -value     => '1',
                -accesskey => "x",
                -onClick   => "document.f.xmlTxt.focus()",
                -label     => 'anstata&#365;igu&nbsp; c<u>x</u>,&nbsp;gx,&nbsp;...,&nbsp;ux').
        br."\n".
        "<div id=\"ajxb\" style=\"display:\">".
        "\n&nbsp;navigadi:\n".
        " <a class=\"butono1\" onclick=\"nextTag(&#39;<drv&#39,-1);return false\" href=\"#\" title=\"Serĉu antaŭan derivaĵon.\">drv</a>".
        "-<a class=\"butono1\" onclick=\"nextTag(&#39;<drv&#39,1);return false\" href=\"#\" href=\"#\" title=\"Serĉu sekvan derivaĵon.\">drv</a>\n".
        "&nbsp;&nbsp;<a onclick=\"showhide(&#39;ajx&#39;);return false\" href=\"#\">montru pli</a><br>\n</div>".
        "<div id=\"ajx\" style=\"display: none;\">\n".
        "\n&nbsp;navigadi:\n".
        " <a class=\"butono1\" onclick=\"nextTag(&#39;<drv&#39,-1);return false\" href=\"#\">drv</a>".
        "-<a class=\"butono1\" onclick=\"nextTag(&#39;<drv&#39,1);return false\" href=\"#\">drv</a>\n".
        "&nbsp;&nbsp;<a onclick=\"showhide(&#39;ajx&#39;);return false\" href=\"#\">montru malpli</a><br>\n".
        "\n&nbsp;aldoni:\n".
        " <a class=\"butono1\" onclick=\"var i=str_indent();insertTags(&#39;<drv mrk=\\&#34;$art.&#39;,&#39;\\&#34;>\\n&#39;+i+&#39;  <kap><tld/>...</kap>\\n&#39;+i+&#39;  <snc mrk=\\&#34;$art.\\&#34;>\\n&#39;+i+&#39;    <dif>\\n&#39;+i+&#39;      \\n&#39;+i+&#39;    </dif>\\n&#39;+i+&#39;  </snc>\\n&#39;+i+&#39;</drv>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu novan derivaĵon.\">drv</a>\n",
        " <a class=\"butono1\" onclick=\"var i=str_indent();insertTags(&#39;<dif>\\n&#39;+i+&#39;  &#39;,&#39;\\n&#39;+i+&#39;</dif>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu novan difinon.\">dif</a>\n",
        " <a class=\"butono1\" onclick=\"var i=str_indent();insertTags(&#39;<snc mrk=\\&#34;$art.&#39;,&#39;\\&#34;>\\n&#39;+i+&#39;  <dif>\\n&#39;+i+&#39;    \\n&#39;+i+&#39;  </dif>\\n&#39;+i+&#39;</snc>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu novan sencon.\">snc</a>\n",
        " <a class=\"butono1\" onclick=\"insertTags2(&#39;<ofc>&#39;,document.getElementById(&#34;ofc&#34;).value,&#39;</ofc>&#39;,&#39;&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu indikon pri oficialeco.\">ofc</a>",
        "=".popup_menu(-id=>'ofc',
          -name    => 'ofc',
        -title   => "Elektu indikon pri oficialeco.",
              -values  => ['', '*', 1 .. 9],
          -default => '',
        )."\n ",
        " <a class=\"butono1\" onclick=\"insertTags2(&#39;<gra>&#39;,document.getElementById(&#34;gra&#34;).value,&#39;</gra>&#39;,&#39;&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu indikon pri gramatiko.\">gra</a>",
        "=".popup_menu(-id=>'gra',
          -name    => 'gra',
        -title   => "Elektu indikon pri gramatiko.",
              -values  => ['<vspec>tr</vspec>', '<vspec>ntr</vspec>'],
          -default => '',
          -labels  => {'<vspec>tr</vspec>' => 'v tr', '<vspec>ntr</vspec>' => 'v ntr'},
        )."\n ",
  #      " <a class=\"butono1\" onclick=\"var i=str_indent();insertTags(&#39;<refgrp cel=\\&#34;\\&#34;>&#39;,&#39;\\n&#39;+i+&#39;  <ref>&#39;,&#39;</ref>,\\n&#39;+i+&#39;  <ref></ref>\\n&#39;+i+&#39;</refgrp>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu grupon de refencoj.\">[refgrp tip]</a> ",
        " <a class=\"butono1\" onclick=\"insertTags2(&#39;<ref tip=\\&#34;&#39;,document.getElementById(&#34;reftip&#34;).value,&#39;\\&#34; cel=\\&#34;\\&#34;>&#39;,&#39;</ref>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu unu referencon.\">ref tip</a> ",
        " <a class=\"butono1\" onclick=\"var i=str_indent();insertTags(&#39;<refgrp tip=\\&#34;&#39;+document.getElementById(&#34;reftip&#34;).value+&#39;\\&#34;>\\n&#39;+i+&#39;  <ref cel=\\&#34;\\&#34;>&#39;,&#39;</ref>\\n&#39;+i+&#39;</refgrp>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu grupon de refencoj.\">refgrp tip</a> ",
        "\n tip=".popup_menu(-id=>'reftip',
          -name   => 'reftip',
        -title  => "Elektu tipon de referenco.",
              -values => ['', qw/vid hom dif sin ant super sub prt malprt ekz/],
          -default=> '',
          -labels =>{'vid'=>'vid-u',
                        'hom'=>'hom-onima',
                        'dif'=>'dif-ina',
                        'sin'=>'sin-onimo',
                        'ant'=>'ant-onimo',
                        'super'=>'super-nocio',
                        'sub'=>'sub-nocio',
                        'prt'=>'part-o',
                        'malprt'=>'malpart-o',
                        'ekz'=>'ekz-emplo',
          },
  #                    -size => 2,2
  #                    -maxlength => 3,
  #                    -value=> cookie(-name=>'reftip') || '',
        )."\n ",
        " <a class=\"butono1\" onclick=\"insertTags(&#39;<ref cel=\\&#34;\\&#34;>&#39;,&#39;</ref>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu unu referencon al grupo (sen tipo).\">ref</a> ",
        " <a class=\"butono1\" onclick=\"var i=str_indent();insertTags(&#39;<rim>\\n&#39;+i+&#39;  &#39;,&#39;\\n&#39;+i+&#39;</rim>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu rimarkon.\">rim</a>\n",
        "&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/manlibro.html#drv'}, "helpo")."\n ".
        a({target=>"_new", href=>'/revo/dok/dtd.html#drv'}, "dtd")."\n".
        br.
        "\n&nbsp;uzo:\n".
        " <a class=\"butono1\" onclick=\"insertTags2(&#39;<uzo tip=\\&#34;fak\\&#34;>&#39;,document.getElementById(&#34;uzofak&#34;).value,&#39;</uzo>&#39;,&#39;&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu fakon (elektu dekstre).\">fak</a>",
        "=".popup_menu(-id=>'uzofak',
          -name    => 'uzofak',
          -title   => "Elektu uzofakon.",
              -values  => \@fakoj,
          -default => '',
          -labels  => \%fakoj,
        )."\n ",
        " <a class=\"butono1\" onclick=\"insertTags2(&#39;<uzo tip=\\&#34;stl\\&#34;>&#39;,document.getElementById(&#34;uzostl&#34;).value,&#39;</uzo>&#39;,&#39;&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu stilon (elektu dekstre).\">stl</a>",
        "=".popup_menu(-id=>'uzostl',
          -name    => 'uzostl',
          -title   => "Elektu uzostilon.",
              -values  => \@stiloj,
          -default => '',
          -labels  => \%stiloj,
        )."\n ",
        "&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/manlibro.html#uzo'}, "helpo")."\n ".
        a({target=>"_new", href=>'/revo/dok/dtd.html#uzo'}, "dtd")."\n".
        br.
        "\n&nbsp;ekzemplo:\n".
        " <a class=\"butono1\" onclick=\"var i=str_indent();insertTags(&#39;<ekz>\\n&#39;+i+&#39;  &#39;,&#39;\\n&#39;+i+&#39;</ekz>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu ekzemplon.\">ekz</a>\n",
        " <a class=\"butono1\" onclick=\"insertTags(&#39;<tld/>&#39;,&#39;&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu tildon (anstataŭigas la radikon).\">tld</a>\n",
        " <a class=\"butono1\" onclick=\"var i=str_indent();insertTags(&#39;<fnt>\\n&#39;+i+&#39;  <aut>&#39;,&#39;</aut>,\\n&#39;+i+&#39;  <vrk><url ref=\\&#34;\\&#34;></url></vrk>,\\n&#39;+i+&#39;  <bib></bib>,\\n&#39;+i+&#39;  <lok></lok>\\n&#39;+i+&#39;</fnt>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu fonton (kun kelkaj informoj).\">fnt</a>\n ",
        "&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/manlibro.html#ekz'}, "helpo")."\n ".
        a({target=>"_new", href=>'/revo/dok/dtd.html#ekz'}, "dtd")."\n".
        br.
        "</div>".
        "\n&nbsp;traduki: <a class=\"butono1\" accesskey=\"t\" onclick=\"insertTags2(&#39;<trd lng=\\&#34;&#39;,document.getElementById(&#34;trdlng&#34;).value,&#39;\\&#34;>&#39;,&#39;</trd>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu unu tradukon.\"><u>t</u>rd lng</a> ",
  #      "\n&nbsp;<a onclick=\"var i=str_indent();insertTags(&#39;<trdgrp>\\n&#39;+i+&#39;  <trd>&#39;,&#39;</trd>\\n&#39;+i+&#39;</trdgrp>&#39;,&#39;&#39;);return false\" href=\"#\">[trdgrp]</a> ",
        "\n&nbsp;<a class=\"butono1\" onclick=\"var i=str_indent();insertTags2(&#39;<trdgrp lng=\\&#34;&#39;,document.getElementById(&#34;trdlng&#34;).value,&#39;\\&#34;>\\n&#39;+i+&#39;  <trd>&#39;,&#39;</trd>,\\n&#39;+i+&#39;  <trd></trd>\\n&#39;+i+&#39;</trdgrp>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu grupon de tradukoj.\">trdgrp lng</a> ",
        "\n lng=".textfield(-id=>'trdlng',
          -name=>'trdlng',
        -title=> "Tajpu la lingvokodon por tradukoj ĉi tie.",
              -size => 2,
              -maxlength => 3,
              -value=> cookie(-name=>'trdlng') || '',
        ),
        "\n&nbsp;<a class=\"butono1\" onclick=\"insertTags(&#39;<trd>&#39;,&#39;</trd>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu unu tradukon al grupo (sen lingvo).\">trd</a> ",
        "\n&nbsp;<a class=\"butono1\" onclick=\"insertTags(&#39;<klr>&#39;,&#39;</klr>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu klarigon sen tipo.\">klr</a> ",
        "\n&nbsp;<a class=\"butono1\" onclick=\"insertTags2(&#39;<klr tip=\\&#34;&#39;,document.getElementById(&#34;klrtip&#34;).value,&#39;\\&#34;>&#39;,&#39;</klr>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu klarigon kun tipo.\">klr tip</a> ",
        "\n tip=".popup_menu(-id=>'klrtip',
          -name=>'klrtip',
        -title=> "Elektu la tipon de la klarigo.",
              -values=>['', qw/ind amb/],
          -default=> cookie(-name=>'klrtip') || 'amb',
          -labels=>{'ind'=>'ind-ekso',
                                'amb'=>'amb-aux',
          },
        )."\n ",
        "\n&nbsp;<a class=\"butono1\" onclick=\"insertTags(&#39;<ind>&#39;,&#39;</ind>&#39;,&#39;&#39;);return false\" href=\"#\" title=\"Aldonu indikon por la indekso.\">ind</a> ",
        "&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/manlibro.html#trd'}, "helpo").
        a({target=>"_new", href=>'/revo/dok/dtd.html#trd'}, "dtd").
        br."\n",
        hidden(-name=>'art', -default=>param('art')),
        hidden(-name=>'mrk', -default=>param('mrk')),
        "&nbsp;".textarea(-id    => 'xmlTxt', -name    => 'xmlTxt',
                -rows    => 25,
                -columns => 80,
              -default => $xml,
                -onkeypress => "return klavo(event)",
        ) if $art;
  if (param('nova') or param('button') eq 'kreu') {
    print hidden(-name=>'nova', -default=>1);
  } else {
    print br."\n&nbsp;&#348;an&#285;o: ".textfield(
        -name => 'sxangxo',
        #-value => Encode::decode($enc, cookie(-name=>'sxangxo')) || 'klarigo de la &#349;an&#285;o',
        -value => cookie(-name=>'sxangxo') || 'klarigo de la &#349;an&#285;o',
        -title => "Klarigu la ŝanĝon ĉi tie.",
        -size => 70,
        -maxlength => 80);
  }
  print br."\n&nbsp;Retpo&#349;ta adreso:".textfield(-name=>'redaktanto',
                      -size      => 70,
                      -maxlength => 80,
                      -title     => "Skribu vian registritan retadreson ĉi tie.",
                      -value     => (cookie(-name=>'redaktanto') || 'via retadreso')
        ),
        br."\n",
        submit(-name => 'button', -label => 'antaŭrigardu'),
        submit(-name => 'button', -label => 'konservu') if $art;
  print checkbox(-name    => 'sendu_al_revo',
                -checked => 1,
                -value   => '1',
                -label   => 'sendu al ReVo') if $art and $debug and 0;
  print end_form if $art;

  print start_form(-id => "n", -name => "n");
  print "&nbsp;Preparu novan artikolon: ".textfield(-name=>'art', -size=>20, -maxlength=>20)."&nbsp;";
  print submit(-name => 'button', -label => 'kreu')."&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/revoserv.html'}, "[helpo]")."\n";
  print end_form;

  return;
}

sub print_klarigojn {
  print <<"EOD" if $art;
<h1>Klarigoj:</h1>
<div class="averto">
Se vi permesas kuketojn, vi ne da&#365;re devas entajpi vian retadreson kaj lingvon.<br>
klavo kontrolo-Z malfaras la lastan &#349;an&#285;on<br>
klavo kontrolo-Y refaras la lastan &#349;an&#285;on<br>
klavo kontrolo-F ebligas ser&#265;i<br>
via retadreso estas $ENV{REMOTE_ADDR}<br>
</div>

<p class="piedlinio">
<a class="redakto" title="Reta Vortaro, konstanta URL" target="_top"
   href="http://purl.org/net/voko/revo/">&#x211B;evo</a> |
<a class="redakto" title="Datumprotekta deklaro" target="_new"
   href="/revo/dok/datumprotekto.html">datumprotekto</a> |
<a class="redakto" title="Permeso de uzado" target="_new"
   href="/revo/dok/copying.txt">permeso</a> |
<a class="redakto" title="Alternativa redaktilo" target="_new"
   href="https://revaj.steloj.de/">alia redaktilo</a> |
<a class="redakto" title="Bibliografio" target="indekso"
   href="/revo/dok/bibliogr.html">bibliografio</a> |
<a class="redakto" title="Vortaraj mallongigoj" target="indekso"
   href="/revo/dok/mallongigoj.html">mallongigoj</a> |
<a class="redakto" title="Superserĉo per ViVo" target="_new"
   href="http://kono.be/vivo">ViVo</a>
</p>

<div class="kuketoaverto" id="kuketoaverto">
<p>
  Ni uzas kuketojn (retumilajn memoretojn).
  Uzante nian servon vi konsentas al konservado de informoj en kuketoj.
  Eksciu pli pri la uzado de personaj datumoj en la
  <a href="/revo/dok/datumprotekto.html">datumprotekta deklaro</a>.<br/>
  <button name="konfirmo" onClick="setCookieConsent()">Mi konfirmas</button>
</p>
</div>
EOD

  print p('<!-- vokomail.pl 2018-2026 ĉe Wieland Pusch kaj Wolfram Diestel -->');
  return;
}

sub redaktanto_permeso {
    # cxu iu redaktanto havas tiun retadreson? Kiu?

  $sth = $dbh->prepare("SELECT count(*), min(ema_red_id) FROM email WHERE LOWER(ema_email) = LOWER(?)");
  eval { $sth->execute($redaktanto) }
    or do { warn "Ne povis elekti datumojn el tabelo 'email'\n"};

  my ($permeso, $red_id) = $sth->fetchrow_array();
  $sth->finish;

  # Kiel nomigxas la redaktanto?
  $sth = $dbh->prepare("SELECT red_nomo FROM redaktanto WHERE red_id = ?");
  eval { $sth->execute($red_id) }
    or do { warn "Ne povis elekti datumojn el tabelo 'redaktanto'\n"};

  my ($red_nomo) = $sth->fetchrow_array();
#  print "red_nomo=$red_nomo\n";
  $sth->finish;

  if (!$permeso) {
    $ne_konservu = 2;

    print <<'EOD';
<div class="averto">
Vi ($redaktanto) ne estas registrita kiel redaktanto !<br>
Legu <a href="http://www.reta-vortaro.de/revo/dok/redinfo.html">&#265;i tie</a> kaj 
  <a href="http://www.reta-vortaro.de/revo/dok/revoserv.html">&#265;i tie</a> kiel registri&#285;i.<br>
Sen tio viaj &#349;an&#285;oj ne estos konservitaj !
</div><br>
EOD
  }

  return;
}

sub konservu {

  print <<'EOD';
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>
EOD
  print "Konservo</b></span></p>\n";
  # $xml2
  if ($ne_konservu) {
    print "ne konservita";
  } else {
    my $from    = 'noreply@retavortaro.de';
    my $name    = "\"Revo redaktu.pl $redaktanto\"";

    $name =~ s/\@/_/xg;
    my (@to, $sxangxo2);
    push @to, $redaktanto; # if param('sendu_al_tio');
    push @to, 'revo@retavortaro.de'; # if not $debug or param('sendu_al_revo');
#      push @to, 'wieland@wielandpusch.de'; # if param('sendu_al_admin');  # revodb::mail_to
    if (param('nova')) {
      $sxangxo2 = "aldono: $art";
    } else {
      $sxangxo2 = "redakto: $sxangxo";
    }
    if (my $to = join(', ', @to)) {
      my $subject = "Revo redaktu.pl $art";
  #my $smlog = "$homedir/logfiles/sendmail.log";

      my $mailtext = <<'End_of_Mail';
From: $name <$from>
To: $to
Reply-To: $redaktanto
Subject: $subject
X-retadreso: $ENV{REMOTE_ADDR}

$sxangxo2

$xml2
End_of_Mail

      # konektu al retposxtservilo
      open my $sendmail, '|-', "/usr/sbin/sendmail -t 2>&1 >$smlog" 
          or do {
            #print LOG "ne povas sendi per 'sendmail'\n";
            warn "ne povas sendi per 'sendmail'\n";
            return;
          };
      print {$sendmail} $mailtext; 
      close $sendmail;

      print "sendita al $to";
        
      if (-s $smlog) {
          open my $log, "<", $smlog or warn "Ne povas legi $smlog: $!\n";
          my $ltxt = do { local $/ = undef, <$log>};
          close $log;
          print pre("sendmail.log: $ltxt");
      }

    } else {
      print "ne sendita, elektu adreson sube";
    }
  }
  print <<'EOD';
</div><br>
EOD
  return;
}

#######################################################################################

sub check {
  my $cond = shift;

  ## if ($debug) {
  ##   print shift, ": ", $cond, "\n";
  ## }

  unless ($cond) {
    print "eraro: ".shift,"!\n";
    print end_html();
    exit;
  }
}  

