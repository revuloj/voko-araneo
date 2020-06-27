var revo_codes = {
  url:
  {
      lingvo: '/revo/cfg/lingvoj.xml',
      fako: '/revo/cfg/fakoj.xml',
      stilo: '/revo/cfg/stiloj.xml'
  }
  // ni plenigos tion per listoj
  // lingvo: [...]
  // fako: [...]
  // stilo: [...]
}

var re_lng = /<(?:trd|trdgrp)\s+lng\s*=\s*"([^]*?)"\s*>/mg; 
var re_fak = /<uzo\s+tip\s*=\s*"fak"\s*>([^]*?)</mg; 
var re_stl = /<uzo\s+tip\s*=\s*"stl"\s*>([^]*?)</mg; 
var re_mrk = /<(drv|snc) mrk="([^]*?)">/mg;

var re_trdgrp = /<trdgrp\s+lng\s*=\s*"[^"]+"\s*>[^]*?<\/trdgrp/mg;	
var re_trd = /<trd\s+lng\s*=\s*"[^"]+"\s*>[^]*?<\/trd/mg;	
var re_ref = /<ref([^g>]*)>([^]*?)<\/ref/mg;
var re_refcel = /cel\s*=\s*"([^"]+?)"/m;

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

  if (document.selection && document.selection.createRange) { // IE/Opera
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
       alert("tio ankoraŭ ne funkcias.");
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

// aliras helpo-paĝon
function helpo_pagho(url) {
  window.open('https://revuloj.github.io/temoj/'+url);
}

// memoras valorojn de kelkaj kampoj en la loka memoro de la retumilo
function store_preferences() {
  var prefs = {};
  for (key of ['redaktanto','trdlng','klrtip','reftip','sxangxo','cx']) {
    prefs[key] = document.getElementById(key).value;
  }
  window.localStorage.setItem("redaktilo_preferoj",JSON.stringify(prefs));  
}

// reprenas memorigitajn valorojn de kelkaj kampoj el la loka memoro de la retumilo
function restore_preferences() {
  var str = window.localStorage.getItem("redaktilo_preferoj");
  var prefs = (str? JSON.parse(str) : null);
  if (prefs) {
    for (key of ['redaktanto','trdlng','klrtip','reftip','sxangxo','cx']) {
      document.getElementById(key).value = prefs[key];
    }
  }
}

function fs_toggle(id) {
  var el = document.getElementById(id);
  var fs_id;
  if (! el.classList.contains('aktiva')) {
    for (ch of el.parentElement.children) {
      ch.classList.remove('aktiva')
      fs_id = 'fs_'+ch.id;
      document.getElementById(fs_id).classList.add('collapsed');
    }
    el.classList.add('aktiva');
    fs_id = 'fs_'+el.id;
    document.getElementById(fs_id).classList.remove('collapsed');
  }
}

function listigu_erarojn(err) {
  var el = document.getElementById("reraroj");
  var elch = el.children;
  var ul;
  if (! elch.length) {
    ul = document.createElement("ul");                
    el.appendChild(ul);
  } else {
    ul = elch[0];
  };
  for (e of err) {
    var li = document.createElement("li");           
    var text = document.createTextNode(e);       
    li.appendChild(text);                        
    ul.appendChild(li);       
  }
}

function forigu_erarojn() {
  var el = document.getElementById("reraroj");
  for (ch of el.children) {
    el.removeChild(ch);
  }
}

function add_err_msg(msg, matches) {
  var errors = [];

  for (m of matches) {
    var m = msg+m[1];
    errors.push(m)
  }
  if (errors.length)
    listigu_erarojn(errors);
}

function kontrolu_kodojn(clist,regex) {
  var xml = document.getElementById("rxmltxt").value;
  var m; var invalid = [];
  var list = revo_codes[clist];

  if (! list.length) {
    console.error("Kodlisto " + clist + "estas malplena, ni ne povas kontroli tion!");
    return;
  }
  
  while (m = regex.exec(xml)) {
    if ( list.indexOf(m[1])<0 ) {
      invalid.push(m);
      console.error("Nevalida kodo \""+m[1]+"\" ĉe: "+m.index);
    }
  }
  return invalid;
}

function kontrolu_mrk(art) {
  var xml = document.getElementById("rxmltxt").value;
  var m; 
  var errors = [];
  
  while (m = re_mrk.exec(xml)) {
    var el = m[1];
    var mrk = m[2];
    if ( mrk.indexOf(art+'.') != 0 ) {
      errors.push("La marko \"" + mrk + "\" (" + el + ") ne komenciĝas je la dosieronomo (" + art + ".).")
    } else if ( mrk.indexOf('0',art.length) < 0 ) {
      errors.push("La marko \"" + mrk + "\" (" + el + ") ne enhavas \"0\" (por tildo).")
    }
  }
  if (errors.length)
    listigu_erarojn(errors); 
}

// trovu tradukojn sen lingvo
function kontrolu_trd() {
  var xml = document.getElementById("rxmltxt").value;
  var m; re_t2 = /(<trd.*?<\/trd>)/g;
  var errors = [];
  
  // forigu bonajn trdgrp kaj trd FARENDA: tio ne trovas <trd lng="..."> ene de trdgrp!
  var x = xml.replace(re_trdgrp,'').replace(re_trd,'');
  while (m = re_t2.exec(x)) {
    errors.push("Traduko sen lingvo: "+m[1]);
  }

  if (errors.length)
    listigu_erarojn(errors); 
}

function kontrolu_ref() {
  var xml = document.getElementById("rxmltxt").value;
  var m; 
  var errors = [];
  
  while (m = re_ref.exec(xml)) {
    var ref = m[1];
    if (ref.search(re_refcel) < 0)
      errors.push("Mankas celo en referenco <ref" + ref + ">"+ m[2] +"</ref>.");
  }
  if (errors.length)
    listigu_erarojn(errors); 
}

function rantaurigardo() {
  vokomailx("rigardo");
  forigu_erarojn();
  kontrolu_mrk("test");
  kontrolu_trd();
  kontrolu_ref();
  add_err_msg("Nekonata lingvo-kodo: ",kontrolu_kodojn("lingvo",re_lng));
  add_err_msg("Nekonata fako: ",kontrolu_kodojn("fako",re_fak));
  add_err_msg("Nekonata stilo: ",kontrolu_kodojn("stilo",re_stl));
 // kontrolu_fak();
  //kontrolu_stl();
  //...
}

function rkonservo() {
  vokomailx("konservo");
}

function create_new_art() {
  var art = document.getElementById("rart").val;
  var ta = document.getElementById("rxmltxt");
  ta.value = 
      '<?xml version="1.0"?>\n'
    + '<!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd">\n'
    + '<vortaro>\n'
    + '<art mrk="\$Id\$">\n'
    + '<kap>\n'
    + '    <rad>' + art + '</rad>/o <fnt><bib>PIV1</bib></fnt>\n'
    + '</kap>\n'
    + '<drv mrk="' + art + '.0o">\n'
    + '  <kap><tld/>o</kap>\n'
    + '  <snc mrk="' + art + '.0o.SNC">\n'
    + '    <uzo tip="fak"></uzo>\n'
    + '    <dif>\n'
    + '      <tld/>o estas:\n'
    + '      <ekz>\n'
    + '        ...\n'
    + '        <fnt><bib></bib>, <lok></lok></fnt>\n'
    + '      </ekz>\n'
    + '    </dif>\n'
    + '  </snc>\n'
    + '  <trd lng=""></trd>\n'
    + '</drv>\n'
    + '</art>\n'
    + '</vortaro>\n';
}
   
function vokomailx(command) {
  var request = new XMLHttpRequest();
  var url = '/cgi-bin/vokomailx.pl';
  var data = new FormData();

  data.append("xmlTxt",document.getElementById("rxmltxt").value);
  data.append("art", document.getElementsByName("art")[0].value);
  data.append("redaktanto", document.getElementsByName("redaktanto")[0].value);
  data.append("sxangxo", document.getElementsByName("sxangxo")[0].value);
  data.append("command", command);

  request.open('POST', url , true);
  
  request.onload = function() {
    if (this.status >= 200 && this.status < 400) {
      // Success!
      parser = new DOMParser();
      doc = parser.parseFromString(this.response,"text/html");

      for (div of doc.getElementsByTagName("div")) {
        console.log("div id=" + div.id);
      }

      /*
      for (e of doc.getElementsByTagName(xmlTag)) {
          var c = e.attributes["kodo"];
          //console.log(c);
          codes.push(c.value);
      } 
*/

    } else {
      // post konektiĝo okazis eraro
      console.error('Eraro dum ŝargo de ' + url);       
    }
  };
  
  request.onerror = function() {
    // konekteraro
    console.error('Eraro dum konektiĝo por ' + url);
  };
  
  //request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
  request.send(data);
}

function load_codes(xmlTag) {
  var codes = [];
  var request = new XMLHttpRequest();
  var fileUrl = revo_codes.url[xmlTag];

  request.open('GET', fileUrl, true);
  
  request.onload = function() {
    if (this.status >= 200 && this.status < 400) {
      // Success!
      parser = new DOMParser();
      doc = parser.parseFromString(this.response,"text/xml");

      for (e of doc.getElementsByTagName(xmlTag)) {
          var c = e.attributes["kodo"];
          //console.log(c);
          codes.push(c.value);
      } 

      revo_codes[xmlTag] = codes;
    } else {
      // post konektiĝo okazis eraro
      console.error('Eraro dum ŝargo de '+fileUrl);       
    }
  };
  
  request.onerror = function() {
    // konekteraro
    console.error('Eraro dum konektiĝo por '+fileUrl);
  };
  
  request.send();
}

function ready(fn) {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
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
}

ready(function() { 
  sf(0, 0, 1);
  restore_preferences();
  load_codes("lingvo");
  load_codes("fako");
  load_codes("stilo");
})