package revo::voko_entities; use utf8;
sub entities { return \%voko_entities; }
%voko_entities = (
'Ĉ'=>'Ccirc',
'ĉ'=>'ccirc',
'Ĝ'=>'Gcirc',
'ĝ'=>'gcirc',
'Ĥ'=>'Hcirc',
'ĥ'=>'hcirc',
'Ĵ'=>'Jcirc',
'ĵ'=>'jcirc',
'Ŝ'=>'Scirc',
'ŝ'=>'scirc',
'Ŭ'=>'Ubreve',
'ŭ'=>'ubreve',
'Œ'=>'OElig',
'œ'=>'oelig',
'Á'=>'Aacute',
'á'=>'aacute',
'É'=>'Eacute',
'é'=>'eacute',
'Í'=>'Iacute',
'í'=>'iacute',
'Ó'=>'Oacute',
'ó'=>'oacute',
'Ú'=>'Uacute',
'ú'=>'uacute',
'À'=>'Agrave',
'à'=>'agrave',
'È'=>'Egrave',
'è'=>'egrave',
'Ì'=>'Igrave',
'ì'=>'igrave',
'Ò'=>'Ograve',
'ò'=>'ograve',
'Ù'=>'Ugrave',
'ù'=>'ugrave',
'Â'=>'Acirc',
'â'=>'acirc',
'Ê'=>'Ecirc',
'ê'=>'ecirc',
'Î'=>'Icirc',
'î'=>'icirc',
'Ô'=>'Ocirc',
'ô'=>'ocirc',
'Û'=>'Ucirc',
'û'=>'ucirc',
'ß'=>'szlig',
'Ä'=>'Auml',
'ä'=>'auml',
'Ö'=>'Ouml',
'ö'=>'ouml',
'Ü'=>'Uuml',
'ü'=>'uuml',
'Ğ'=>'Gbreve',
'ğ'=>'gbreve',
'ı'=>'inodot',
'İ'=>'Idot',
'Ş'=>'Scedil',
'ş'=>'scedil',
'Ç'=>'Ccedil',
'ç'=>'ccedil',
'′'=>'minute',
'″'=>'second',
'„'=>'leftquot',
'“'=>'rightquot',
'°'=>'deg',
'℃'=>'Celsius',
'℉'=>'Fahrenheit',
'²'=>'quadrat',
'³'=>'cubic',
'§'=>'para',
'―'=>'dash',
'—'=>'mdash',
'–'=>'ndash',
' '=>'nbsp',
'Ë'=>'Euml',
'ë'=>'euml',
'Ï'=>'Iuml',
'ï'=>'iuml',
'Å'=>'Aring',
'å'=>'aring',
'Æ'=>'AElig',
'æ'=>'aelig',
'Ø'=>'Oslash',
'ø'=>'oslash',
'Ñ'=>'Ntilde',
'ñ'=>'ntilde',
'Ã'=>'Atilde',
'ã'=>'atilde',
'Õ'=>'Otilde',
'õ'=>'otilde',
'·'=>'middot',
'Ă'=>'Abreve',
'ă'=>'abreve',
'Ţ'=>'Tcedil',
'ţ'=>'tcedil',
'Α'=>'Alfa',
'α'=>'alfa',
'ά'=>'alfa_acute',
'Ά'=>'Alfa_acute',
'ᾴ'=>'alfa_acute_subj',
'ᾰ'=>'alfa_breve',
'Ᾰ'=>'Alfa_breve',
'ᾶ'=>'alfa_circ',
'ᾷ'=>'alfa_circ_subj',
'ἁ'=>'alfa_densa',
'Ἁ'=>'Alfa_densa',
'ἅ'=>'alfa_densa_acute',
'Ἅ'=>'Alfa_densa_acute',
'ᾅ'=>'alfa_densa_acute_subj',
'ᾍ'=>'Alfa_densa_acute_Subj',
'ἇ'=>'alfa_densa_circ',
'Ἇ'=>'Alfa_densa_circ',
'ᾇ'=>'alfa_densa_circ_subj',
'ᾏ'=>'Alfa_densa_circ_Subj',
'ἃ'=>'alfa_densa_grave',
'Ἃ'=>'Alfa_densa_grave',
'ᾃ'=>'alfa_densa_grave_subj',
'ᾋ'=>'Alfa_densa_grave_Subj',
'ᾁ'=>'alfa_densa_subj',
'ᾉ'=>'Alfa_densa_Subj',
'ὰ'=>'alfa_grave',
'Ὰ'=>'Alfa_grave',
'ᾲ'=>'alfa_grave_subj',
'ᾱ'=>'alfa_makron',
'Ᾱ'=>'Alfa_makron',
'ἀ'=>'alfa_psili',
'Ἀ'=>'Alfa_psili',
'ἄ'=>'alfa_psili_acute',
'Ἄ'=>'Alfa_psili_acute',
'ᾄ'=>'alfa_psili_acute_subj',
'ᾌ'=>'Alfa_psili_acute_Subj',
'ἆ'=>'alfa_psili_circ',
'Ἆ'=>'Alfa_psili_circ',
'ᾆ'=>'alfa_psili_circ_subj',
'ᾎ'=>'Alfa_psili_circ_Subj',
'ἂ'=>'alfa_psili_grave',
'Ἂ'=>'Alfa_psili_grave',
'ᾂ'=>'alfa_psili_grave_subj',
'ᾊ'=>'Alfa_psili_grave_Subj',
'ᾀ'=>'alfa_psili_subj',
'ᾈ'=>'Alfa_psili_Subj',
'ᾳ'=>'alfa_subj',
'ᾼ'=>'Alfa_Subj',
'Ά'=>'Alfa_ton',
'ά'=>'alfa_ton',
'Β'=>'Beta',
'β'=>'beta',
'Γ'=>'Gamma',
'γ'=>'gamma',
'Δ'=>'Delta',
'δ'=>'delta',
'Ε'=>'Epsilon',
'ε'=>'epsilon',
'έ'=>'epsilon_acute',
'Έ'=>'Epsilon_acute',
'ἑ'=>'epsilon_densa',
'Ἑ'=>'Epsilon_densa',
'ἕ'=>'epsilon_densa_acute',
'Ἕ'=>'Epsilon_densa_acute',
'ἓ'=>'epsilon_densa_grave',
'Ἓ'=>'Epsilon_densa_grave',
'ὲ'=>'epsilon_grave',
'Ὲ'=>'Epsilon_grave',
'ἐ'=>'epsilon_psili',
'Ἐ'=>'Epsilon_psili',
'ἔ'=>'epsilon_psili_acute',
'Ἔ'=>'Epsilon_psili_acute',
'ἒ'=>'epsilon_psili_grave',
'Ἒ'=>'Epsilon_psili_grave',
'Έ'=>'Epsilon_ton',
'έ'=>'epsilon_ton',
'Ζ'=>'Zeta',
'ζ'=>'zeta',
'Η'=>'Eta',
'η'=>'eta',
'ή'=>'eta_acute',
'Ή'=>'Eta_acute',
'ῄ'=>'eta_acute_subj',
'ῆ'=>'eta_circ',
'ῇ'=>'eta_circ_subj',
'ἡ'=>'eta_densa',
'Ἡ'=>'Eta_densa',
'ἥ'=>'eta_densa_acute',
'Ἥ'=>'Eta_densa_acute',
'ᾕ'=>'eta_densa_acute_subj',
'ᾝ'=>'Eta_densa_acute_Subj',
'ἧ'=>'eta_densa_circ',
'Ἧ'=>'Eta_densa_circ',
'ᾗ'=>'eta_densa_circ_subj',
'ᾟ'=>'Eta_densa_circ_Subj',
'ἣ'=>'eta_densa_grave',
'Ἣ'=>'Eta_densa_grave',
'ᾓ'=>'eta_densa_grave_subj',
'ᾛ'=>'Eta_densa_grave_Subj',
'ᾑ'=>'eta_densa_subj',
'ᾙ'=>'Eta_densa_Subj',
'ὴ'=>'eta_grave',
'Ὴ'=>'Eta_grave',
'ῂ'=>'eta_grave_subj',
'ἠ'=>'eta_psili',
'Ἠ'=>'Eta_psili',
'ἤ'=>'eta_psili_acute',
'Ἤ'=>'Eta_psili_acute',
'ᾔ'=>'eta_psili_acute_subj',
'ᾜ'=>'Eta_psili_acute_Subj',
'ἦ'=>'eta_psili_circ',
'Ἦ'=>'Eta_psili_circ',
'ᾖ'=>'eta_psili_circ_subj',
'ᾞ'=>'Eta_psili_circ_Subj',
'ἢ'=>'eta_psili_grave',
'Ἢ'=>'Eta_psili_grave',
'ᾒ'=>'eta_psili_grave_subj',
'ᾚ'=>'Eta_psili_grave_Subj',
'ᾐ'=>'eta_psili_subj',
'ᾘ'=>'Eta_psili_Subj',
'ῃ'=>'eta_subj',
'ῌ'=>'Eta_Subj',
'Ή'=>'Eta_ton',
'ή'=>'eta_ton',
'Θ'=>'Theta',
'θ'=>'theta',
'Ι'=>'Jota',
'ι'=>'jota',
'ί'=>'jota_acute',
'Ί'=>'Jota_acute',
'ῐ'=>'jota_breve',
'Ῐ'=>'Jota_breve',
'ῖ'=>'jota_circ',
'ἱ'=>'jota_densa',
'Ἱ'=>'Jota_densa',
'ἵ'=>'jota_densa_acute',
'Ἵ'=>'Jota_densa_acute',
'ἷ'=>'jota_densa_circ',
'Ἷ'=>'Jota_densa_circ',
'ἳ'=>'jota_densa_grave',
'Ἳ'=>'Jota_densa_grave',
'ὶ'=>'jota_grave',
'Ὶ'=>'Jota_grave',
'ῑ'=>'jota_makron',
'Ῑ'=>'Jota_makron',
'ἰ'=>'jota_psili',
'Ἰ'=>'Jota_psili',
'ἴ'=>'jota_psili_acute',
'Ἴ'=>'Jota_psili_acute',
'ἶ'=>'jota_psili_circ',
'Ἶ'=>'Jota_psili_circ',
'ἲ'=>'jota_psili_grave',
'Ἲ'=>'Jota_psili_grave',
'Ί'=>'Jota_ton',
'ί'=>'jota_ton',
'Ϊ'=>'Jota_trema',
'ϊ'=>'jota_trema',
'ΐ'=>'jota_trema_acute',
'ῗ'=>'jota_trema_circ',
'ῒ'=>'jota_trema_grave',
'ΐ'=>'jota_trema_ton',
'Κ'=>'Kappa',
'κ'=>'kappa',
'Λ'=>'Lambda',
'λ'=>'lambda',
'Μ'=>'My',
'μ'=>'my',
'Ν'=>'Ny',
'ν'=>'ny',
'Ξ'=>'Xi',
'ξ'=>'xi',
'Ο'=>'Omikron',
'ο'=>'omikron',
'ό'=>'omikron_acute',
'Ό'=>'Omikron_acute',
'ὁ'=>'omikron_densa',
'Ὁ'=>'Omikron_densa',
'ὅ'=>'omikron_densa_acute',
'Ὅ'=>'Omikron_densa_acute',
'ὃ'=>'omikron_densa_grave',
'Ὃ'=>'Omikron_densa_grave',
'ὸ'=>'omikron_grave',
'Ὸ'=>'Omikron_grave',
'ὀ'=>'omikron_psili',
'Ὀ'=>'Omikron_psili',
'ὄ'=>'omikron_psili_acute',
'Ὄ'=>'Omikron_psili_acute',
'ὂ'=>'omikron_psili_grave',
'Ὂ'=>'Omikron_psili_grave',
'Ό'=>'Omikron_ton',
'ό'=>'omikron_ton',
'Π'=>'Pi',
'π'=>'pi',
'Ρ'=>'Rho',
'ρ'=>'rho',
'ῥ'=>'rho_densa',
'Ῥ'=>'Rho_densa',
'ῤ'=>'rho_psili',
'Σ'=>'Sigma',
'σ'=>'sigma',
'ς'=>'sigma_fina',
'Τ'=>'Tau',
'τ'=>'tau',
'Υ'=>'Ypsilon',
'υ'=>'ypsilon',
'ύ'=>'ypsilon_acute',
'Ύ'=>'Ypsilon_acute',
'ῠ'=>'ypsilon_breve',
'Ῠ'=>'Ypsilon_breve',
'ῦ'=>'ypsilon_circ',
'ὑ'=>'ypsilon_densa',
'Ὑ'=>'Ypsilon_densa',
'ὕ'=>'ypsilon_densa_acute',
'Ὕ'=>'Ypsilon_densa_acute',
'ὗ'=>'ypsilon_densa_circ',
'Ὗ'=>'Ypsilon_densa_circ',
'ὓ'=>'ypsilon_densa_grave',
'Ὓ'=>'Ypsilon_densa_grave',
'ὺ'=>'ypsilon_grave',
'Ὺ'=>'Ypsilon_grave',
'ῡ'=>'ypsilon_makron',
'Ῡ'=>'Ypsilon_makron',
'ὐ'=>'ypsilon_psili',
'ὔ'=>'ypsilon_psili_acute',
'ὖ'=>'ypsilon_psili_circ',
'ὒ'=>'ypsilon_psili_grave',
'Ύ'=>'Ypsilon_ton',
'ύ'=>'ypsilon_ton',
'Ϋ'=>'Ypsilon_trema',
'ϋ'=>'ypsilon_trema',
'ΰ'=>'ypsilon_trema_acute',
'ῧ'=>'ypsilon_trema_circ',
'ῢ'=>'ypsilon_trema_grave',
'ΰ'=>'ypsilon_trema_ton',
'Φ'=>'Phi',
'φ'=>'phi',
'Χ'=>'Chi',
'χ'=>'chi',
'Ψ'=>'Psi',
'ψ'=>'psi',
'Ω'=>'Omega',
'ω'=>'omega',
'ώ'=>'omega_acute',
'Ώ'=>'Omega_acute',
'ῴ'=>'omega_acute_subj',
'ῶ'=>'omega_circ',
'ῷ'=>'omega_circ_subj',
'ὡ'=>'omega_densa',
'Ὡ'=>'Omega_densa',
'ὥ'=>'omega_densa_acute',
'Ὥ'=>'Omega_densa_acute',
'ᾥ'=>'omega_densa_acute_subj',
'ᾭ'=>'Omega_densa_acute_Subj',
'ὧ'=>'omega_densa_circ',
'Ὧ'=>'Omega_densa_circ',
'ᾧ'=>'omega_densa_circ_subj',
'ᾯ'=>'Omega_densa_circ_Subj',
'ὣ'=>'omega_densa_grave',
'Ὣ'=>'Omega_densa_grave',
'ᾣ'=>'omega_densa_grave_subj',
'ᾫ'=>'Omega_densa_grave_Subj',
'ᾡ'=>'omega_densa_subj',
'ᾩ'=>'Omega_densa_Subj',
'ὼ'=>'omega_grave',
'Ὼ'=>'Omega_grave',
'ῲ'=>'omega_grave_subj',
'ὠ'=>'omega_psili',
'Ὠ'=>'Omega_psili',
'ὤ'=>'omega_psili_acute',
'Ὤ'=>'Omega_psili_acute',
'ᾤ'=>'omega_psili_acute_subj',
'ᾬ'=>'Omega_psili_acute_Subj',
'ὦ'=>'omega_psili_circ',
'Ὦ'=>'Omega_psili_circ',
'ᾦ'=>'omega_psili_circ_subj',
'ᾮ'=>'Omega_psili_circ_Subj',
'ὢ'=>'omega_psili_grave',
'Ὢ'=>'Omega_psili_grave',
'ᾢ'=>'omega_psili_grave_subj',
'ᾪ'=>'Omega_psili_grave_Subj',
'ᾠ'=>'omega_psili_subj',
'ᾨ'=>'Omega_psili_Subj',
'ῳ'=>'omega_subj',
'ῼ'=>'Omega_Subj',
'Ώ'=>'Omega_ton',
'ώ'=>'omega_ton',
'Ю'=>'c_Ju',
'А'=>'c_A',
'Б'=>'c_B',
'Ц'=>'c_C',
'Д'=>'c_D',
'Е'=>'c_Je',
'Ф'=>'c_F',
'Г'=>'c_G',
'Х'=>'c_H',
'И'=>'c_I',
'Й'=>'c_J',
'К'=>'c_K',
'Л'=>'c_L',
'М'=>'c_M',
'Н'=>'c_N',
'О'=>'c_O',
'П'=>'c_P',
'Я'=>'c_Ja',
'Р'=>'c_R',
'С'=>'c_S',
'Т'=>'c_T',
'У'=>'c_U',
'Ж'=>'c_Zh',
'В'=>'c_V',
'Ь'=>'c_Mol',
'Ы'=>'c_Y',
'З'=>'c_Z',
'Ш'=>'c_Sh',
'Э'=>'c_E',
'Щ'=>'c_Shch',
'Ч'=>'c_Ch',
'Ё'=>'c_Jo',
'Ў'=>'c_W',
'І'=>'c_Ib',
'Ґ'=>'c_Gu',
'Є'=>'c_Jeu',
'Ї'=>'c_Ji',
'ю'=>'c_ju',
'а'=>'c_a',
'б'=>'c_b',
'ц'=>'c_c',
'д'=>'c_d',
'е'=>'c_je',
'ф'=>'c_f',
'г'=>'c_g',
'х'=>'c_h',
'и'=>'c_i',
'й'=>'c_j',
'к'=>'c_k',
'л'=>'c_l',
'м'=>'c_m',
'н'=>'c_n',
'о'=>'c_o',
'п'=>'c_p',
'я'=>'c_ja',
'р'=>'c_r',
'с'=>'c_s',
'т'=>'c_t',
'у'=>'c_u',
'ж'=>'c_zh',
'в'=>'c_v',
'ь'=>'c_mol',
'ы'=>'c_y',
'з'=>'c_z',
'ш'=>'c_sh',
'э'=>'c_e',
'щ'=>'c_shch',
'ч'=>'c_ch',
'ъ'=>'c_malmol',
'ё'=>'c_jo',
'ў'=>'c_w',
'і'=>'c_ib',
'ґ'=>'c_gu',
'є'=>'c_jeu',
'ї'=>'c_ji',
'Č'=>'Ccaron',
'č'=>'ccaron',
'Š'=>'Scaron',
'š'=>'scaron',
'Ř'=>'Rcaron',
'ř'=>'rcaron',
'Ý'=>'Yacute',
'ý'=>'yacute',
'Ž'=>'Zcaron',
'ž'=>'zcaron',
'Ż'=>'Zdot',
'ż'=>'zdot',
'Ň'=>'Ncaron',
'ň'=>'ncaron',
'Ě'=>'Ecaron',
'ě'=>'ecaron',
'Ď'=>'Dcaron',
'ď'=>'dcaron',
'Ť'=>'Tcaron',
'ť'=>'tcaron',
'Ů'=>'Uring',
'ů'=>'uring',
'Ĺ'=>'Lacute',
'ĺ'=>'lacute',
'Ľ'=>'Lcaron',
'ľ'=>'lcaron',
'Ŕ'=>'Racute',
'ŕ'=>'racute',
'Ą'=>'Aogonek',
'ą'=>'aogonek',
'Ł'=>'Lstroke',
'ł'=>'lstroke',
'Ę'=>'Eogonek',
'ę'=>'eogonek',
'Ć'=>'Cacute',
'ć'=>'cacute',
'Ń'=>'Nacute',
'ń'=>'nacute',
'Ś'=>'Sacute',
'ś'=>'sacute',
'Ź'=>'Zacute',
'ź'=>'zacute',
'א'=>'alef',
'ב'=>'bet',
'ג'=>'gimel',
'ד'=>'dalet',
'ה'=>'he',
'ו'=>'vav',
'ז'=>'zayin',
'ח'=>'het',
'ט'=>'tet',
'י'=>'yod',
'ך'=>'fkaf',
'כ'=>'kaf',
'ל'=>'lamed',
'ם'=>'fmem',
'מ'=>'mem',
'ן'=>'fnun',
'נ'=>'nun',
'ס'=>'samekh',
'ע'=>'ayin',
'ף'=>'fpe',
'פ'=>'pe',
'ץ'=>'ftsadi',
'צ'=>'tsadi',
'ק'=>'qof',
'ר'=>'resh',
'ש'=>'shin',
'ת'=>'tav',
'Ő'=>'Odacute',
'ő'=>'odacute',
'Ű'=>'Udacute',
'ű'=>'udacute',
'Ő'=>'Odblac',
'ő'=>'odblac',
'Ű'=>'Udblac',
'ű'=>'udblac',
'ā'=>'amacron',
'ē'=>'emacron',
'ģ'=>'gcommaaccent',
'ī'=>'imacron',
'ķ'=>'kcommaaccent',
'ļ'=>'lcommaaccent',
'ņ'=>'ncommaaccent',
'ō'=>'omacron',
'ŗ'=>'rcommaaccent',
'ū'=>'umacron',
'Ā'=>'Amacron',
'Ē'=>'Emacron',
'Ģ'=>'Gcommaaccent',
'Ī'=>'Imacron',
'Ķ'=>'Kcommaaccent',
'Ļ'=>'Lcommaaccent',
'Ņ'=>'Ncommaaccent',
'Ō'=>'Omacron',
'Ŗ'=>'Rcommaaccent',
'Ū'=>'Umacron',
'Ŷ'=>'Ycirc',
'ŷ'=>'ycirc',
'Ẁ'=>'Wgrave',
'ẁ'=>'wgrave',
'Ẃ'=>'Wacute',
'ẃ'=>'wacute',
'Ẅ'=>'Wuml',
'ẅ'=>'wuml',
'Ỳ'=>'Ygrave',
'ỳ'=>'ygrave',
'Ŵ'=>'Wcirc',
'ŵ'=>'wcirc',
'Ÿ'=>'Yuml',
'ÿ'=>'yuml',
'،'=>'a_komo',
'؛'=>'a_punktokomo',
'؟'=>'a_demando',
'ء'=>'a_hamza',
'آ'=>'a_A_madda',
'أ'=>'a_A_hamza_sure',
'ؤ'=>'a_w_hamza',
'إ'=>'a_A_hamza_sube',
'ئ'=>'a_y_hamza',
'ا'=>'a_A',
'ب'=>'a_b',
'ة'=>'a_t_marbuta',
'ت'=>'a_t',
'ث'=>'a_th',
'ج'=>'a_j',
'ح'=>'a_H',
'خ'=>'a_kh',
'د'=>'a_d',
'ذ'=>'a_dh',
'ر'=>'a_r',
'ز'=>'a_z',
'س'=>'a_s',
'ش'=>'a_sh',
'ص'=>'a_S',
'ض'=>'a_D',
'ط'=>'a_T',
'ظ'=>'a_Z',
'ع'=>'a_ayn',
'غ'=>'a_gh',
'ـ'=>'a_tatwil',
'ف'=>'a_f',
'ق'=>'a_q',
'ك'=>'a_k',
'ل'=>'a_l',
'م'=>'a_m',
'ن'=>'a_n',
'ه'=>'a_h',
'و'=>'a_w',
'ى'=>'a_A_maqsura',
'ي'=>'a_y',
'ً'=>'a_fathatan',
'ٌ'=>'a_dammatan',
'ٍ'=>'a_kasratan',
'َ'=>'a_fatha',
'ُ'=>'a_damma',
'ِ'=>'a_kasra',
'ّ'=>'a_shadda',
'ْ'=>'a_sukun',
'ٓ'=>'a_madda_sure',
'ٔ'=>'a_hamza_sure',
'ٕ'=>'a_hamza_sube',
'ٖ'=>'a_A_sube',
'٠'=>'a_0',
'١'=>'a_1',
'٢'=>'a_2',
'٣'=>'a_3',
'٤'=>'a_4',
'٥'=>'a_5',
'٦'=>'a_6',
'٧'=>'a_7',
'٨'=>'a_8',
'٩'=>'a_9',
'٪'=>'a_procento',
'٫'=>'a_dekumakomo',
'٬'=>'a_milumakomo',
'٭'=>'a_asterisko',
'ٰ'=>'a_A_sure',
'ٱ'=>'a_A_wasla',
'پ'=>'f_p',
'چ'=>'f_ch',
'ژ'=>'f_zh',
'ک'=>'f_k',
'گ'=>'f_g',
'ۀ'=>'u_hy',
'ی'=>'f_y',
'۰'=>'f_0',
'۱'=>'f_1',
'۲'=>'f_2',
'۳'=>'f_3',
'۴'=>'f_4',
'۵'=>'f_5',
'۶'=>'f_6',
'۷'=>'f_7',
'۸'=>'f_8',
'۹'=>'f_9',
'་'=>'t_tsheg',
'ཀ'=>'t_ka',
'ཁ'=>'t_kha',
'ག'=>'t_ga',
'ང'=>'t_nga',
'ཅ'=>'t_ca',
'ཆ'=>'t_cha',
'ཇ'=>'t_ja',
'ཉ'=>'t_nya',
'ཏ'=>'t_ta',
'ཐ'=>'t_tha',
'ད'=>'t_da',
'ན'=>'t_na',
'པ'=>'t_pa',
'ཕ'=>'t_pha',
'བ'=>'t_ba',
'མ'=>'t_ma',
'ཙ'=>'t_tsa',
'ཚ'=>'t_tsha',
'ཛ'=>'t_dza',
'ཝ'=>'t_wa',
'ཞ'=>'t_zha',
'ཟ'=>'t_za',
'འ'=>'t_-a',
'ཡ'=>'t_ya',
'ར'=>'t_ra',
'ལ'=>'t_la',
'ཤ'=>'t_sha',
'ས'=>'t_sa',
'ཧ'=>'t_ha',
'ཨ'=>'t_a',
'ི'=>'t_gigu',
'ུ'=>'t_shabchu',
'ེ'=>'t_drengbu',
'ོ'=>'t_naro',
'ྐ'=>'t_kata',
'ྑ'=>'t_khata',
'ྒ'=>'t_gata',
'ྔ'=>'t_ngata',
'ྕ'=>'t_cata',
'ྖ'=>'t_chata',
'ྗ'=>'t_jata',
'ྙ'=>'t_nyata',
'ྟ'=>'t_tata',
'ྠ'=>'t_thata',
'ྡ'=>'t_data',
'ྣ'=>'t_nata',
'ྤ'=>'t_pata',
'ྥ'=>'t_phata',
'ྦ'=>'t_bata',
'ྨ'=>'t_mata',
'ྩ'=>'t_tsata',
'ྪ'=>'t_tshata',
'ྫ'=>'t_dzata',
'ྭ'=>'t_wasur',
'ྮ'=>'t_zhata',
'ྯ'=>'t_zata',
'ྰ'=>'t_achung',
'ྱ'=>'t_yata',
'ྲ'=>'t_rata',
'ླ'=>'t_lata',
'ྴ'=>'t_shata',
'ྶ'=>'t_sata',
'ྷ'=>'t_hata',
'ྸ'=>'t_ata',
'__%'=>'__%');
