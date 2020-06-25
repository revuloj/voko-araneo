var lingvoj_xml = '/revo/cfg/lingvoj.xml';
var fakoj_xml = '/revo/cfg/fakoj.xml';
var stiloj_xml = '/revo/cfg/stiloj.xml';

var c_lingvoj = [];
var c_fakoj = [];
var c_stiloj = [];

function load_codes(file,selector) {
  var codes = [];
  $.get(file)
   .done(function(data) {
      var doc = (data instanceof XMLDocument)? data : $.parseXML(data);
      $(doc).find(selector).each(
        function() {
          codes.push(this.attributes["kodo"].value);
    })   
  }) 
  return codes;
}

$(function() { 
    c_lingvoj=load_codes(lingvoj_xml,"lingvo");
    c_fakoj=load_codes(fakoj_xml,"fako");
    c_stiloj=load_codes(stiloj_xml,"stilo");
})