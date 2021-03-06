
use strict;

package revo::eosort;



use Encode;
use CGI qw(escapeHTML);   # nur por trovi erarojn

my @_order_kodoj = ('!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/', '0'..'9','A'..'Z','a'..'z');

##############################################
# cxiuj literoj en unu linio estas samvaloroj
# ili estas ordigita aux tio ordo
##############################################
## .-.-.-.-. begin: this code is generated by ordigo.pl .-.-.-.-.-
my %_order_ci = (
'eo' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'cx'},'ĉ','Ĉ'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'gx'},'ĝ','Ĝ'],
[ {name=>'h'},'h','H'],
[ {name=>'hx'},'ĥ','Ĥ'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'jx'},'ĵ','Ĵ'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'sx'},'ŝ','Ŝ'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U'],
[ {name=>'ux'},'ŭ','Ŭ'],
[ {name=>'v'},'v','V'],
[ {name=>'z'},'z','Z'],

[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
],
'ar' => [
[ {name=>'a'},'ا','أ','إ','آ','ٱ','ء'],
[ {name=>'b'},'ب'],
[ {name=>'c'},'ت','ة'],
[ {name=>'d'},'ث'],
[ {name=>'e'},'ج'],
[ {name=>'f'},'ح'],
[ {name=>'g'},'خ'],
[ {name=>'h'},'د'],
[ {name=>'i'},'ذ'],
[ {name=>'j'},'ر'],
[ {name=>'k'},'ز'],
[ {name=>'l'},'س'],
[ {name=>'m'},'ش'],
[ {name=>'n'},'ص'],
[ {name=>'o'},'ض'],
[ {name=>'p'},'ط'],
[ {name=>'q'},'ظ'],
[ {name=>'r'},'ع'],
[ {name=>'s'},'غ'],
[ {name=>'t'},'ف'],
[ {name=>'u'},'ق'],
[ {name=>'v'},'ك'],
[ {name=>'w'},'ل'],
[ {name=>'x'},'م'],
[ {name=>'y'},'ن'],
[ {name=>'z'},'ه'],
],
'be' => [
[ {name=>'a'},'а','А'],
[ {name=>'b'},'б','Б'],
[ {name=>'v'},'в','В'],
[ {name=>'g'},'г','Г'],
[ {name=>'d'},'д','Д'],
[ {name=>'je'},'е','Е'],
[ {name=>'jo'},'ё','Ё'],
[ {name=>'zh'},'ж','Ж'],
[ {name=>'z'},'з','З'],
[ {name=>'i'},'і','І'],
[ {name=>'j'},'й','Й'],
[ {name=>'k'},'к','К'],
[ {name=>'l'},'л','Л'],
[ {name=>'m'},'м','М'],
[ {name=>'n'},'н','Н'],
[ {name=>'o'},'о','О'],
[ {name=>'p'},'п','П'],
[ {name=>'r'},'р','Р'],
[ {name=>'s'},'с','С'],
[ {name=>'t'},'т','Т'],
[ {name=>'u'},'у','У','ў','Ў'],
[ {name=>'f'},'ф','Ф'],
[ {name=>'h'},'х','Х'],
[ {name=>'c'},'ц','Ц'],
[ {name=>'ch'},'ч','Ч'],
[ {name=>'sh'},'ш','Ш'],
[ {name=>'y'},'ы','Ы'],
[ {name=>'mo'},'ь','Ь'],
[ {name=>'e'},'э','Э'],
[ {name=>'ju'},'ю','Ю'],
[ {name=>'ja'},'я','Я'],
#[ {name=>'ap'},'\x{6E}'],
[ "ign", qr/'/ ],
],
'bg' => [
[ {name=>'a'},'а','А'],
[ {name=>'b'},'б','Б'],
[ {name=>'v'},'в','В'],
[ {name=>'g'},'г','Г'],
[ {name=>'d'},'д','Д'],
[ {name=>'je'},'е','Е'],
[ {name=>'zh'},'ж','Ж'],
[ {name=>'z'},'з','З'],
[ {name=>'i'},'и','И'],
[ {name=>'j'},'й','Й'],
[ {name=>'k'},'к','К'],
[ {name=>'l'},'л','Л'],
[ {name=>'m'},'м','М'],
[ {name=>'n'},'н','Н'],
[ {name=>'o'},'о','О'],
[ {name=>'p'},'п','П'],
[ {name=>'r'},'р','Р'],
[ {name=>'s'},'с','С'],
[ {name=>'t'},'т','Т'],
[ {name=>'u'},'у','У'],
[ {name=>'f'},'ф','Ф'],
[ {name=>'h'},'х','Х'],
[ {name=>'c'},'ц','Ц'],
[ {name=>'ch'},'ч','Ч'],
[ {name=>'sh'},'ш','Ш'],
[ {name=>'shch'},'щ','Щ'],
[ {name=>'mm'},'ъ','Ъ'],
[ {name=>'y'},'ы','Ы'],
[ {name=>'mo'},'ь','Ь'],
[ {name=>'e'},'э','Э'],
[ {name=>'ju'},'ю','Ю'],
[ {name=>'ja'},'я','Я'],
],
'br' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'ch', n=>2},'ch','cH','Ch','CH'],
[ {name=>'cx', n=>3},'c\'h','c\'H','C\'h','C\'H'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N','q','Q'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ù','Ù','ü','Ü'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
],
'ca' => [
[ {name=>'a'},'a','A','à','À'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C','ç','Ç'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','é','É','è','È'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','í','Í','ï','Ï'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L','l','·','L','·'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O','ó','Ó','ò','Ò'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ú','Ú','ü','Ü'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
],
'cs' => [
[ {name=>'a'},'a','A','á','Á'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'cx'},'č','Č'],
[ {name=>'d'},'d','D','ď','Ď'],
[ {name=>'e'},'e','E','é','É','ě','Ě'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'ch', n=>2},'ch','Ch'],
[ {name=>'i'},'i','I','í','Í'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N','ň','Ň'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'rx'},'ř','Ř'],
[ {name=>'s'},'s','S'],
[ {name=>'sx'},'š','Š'],
[ {name=>'t'},'t','T','ť','Ť'],
[ {name=>'u'},'u','U','ú','Ú','ů','Ů'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y','ý','Ý'],
[ {name=>'z'},'z','Z'],
[ {name=>'zx'},'ž','Ž'],
],
'cy' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'c', minus=>'ch'},'c','C'],
[ {name=>'ch', n=>2},'ch','cH','Ch','CH'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'f', minus=>'ff'},'f','F'],
[ {name=>'ff', n=>2},'ff','fF','Ff','FF'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'l', minus=>'ll'},'l','L'],
[ {name=>'ll', n=>2},'ll','lL','Ll','LL'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p', minus=>'ph'},'p','P'],
[ {name=>'ph', n=>2},'ph','pH','Ph','PH'],
[ {name=>'r', minus=>'rh'},'r','R'],
[ {name=>'rh', n=>2},'rh','rH','Rh','RH'],
[ {name=>'s'},'s','S'],
[ {name=>'t', minus=>'th'},'t','T'],
[ {name=>'th', n=>2},'th','tH','Th','TH'],
[ {name=>'u'},'u','U'],
[ {name=>'w'},'w','W','ẃ','Ẃ','ẁ','Ẁ','ŵ','Ŵ','ẅ','Ẅ'],
[ {name=>'y'},'y','Y','ỳ','Ỳ','ŷ','Ŷ','Ÿ'],
],
'da' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
[ {name=>'ae'},'æ','Æ'],
[ {name=>'oe'},'ø','Ø'],
[ {name=>'aa'},'å','Å'],
],
'de' => [
[ {name=>'a'},'a','A','ä','Ä'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O','ö','Ö'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S','ß'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ü','Ü'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
],
'el' => [
[ {name=>'a'},'α','Α','ά','Ά'],
[ {name=>'b'},'β','Β'],
[ {name=>'g'},'γ','Γ'],
[ {name=>'d'},'δ','Δ'],
[ {name=>'e'},'ε','Ε','έ','Έ'],
[ {name=>'z'},'ζ','Ζ'],
[ {name=>'h'},'η','Η','ή','Ή'],
[ {name=>'th'},'θ','Θ'],
[ {name=>'j'},'ι','Ι','ί','Ί','ϊ','Ϊ','ΐ'],
[ {name=>'k'},'κ','Κ'],
[ {name=>'l'},'λ','Λ'],
[ {name=>'m'},'μ','Μ'],
[ {name=>'n'},'ν','Ν'],
[ {name=>'x'},'ξ','Ξ'],
[ {name=>'o'},'ο','Ο','ό','Ό'],
[ {name=>'p'},'π','Π'],
[ {name=>'r'},'ρ','Ρ'],
[ {name=>'s'},'σ','Σ','ς'],
[ {name=>'t'},'τ','Τ'],
[ {name=>'y'},'υ','Υ','ύ','Ύ','ϋ','Ϋ','ΰ'],
[ {name=>'f'},'φ','Φ'],
[ {name=>'ch'},'χ','Χ'],
[ {name=>'ps'},'ψ','Ψ'],
[ {name=>'om'},'ω','Ω','ώ','Ώ'],
],
'en' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','é','É','è','È','ê','Ê'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
[ "sp", qr/['\.]/],
[ "ign", qr/[- ]/ ],
],
'es' => [
[ {name=>'a'},'a','A','á','Á'],
[ {name=>'b'},'b','B'],
[ {name=>'c', minus=>'ch'},'c','C'],
[ {name=>'ch', n=>2},'ch','cH','Ch','CH'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','é','É'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','í','Í'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l', minus=>'ll'},'l','L'],
[ {name=>'ll', n=>2},'ll','lL','Ll','LL'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'nx'},'ñ','Ñ'],
[ {name=>'o'},'o','O','ó','Ó'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ú','Ú','ü','Ü'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
],
'fi' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U'],
[ {name=>'v'},'v','V','w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
[ {name=>'aa'},'å','Å'],
[ {name=>'ae'},'ä','Ä'],
[ {name=>'oe'},'ö','Ö'],
],
'fr' => [
[ {name=>'a'},'a','A','à','À','â','Â','Æ','æ'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C','ç','Ç'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','é','É','è','È','ê','Ê','ë','Ë'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','ì','Ì','î','Î','ï','Ï'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O','ô','Ô','Œ','œ'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ù','Ù','û','Û','ü','Ü'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y','ÿ'],
[ {name=>'z'},'z','Z'],
[ "sp", qr/['\.]/],
[ "ign", qr/[- ]/ ],
],
'gd' => [
[ {name=>'a'},'a','A','à','À'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','è','È'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','ì','Ì'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O','ò','Ò'],
[ {name=>'p'},'p','P'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ù','Ù'],
],
'he' => [
[ {name=>'a'},'א'],
[ {name=>'b'},'ב'],
[ {name=>'g'},'ג'],
[ {name=>'d'},'ד'],
[ {name=>'h'},'ה'],
[ {name=>'v'},'ו'],
[ {name=>'z'},'ז'],
[ {name=>'x'},'ח'],
[ {name=>'t'},'ט'],
[ {name=>'y'},'י'],
[ {name=>'k'},'כ','ך'],
[ {name=>'l'},'ל'],
[ {name=>'m'},'מ','ם'],
[ {name=>'n'},'נ','ן'],
[ {name=>'s'},'ס'],
[ {name=>'ay'},'ע'],
[ {name=>'p'},'פ','ף'],
[ {name=>'ts'},'צ','ץ'],
[ {name=>'q'},'ק'],
[ {name=>'r'},'ר'],
[ {name=>'sh'},'ש'],
[ {name=>'th'},'ת'],
],
'hu' => [
[ {name=>'a'},'a','A','á','Á'],
[ {name=>'b'},'b','B'],
[ {name=>'c', minus=>'cs'},'c','C'],
[ {name=>'cs', n=>2},'cs','Cs'],
[ {name=>'d', minus=>'dz'},'d','D'],
[ {name=>'dz', n=>2, minus=>'dzs'},'dz','Dz'],
[ {name=>'dzs', n=>3},'dzs','Dzs'],
[ {name=>'e'},'e','E','é','É'],
[ {name=>'f'},'f','F'],
[ {name=>'g', minus=>'gy'},'g','G'],
[ {name=>'gy', n=>2},'gy','Gy'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','í','Í'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l', minus=>'ly'},'l','L'],
[ {name=>'ly', n=>2},'ly','Ly'],
[ {name=>'m'},'m','M'],
[ {name=>'n', minus=>'ny'},'n','N'],
[ {name=>'ny', n=>2},'ny','Ny'],
[ {name=>'o'},'o','O','ó','Ó'],
[ {name=>'oe'},'ö','Ö','ő','Ő'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s', minus=>'sz'},'s','S'],
[ {name=>'sz', n=>2},'sz','Sz'],
[ {name=>'t', minus=>'ty'},'t','T'],
[ {name=>'ty', n=>2},'ty','Ty'],
[ {name=>'u'},'u','U','ú','Ú'],
[ {name=>'ue'},'ü','Ü','ű','Ű'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z', minus=>'zs'},'z','Z'],
[ {name=>'zs', n=>2},'zs','Zs'],
],
'is' => [
[ {name=>'a'},'a','A','á','Á'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D',' ','ð','Ð'],
[ {name=>'e'},'e','E','é','É'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','í','Í'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O','ó','Ó'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ú','Ú'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y','ý','Ý'],
[ {name=>'z'},'z','Z'],
[ {name=>'px'},'þ','Þ'],
[ {name=>'ae'},'æ','Æ'],
[ {name=>'oe'},'ö','Ö'],
],
'ja' => [
[ {name=>'a'},'あ','ぁ'],
[ {name=>'i'},'い','ぃ'],
[ {name=>'u'},'う','ぅ'],
[ {name=>'e'},'え','ぇ'],
[ {name=>'o'},'お','ぉ'],
[ {name=>'ka'},'か'],
[ {name=>'ga'},'が'],
[ {name=>'ki'},'き'],
[ {name=>'gi'},'ぎ'],
[ {name=>'ku'},'く'],
[ {name=>'gu'},'ぐ'],
[ {name=>'ke'},'け'],
[ {name=>'ge'},'げ'],
[ {name=>'ko'},'こ'],
[ {name=>'go'},'ご'],
[ {name=>'sa'},'さ'],
[ {name=>'za'},'ざ'],
[ {name=>'si'},'し'],
[ {name=>'zi'},'じ'],
[ {name=>'su'},'す'],
[ {name=>'zu'},'ず'],
[ {name=>'se'},'せ'],
[ {name=>'ze'},'ぜ'],
[ {name=>'so'},'そ'],
[ {name=>'zo'},'ぞ'],
[ {name=>'ta'},'た'],
[ {name=>'da'},'だ'],
[ {name=>'ti'},'ち'],
[ {name=>'di'},'ぢ'],
[ {name=>'tu'},'つ','っ'],
[ {name=>'du'},'づ'],
[ {name=>'te'},'て'],
[ {name=>'de'},'で'],
[ {name=>'to'},'と'],
[ {name=>'do'},'ど'],
[ {name=>'na'},'な'],
[ {name=>'ni'},'に'],
[ {name=>'nu'},'ぬ'],
[ {name=>'ne'},'ね'],
[ {name=>'no'},'の'],
[ {name=>'ha'},'は'],
[ {name=>'ba'},'ば'],
[ {name=>'pa'},'ぱ'],
[ {name=>'hi'},'ひ'],
[ {name=>'bi'},'び'],
[ {name=>'pi'},'ぴ'],
[ {name=>'hu'},'ふ'],
[ {name=>'bu'},'ぶ'],
[ {name=>'pu'},'ぷ'],
[ {name=>'he'},'へ'],
[ {name=>'be'},'べ'],
[ {name=>'pe'},'ぺ'],
[ {name=>'ho'},'ほ'],
[ {name=>'bo'},'ぼ'],
[ {name=>'po'},'ぽ'],
[ {name=>'ma'},'ま'],
[ {name=>'mi'},'み'],
[ {name=>'mu'},'む'],
[ {name=>'me'},'め'],
[ {name=>'mo'},'も'],
[ {name=>'ya'},'や','ゃ'],
[ {name=>'yu'},'ゆ','ゅ'],
[ {name=>'yo'},'よ','ょ'],
[ {name=>'ra'},'ら'],
[ {name=>'ri'},'り'],
[ {name=>'ru'},'る'],
[ {name=>'re'},'れ'],
[ {name=>'ro'},'ろ'],
[ {name=>'wa'},'わ','ゎ'],
[ {name=>'wi'},'ゐ'],
[ {name=>'we'},'ゑ'],
[ {name=>'wo'},'を'],
[ {name=>'n'},'ん'],
[ {name=>'vu'},'ゔ'],
],
'la' => [
[ {name=>'a'},'a','A','á','Á','à','À','ä','Ä'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C','ç','Ç'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','é','É','è','È','ë','Ë'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','í','Í','ì','Ì','ï','Ï'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O','ó','Ó','ò','Ò','ö','Ö'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ú','Ú','ù','Ù','ü','Ü'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
],
'lt' => [
[ {name=>'a'},'a','A','ą'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C','č'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','ę','ė'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','į'],
[ {name=>'y'},'y','Y'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S','š'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ų','ū'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'z'},'z','Z','ž'],
],
'lv' => [
[ {name=>'a'},'a','A','ā'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C','č'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','ē'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G','ģ'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','ī'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K','ķ'],
[ {name=>'l'},'l','L','ļ'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N','ņ'],
[ {name=>'o'},'o','O','ō'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R','ŗ'],
[ {name=>'s'},'s','S','š'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ū'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z','ž'],
],
'no' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
[ {name=>'ae'},'æ','Æ'],
[ {name=>'oe'},'ø','Ø'],
],
'os' => [
[ {name=>'a'},'а','А'],
[ {name=>'ae'},'æ','Æ'],
[ {name=>'b'},'б','Б'],
[ {name=>'v'},'в','В'],
[ {name=>'g', minus=>'gh'},'г','Г'],
[ {name=>'gh', n=>2},'гъ','Гъ'],
[ {name=>'d', minus=>'dz'},'д','Д'],
[ {name=>'dz', n=>2, minus=>'dj'},'дз','Дз','дж','Дж'],
[ {name=>'dj', n=>2},'дж','Дж'],
[ {name=>'je'},'е','Е'],
[ {name=>'jo'},'ё','Ё'],
[ {name=>'zh'},'ж','Ж'],
[ {name=>'z'},'з','З'],
[ {name=>'i'},'и','И'],
[ {name=>'j'},'й','Й'],
[ {name=>'k', minus=>'kh'},'к','К'],
[ {name=>'kh', n=>2},'къ','Къ'],
[ {name=>'l'},'л','Л'],
[ {name=>'m'},'м','М'],
[ {name=>'n'},'н','Н'],
[ {name=>'o'},'о','О'],
[ {name=>'p', minus=>'ph'},'п','П'],
[ {name=>'ph', n=>2},'пъ','Пъ'],
[ {name=>'r'},'р','Р'],
[ {name=>'s'},'с','С'],
[ {name=>'t', minus=>'th'},'т','Т'],
[ {name=>'th', n=>2},'тъ','Тр'],
[ {name=>'u'},'у','У'],
[ {name=>'f'},'ф','Ф'],
[ {name=>'h', minus=>'hh'},'х','Х'],
[ {name=>'hh', n=>2},'хъ','Хъ'],
[ {name=>'c', minus=>'cs'},'ц','Ц'],
[ {name=>'cs', n=>2},'цъ','Цъ'],
[ {name=>'ch', minus=>'cx'},'ч','Ч'],
[ {name=>'cx', n=>2},'чъ','Чъ'],
[ {name=>'sh'},'ш','Ш'],
[ {name=>'shch'},'щ','Щ'],
[ {name=>'mm'},'ъ','Ъ'],
[ {name=>'y'},'ы','Ы'],
[ {name=>'mo'},'ь','Ь'],
[ {name=>'e'},'э','Э'],
[ {name=>'ju'},'ю','Ю'],
[ {name=>'ja'},'я','Я'],
],
'pl' => [
[ {name=>'a'},'a','A'],
[ {name=>'ax'},'ą','Ą'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'cx'},'ć','Ć'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'ex'},'ę','Ę'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'lx'},'ł','Ł'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'nx'},'ń','Ń'],
[ {name=>'o'},'o','O'],
[ {name=>'ox'},'ó','Ó'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'sx'},'ś','Ś'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
[ {name=>'zx'},'ź','Ź'],
[ {name=>'zy'},'ż','Ż'],
],
'pt' => [
[ {name=>'a'},'a','A','á','Á','à','À','â','Â','�','�'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C','ç','Ç'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','é','É','ê','Ê'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I','í','Í'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O','ó','Ó','ô','Ô','ġ','Ġ'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ú','Ú','ü'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
],
'ru' => [
[ {name=>'a'},'а','А'],
[ {name=>'b'},'б','Б'],
[ {name=>'v'},'в','В'],
[ {name=>'g'},'г','Г'],
[ {name=>'d'},'д','Д'],
[ {name=>'je'},'е','Е'],
[ {name=>'jo'},'ё','Ё'],
[ {name=>'zh'},'ж','Ж'],
[ {name=>'z'},'з','З'],
[ {name=>'i'},'и','И'],
[ {name=>'j'},'й','Й'],
[ {name=>'k'},'к','К'],
[ {name=>'l'},'л','Л'],
[ {name=>'m'},'м','М'],
[ {name=>'n'},'н','Н'],
[ {name=>'o'},'о','О'],
[ {name=>'p'},'п','П'],
[ {name=>'r'},'р','Р'],
[ {name=>'s'},'с','С'],
[ {name=>'t'},'т','Т'],
[ {name=>'u'},'у','У'],
[ {name=>'f'},'ф','Ф'],
[ {name=>'h'},'х','Х'],
[ {name=>'c'},'ц','Ц'],
[ {name=>'ch'},'ч','Ч'],
[ {name=>'sh'},'ш','Ш'],
[ {name=>'shch'},'щ','Щ'],
[ {name=>'mm'},'ъ','Ъ'],
[ {name=>'y'},'ы','Ы'],
[ {name=>'mo'},'ь','Ь'],
[ {name=>'e'},'э','Э'],
[ {name=>'ju'},'ю','Ю'],
[ {name=>'ja'},'я','Я'],
],
'sk' => [
[ {name=>'a'},'a','A','á','Á'],
[ {name=>'ae'},'ä','Ä'],
[ {name=>'b'},'b','B'],
[ {name=>'c', minus=>'ch'},'c','C'],
[ {name=>'cx'},'č','Č'],
[ {name=>'d', minus=>'dz'},'d','D',';','ď','Ď'],
[ {name=>'dz', n=>2, minus=>'dj'},'dz','Dz','d&','#x','01','7e','D;','ž'],
[ {name=>'dj', n=>2},'d&','#x','01','7e','D;','ž'],
[ {name=>'e'},'e','E','é','É'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'ch', n=>2},'ch','CH'],
[ {name=>'i'},'i','I','í','Í'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L',';','ĺ','Ĺ','ľ','Ľ'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N',';','ň','Ň'],
[ {name=>'o'},'o','O','ó','Ó'],
[ {name=>'ox'},'ô','Ô'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R',';','ŕ','Ŕ'],
[ {name=>'s'},'s','S'],
[ {name=>'sx'},'š','Š'],
[ {name=>'t'},'t','T',';','ť','Ť'],
[ {name=>'u'},'u','U','ú','Ú'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y','ŭ','Ŭ'],
[ {name=>'z'},'z','Z'],
[ {name=>'zx'},'ž','Ž'],
],
'sl' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C','č'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S','š'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z','ž'],
],
'sv' => [
[ {name=>'a'},'a','A'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','é','É'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U'],
[ {name=>'v'},'v','V','w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
[ {name=>'aa'},'å','Å'],
[ {name=>'ae'},'ä','Ä'],
[ {name=>'oe'},'ö','Ö'],
],
'tr' => [
[ {name=>'a'},'A','a','Â','â'],
[ {name=>'b'},'B','b'],
[ {name=>'c'},'C','c'],
[ {name=>'cx'},'Ç','ç'],
[ {name=>'d'},'D','d'],
[ {name=>'e'},'E','e'],
[ {name=>'f'},'F','f'],
[ {name=>'g'},'G','g'],
[ {name=>'gx'},'Ğ','ğ'],
[ {name=>'h'},'H','h'],
[ {name=>'ix'},'I','ı'],
[ {name=>'i'},'İ','i','Î','î'],
[ {name=>'j'},'J','j'],
[ {name=>'k'},'K','k'],
[ {name=>'l'},'L','l'],
[ {name=>'m'},'M','m'],
[ {name=>'n'},'N','n'],
[ {name=>'o'},'O','o'],
[ {name=>'ox'},'Ö','ö'],
[ {name=>'p'},'P','p'],
[ {name=>'r'},'R','r'],
[ {name=>'s'},'S','s'],
[ {name=>'sx'},'Ş','ş'],
[ {name=>'t'},'T','t'],
[ {name=>'u'},'U','u','Û','û'],
[ {name=>'ux'},'Ü','ü'],
[ {name=>'v'},'V','v'],
[ {name=>'y'},'Y','y'],
[ {name=>'z'},'Z','z'],
],
'uk' => [
[ {name=>'a'},'а','А'],
[ {name=>'b'},'б','Б'],
[ {name=>'v'},'в','В'],
[ {name=>'g'},'г','Г'],
[ {name=>'gu'},'ґ','Ґ'],
[ {name=>'d'},'д','Д'],
[ {name=>'je'},'е','Е'],
[ {name=>'jeu'},'є','Є'],
[ {name=>'zh'},'ж','Ж'],
[ {name=>'z'},'з','З'],
[ {name=>'i'},'и','И'],
[ {name=>'ib'},'і','І'],
[ {name=>'ji'},'ї','Ї'],
[ {name=>'j'},'й','Й'],
[ {name=>'k'},'к','К'],
[ {name=>'l'},'л','Л'],
[ {name=>'m'},'м','М'],
[ {name=>'n'},'н','Н'],
[ {name=>'o'},'о','О'],
[ {name=>'p'},'п','П'],
[ {name=>'r'},'р','Р'],
[ {name=>'s'},'с','С'],
[ {name=>'t'},'т','Т'],
[ {name=>'u'},'у','У'],
[ {name=>'f'},'ф','Ф'],
[ {name=>'h'},'х','Х'],
[ {name=>'c'},'ц','Ц'],
[ {name=>'ch'},'ч','Ч'],
[ {name=>'sh'},'ш','Ш'],
[ {name=>'shch'},'щ','Щ'],
[ {name=>'mo'},'ь','Ь'],
[ {name=>'ju'},'ю','Ю'],
[ {name=>'ja'},'я','Я'],
],
'zh' => [
[ {name=>'ling2'},'〇'],
[ {name=>'ai4'},'爱','愛','伌','僾','叆','唆','嗋','嗳','噯','堥','塧','壒','嫒','嬡','懓','懝',
  '戳','暧','曖','濭','瑷','璦','皧','瞹','砨','砱','硋','碍','礙','艾','薆','譪','賹','鑀','閝',
  '阦','阵','隘','靉','餱','鴱'],
[ {name=>'pa1'},'啪','夿','妑','扒','派','皅','舥','芭','葩','蚆','趴'],
[ {name=>'pa2'},'扒','掭','杷','潖','爬','琶','筢','耙','跁','鈀','钭'],
[ {name=>'ba1'},'八','仈','叭','吧','哵','夿','岜','岰','巴','扒','捌','朳','玐',
  '疤','笆','粑','羓','芭','豝','釟','鈀','鲃'],
[ {name=>'bai3'},'百','伫','佰','捭','摆','擺','柏','栢','百','矲','粨','絔','罞','署','襬'],

[ {name=>'yi1'},'一'],
],

'utf' => [
[ {name=>'a'},'a','A','ä','Ä'],
[ {name=>'b'},'b','B'],
[ {name=>'c'},'c','C'],
[ {name=>'d'},'d','D'],
[ {name=>'e'},'e','E','é','É','è','È','ê','Ê','ë','Ë'],
[ {name=>'f'},'f','F'],
[ {name=>'g'},'g','G'],
[ {name=>'h'},'h','H'],
[ {name=>'i'},'i','I', 'ï'],
[ {name=>'j'},'j','J'],
[ {name=>'k'},'k','K'],
[ {name=>'l'},'l','L'],
[ {name=>'m'},'m','M'],
[ {name=>'n'},'n','N'],
[ {name=>'o'},'o','O','ö','Ö'],
[ {name=>'p'},'p','P'],
[ {name=>'q'},'q','Q'],
[ {name=>'r'},'r','R'],
[ {name=>'s'},'s','S','ß'],
[ {name=>'t'},'t','T'],
[ {name=>'u'},'u','U','ü','Ü'],
[ {name=>'v'},'v','V'],
[ {name=>'w'},'w','W'],
[ {name=>'x'},'x','X'],
[ {name=>'y'},'y','Y'],
[ {name=>'z'},'z','Z'],
],
);
## .-.-.-.-. end: this code is generated by ordigo.pl .-.-.-.-.-
##############################################
sub new
{
  my $type = shift;
  my %params = @_;
  my $self = {dbg=>$params{dbg}};
  my %mapper_ci;
  my %ignoru;
  my %spacigu;
	
#  print "count_lng = ".(keys %_order_ci)."\n" if $self->{dbg};
  foreach my $lng (keys %_order_ci) {
#    print "lng = $lng\n" if $self->{dbg};

    $mapper_ci{$lng} = [{}, {}, {}, {}];
  
    my $lingvo = $_order_ci{$lng};
#    print "lingvo = $lingvo\n" if $self->{dbg};
    my $count = $#$lingvo;
#    print "count = $count\n" if $self->{dbg};
    die "Ne suficxe da kodoj max $#_order_kodoj" if $#_order_kodoj < $count;

    for my $i (0..$count) {
#$self->{dbg} = ($lng eq "eo");
#$self->{dbg} = ($lng eq "eo" and $i == 3);
      my $aref = $$lingvo[$i];
      if (ref($aref->[1]) eq "Regexp") {
#        print "<pre>ref aref=ref(".ref($aref).")</pre>\n" if $lng eq "be" and $self->{dbg};
        if ($aref->[0] eq 'sp') {
          $spacigu{$lng} = $aref->[1];
        } elsif ($aref->[0] eq 'ign') {
          $ignoru{$lng} = $aref->[1];
        } else {
        }
        next;
      }
#      print "i = $i\n" if $self->{dbg};
#      print "aref = $aref\n" if $self->{dbg};
      my $litparam = $aref->[0];
      $$litparam{'n'} = 1 unless $$litparam{'n'};
#      print "litparam = $litparam\n" if $self->{dbg};
#      if ($self->{dbg}) {
#        print "  $_ = $$litparam{$_}\n" foreach (keys %$litparam);
#      }

#exit if $i > 4;
      my $kodo = $_order_kodoj[$i];
#      print "kodo = $kodo\n" if $self->{dbg};
      foreach my $i (1..$#$aref) {
#        my $u = utf8(@$aref[$i]);
#        my @lit = $u->unpack('U*');
        my $enc = "utf-8";
        my $u = Encode::decode($enc, @$aref[$i]);
        my @lit = unpack 'U*', $u;
        die "pli ol $$litparam{'n'} unikodo letero: $u" if $#lit >= $$litparam{'n'};
#        print "lit = ".(join ',', @lit).", lit = @$aref[$i], kodo=$kodo\n" if $self->{dbg};
        $mapper_ci{$lng}->[0]->{join(',', @lit)} = $i;
        $mapper_ci{$lng}->[$$litparam{'n'}]->{join(',', @lit)} = $kodo;
        $mapper_ci{$lng}->[$$litparam{'n'}]->{$lit[0]} = 1 if $$litparam{'n'} > 1;
#exit if $$litparam{'n'} > 1;
      }
#      print "\n" if $self->{dbg};
    }
  }

#  foreach (@_order_kodoj) {
#    print "kodo: $_\n";
#  }

  $self->{mapper_ci}  = \%mapper_ci;
  $self->{ignoru}     = \%ignoru;
  $self->{spacigu}    = \%spacigu;
  bless $self, $type;
}

sub sortval_lng
{
  my ($self, $kat, $lng, $str) = @_;
  my $str2 = $str;
  print "sortval_lng ($lng, $str)\n" if $self->{dbg};
  if ($str =~ s/^.*?<u>(.*?)<\/u>.*/$1/
   || $str =~ s/ ?\(.*?\) ?//) {
    $str2 =~ s/<\/?u>//g;
  } else {
    $str2 = undef;
  }
  my ($kap_ci, $unua) = $self->remap_ci_lng($lng, $str);
  my ($kap_ci2) = $self->remap_ci_lng($lng, $str2) if $str2;
  print "sortval_lng: str=$str, kap_ci=$kap_ci, unua=$unua\n" if $self->{dbg};

  return ($kap_ci, $unua, $kap_ci2);
}

sub remap_ci_lng
{
  my $self = shift;
  my $lng = shift;
  my $arg = shift;
  my $enc = "utf-8";
  my $u = $arg;
#  print "arg $arg is not utf8\n" if not Encode::is_utf8($arg) and $self->{dbg};
#  print "arg $u is not utf8\n" if not Encode::is_utf8($u) and $self->{dbg};
  $u = Encode::decode($enc, $u) if not Encode::is_utf8($u);
#  my $u = utf8($arg);
#  print "remap_ci_lng err arg=$arg\n";# unless $u;
#  print "remap_ci_lng (".$u->utf8().", $lng)\n" if $self->{dbg};
  print "remap_ci_lng (".escapeHTML(encode('UTF-8', $u)).", $lng)\n" if $self->{dbg};

  if (exists $self->{ignoru}->{$lng}) {
    $u =~ s/$self->{ignoru}->{$lng}//g;
    print "remap_re\n" if $self->{dbg};
    print "remap_ci_lng (".encode('UTF-8', $u).", $lng)\n" if $self->{dbg};
  }
  if (exists $self->{spacigu}->{$lng}) {
    $u =~ s/$self->{spacigu}->{$lng}/ /g;
    print "remap spacigu re\n" if $self->{dbg};
    print "remap_ci_lng (".encode('UTF-8', $u).", $lng)\n" if $self->{dbg};
  }
#  if ($lng eq "zh") {
#    return ($u, '?', '?', undef);
#  }

#  $u->utf8() =~ s/[- ]//g;
#  print "remap_ci ($u)\n";# if $self->{dbg};
#  print "$_ len=".$u->length()."\n" if $self->{dbg};
#  my @lit = $u->unpack('U*');
  my @lit = unpack 'U*', $u;
#  print "lit1 = ".join('-', @lit)."\n" if $self->{dbg};
  for (my $i = $#lit; $i >= 0; $i--) {
#    print "test $i: $lit[$i]\n" if $self->{dbg};
    splice(@lit,$i,1) if $lit[$i] == ord('(') or $lit[$i] == ord(')');  # or $lit[$i] == ord(' ')	 # or $lit[$i] == ord('-') 
  }
  my $mapref = $self->{mapper_ci}->{$lng};
  $mapref = $self->{mapper_ci}->{'utf'} unless $mapref;
  my ($unua, $unua_utf8, $name, $ord);
  if ($mapref) {
    for (my $i = 0; $i <= $#lit; $i++) {
#      print "test $i: $lit[$i]\n";# if $self->{dbg};
      my $j;
      for ($j = 3; $j > 0; $j--) {
        if (exists($$mapref[$j]->{$lit[$i]})) {
#          print "map j=".($j)."\n";# if $self->{dbg};
#          print "  ".(join(',', @lit[$i..($i+($j-1))]))."\n";# if $self->{dbg};
#          print "lit1 = ".join('-', @lit)."\n";# if $self->{dbg};
          if (exists($$mapref[$j]->{join(',', @lit[$i..($i+($j-1))])})) {
#            print "map n=$j match kodo=$$mapref[$j]->{join(',', @lit[$i..($i+($j-1))])}\n";# if $self->{dbg};
#            print "lit=".join(',', @lit[$i..($i+($j-1))])."\n";# if $self->{dbg};
            my $ord2 = $$mapref[0]->{join(',', @lit[$i..($i+($j-1))])};
            $lit[$i] = $$mapref[$j]->{join(',', @lit[$i..($i+($j-1))])};
            if ($i == 0) {
              $unua = $lit[$i];
              $ord = $ord2;
            }
#            print "i=$i, j=$j, lit=".join(',', @lit[$i..($i+($j-1))])."\n";# if $self->{dbg};
            if ($j > 1) {
              splice(@lit, $i+1, $j-1);
#              $i -= $j - 1;
            }
#            print "lit1 = ".join('-', @lit)."-\n" if $self->{dbg};
            last;
          }
        }
      }
#      print "ne konata letero $lng $lit[$i]" if $j <= 0;
      if ($j <= 0) {
#        if ($lit[$i] == ord('-')) {
#          $lit[$i] = 'y';
#        } els
	if ($lit[$i] == ord(',') or $lit[$i] == ord(' ')) {
          $lit[$i] = ' ';
        } else {
          splice(@lit, $i, 1);
        }
      }
    }

    ($unua_utf8, $name) = $self->ord2utf8($lng, $unua);
  }
  print "remap_ci_lng -> ".join('', @lit)."-\n" if $self->{dbg};
  return (join('', @lit), $unua, $unua_utf8, $name);
}

sub ord2utf8
{
  my $self = shift;
  my $lng = shift;
  my $arg = shift;
  my $arg_utf8;
  my $name;
  my $orderref = $_order_ci{$lng};
  $orderref = $_order_ci{'utf'} unless $orderref;

  return ($arg, $arg) unless $orderref;
  return ($arg, 0) if $arg eq '?';
  
  for (my $i = 0; $i < $#_order_kodoj; $i++) {
    if ($_order_kodoj[$i] eq $arg) {
#      print "found i=$i\n";
      $arg_utf8 = $orderref->[$i]->[1];
      $name = $orderref->[$i]->[0]->{name};
#      print "found arg_utf8=$arg_utf8\n";
      last;
    }
  }
  return ($arg_utf8, $name);
}

sub name2utf8
{
  my $self = shift;
  my $lng = shift;
  my $arg = shift;
  my $arg_utf8;
  my $kodo;
  my $orderref = $_order_ci{$lng};
  $orderref = $_order_ci{'utf'} unless $orderref;

  return ($arg, $arg) unless $orderref;
  return ('?', '?') if $arg eq '0';

#  print pre("name2utf8: lng=$lng, arg=$arg\n");
  for (my $i = 0; $i <= $#$orderref; $i++) {
    next if ref($orderref->[$i]->[1]) eq "Regexp";
    if ($orderref->[$i]->[0]->{name} eq $arg) {
      $arg_utf8 = $orderref->[$i]->[1];
      $kodo = $_order_kodoj[$i];
      last;
    }
  }
  return ($arg_utf8, $kodo);
}

1;
