/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.parser.html;

using StringTools;

/**
 * @see http://www.w3.org/TR/html5/syntax.html#input-stream
 * 
 * TODO
 *  - instead of parsing the string as an array, we could use two stringbuf, one for consumed chars and one for chars to consume
 *  - manage insertion point ?
 * 
 * @author Thomas Fétiveau
 */
class InputStream
{
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#tokenizing-character-references
	 */
	static inline function charRefReplacements() : Map<Int,Int>
	{
		return [ 0x0 => 0xFFFD, 0xD => 0xD, 0x80 => 0x20AC,
		0x81 => 0x81, 0x82 => 0x201A, 0x83 => 0x192, 0x84 => 0x201E,
		0x85 => 0x2026, 0x86 => 0x2020, 0x87 => 0x2021, 0x88 => 0x2C6,
		0x89 => 0x2030, 0x8A => 0x160, 0x8B => 0x2039, 0x8C => 0x152, 
		0x8D => 0x8D, 0x8E => 0x17D, 0x8F => 0x8F, 0x90 => 0x90, 
		0x91 => 0x2018, 0x92 => 0x2019, 0x93 => 0x201C, 0x94 => 0x201D, 
		0x95 => 0x2022, 0x96 => 0x2013, 0x97 => 0x2014, 0x98 => 0x2DC, 
		0x99 => 0x2122, 0x9A => 0x161, 0x9B => 0x203A, 0x9C => 0x153, 
		0x9D => 0x9D, 0x9E => 0x17E, 0x9F => 0x178 ];
	}
	
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#named-character-references
	 */
	static inline function namedCharRef() : Map<String,Array<Int>>
	{
		return [ "&Aacute;" => [0xC1], "&Aacute" => [0xC1], "&aacute;" => [0xE1], "&aacute" => [0xE1], "&Abreve;" => [0x102], "&abreve;" => [0x103], "&ac;" => [0x223E],
		"&acd;" => [0x223F], "&acE;" => [0x223E, 0x333], "&Acirc;" => [0xC2], "&Acirc" => [0xC2], "&acirc;" => [0xE2], "&acirc" => [0xE2], "&acute;" => [0xB4], 
		"&acute" => [0xB4], "&Acy;" => [0x410], "&acy;" => [0x430], "&AElig;" => [0xC6], "&AElig" => [0xC6], "&aelig;" => [0xE6], "&aelig" => [0xE6], "&af;" => [0x2061],
		"&Afr;" => [0x1D504], "&afr;" => [0x1D51E], "&Agrave;" => [0xC0], "&Agrave" => [0xC0], "&agrave;" => [0xE0], "&agrave" => [0xE0], "&alefsym;" => [0x2135],
		"&aleph;" => [0x2135], "&Alpha;" => [0x391], "&alpha;" => [0x3B1], "&Amacr;" => [0x100], "&amacr;" => [0x101], "&amalg;" => [0x2A3F], "&AMP;" => [0x26],
		"&AMP" => [0x26], "&amp;" => [0x26], "&amp" => [0x26], "&And;" => [0x2A53], "&and;" => [0x2227], "&andand;" => [0x2A55], "&andd;" => [0x2A5C],
		"&andslope;" => [0x2A58], "&andv;" => [0x2A5A], "&ang;" => [0x2220], "&ange;" => [0x29A4], "&angle;" => [0x2220], "&angmsd;" => [0x2221], "&angmsdaa;" => [0x29A8], 
		"&angmsdab;" => [0x29A9], "&angmsdac;" => [0x29AA], "&angmsdad;" => [0x29AB], "&angmsdae;" => [0x29AC], "&angmsdaf;" => [0x29AD], "&angmsdag;" => [0x29AE],
		"&angmsdah;" => [0x29AF], "&angrt;" => [0x221F], "&angrtvb;" => [0x22BE], "&angrtvbd;" => [0x299D], "&angsph;" => [0x2222], "&angst;" => [0xC5], "&angzarr;" => [0x237C],
		"&Aogon;" => [0x104], "&aogon;" => [0x105], "&Aopf;" => [0x1D538], "&aopf;" => [0x1D552], "&ap;" => [0x2248], "&apacir;" => [0x2A6F], "&apE;" => [0x2A70], 
		"&ape;" => [0x224A], "&apid;" => [0x224B], "&apos;" => [0x27], "&ApplyFunction;" => [0x2061], "&approx;" => [0x2248], "&approxeq;" => [0x224A], "&Aring;" => [0xC5], 
		"&Aring" => [0xC5], "&aring;" => [0xE5], "&aring" => [0xE5], "&Ascr;" => [0x1D49C], "&ascr;" => [0x1D4B6], "&Assign;" => [0x2254], "&ast;" => [0x2A], 
		"&asymp;" => [0x2248], "&asympeq;" => [0x224D], "&Atilde;" => [0xC3], "&Atilde" => [0xC3], "&atilde;" => [0xE3], "&atilde" => [0xE3], "&Auml;" => [0xC4], 
		"&Auml" => [0xC4], "&auml;" => [0xE4], "&auml" => [0xE4], "&awconint;" => [0x2233], "&awint;" => [0x2A11], "&backcong;" => [0x224C], "&backepsilon;" => [0x3F6], 
		"&backprime;" => [0x2035], "&backsim;" => [0x223D], "&backsimeq;" => [0x22CD], "&Backslash;" => [0x2216], "&Barv;" => [0x2AE7], "&barvee;" => [0x22BD], "&Barwed;" => [0x2306], 
		"&barwed;" => [0x2305], "&barwedge;" => [0x2305], "&bbrk;" => [0x23B5], "&bbrktbrk;" => [0x23B6], "&bcong;" => [0x224C], "&Bcy;" => [0x411], "&bcy;" => [0x431], 
		"&bdquo;" => [0x201E], "&becaus;" => [0x2235], "&Because;" => [0x2235], "&because;" => [0x2235], "&bemptyv;" => [0x29B0], "&bepsi;" => [0x3F6], "&bernou;" => [0x212C], 
		"&Bernoullis;" => [0x212C], "&Beta;" => [0x392], "&beta;" => [0x3B2], "&beth;" => [0x2136], "&between;" => [0x226C], "&Bfr;" => [0x1D505], "&bfr;" => [0x1D51F], 
		"&bigcap;" => [0x22C2], "&bigcirc;" => [0x25EF], "&bigcup;" => [0x22C3], "&bigodot;" => [0x2A00], "&bigoplus;" => [0x2A01], "&bigotimes;" => [0x2A02], "&bigsqcup;" => [0x2A06], 
		"&bigstar;" => [0x2605], "&bigtriangledown;" => [0x25BD], "&bigtriangleup;" => [0x25B3], "&biguplus;" => [0x2A04], "&bigvee;" => [0x22C1], "&bigwedge;" => [0x22C0], 
		"&bkarow;" => [0x290D], "&blacklozenge;" => [0x29EB], "&blacksquare;" => [0x25AA], "&blacktriangle;" => [0x25B4], "&blacktriangledown;" => [0x25BE], "&blacktriangleleft;" => [0x25C2], 
		"&blacktriangleright;" => [0x25B8], "&blank;" => [0x2423], "&blk12;" => [0x2592], "&blk14;" => [0x2591], "&blk34;" => [0x2593], "&block;" => [0x2588], "&bne;" => [0x3D, 0x20E5], 
		"&bnequiv;" => [0x2261, 0x20E5], "&bNot;" => [0x2AED], "&bnot;" => [0x2310], "&Bopf;" => [0x1D539], "&bopf;" => [0x1D553], "&bot;" => [0x22A5], "&bottom;" => [0x22A5], 
		"&bowtie;" => [0x22C8], "&boxbox;" => [0x29C9], "&boxDL;" => [0x2557], "&boxDl;" => [0x2556], "&boxdL;" => [0x2555], "&boxdl;" => [0x2510], "&boxDR;" => [0x2554], 
		"&boxDr;" => [0x2553], "&boxdR;" => [0x2552], "&boxdr;" => [0x250C], "&boxH;" => [0x2550], "&boxh;" => [0x2500], "&boxHD;" => [0x2566], "&boxHd;" => [0x2564], 
		"&boxhD;" => [0x2565], "&boxhd;" => [0x252C], "&boxHU;" => [0x2569], "&boxHu;" => [0x2567], "&boxhU;" => [0x2568], "&boxhu;" => [0x2534], "&boxminus;" => [0x229F], 
		"&boxplus;" => [0x229E], "&boxtimes;" => [0x22A0], "&boxUL;" => [0x255D], "&boxUl;" => [0x255C], "&boxuL;" => [0x255B], "&boxul;" => [0x2518], "&boxUR;" => [0x255A], 
		"&boxUr;" => [0x2559], "&boxuR;" => [0x2558], "&boxur;" => [0x2514], "&boxV;" => [0x2551], "&boxv;" => [0x2502], "&boxVH;" => [0x256C], "&boxVh;" => [0x256B], 
		"&boxvH;" => [0x256A], "&boxvh;" => [0x253C], "&boxVL;" => [0x2563], "&boxVl;" => [0x2562], "&boxvL;" => [0x2561], "&boxvl;" => [0x2524], "&boxVR;" => [0x2560], 
		"&boxVr;" => [0x255F], "&boxvR;" => [0x255E], "&boxvr;" => [0x251C], "&bprime;" => [0x2035], "&Breve;" => [0x02D8], "&breve;" => [0x02D8], "&brvbar;" => [0x00A6], 
		"&brvbar" => [0xA6], "&Bscr;" => [0x212C], "&bscr;" => [0x1D4B7], "&bsemi;" => [0x204F], "&bsim;" => [0x223D], "&bsime;" => [0x22CD], "&bsol;" => [0x005C], 
		"&bsolb;" => [0x29C5], "&bsolhsub;" => [0x27C8], "&bull;" => [0x2022], "&bullet;" => [0x2022], "&bump;" => [0x224E], "&bumpE;" => [0x2AAE], "&bumpe;" => [0x224F], 
		"&Bumpeq;" => [0x224E], "&bumpeq;" => [0x224F], "&Cacute;" => [0x106], "&cacute;" => [0x107], "&Cap;" => [0x22D2], "&cap;" => [0x2229], "&capand;" => [0x2A44], 
		"&capbrcup;" => [0x2A49], "&capcap;" => [0x2A4B], "&capcup;" => [0x2A47], "&capdot;" => [0x2A40], "&CapitalDifferentialD;" => [0x2145], "&caps;" => [0x2229, 0xFE00], 
		"&caret;" => [0x2041], "&caron;" => [0x2C7], "&Cayleys;" => [0x212D], "&ccaps;" => [0x2A4D], "&Ccaron;" => [0x10C], "&ccaron;" => [0x10D], "&Ccedil;" => [0xC7], 
		"&Ccedil" => [0xC7], "&ccedil;" => [0xE7], "&ccedil" => [0xE7], "&Ccirc;" => [0x108], "&ccirc;" => [0x109], "&Cconint;" => [0x2230], "&ccups;" => [0x2A4C], 
		"&ccupssm;" => [0x2A50], "&Cdot;" => [0x10A], "&cdot;" => [0x10B], "&cedil;" => [0xB8], "&cedil" => [0xB8], "&Cedilla;" => [0xB8], "&cemptyv;" => [0x29B2], 
		"&cent;" => [0xA2], "&cent" => [0xA2], "&CenterDot;" => [0xB7], "&centerdot;" => [0xB7], "&Cfr;" => [0x212D], "&cfr;" => [0x1D520], "&CHcy;" => [0x427], 
		"&chcy;" => [0x447], "&check;" => [0x2713], "&checkmark;" => [0x2713], "&Chi;" => [0x3A7], "&chi;" => [0x3C7], "&cir;" => [0x25CB], "&circ;" => [0x2C6], 
		"&circeq;" => [0x2257], "&circlearrowleft;" => [0x21BA], "&circlearrowright;" => [0x21BB], "&circledast;" => [0x229B], "&circledcirc;" => [0x229A], 
		"&circleddash;" => [0x229D], "&CircleDot;" => [0x2299], "&circledR;" => [0xAE], "&circledS;" => [0x24C8], "&CircleMinus;" => [0x2296], "&CirclePlus;" => [0x2295], 
		"&CircleTimes;" => [0x2297], "&cirE;" => [0x29C3], "&cire;" => [0x2257], "&cirfnint;" => [0x2A10], "&cirmid;" => [0x2AEF], "&cirscir;" => [0x29C2], 
		"&ClockwiseContourIntegral;" => [0x2232], "&CloseCurlyDoubleQuote;" => [0x201D], "&CloseCurlyQuote;" => [0x2019], "&clubs;" => [0x2663], "&clubsuit;" => [0x2663], 
		"&Colon;" => [0x2237], "&colon;" => [0x3A], "&Colone;" => [0x2A74], "&colone;" => [0x2254], "&coloneq;" => [0x2254], "&comma;" => [0x2C], "&commat;" => [0x40], 
		"&comp;" => [0x2201], "&compfn;" => [0x2218], "&complement;" => [0x2201], "&complexes;" => [0x2102], "&cong;" => [0x2245], "&congdot;" => [0x2A6D], 
		"&Congruent;" => [0x2261], "&Conint;" => [0x222F], "&conint;" => [0x222E], "&ContourIntegral;" => [0x222E], "&Copf;" => [0x2102], "&copf;" => [0x1D554], 
		"&coprod;" => [0x2210], "&Coproduct;" => [0x2210], "&COPY;" => [0xA9], "&COPY" => [0xA9], "&copy;" => [0xA9], "&copy" => [0xA9], "&copysr;" => [0x2117], 
		"&CounterClockwiseContourIntegral;" => [0x2233], "&crarr;" => [0x21B5], "&Cross;" => [0x2A2F], "&cross;" => [0x2717], "&Cscr;" => [0x1D49E], "&cscr;" => [0x1D4B8], 
		"&csub;" => [0x2ACF], "&csube;" => [0x2AD1], "&csup;" => [0x2AD0], "&csupe;" => [0x2AD2], "&ctdot;" => [0x22EF], "&cudarrl;" => [0x2938], "&cudarrr;" => [0x2935], 
		"&cuepr;" => [0x22DE], "&cuesc;" => [0x22DF], "&cularr;" => [0x21B6], "&cularrp;" => [0x293D], "&Cup;" => [0x22D3], "&cup;" => [0x222A], "&cupbrcap;" => [0x2A48], 
		"&CupCap;" => [0x224D], "&cupcap;" => [0x2A46], "&cupcup;" => [0x2A4A], "&cupdot;" => [0x228D], "&cupor;" => [0x2A45], "&cups;" => [0x222A, 0xFE00], "&curarr;" => [0x21B7], 
		"&curarrm;" => [0x293C], "&curlyeqprec;" => [0x22DE], "&curlyeqsucc;" => [0x22DF], "&curlyvee;" => [0x22CE], "&curlywedge;" => [0x22CF], "&curren;" => [0x00A4], 
		
		// TODO
		/* 
		"&curren" => [164] 00A4, "&curvearrowleft;" => [8630] 21B6, "&curvearrowright;" => [8631] 21B7, "&cuvee;" => [8910] 22CE, "&cuwed;" => [8911] 22CF, "&cwconint;" => [8754] 2232, "&cwint;" => [8753] 2231, "&cylcty;" => [9005] 232D, "&Dagger;" => [8225] 2021, "&dagger;" => [8224] 2020, "&daleth;" => [8504] 2138, "&Darr;" => [8609] 21A1, "&dArr;" => [8659] 21D3, "&darr;" => [8595] 2193, "&dash;" => [8208] 2010, "&Dashv;" => [10980] 2AE4, "&dashv;" => [8867] 22A3, "&dbkarow;" => [10511] 290F, "&dblac;" => [733] 02DD, "&Dcaron;" => [270] 010E, "&dcaron;" => [271] 010F, "&Dcy;" => [1044] 0414, "&dcy;" => [1076] 0434, "&DD;" => [8517] 2145, "&dd;" => [8518] 2146, "&ddagger;" => [8225] 2021, "&ddarr;" => [8650] 21CA, "&DDotrahd;" => [10513] 2911, "&ddotseq;" => [10871] 2A77, "&deg;" => [176] 00B0, "&deg" => [176] 00B0, "&Del;" => [8711] 2207, "&Delta;" => [916] 0394, "&delta;" => [948] 03B4, "&demptyv;" => [10673] 29B1, "&dfisht;" => [10623] 297F, "&Dfr;" => [120071] D835\uDD07, "&dfr;" => [120097] D835\uDD21, "&dHar;" => [10597] 2965, "&dharl;" => [8643] 21C3, "&dharr;" => [8642] 21C2, "&DiacriticalAcute;" => [180] 00B4, "&DiacriticalDot;" => [729] 02D9, "&DiacriticalDoubleAcute;" => [733] 02DD, "&DiacriticalGrave;" => [96] 0060, "&DiacriticalTilde;" => [732] 02DC, "&diam;" => [8900] 22C4, "&Diamond;" => [8900] 22C4, "&diamond;" => [8900] 22C4, "&diamondsuit;" => [9830] 2666, "&diams;" => [9830] 2666, "&die;" => [168] 00A8, "&DifferentialD;" => [8518] 2146, "&digamma;" => [989] 03DD, "&disin;" => [8946] 22F2, "&div;" => [247] 00F7, "&divide;" => [247] 00F7, "&divide" => [247] 00F7, "&divideontimes;" => [8903] 22C7, "&divonx;" => [8903] 22C7, "&DJcy;" => [1026] 0402, "&djcy;" => [1106] 0452, "&dlcorn;" => [8990] 231E, "&dlcrop;" => [8973] 230D, "&dollar;" => [36] 0024, "&Dopf;" => [120123] D835\uDD3B, "&dopf;" => [120149] D835\uDD55, "&Dot;" => [168] 00A8, "&dot;" => [729] 02D9, "&DotDot;" => [8412] 20DC, "&doteq;" => [8784] 2250, "&doteqdot;" => [8785] 2251, "&DotEqual;" => [8784] 2250, "&dotminus;" => [8760] 2238, "&dotplus;" => [8724] 2214, "&dotsquare;" => [8865] 22A1, "&doublebarwedge;" => [8966] 2306, "&DoubleContourIntegral;" => [8751] 222F, "&DoubleDot;" => [168] 00A8, "&DoubleDownArrow;" => [8659] 21D3, "&DoubleLeftArrow;" => [8656] 21D0, "&DoubleLeftRightArrow;" => [8660] 21D4, "&DoubleLeftTee;" => [10980] 2AE4, "&DoubleLongLeftArrow;" => [10232] 27F8, "&DoubleLongLeftRightArrow;" => [10234] 27FA, "&DoubleLongRightArrow;" => [10233] 27F9, "&DoubleRightArrow;" => [8658] 21D2, "&DoubleRightTee;" => [8872] 22A8, "&DoubleUpArrow;" => [8657] 21D1, "&DoubleUpDownArrow;" => [8661] 21D5, "&DoubleVerticalBar;" => [8741] 2225, "&DownArrow;" => [8595] 2193, "&Downarrow;" => [8659] 21D3, "&downarrow;" => [8595] 2193, "&DownArrowBar;" => [10515] 2913, "&DownArrowUpArrow;" => [8693] 21F5, "&DownBreve;" => [785] 0311, "&downdownarrows;" => [8650] 21CA, "&downharpoonleft;" => [8643] 21C3, "&downharpoonright;" => [8642] 21C2, "&DownLeftRightVector;" => [10576] 2950, "&DownLeftTeeVector;" => [10590] 295E, "&DownLeftVector;" => [8637] 21BD, "&DownLeftVectorBar;" => [10582] 2956, "&DownRightTeeVector;" => [10591] 295F, "&DownRightVector;" => [8641] 21C1, "&DownRightVectorBar;" => [10583] 2957, "&DownTee;" => [8868] 22A4, "&DownTeeArrow;" => [8615] 21A7, "&drbkarow;" => [10512] 2910, "&drcorn;" => [8991] 231F, "&drcrop;" => [8972] 230C, "&Dscr;" => [119967] D835\uDC9F, "&dscr;" => [119993] D835\uDCB9, "&DScy;" => [1029] 0405, "&dscy;" => [1109] 0455, "&dsol;" => [10742] 29F6, "&Dstrok;" => [272] 0110, "&dstrok;" => [273] 0111, "&dtdot;" => [8945] 22F1, "&dtri;" => [9663] 25BF, "&dtrif;" => [9662] 25BE, "&duarr;" => [8693] 21F5, "&duhar;" => [10607] 296F, "&dwangle;" => [10662] 29A6, "&DZcy;" => [1039] 040F, "&dzcy;" => [1119] 045F, "&dzigrarr;" => [10239] 27FF, "&Eacute;" => [201] 00C9, "&Eacute" => [201] 00C9, "&eacute;" => [233] 00E9, "&eacute" => [233] 00E9, "&easter;" => [10862] 2A6E, "&Ecaron;" => [282] 011A, "&ecaron;" => [283] 011B, "&ecir;" => [8790] 2256, "&Ecirc;" => [202] 00CA, "&Ecirc" => [202] 00CA, "&ecirc;" => [234] 00EA, "&ecirc" => [234] 00EA, "&ecolon;" => [8789] 2255, "&Ecy;" => [1069] 042D, "&ecy;" => [1101] 044D, "&eDDot;" => [10871] 2A77, "&Edot;" => [278] 0116, "&eDot;" => [8785] 2251, "&edot;" => [279] 0117, "&ee;" => [8519] 2147, "&efDot;" => [8786] 2252, "&Efr;" => [120072] D835\uDD08, "&efr;" => [120098] D835\uDD22, "&eg;" => [10906] 2A9A, "&Egrave;" => [200] 00C8, "&Egrave" => [200] 00C8, "&egrave;" => [232] 00E8, "&egrave" => [232] 00E8, "&egs;" => [10902] 2A96, "&egsdot;" => [10904] 2A98, "&el;" => [10905] 2A99, "&Element;" => [8712] 2208, "&elinters;" => [9191] 23E7, "&ell;" => [8467] 2113, "&els;" => [10901] 2A95, "&elsdot;" => [10903] 2A97, "&Emacr;" => [274] 0112, "&emacr;" => [275] 0113, "&empty;" => [8709] 2205, "&emptyset;" => [8709] 2205, "&EmptySmallSquare;" => [9723] 25FB, "&emptyv;" => [8709] 2205, "&EmptyVerySmallSquare;" => [9643] 25AB, "&emsp;" => [8195] 2003, "&emsp13;" => [8196] 2004, "&emsp14;" => [8197] 2005, "&ENG;" => [330] 014A, "&eng;" => [331] 014B, "&ensp;" => [8194] 2002, "&Eogon;" => [280] 0118, "&eogon;" => [281] 0119, "&Eopf;" => [120124] D835\uDD3C, "&eopf;" => [120150] D835\uDD56, "&epar;" => [8917] 22D5, "&eparsl;" => [10723] 29E3, "&eplus;" => [10865] 2A71, "&epsi;" => [949] 03B5, "&Epsilon;" => [917] 0395, "&epsilon;" => [949] 03B5, "&epsiv;" => [1013] 03F5, "&eqcirc;" => [8790] 2256, "&eqcolon;" => [8789] 2255, "&eqsim;" => [8770] 2242, "&eqslantgtr;" => [10902] 2A96, "&eqslantless;" => [10901] 2A95, "&Equal;" => [10869] 2A75, "&equals;" => [61] 003D, "&EqualTilde;" => [8770] 2242, "&equest;" => [8799] 225F, "&Equilibrium;" => [8652] 21CC, "&equiv;" => [8801] 2261, "&equivDD;" => [10872] 2A78, "&eqvparsl;" => [10725] 29E5, "&erarr;" => [10609] 2971, "&erDot;" => [8787] 2253, "&Escr;" => [8496] 2130, "&escr;" => [8495] 212F, "&esdot;" => [8784] 2250, "&Esim;" => [10867] 2A73, "&esim;" => [8770] 2242, "&Eta;" => [919] 0397, "&eta;" => [951] 03B7, "&ETH;" => [208] 00D0, "&ETH" => [208] 00D0, "&eth;" => [240] 00F0, "&eth" => [240] 00F0, "&Euml;" => [203] 00CB, "&Euml" => [203] 00CB, "&euml;" => [235] 00EB, "&euml" => [235] 00EB, "&euro;" => [8364] 20AC, "&excl;" => [33] 0021, "&exist;" => [8707] 2203, "&Exists;" => [8707] 2203, "&expectation;" => [8496] 2130, "&ExponentialE;" => [8519] 2147, "&exponentiale;" => [8519] 2147, "&fallingdotseq;" => [8786] 2252, "&Fcy;" => [1060] 0424, "&fcy;" => [1092] 0444, "&female;" => [9792] 2640, "&ffilig;" => [64259] FB03, "&fflig;" => [64256] FB00, "&ffllig;" => [64260] FB04, "&Ffr;" => [120073] D835\uDD09, "&ffr;" => [120099] D835\uDD23, "&filig;" => [64257] FB01, "&FilledSmallSquare;" => [9724] 25FC, "&FilledVerySmallSquare;" => [9642] 25AA, "&fjlig;" => [102, 106] 0066\u006A, "&flat;" => [9837] 266D, "&fllig;" => [64258] FB02, "&fltns;" => [9649] 25B1, "&fnof;" => [402] 0192, "&Fopf;" => [120125] D835\uDD3D, "&fopf;" => [120151] D835\uDD57, "&ForAll;" => [8704] 2200, "&forall;" => [8704] 2200, "&fork;" => [8916] 22D4, "&forkv;" => [10969] 2AD9, "&Fouriertrf;" => [8497] 2131, "&fpartint;" => [10765] 2A0D, "&frac12;" => [189] 00BD, "&frac12" => [189] 00BD, "&frac13;" => [8531] 2153, "&frac14;" => [188] 00BC, "&frac14" => [188] 00BC, "&frac15;" => [8533] 2155, "&frac16;" => [8537] 2159, "&frac18;" => [8539] 215B, "&frac23;" => [8532] 2154, "&frac25;" => [8534] 2156, "&frac34;" => [190] 00BE, "&frac34" => [190] 00BE, "&frac35;" => [8535] 2157, "&frac38;" => [8540] 215C, "&frac45;" => [8536] 2158, "&frac56;" => [8538] 215A, "&frac58;" => [8541] 215D, "&frac78;" => [8542] 215E, "&frasl;" => [8260] 2044, "&frown;" => [8994] 2322, "&Fscr;" => [8497] 2131, "&fscr;" => [119995] D835\uDCBB, "&gacute;" => [501] 01F5, "&Gamma;" => [915] 0393, "&gamma;" => [947] 03B3, "&Gammad;" => [988] 03DC, "&gammad;" => [989] 03DD, "&gap;" => [10886] 2A86, "&Gbreve;" => [286] 011E, "&gbreve;" => [287] 011F, "&Gcedil;" => [290] 0122, "&Gcirc;" => [284] 011C, "&gcirc;" => [285] 011D, "&Gcy;" => [1043] 0413, "&gcy;" => [1075] 0433, "&Gdot;" => [288] 0120, "&gdot;" => [289] 0121, "&gE;" => [8807] 2267, "&ge;" => [8805] 2265, "&gEl;" => [10892] 2A8C, "&gel;" => [8923] 22DB, "&geq;" => [8805] 2265, "&geqq;" => [8807] 2267, "&geqslant;" => [10878] 2A7E, "&ges;" => [10878] 2A7E, "&gescc;" => [10921] 2AA9, "&gesdot;" => [10880] 2A80, "&gesdoto;" => [10882] 2A82, "&gesdotol;" => [10884] 2A84, "&gesl;" => [8923, 65024] 22DB\uFE00, "&gesles;" => [10900] 2A94, "&Gfr;" => [120074] D835\uDD0A, "&gfr;" => [120100] D835\uDD24, "&Gg;" => [8921] 22D9, "&gg;" => [8811] 226B, "&ggg;" => [8921] 22D9, "&gimel;" => [8503] 2137, "&GJcy;" => [1027] 0403, "&gjcy;" => [1107] 0453, "&gl;" => [8823] 2277, "&gla;" => [10917] 2AA5, "&glE;" => [10898] 2A92, "&glj;" => [10916] 2AA4, "&gnap;" => [10890] 2A8A, "&gnapprox;" => [10890] 2A8A, "&gnE;" => [8809] 2269, "&gne;" => [10888] 2A88, "&gneq;" => [10888] 2A88, "&gneqq;" => [8809] 2269, "&gnsim;" => [8935] 22E7, "&Gopf;" => [120126] D835\uDD3E, "&gopf;" => [120152] D835\uDD58, "&grave;" => [96] 0060, "&GreaterEqual;" => [8805] 2265, "&GreaterEqualLess;" => [8923] 22DB, "&GreaterFullEqual;" => [8807] 2267, "&GreaterGreater;" => [10914] 2AA2, "&GreaterLess;" => [8823] 2277, "&GreaterSlantEqual;" => [10878] 2A7E, "&GreaterTilde;" => [8819] 2273, "&Gscr;" => [119970] D835\uDCA2, "&gscr;" => [8458] 210A, "&gsim;" => [8819] 2273, "&gsime;" => [10894] 2A8E, "&gsiml;" => [10896] 2A90, "&GT;" => [62] 003E, "&GT" => [62] 003E, "&Gt;" => [8811] 226B, "&gt;" => [62] 003E, "&gt" => [62] 003E, "&gtcc;" => [10919] 2AA7, "&gtcir;" => [10874] 2A7A, "&gtdot;" => [8919] 22D7, "&gtlPar;" => [10645] 2995, "&gtquest;" => [10876] 2A7C, "&gtrapprox;" => [10886] 2A86, "&gtrarr;" => [10616] 2978, "&gtrdot;" => [8919] 22D7, "&gtreqless;" => [8923] 22DB, "&gtreqqless;" => [10892] 2A8C, "&gtrless;" => [8823] 2277, "&gtrsim;" => [8819] 2273, "&gvertneqq;" => [8809, 65024] 2269\uFE00, "&gvnE;" => [8809, 65024] 2269\uFE00, "&Hacek;" => [711] 02C7, "&hairsp;" => [8202] 200A, "&half;" => [189] 00BD, "&hamilt;" => [8459] 210B, "&HARDcy;" => [1066] 042A, "&hardcy;" => [1098] 044A, "&hArr;" => [8660] 21D4, "&harr;" => [8596] 2194, "&harrcir;" => [10568] 2948, "&harrw;" => [8621] 21AD, "&Hat;" => [94] 005E, "&hbar;" => [8463] 210F, "&Hcirc;" => [292] 0124, "&hcirc;" => [293] 0125, "&hearts;" => [9829] 2665, "&heartsuit;" => [9829] 2665, "&hellip;" => [8230] 2026, "&hercon;" => [8889] 22B9, "&Hfr;" => [8460] 210C, "&hfr;" => [120101] D835\uDD25, "&HilbertSpace;" => [8459] 210B, "&hksearow;" => [10533] 2925, "&hkswarow;" => [10534] 2926, "&hoarr;" => [8703] 21FF, "&homtht;" => [8763] 223B, "&hookleftarrow;" => [8617] 21A9, "&hookrightarrow;" => [8618] 21AA, "&Hopf;" => [8461] 210D, "&hopf;" => [120153] D835\uDD59, "&horbar;" => [8213] 2015, "&HorizontalLine;" => [9472] 2500, "&Hscr;" => [8459] 210B, "&hscr;" => [119997] D835\uDCBD, "&hslash;" => [8463] 210F, "&Hstrok;" => [294] 0126, "&hstrok;" => [295] 0127, "&HumpDownHump;" => [8782] 224E, "&HumpEqual;" => [8783] 224F, "&hybull;" => [8259] 2043, "&hyphen;" => [8208] 2010, "&Iacute;" => [205] 00CD, "&Iacute" => [205] 00CD, "&iacute;" => [237] 00ED, "&iacute" => [237] 00ED, "&ic;" => [8291] 2063, "&Icirc;" => [206] 00CE, "&Icirc" => [206] 00CE, "&icirc;" => [238] 00EE, "&icirc" => [238] 00EE, "&Icy;" => [1048] 0418, "&icy;" => [1080] 0438, "&Idot;" => [304] 0130, "&IEcy;" => [1045] 0415, "&iecy;" => [1077] 0435, "&iexcl;" => [161] 00A1, "&iexcl" => [161] 00A1, "&iff;" => [8660] 21D4, "&Ifr;" => [8465] 2111, "&ifr;" => [120102] D835\uDD26, "&Igrave;" => [204] 00CC, "&Igrave" => [204] 00CC, "&igrave;" => [236] 00EC, "&igrave" => [236] 00EC, "&ii;" => [8520] 2148, "&iiiint;" => [10764] 2A0C, "&iiint;" => [8749] 222D, "&iinfin;" => [10716] 29DC, "&iiota;" => [8489] 2129, "&IJlig;" => [306] 0132, "&ijlig;" => [307] 0133, "&Im;" => [8465] 2111, "&Imacr;" => [298] 012A, "&imacr;" => [299] 012B, "&image;" => [8465] 2111, "&ImaginaryI;" => [8520] 2148, "&imagline;" => [8464] 2110, "&imagpart;" => [8465] 2111, "&imath;" => [305] 0131, "&imof;" => [8887] 22B7, "&imped;" => [437] 01B5, "&Implies;" => [8658] 21D2, "&in;" => [8712] 2208, "&incare;" => [8453] 2105, "&infin;" => [8734] 221E, "&infintie;" => [10717] 29DD, "&inodot;" => [305] 0131, "&Int;" => [8748] 222C, "&int;" => [8747] 222B, "&intcal;" => [8890] 22BA, "&integers;" => [8484] 2124, "&Integral;" => [8747] 222B, "&intercal;" => [8890] 22BA, "&Intersection;" => [8898] 22C2, "&intlarhk;" => [10775] 2A17, "&intprod;" => [10812] 2A3C, "&InvisibleComma;" => [8291] 2063, "&InvisibleTimes;" => [8290] 2062, "&IOcy;" => [1025] 0401, "&iocy;" => [1105] 0451, "&Iogon;" => [302] 012E, "&iogon;" => [303] 012F, "&Iopf;" => [120128] D835\uDD40, "&iopf;" => [120154] D835\uDD5A, "&Iota;" => [921] 0399, "&iota;" => [953] 03B9, "&iprod;" => [10812] 2A3C, "&iquest;" => [191] 00BF, "&iquest" => [191] 00BF, "&Iscr;" => [8464] 2110, "&iscr;" => [119998] D835\uDCBE, "&isin;" => [8712] 2208, "&isindot;" => [8949] 22F5, "&isinE;" => [8953] 22F9, "&isins;" => [8948] 22F4, "&isinsv;" => [8947] 22F3, "&isinv;" => [8712] 2208, "&it;" => [8290] 2062, "&Itilde;" => [296] 0128, "&itilde;" => [297] 0129, "&Iukcy;" => [1030] 0406, "&iukcy;" => [1110] 0456, "&Iuml;" => [207] 00CF, "&Iuml" => [207] 00CF, "&iuml;" => [239] 00EF, "&iuml" => [239] 00EF, "&Jcirc;" => [308] 0134, "&jcirc;" => [309] 0135, "&Jcy;" => [1049] 0419, "&jcy;" => [1081] 0439, "&Jfr;" => [120077] D835\uDD0D, "&jfr;" => [120103] D835\uDD27, "&jmath;" => [567] 0237, "&Jopf;" => [120129] D835\uDD41, "&jopf;" => [120155] D835\uDD5B, "&Jscr;" => [119973] D835\uDCA5, "&jscr;" => [119999] D835\uDCBF, "&Jsercy;" => [1032] 0408, "&jsercy;" => [1112] 0458, "&Jukcy;" => [1028] 0404, "&jukcy;" => [1108] 0454, "&Kappa;" => [922] 039A, "&kappa;" => [954] 03BA, "&kappav;" => [1008] 03F0, "&Kcedil;" => [310] 0136, "&kcedil;" => [311] 0137, "&Kcy;" => [1050] 041A, "&kcy;" => [1082] 043A, "&Kfr;" => [120078] D835\uDD0E, "&kfr;" => [120104] D835\uDD28, "&kgreen;" => [312] 0138, "&KHcy;" => [1061] 0425, "&khcy;" => [1093] 0445, "&KJcy;" => [1036] 040C, "&kjcy;" => [1116] 045C, "&Kopf;" => [120130] D835\uDD42, "&kopf;" => [120156] D835\uDD5C, "&Kscr;" => [119974] D835\uDCA6, "&kscr;" => [120000] D835\uDCC0, "&lAarr;" => [8666] 21DA, "&Lacute;" => [313] 0139, "&lacute;" => [314] 013A, "&laemptyv;" => [10676] 29B4, "&lagran;" => [8466] 2112, "&Lambda;" => [923] 039B, "&lambda;" => [955] 03BB, "&Lang;" => [10218] 27EA, "&lang;" => [10216] 27E8, "&langd;" => [10641] 2991, "&langle;" => [10216] 27E8, "&lap;" => [10885] 2A85, "&Laplacetrf;" => [8466] 2112, "&laquo;" => [171] 00AB, "&laquo" => [171] 00AB, "&Larr;" => [8606] 219E, "&lArr;" => [8656] 21D0, "&larr;" => [8592] 2190, "&larrb;" => [8676] 21E4, "&larrbfs;" => [10527] 291F, "&larrfs;" => [10525] 291D, "&larrhk;" => [8617] 21A9, "&larrlp;" => [8619] 21AB, "&larrpl;" => [10553] 2939, "&larrsim;" => [10611] 2973, "&larrtl;" => [8610] 21A2, "&lat;" => [10923] 2AAB, "&lAtail;" => [10523] 291B, "&latail;" => [10521] 2919, "&late;" => [10925] 2AAD, "&lates;" => [10925, 65024] 2AAD\uFE00, "&lBarr;" => [10510] 290E, "&lbarr;" => [10508] 290C, "&lbbrk;" => [10098] 2772, "&lbrace;" => [123] 007B, "&lbrack;" => [91] 005B, "&lbrke;" => [10635] 298B, "&lbrksld;" => [10639] 298F, "&lbrkslu;" => [10637] 298D, "&Lcaron;" => [317] 013D, "&lcaron;" => [318] 013E, "&Lcedil;" => [315] 013B, "&lcedil;" => [316] 013C, "&lceil;" => [8968] 2308, "&lcub;" => [123] 007B, "&Lcy;" => [1051] 041B, "&lcy;" => [1083] 043B, "&ldca;" => [10550] 2936, "&ldquo;" => [8220] 201C, "&ldquor;" => [8222] 201E, "&ldrdhar;" => [10599] 2967, "&ldrushar;" => [10571] 294B, "&ldsh;" => [8626] 21B2, "&lE;" => [8806] 2266, "&le;" => [8804] 2264, "&LeftAngleBracket;" => [10216] 27E8, "&LeftArrow;" => [8592] 2190, "&Leftarrow;" => [8656] 21D0, "&leftarrow;" => [8592] 2190, "&LeftArrowBar;" => [8676] 21E4, "&LeftArrowRightArrow;" => [8646] 21C6, "&leftarrowtail;" => [8610] 21A2, "&LeftCeiling;" => [8968] 2308, "&LeftDoubleBracket;" => [10214] 27E6, "&LeftDownTeeVector;" => [10593] 2961, "&LeftDownVector;" => [8643] 21C3, "&LeftDownVectorBar;" => [10585] 2959, "&LeftFloor;" => [8970] 230A, "&leftharpoondown;" => [8637] 21BD, "&leftharpoonup;" => [8636] 21BC, "&leftleftarrows;" => [8647] 21C7, "&LeftRightArrow;" => [8596] 2194, "&Leftrightarrow;" => [8660] 21D4, "&leftrightarrow;" => [8596] 2194, "&leftrightarrows;" => [8646] 21C6, "&leftrightharpoons;" => [8651] 21CB, "&leftrightsquigarrow;" => [8621] 21AD, "&LeftRightVector;" => [10574] 294E, "&LeftTee;" => [8867] 22A3, "&LeftTeeArrow;" => [8612] 21A4, "&LeftTeeVector;" => [10586] 295A, "&leftthreetimes;" => [8907] 22CB, "&LeftTriangle;" => [8882] 22B2, "&LeftTriangleBar;" => [10703] 29CF, "&LeftTriangleEqual;" => [8884] 22B4, "&LeftUpDownVector;" => [10577] 2951, "&LeftUpTeeVector;" => [10592] 2960, "&LeftUpVector;" => [8639] 21BF, "&LeftUpVectorBar;" => [10584] 2958, "&LeftVector;" => [8636] 21BC, "&LeftVectorBar;" => [10578] 2952, "&lEg;" => [10891] 2A8B, "&leg;" => [8922] 22DA, "&leq;" => [8804] 2264, "&leqq;" => [8806] 2266, "&leqslant;" => [10877] 2A7D, "&les;" => [10877] 2A7D, "&lescc;" => [10920] 2AA8, "&lesdot;" => [10879] 2A7F, "&lesdoto;" => [10881] 2A81, "&lesdotor;" => [10883] 2A83, "&lesg;" => [8922, 65024] 22DA\uFE00, "&lesges;" => [10899] 2A93, "&lessapprox;" => [10885] 2A85, "&lessdot;" => [8918] 22D6, "&lesseqgtr;" => [8922] 22DA, "&lesseqqgtr;" => [10891] 2A8B, "&LessEqualGreater;" => [8922] 22DA, "&LessFullEqual;" => [8806] 2266, "&LessGreater;" => [8822] 2276, "&lessgtr;" => [8822] 2276, "&LessLess;" => [10913] 2AA1, "&lesssim;" => [8818] 2272, "&LessSlantEqual;" => [10877] 2A7D, "&LessTilde;" => [8818] 2272, "&lfisht;" => [10620] 297C, "&lfloor;" => [8970] 230A, "&Lfr;" => [120079] D835\uDD0F, "&lfr;" => [120105] D835\uDD29, "&lg;" => [8822] 2276, "&lgE;" => [10897] 2A91, "&lHar;" => [10594] 2962, "&lhard;" => [8637] 21BD, "&lharu;" => [8636] 21BC, "&lharul;" => [10602] 296A, "&lhblk;" => [9604] 2584, "&LJcy;" => [1033] 0409, "&ljcy;" => [1113] 0459, "&Ll;" => [8920] 22D8, "&ll;" => [8810] 226A, "&llarr;" => [8647] 21C7, "&llcorner;" => [8990] 231E, "&Lleftarrow;" => [8666] 21DA, "&llhard;" => [10603] 296B, "&lltri;" => [9722] 25FA, "&Lmidot;" => [319] 013F, "&lmidot;" => [320] 0140, "&lmoust;" => [9136] 23B0, "&lmoustache;" => [9136] 23B0, "&lnap;" => [10889] 2A89, "&lnapprox;" => [10889] 2A89, "&lnE;" => [8808] 2268, "&lne;" => [10887] 2A87, "&lneq;" => [10887] 2A87, "&lneqq;" => [8808] 2268, "&lnsim;" => [8934] 22E6, "&loang;" => [10220] 27EC, "&loarr;" => [8701] 21FD, "&lobrk;" => [10214] 27E6, "&LongLeftArrow;" => [10229] 27F5, "&Longleftarrow;" => [10232] 27F8, "&longleftarrow;" => [10229] 27F5, "&LongLeftRightArrow;" => [10231] 27F7, "&Longleftrightarrow;" => [10234] 27FA, "&longleftrightarrow;" => [10231] 27F7, "&longmapsto;" => [10236] 27FC, "&LongRightArrow;" => [10230] 27F6, "&Longrightarrow;" => [10233] 27F9, "&longrightarrow;" => [10230] 27F6, "&looparrowleft;" => [8619] 21AB, "&looparrowright;" => [8620] 21AC, "&lopar;" => [10629] 2985, "&Lopf;" => [120131] D835\uDD43, "&lopf;" => [120157] D835\uDD5D, "&loplus;" => [10797] 2A2D, "&lotimes;" => [10804] 2A34, "&lowast;" => [8727] 2217, "&lowbar;" => [95] 005F, "&LowerLeftArrow;" => [8601] 2199, "&LowerRightArrow;" => [8600] 2198, "&loz;" => [9674] 25CA, "&lozenge;" => [9674] 25CA, "&lozf;" => [10731] 29EB, "&lpar;" => [40] 0028, "&lparlt;" => [10643] 2993, "&lrarr;" => [8646] 21C6, "&lrcorner;" => [8991] 231F, "&lrhar;" => [8651] 21CB, "&lrhard;" => [10605] 296D, "&lrm;" => [8206] 200E, "&lrtri;" => [8895] 22BF, "&lsaquo;" => [8249] 2039, "&Lscr;" => [8466] 2112, "&lscr;" => [120001] D835\uDCC1, "&Lsh;" => [8624] 21B0, "&lsh;" => [8624] 21B0, "&lsim;" => [8818] 2272, "&lsime;" => [10893] 2A8D, "&lsimg;" => [10895] 2A8F, "&lsqb;" => [91] 005B, "&lsquo;" => [8216] 2018, "&lsquor;" => [8218] 201A, "&Lstrok;" => [321] 0141, "&lstrok;" => [322] 0142, "&LT;" => [60] 003C, "&LT" => [60] 003C, "&Lt;" => [8810] 226A, "&lt;" => [60] 003C, "&lt" => [60] 003C, "&ltcc;" => [10918] 2AA6, "&ltcir;" => [10873] 2A79, "&ltdot;" => [8918] 22D6, "&lthree;" => [8907] 22CB, "&ltimes;" => [8905] 22C9, "&ltlarr;" => [10614] 2976, "&ltquest;" => [10875] 2A7B, "&ltri;" => [9667] 25C3, "&ltrie;" => [8884] 22B4, "&ltrif;" => [9666] 25C2, "&ltrPar;" => [10646] 2996, "&lurdshar;" => [10570] 294A, "&luruhar;" => [10598] 2966, "&lvertneqq;" => [8808, 65024] 2268\uFE00, "&lvnE;" => [8808, 65024] 2268\uFE00, "&macr;" => [175] 00AF, "&macr" => [175] 00AF, "&male;" => [9794] 2642, "&malt;" => [10016] 2720, "&maltese;" => [10016] 2720, "&Map;" => [10501] 2905, "&map;" => [8614] 21A6, "&mapsto;" => [8614] 21A6, "&mapstodown;" => [8615] 21A7, "&mapstoleft;" => [8612] 21A4, "&mapstoup;" => [8613] 21A5, "&marker;" => [9646] 25AE, "&mcomma;" => [10793] 2A29, "&Mcy;" => [1052] 041C, "&mcy;" => [1084] 043C, "&mdash;" => [8212] 2014, "&mDDot;" => [8762] 223A, "&measuredangle;" => [8737] 2221, "&MediumSpace;" => [8287] 205F, "&Mellintrf;" => [8499] 2133, "&Mfr;" => [120080] D835\uDD10, "&mfr;" => [120106] D835\uDD2A, "&mho;" => [8487] 2127, "&micro;" => [181] 00B5, "&micro" => [181] 00B5, "&mid;" => [8739] 2223, "&midast;" => [42] 002A, "&midcir;" => [10992] 2AF0, "&middot;" => [183] 00B7, "&middot" => [183] 00B7, "&minus;" => [8722] 2212, "&minusb;" => [8863] 229F, "&minusd;" => [8760] 2238, "&minusdu;" => [10794] 2A2A, "&MinusPlus;" => [8723] 2213, "&mlcp;" => [10971] 2ADB, "&mldr;" => [8230] 2026, "&mnplus;" => [8723] 2213, "&models;" => [8871] 22A7, "&Mopf;" => [120132] D835\uDD44, "&mopf;" => [120158] D835\uDD5E, "&mp;" => [8723] 2213, "&Mscr;" => [8499] 2133, "&mscr;" => [120002] D835\uDCC2, "&mstpos;" => [8766] 223E, "&Mu;" => [924] 039C, "&mu;" => [956] 03BC, "&multimap;" => [8888] 22B8, "&mumap;" => [8888] 22B8, "&nabla;" => [8711] 2207, "&Nacute;" => [323] 0143, "&nacute;" => [324] 0144, "&nang;" => [8736, 8402] 2220\u20D2, "&nap;" => [8777] 2249, "&napE;" => [10864, 824] 2A70\u0338, "&napid;" => [8779, 824] 224B\u0338, "&napos;" => [329] 0149, "&napprox;" => [8777] 2249, "&natur;" => [9838] 266E, "&natural;" => [9838] 266E, "&naturals;" => [8469] 2115, "&nbsp;" => [160] 00A0, "&nbsp" => [160] 00A0, "&nbump;" => [8782, 824] 224E\u0338, "&nbumpe;" => [8783, 824] 224F\u0338, "&ncap;" => [10819] 2A43, "&Ncaron;" => [327] 0147, "&ncaron;" => [328] 0148, "&Ncedil;" => [325] 0145, "&ncedil;" => [326] 0146, "&ncong;" => [8775] 2247, "&ncongdot;" => [10861, 824] 2A6D\u0338, "&ncup;" => [10818] 2A42, "&Ncy;" => [1053] 041D, "&ncy;" => [1085] 043D, "&ndash;" => [8211] 2013, "&ne;" => [8800] 2260, "&nearhk;" => [10532] 2924, "&neArr;" => [8663] 21D7, "&nearr;" => [8599] 2197, "&nearrow;" => [8599] 2197, "&nedot;" => [8784, 824] 2250\u0338, "&NegativeMediumSpace;" => [8203] 200B, "&NegativeThickSpace;" => [8203] 200B, "&NegativeThinSpace;" => [8203] 200B, "&NegativeVeryThinSpace;" => [8203] 200B, "&nequiv;" => [8802] 2262, "&nesear;" => [10536] 2928, "&nesim;" => [8770, 824] 2242\u0338, "&NestedGreaterGreater;" => [8811] 226B, "&NestedLessLess;" => [8810] 226A, "&NewLine;" => [10] 000A, "&nexist;" => [8708] 2204, "&nexists;" => [8708] 2204, "&Nfr;" => [120081] D835\uDD11, "&nfr;" => [120107] D835\uDD2B, "&ngE;" => [8807, 824] 2267\u0338, "&nge;" => [8817] 2271, "&ngeq;" => [8817] 2271, "&ngeqq;" => [8807, 824] 2267\u0338, "&ngeqslant;" => [10878, 824] 2A7E\u0338, "&nges;" => [10878, 824] 2A7E\u0338, "&nGg;" => [8921, 824] 22D9\u0338, "&ngsim;" => [8821] 2275, "&nGt;" => [8811, 8402] 226B\u20D2, "&ngt;" => [8815] 226F, "&ngtr;" => [8815] 226F, "&nGtv;" => [8811, 824] 226B\u0338, "&nhArr;" => [8654] 21CE, "&nharr;" => [8622] 21AE, "&nhpar;" => [10994] 2AF2, "&ni;" => [8715] 220B, "&nis;" => [8956] 22FC, "&nisd;" => [8954] 22FA, "&niv;" => [8715] 220B, "&NJcy;" => [1034] 040A, "&njcy;" => [1114] 045A, "&nlArr;" => [8653] 21CD, "&nlarr;" => [8602] 219A, "&nldr;" => [8229] 2025, "&nlE;" => [8806, 824] 2266\u0338, "&nle;" => [8816] 2270, "&nLeftarrow;" => [8653] 21CD, "&nleftarrow;" => [8602] 219A, "&nLeftrightarrow;" => [8654] 21CE, "&nleftrightarrow;" => [8622] 21AE, "&nleq;" => [8816] 2270, "&nleqq;" => [8806, 824] 2266\u0338, "&nleqslant;" => [10877, 824] 2A7D\u0338, "&nles;" => [10877, 824] 2A7D\u0338, "&nless;" => [8814] 226E, "&nLl;" => [8920, 824] 22D8\u0338, "&nlsim;" => [8820] 2274, "&nLt;" => [8810, 8402] 226A\u20D2, "&nlt;" => [8814] 226E, "&nltri;" => [8938] 22EA, "&nltrie;" => [8940] 22EC, "&nLtv;" => [8810, 824] 226A\u0338, "&nmid;" => [8740] 2224, "&NoBreak;" => [8288] 2060, "&NonBreakingSpace;" => [160] 00A0, "&Nopf;" => [8469] 2115, "&nopf;" => [120159] D835\uDD5F, "&Not;" => [10988] 2AEC, "&not;" => [172] 00AC, "&not" => [172] 00AC, "&NotCongruent;" => [8802] 2262, "&NotCupCap;" => [8813] 226D, "&NotDoubleVerticalBar;" => [8742] 2226, "&NotElement;" => [8713] 2209, "&NotEqual;" => [8800] 2260, "&NotEqualTilde;" => [8770, 824] 2242\u0338, "&NotExists;" => [8708] 2204, "&NotGreater;" => [8815] 226F, "&NotGreaterEqual;" => [8817] 2271, "&NotGreaterFullEqual;" => [8807, 824] 2267\u0338, "&NotGreaterGreater;" => [8811, 824] 226B\u0338, "&NotGreaterLess;" => [8825] 2279, "&NotGreaterSlantEqual;" => [10878, 824] 2A7E\u0338, "&NotGreaterTilde;" => [8821] 2275, "&NotHumpDownHump;" => [8782, 824] 224E\u0338, "&NotHumpEqual;" => [8783, 824] 224F\u0338, "&notin;" => [8713] 2209, "&notindot;" => [8949, 824] 22F5\u0338, "&notinE;" => [8953, 824] 22F9\u0338, "&notinva;" => [8713] 2209, "&notinvb;" => [8951] 22F7, "&notinvc;" => [8950] 22F6, "&NotLeftTriangle;" => [8938] 22EA, "&NotLeftTriangleBar;" => [10703, 824] 29CF\u0338, "&NotLeftTriangleEqual;" => [8940] 22EC, "&NotLess;" => [8814] 226E, "&NotLessEqual;" => [8816] 2270, "&NotLessGreater;" => [8824] 2278, "&NotLessLess;" => [8810, 824] 226A\u0338, "&NotLessSlantEqual;" => [10877, 824] 2A7D\u0338, "&NotLessTilde;" => [8820] 2274, "&NotNestedGreaterGreater;" => [10914, 824] 2AA2\u0338, "&NotNestedLessLess;" => [10913, 824] 2AA1\u0338, "&notni;" => [8716] 220C, "&notniva;" => [8716] 220C, "&notnivb;" => [8958] 22FE, "&notnivc;" => [8957] 22FD, "&NotPrecedes;" => [8832] 2280, "&NotPrecedesEqual;" => [10927, 824] 2AAF\u0338, "&NotPrecedesSlantEqual;" => [8928] 22E0, "&NotReverseElement;" => [8716] 220C, "&NotRightTriangle;" => [8939] 22EB, "&NotRightTriangleBar;" => [10704, 824] 29D0\u0338, "&NotRightTriangleEqual;" => [8941] 22ED, "&NotSquareSubset;" => [8847, 824] 228F\u0338, "&NotSquareSubsetEqual;" => [8930] 22E2, "&NotSquareSuperset;" => [8848, 824] 2290\u0338, "&NotSquareSupersetEqual;" => [8931] 22E3, "&NotSubset;" => [8834, 8402] 2282\u20D2, "&NotSubsetEqual;" => [8840] 2288, "&NotSucceeds;" => [8833] 2281, "&NotSucceedsEqual;" => [10928, 824] 2AB0\u0338, "&NotSucceedsSlantEqual;" => [8929] 22E1, "&NotSucceedsTilde;" => [8831, 824] 227F\u0338, "&NotSuperset;" => [8835, 8402] 2283\u20D2, "&NotSupersetEqual;" => [8841] 2289, "&NotTilde;" => [8769] 2241, "&NotTildeEqual;" => [8772] 2244, "&NotTildeFullEqual;" => [8775] 2247, "&NotTildeTilde;" => [8777] 2249, "&NotVerticalBar;" => [8740] 2224, "&npar;" => [8742] 2226, "&nparallel;" => [8742] 2226, "&nparsl;" => [11005, 8421] 2AFD\u20E5, "&npart;" => [8706, 824] 2202\u0338, "&npolint;" => [10772] 2A14, "&npr;" => [8832] 2280, "&nprcue;" => [8928] 22E0, "&npre;" => [10927, 824] 2AAF\u0338, "&nprec;" => [8832] 2280, "&npreceq;" => [10927, 824] 2AAF\u0338, "&nrArr;" => [8655] 21CF, "&nrarr;" => [8603] 219B, "&nrarrc;" => [10547, 824] 2933\u0338, "&nrarrw;" => [8605, 824] 219D\u0338, "&nRightarrow;" => [8655] 21CF, "&nrightarrow;" => [8603] 219B, "&nrtri;" => [8939] 22EB, "&nrtrie;" => [8941] 22ED, "&nsc;" => [8833] 2281, "&nsccue;" => [8929] 22E1, "&nsce;" => [10928, 824] 2AB0\u0338, "&Nscr;" => [119977] D835\uDCA9, "&nscr;" => [120003] D835\uDCC3, "&nshortmid;" => [8740] 2224, "&nshortparallel;" => [8742] 2226, "&nsim;" => [8769] 2241, "&nsime;" => [8772] 2244, "&nsimeq;" => [8772] 2244, "&nsmid;" => [8740] 2224, "&nspar;" => [8742] 2226, "&nsqsube;" => [8930] 22E2, "&nsqsupe;" => [8931] 22E3, "&nsub;" => [8836] 2284, "&nsubE;" => [10949, 824] 2AC5\u0338, "&nsube;" => [8840] 2288, "&nsubset;" => [8834, 8402] 2282\u20D2, "&nsubseteq;" => [8840] 2288, "&nsubseteqq;" => [10949, 824] 2AC5\u0338, "&nsucc;" => [8833] 2281, "&nsucceq;" => [10928, 824] 2AB0\u0338, "&nsup;" => [8837] 2285, "&nsupE;" => [10950, 824] 2AC6\u0338, "&nsupe;" => [8841] 2289, "&nsupset;" => [8835, 8402] 2283\u20D2, "&nsupseteq;" => [8841] 2289, "&nsupseteqq;" => [10950, 824] 2AC6\u0338, "&ntgl;" => [8825] 2279, "&Ntilde;" => [209] 00D1, "&Ntilde" => [209] 00D1, "&ntilde;" => [241] 00F1, "&ntilde" => [241] 00F1, "&ntlg;" => [8824] 2278, "&ntriangleleft;" => [8938] 22EA, "&ntrianglelefteq;" => [8940] 22EC, "&ntriangleright;" => [8939] 22EB, "&ntrianglerighteq;" => [8941] 22ED, "&Nu;" => [925] 039D, "&nu;" => [957] 03BD, "&num;" => [35] 0023, "&numero;" => [8470] 2116, "&numsp;" => [8199] 2007, "&nvap;" => [8781, 8402] 224D\u20D2, "&nVDash;" => [8879] 22AF, "&nVdash;" => [8878] 22AE, "&nvDash;" => [8877] 22AD, "&nvdash;" => [8876] 22AC, "&nvge;" => [8805, 8402] 2265\u20D2, "&nvgt;" => [62, 8402] 003E\u20D2, "&nvHarr;" => [10500] 2904, "&nvinfin;" => [10718] 29DE, "&nvlArr;" => [10498] 2902, "&nvle;" => [8804, 8402] 2264\u20D2, "&nvlt;" => [60, 8402] 003C\u20D2, "&nvltrie;" => [8884, 8402] 22B4\u20D2, "&nvrArr;" => [10499] 2903, "&nvrtrie;" => [8885, 8402] 22B5\u20D2, "&nvsim;" => [8764, 8402] 223C\u20D2, "&nwarhk;" => [10531] 2923, "&nwArr;" => [8662] 21D6, "&nwarr;" => [8598] 2196, "&nwarrow;" => [8598] 2196, "&nwnear;" => [10535] 2927, "&Oacute;" => [211] 00D3, "&Oacute" => [211] 00D3, "&oacute;" => [243] 00F3, "&oacute" => [243] 00F3, "&oast;" => [8859] 229B, "&ocir;" => [8858] 229A, "&Ocirc;" => [212] 00D4, "&Ocirc" => [212] 00D4, "&ocirc;" => [244] 00F4, "&ocirc" => [244] 00F4, "&Ocy;" => [1054] 041E, "&ocy;" => [1086] 043E, "&odash;" => [8861] 229D, "&Odblac;" => [336] 0150, "&odblac;" => [337] 0151, "&odiv;" => [10808] 2A38, "&odot;" => [8857] 2299, "&odsold;" => [10684] 29BC, "&OElig;" => [338] 0152, "&oelig;" => [339] 0153, "&ofcir;" => [10687] 29BF, "&Ofr;" => [120082] D835\uDD12, "&ofr;" => [120108] D835\uDD2C, "&ogon;" => [731] 02DB, "&Ograve;" => [210] 00D2, "&Ograve" => [210] 00D2, "&ograve;" => [242] 00F2, "&ograve" => [242] 00F2, "&ogt;" => [10689] 29C1, "&ohbar;" => [10677] 29B5, "&ohm;" => [937] 03A9, "&oint;" => [8750] 222E, "&olarr;" => [8634] 21BA, "&olcir;" => [10686] 29BE, "&olcross;" => [10683] 29BB, "&oline;" => [8254] 203E, "&olt;" => [10688] 29C0, "&Omacr;" => [332] 014C, "&omacr;" => [333] 014D, "&Omega;" => [937] 03A9, "&omega;" => [969] 03C9, "&Omicron;" => [927] 039F, "&omicron;" => [959] 03BF, "&omid;" => [10678] 29B6, "&ominus;" => [8854] 2296, "&Oopf;" => [120134] D835\uDD46, "&oopf;" => [120160] D835\uDD60, "&opar;" => [10679] 29B7, "&OpenCurlyDoubleQuote;" => [8220] 201C, "&OpenCurlyQuote;" => [8216] 2018, "&operp;" => [10681] 29B9, "&oplus;" => [8853] 2295, "&Or;" => [10836] 2A54, "&or;" => [8744] 2228, "&orarr;" => [8635] 21BB, "&ord;" => [10845] 2A5D, "&order;" => [8500] 2134, "&orderof;" => [8500] 2134, "&ordf;" => [170] 00AA, "&ordf" => [170] 00AA, "&ordm;" => [186] 00BA, "&ordm" => [186] 00BA, "&origof;" => [8886] 22B6, "&oror;" => [10838] 2A56, "&orslope;" => [10839] 2A57, "&orv;" => [10843] 2A5B, "&oS;" => [9416] 24C8, "&Oscr;" => [119978] D835\uDCAA, "&oscr;" => [8500] 2134, "&Oslash;" => [216] 00D8, "&Oslash" => [216] 00D8, "&oslash;" => [248] 00F8, "&oslash" => [248] 00F8, "&osol;" => [8856] 2298, "&Otilde;" => [213] 00D5, "&Otilde" => [213] 00D5, "&otilde;" => [245] 00F5, "&otilde" => [245] 00F5, "&Otimes;" => [10807] 2A37, "&otimes;" => [8855] 2297, "&otimesas;" => [10806] 2A36, "&Ouml;" => [214] 00D6, "&Ouml" => [214] 00D6, "&ouml;" => [246] 00F6, "&ouml" => [246] 00F6, "&ovbar;" => [9021] 233D, "&OverBar;" => [8254] 203E, "&OverBrace;" => [9182] 23DE, "&OverBracket;" => [9140] 23B4, "&OverParenthesis;" => [9180] 23DC, "&par;" => [8741] 2225, "&para;" => [182] 00B6, "&para" => [182] 00B6, "&parallel;" => [8741] 2225, "&parsim;" => [10995] 2AF3, "&parsl;" => [11005] 2AFD, "&part;" => [8706] 2202, "&PartialD;" => [8706] 2202, "&Pcy;" => [1055] 041F, "&pcy;" => [1087] 043F, "&percnt;" => [37] 0025, "&period;" => [46] 002E, "&permil;" => [8240] 2030, "&perp;" => [8869] 22A5, "&pertenk;" => [8241] 2031, "&Pfr;" => [120083] D835\uDD13, "&pfr;" => [120109] D835\uDD2D, "&Phi;" => [934] 03A6, "&phi;" => [966] 03C6, "&phiv;" => [981] 03D5, "&phmmat;" => [8499] 2133, "&phone;" => [9742] 260E, "&Pi;" => [928] 03A0, "&pi;" => [960] 03C0, "&pitchfork;" => [8916] 22D4, "&piv;" => [982] 03D6, "&planck;" => [8463] 210F, "&planckh;" => [8462] 210E, "&plankv;" => [8463] 210F, "&plus;" => [43] 002B, "&plusacir;" => [10787] 2A23, "&plusb;" => [8862] 229E, "&pluscir;" => [10786] 2A22, "&plusdo;" => [8724] 2214, "&plusdu;" => [10789] 2A25, "&pluse;" => [10866] 2A72, "&PlusMinus;" => [177] 00B1, "&plusmn;" => [177] 00B1, "&plusmn" => [177] 00B1, "&plussim;" => [10790] 2A26, "&plustwo;" => [10791] 2A27, "&pm;" => [177] 00B1, "&Poincareplane;" => [8460] 210C, "&pointint;" => [10773] 2A15, "&Popf;" => [8473] 2119, "&popf;" => [120161] D835\uDD61, "&pound;" => [163] 00A3, "&pound" => [163] 00A3, "&Pr;" => [10939] 2ABB, "&pr;" => [8826] 227A, "&prap;" => [10935] 2AB7, "&prcue;" => [8828] 227C, "&prE;" => [10931] 2AB3, "&pre;" => [10927] 2AAF, "&prec;" => [8826] 227A, "&precapprox;" => [10935] 2AB7, "&preccurlyeq;" => [8828] 227C, "&Precedes;" => [8826] 227A, "&PrecedesEqual;" => [10927] 2AAF, "&PrecedesSlantEqual;" => [8828] 227C, "&PrecedesTilde;" => [8830] 227E, "&preceq;" => [10927] 2AAF, "&precnapprox;" => [10937] 2AB9, "&precneqq;" => [10933] 2AB5, "&precnsim;" => [8936] 22E8, "&precsim;" => [8830] 227E, "&Prime;" => [8243] 2033, "&prime;" => [8242] 2032, "&primes;" => [8473] 2119, "&prnap;" => [10937] 2AB9, "&prnE;" => [10933] 2AB5, "&prnsim;" => [8936] 22E8, "&prod;" => [8719] 220F, "&Product;" => [8719] 220F, "&profalar;" => [9006] 232E, "&profline;" => [8978] 2312, "&profsurf;" => [8979] 2313, "&prop;" => [8733] 221D, "&Proportion;" => [8759] 2237, "&Proportional;" => [8733] 221D, "&propto;" => [8733] 221D, "&prsim;" => [8830] 227E, "&prurel;" => [8880] 22B0, "&Pscr;" => [119979] D835\uDCAB, "&pscr;" => [120005] D835\uDCC5, "&Psi;" => [936] 03A8, "&psi;" => [968] 03C8, "&puncsp;" => [8200] 2008, "&Qfr;" => [120084] D835\uDD14, "&qfr;" => [120110] D835\uDD2E, "&qint;" => [10764] 2A0C, "&Qopf;" => [8474] 211A, "&qopf;" => [120162] D835\uDD62, "&qprime;" => [8279] 2057, "&Qscr;" => [119980] D835\uDCAC, "&qscr;" => [120006] D835\uDCC6, "&quaternions;" => [8461] 210D, "&quatint;" => [10774] 2A16, "&quest;" => [63] 003F, "&questeq;" => [8799] 225F, "&QUOT;" => [34] 0022, "&QUOT" => [34] 0022, "&quot;" => [34] 0022, "&quot" => [34] 0022, "&rAarr;" => [8667] 21DB, "&race;" => [8765, 817] 223D\u0331, "&Racute;" => [340] 0154, "&racute;" => [341] 0155, "&radic;" => [8730] 221A, "&raemptyv;" => [10675] 29B3, "&Rang;" => [10219] 27EB, "&rang;" => [10217] 27E9, "&rangd;" => [10642] 2992, "&range;" => [10661] 29A5, "&rangle;" => [10217] 27E9, "&raquo;" => [187] 00BB, "&raquo" => [187] 00BB, "&Rarr;" => [8608] 21A0, "&rArr;" => [8658] 21D2, "&rarr;" => [8594] 2192, "&rarrap;" => [10613] 2975, "&rarrb;" => [8677] 21E5, "&rarrbfs;" => [10528] 2920, "&rarrc;" => [10547] 2933, "&rarrfs;" => [10526] 291E, "&rarrhk;" => [8618] 21AA, "&rarrlp;" => [8620] 21AC, "&rarrpl;" => [10565] 2945, "&rarrsim;" => [10612] 2974, "&Rarrtl;" => [10518] 2916, "&rarrtl;" => [8611] 21A3, "&rarrw;" => [8605] 219D, "&rAtail;" => [10524] 291C, "&ratail;" => [10522] 291A, "&ratio;" => [8758] 2236, "&rationals;" => [8474] 211A, "&RBarr;" => [10512] 2910, "&rBarr;" => [10511] 290F, "&rbarr;" => [10509] 290D, "&rbbrk;" => [10099] 2773, "&rbrace;" => [125] 007D, "&rbrack;" => [93] 005D, "&rbrke;" => [10636] 298C, "&rbrksld;" => [10638] 298E, "&rbrkslu;" => [10640] 2990, "&Rcaron;" => [344] 0158, "&rcaron;" => [345] 0159, "&Rcedil;" => [342] 0156, "&rcedil;" => [343] 0157, "&rceil;" => [8969] 2309, "&rcub;" => [125] 007D, "&Rcy;" => [1056] 0420, "&rcy;" => [1088] 0440, "&rdca;" => [10551] 2937, "&rdldhar;" => [10601] 2969, "&rdquo;" => [8221] 201D, "&rdquor;" => [8221] 201D, "&rdsh;" => [8627] 21B3, "&Re;" => [8476] 211C, "&real;" => [8476] 211C, "&realine;" => [8475] 211B, "&realpart;" => [8476] 211C, "&reals;" => [8477] 211D, "&rect;" => [9645] 25AD, "&REG;" => [174] 00AE, "&REG" => [174] 00AE, "&reg;" => [174] 00AE, "&reg" => [174] 00AE, "&ReverseElement;" => [8715] 220B, "&ReverseEquilibrium;" => [8651] 21CB, "&ReverseUpEquilibrium;" => [10607] 296F, "&rfisht;" => [10621] 297D, "&rfloor;" => [8971] 230B, "&Rfr;" => [8476] 211C, "&rfr;" => [120111] D835\uDD2F, "&rHar;" => [10596] 2964, "&rhard;" => [8641] 21C1, "&rharu;" => [8640] 21C0, "&rharul;" => [10604] 296C, "&Rho;" => [929] 03A1, "&rho;" => [961] 03C1, "&rhov;" => [1009] 03F1, "&RightAngleBracket;" => [10217] 27E9, "&RightArrow;" => [8594] 2192, "&Rightarrow;" => [8658] 21D2, "&rightarrow;" => [8594] 2192, "&RightArrowBar;" => [8677] 21E5, "&RightArrowLeftArrow;" => [8644] 21C4, "&rightarrowtail;" => [8611] 21A3, "&RightCeiling;" => [8969] 2309, "&RightDoubleBracket;" => [10215] 27E7, "&RightDownTeeVector;" => [10589] 295D, "&RightDownVector;" => [8642] 21C2, "&RightDownVectorBar;" => [10581] 2955, "&RightFloor;" => [8971] 230B, "&rightharpoondown;" => [8641] 21C1, "&rightharpoonup;" => [8640] 21C0, "&rightleftarrows;" => [8644] 21C4, "&rightleftharpoons;" => [8652] 21CC, "&rightrightarrows;" => [8649] 21C9, "&rightsquigarrow;" => [8605] 219D, "&RightTee;" => [8866] 22A2, "&RightTeeArrow;" => [8614] 21A6, "&RightTeeVector;" => [10587] 295B, "&rightthreetimes;" => [8908] 22CC, "&RightTriangle;" => [8883] 22B3, "&RightTriangleBar;" => [10704] 29D0, "&RightTriangleEqual;" => [8885] 22B5, "&RightUpDownVector;" => [10575] 294F, "&RightUpTeeVector;" => [10588] 295C, "&RightUpVector;" => [8638] 21BE, "&RightUpVectorBar;" => [10580] 2954, "&RightVector;" => [8640] 21C0, "&RightVectorBar;" => [10579] 2953, "&ring;" => [730] 02DA, "&risingdotseq;" => [8787] 2253, "&rlarr;" => [8644] 21C4, "&rlhar;" => [8652] 21CC, "&rlm;" => [8207] 200F, "&rmoust;" => [9137] 23B1, "&rmoustache;" => [9137] 23B1, "&rnmid;" => [10990] 2AEE, "&roang;" => [10221] 27ED, "&roarr;" => [8702] 21FE, "&robrk;" => [10215] 27E7, "&ropar;" => [10630] 2986, "&Ropf;" => [8477] 211D, "&ropf;" => [120163] D835\uDD63, "&roplus;" => [10798] 2A2E, "&rotimes;" => [10805] 2A35, "&RoundImplies;" => [10608] 2970, "&rpar;" => [41] 0029, "&rpargt;" => [10644] 2994, "&rppolint;" => [10770] 2A12, "&rrarr;" => [8649] 21C9, "&Rrightarrow;" => [8667] 21DB, "&rsaquo;" => [8250] 203A, "&Rscr;" => [8475] 211B, "&rscr;" => [120007] D835\uDCC7, "&Rsh;" => [8625] 21B1, "&rsh;" => [8625] 21B1, "&rsqb;" => [93] 005D, "&rsquo;" => [8217] 2019, "&rsquor;" => [8217] 2019, "&rthree;" => [8908] 22CC, "&rtimes;" => [8906] 22CA, "&rtri;" => [9657] 25B9, "&rtrie;" => [8885] 22B5, "&rtrif;" => [9656] 25B8, "&rtriltri;" => [10702] 29CE, "&RuleDelayed;" => [10740] 29F4, "&ruluhar;" => [10600] 2968, "&rx;" => [8478] 211E, "&Sacute;" => [346] 015A, "&sacute;" => [347] 015B, "&sbquo;" => [8218] 201A, "&Sc;" => [10940] 2ABC, "&sc;" => [8827] 227B, "&scap;" => [10936] 2AB8, "&Scaron;" => [352] 0160, "&scaron;" => [353] 0161, "&sccue;" => [8829] 227D, "&scE;" => [10932] 2AB4, "&sce;" => [10928] 2AB0, "&Scedil;" => [350] 015E, "&scedil;" => [351] 015F, "&Scirc;" => [348] 015C, "&scirc;" => [349] 015D, "&scnap;" => [10938] 2ABA, "&scnE;" => [10934] 2AB6, "&scnsim;" => [8937] 22E9, "&scpolint;" => [10771] 2A13, "&scsim;" => [8831] 227F, "&Scy;" => [1057] 0421, "&scy;" => [1089] 0441, "&sdot;" => [8901] 22C5, "&sdotb;" => [8865] 22A1, "&sdote;" => [10854] 2A66, "&searhk;" => [10533] 2925, "&seArr;" => [8664] 21D8, "&searr;" => [8600] 2198, "&searrow;" => [8600] 2198, "&sect;" => [167] 00A7, "&sect" => [167] 00A7, "&semi;" => [59] 003B, "&seswar;" => [10537] 2929, "&setminus;" => [8726] 2216, "&setmn;" => [8726] 2216, "&sext;" => [10038] 2736, "&Sfr;" => [120086] D835\uDD16, "&sfr;" => [120112] D835\uDD30, "&sfrown;" => [8994] 2322, "&sharp;" => [9839] 266F, "&SHCHcy;" => [1065] 0429, "&shchcy;" => [1097] 0449, "&SHcy;" => [1064] 0428, "&shcy;" => [1096] 0448, "&ShortDownArrow;" => [8595] 2193, "&ShortLeftArrow;" => [8592] 2190, "&shortmid;" => [8739] 2223, "&shortparallel;" => [8741] 2225, "&ShortRightArrow;" => [8594] 2192, "&ShortUpArrow;" => [8593] 2191, "&shy;" => [173] 00AD, "&shy" => [173] 00AD, "&Sigma;" => [931] 03A3, "&sigma;" => [963] 03C3, "&sigmaf;" => [962] 03C2, "&sigmav;" => [962] 03C2, "&sim;" => [8764] 223C, "&simdot;" => [10858] 2A6A, "&sime;" => [8771] 2243, "&simeq;" => [8771] 2243, "&simg;" => [10910] 2A9E, "&simgE;" => [10912] 2AA0, "&siml;" => [10909] 2A9D, "&simlE;" => [10911] 2A9F, "&simne;" => [8774] 2246, "&simplus;" => [10788] 2A24, "&simrarr;" => [10610] 2972, "&slarr;" => [8592] 2190, "&SmallCircle;" => [8728] 2218, "&smallsetminus;" => [8726] 2216, "&smashp;" => [10803] 2A33, "&smeparsl;" => [10724] 29E4, "&smid;" => [8739] 2223, "&smile;" => [8995] 2323, "&smt;" => [10922] 2AAA, "&smte;" => [10924] 2AAC, "&smtes;" => [10924, 65024] 2AAC\uFE00, "&SOFTcy;" => [1068] 042C, "&softcy;" => [1100] 044C, "&sol;" => [47] 002F, "&solb;" => [10692] 29C4, "&solbar;" => [9023] 233F, "&Sopf;" => [120138] D835\uDD4A, "&sopf;" => [120164] D835\uDD64, "&spades;" => [9824] 2660, "&spadesuit;" => [9824] 2660, "&spar;" => [8741] 2225, "&sqcap;" => [8851] 2293, "&sqcaps;" => [8851, 65024] 2293\uFE00, "&sqcup;" => [8852] 2294, "&sqcups;" => [8852, 65024] 2294\uFE00, "&Sqrt;" => [8730] 221A, "&sqsub;" => [8847] 228F, "&sqsube;" => [8849] 2291, "&sqsubset;" => [8847] 228F, "&sqsubseteq;" => [8849] 2291, "&sqsup;" => [8848] 2290, "&sqsupe;" => [8850] 2292, "&sqsupset;" => [8848] 2290, "&sqsupseteq;" => [8850] 2292, "&squ;" => [9633] 25A1, "&Square;" => [9633] 25A1, "&square;" => [9633] 25A1, "&SquareIntersection;" => [8851] 2293, "&SquareSubset;" => [8847] 228F, "&SquareSubsetEqual;" => [8849] 2291, "&SquareSuperset;" => [8848] 2290, "&SquareSupersetEqual;" => [8850] 2292, "&SquareUnion;" => [8852] 2294, "&squarf;" => [9642] 25AA, "&squf;" => [9642] 25AA, "&srarr;" => [8594] 2192, "&Sscr;" => [119982] D835\uDCAE, "&sscr;" => [120008] D835\uDCC8, "&ssetmn;" => [8726] 2216, "&ssmile;" => [8995] 2323, "&sstarf;" => [8902] 22C6, "&Star;" => [8902] 22C6, "&star;" => [9734] 2606, "&starf;" => [9733] 2605, "&straightepsilon;" => [1013] 03F5, "&straightphi;" => [981] 03D5, "&strns;" => [175] 00AF, "&Sub;" => [8912] 22D0, "&sub;" => [8834] 2282, "&subdot;" => [10941] 2ABD, "&subE;" => [10949] 2AC5, "&sube;" => [8838] 2286, "&subedot;" => [10947] 2AC3, "&submult;" => [10945] 2AC1, "&subnE;" => [10955] 2ACB, "&subne;" => [8842] 228A, "&subplus;" => [10943] 2ABF, "&subrarr;" => [10617] 2979, "&Subset;" => [8912] 22D0, "&subset;" => [8834] 2282, "&subseteq;" => [8838] 2286, "&subseteqq;" => [10949] 2AC5, "&SubsetEqual;" => [8838] 2286, "&subsetneq;" => [8842] 228A, "&subsetneqq;" => [10955] 2ACB, "&subsim;" => [10951] 2AC7, "&subsub;" => [10965] 2AD5, "&subsup;" => [10963] 2AD3, "&succ;" => [8827] 227B, "&succapprox;" => [10936] 2AB8, "&succcurlyeq;" => [8829] 227D, "&Succeeds;" => [8827] 227B, "&SucceedsEqual;" => [10928] 2AB0, "&SucceedsSlantEqual;" => [8829] 227D, "&SucceedsTilde;" => [8831] 227F, "&succeq;" => [10928] 2AB0, "&succnapprox;" => [10938] 2ABA, "&succneqq;" => [10934] 2AB6, "&succnsim;" => [8937] 22E9, "&succsim;" => [8831] 227F, "&SuchThat;" => [8715] 220B, "&Sum;" => [8721] 2211, "&sum;" => [8721] 2211, "&sung;" => [9834] 266A, "&Sup;" => [8913] 22D1, "&sup;" => [8835] 2283, "&sup1;" => [185] 00B9, "&sup1" => [185] 00B9, "&sup2;" => [178] 00B2, "&sup2" => [178] 00B2, "&sup3;" => [179] 00B3, "&sup3" => [179] 00B3, "&supdot;" => [10942] 2ABE, "&supdsub;" => [10968] 2AD8, "&supE;" => [10950] 2AC6, "&supe;" => [8839] 2287, "&supedot;" => [10948] 2AC4, "&Superset;" => [8835] 2283, "&SupersetEqual;" => [8839] 2287, "&suphsol;" => [10185] 27C9, "&suphsub;" => [10967] 2AD7, "&suplarr;" => [10619] 297B, "&supmult;" => [10946] 2AC2, "&supnE;" => [10956] 2ACC, "&supne;" => [8843] 228B, "&supplus;" => [10944] 2AC0, "&Supset;" => [8913] 22D1, "&supset;" => [8835] 2283, "&supseteq;" => [8839] 2287, "&supseteqq;" => [10950] 2AC6, "&supsetneq;" => [8843] 228B, "&supsetneqq;" => [10956] 2ACC, "&supsim;" => [10952] 2AC8, "&supsub;" => [10964] 2AD4, "&supsup;" => [10966] 2AD6, "&swarhk;" => [10534] 2926, "&swArr;" => [8665] 21D9, "&swarr;" => [8601] 2199, "&swarrow;" => [8601] 2199, "&swnwar;" => [10538] 292A, "&szlig;" => [223] 00DF, "&szlig" => [223] 00DF, "&Tab;" => [9] 0009, "&target;" => [8982] 2316, "&Tau;" => [932] 03A4, "&tau;" => [964] 03C4, "&tbrk;" => [9140] 23B4, "&Tcaron;" => [356] 0164, "&tcaron;" => [357] 0165, "&Tcedil;" => [354] 0162, "&tcedil;" => [355] 0163, "&Tcy;" => [1058] 0422, "&tcy;" => [1090] 0442, "&tdot;" => [8411] 20DB, "&telrec;" => [8981] 2315, "&Tfr;" => [120087] D835\uDD17, "&tfr;" => [120113] D835\uDD31, "&there4;" => [8756] 2234, "&Therefore;" => [8756] 2234, "&therefore;" => [8756] 2234, "&Theta;" => [920] 0398, "&theta;" => [952] 03B8, "&thetasym;" => [977] 03D1, "&thetav;" => [977] 03D1, "&thickapprox;" => [8776] 2248, "&thicksim;" => [8764] 223C, "&ThickSpace;" => [8287, 8202] 205F\u200A, "&thinsp;" => [8201] 2009, "&ThinSpace;" => [8201] 2009, "&thkap;" => [8776] 2248, "&thksim;" => [8764] 223C, "&THORN;" => [222] 00DE, "&THORN" => [222] 00DE, "&thorn;" => [254] 00FE, "&thorn" => [254] 00FE, "&Tilde;" => [8764] 223C, "&tilde;" => [732] 02DC, "&TildeEqual;" => [8771] 2243, "&TildeFullEqual;" => [8773] 2245, "&TildeTilde;" => [8776] 2248, "&times;" => [215] 00D7, "&times" => [215] 00D7, "&timesb;" => [8864] 22A0, "&timesbar;" => [10801] 2A31, "&timesd;" => [10800] 2A30, "&tint;" => [8749] 222D, "&toea;" => [10536] 2928, "&top;" => [8868] 22A4, "&topbot;" => [9014] 2336, "&topcir;" => [10993] 2AF1, "&Topf;" => [120139] D835\uDD4B, "&topf;" => [120165] D835\uDD65, "&topfork;" => [10970] 2ADA, "&tosa;" => [10537] 2929, "&tprime;" => [8244] 2034, "&TRADE;" => [8482] 2122, "&trade;" => [8482] 2122, "&triangle;" => [9653] 25B5, "&triangledown;" => [9663] 25BF, "&triangleleft;" => [9667] 25C3, "&trianglelefteq;" => [8884] 22B4, "&triangleq;" => [8796] 225C, "&triangleright;" => [9657] 25B9, "&trianglerighteq;" => [8885] 22B5, "&tridot;" => [9708] 25EC, "&trie;" => [8796] 225C, "&triminus;" => [10810] 2A3A, "&TripleDot;" => [8411] 20DB, "&triplus;" => [10809] 2A39, "&trisb;" => [10701] 29CD, "&tritime;" => [10811] 2A3B, "&trpezium;" => [9186] 23E2, "&Tscr;" => [119983] D835\uDCAF, "&tscr;" => [120009] D835\uDCC9, "&TScy;" => [1062] 0426, "&tscy;" => [1094] 0446, "&TSHcy;" => [1035] 040B, "&tshcy;" => [1115] 045B, "&Tstrok;" => [358] 0166, "&tstrok;" => [359] 0167, "&twixt;" => [8812] 226C, "&twoheadleftarrow;" => [8606] 219E, "&twoheadrightarrow;" => [8608] 21A0, "&Uacute;" => [218] 00DA, "&Uacute" => [218] 00DA, "&uacute;" => [250] 00FA, "&uacute" => [250] 00FA, "&Uarr;" => [8607] 219F, "&uArr;" => [8657] 21D1, "&uarr;" => [8593] 2191, "&Uarrocir;" => [10569] 2949, "&Ubrcy;" => [1038] 040E, "&ubrcy;" => [1118] 045E, "&Ubreve;" => [364] 016C, "&ubreve;" => [365] 016D, "&Ucirc;" => [219] 00DB, "&Ucirc" => [219] 00DB, "&ucirc;" => [251] 00FB, "&ucirc" => [251] 00FB, "&Ucy;" => [1059] 0423, "&ucy;" => [1091] 0443, "&udarr;" => [8645] 21C5, "&Udblac;" => [368] 0170, "&udblac;" => [369] 0171, "&udhar;" => [10606] 296E, "&ufisht;" => [10622] 297E, "&Ufr;" => [120088] D835\uDD18, "&ufr;" => [120114] D835\uDD32, "&Ugrave;" => [217] 00D9, "&Ugrave" => [217] 00D9, "&ugrave;" => [249] 00F9, "&ugrave" => [249] 00F9, "&uHar;" => [10595] 2963, "&uharl;" => [8639] 21BF, "&uharr;" => [8638] 21BE, "&uhblk;" => [9600] 2580, "&ulcorn;" => [8988] 231C, "&ulcorner;" => [8988] 231C, "&ulcrop;" => [8975] 230F, "&ultri;" => [9720] 25F8, "&Umacr;" => [362] 016A, "&umacr;" => [363] 016B, "&uml;" => [168] 00A8, "&uml" => [168] 00A8, "&UnderBar;" => [95] 005F, "&UnderBrace;" => [9183] 23DF, "&UnderBracket;" => [9141] 23B5, "&UnderParenthesis;" => [9181] 23DD, "&Union;" => [8899] 22C3, "&UnionPlus;" => [8846] 228E, "&Uogon;" => [370] 0172, "&uogon;" => [371] 0173, "&Uopf;" => [120140] D835\uDD4C, "&uopf;" => [120166] D835\uDD66, "&UpArrow;" => [8593] 2191, "&Uparrow;" => [8657] 21D1, "&uparrow;" => [8593] 2191, "&UpArrowBar;" => [10514] 2912, "&UpArrowDownArrow;" => [8645] 21C5, "&UpDownArrow;" => [8597] 2195, "&Updownarrow;" => [8661] 21D5, "&updownarrow;" => [8597] 2195, "&UpEquilibrium;" => [10606] 296E, "&upharpoonleft;" => [8639] 21BF, "&upharpoonright;" => [8638] 21BE, "&uplus;" => [8846] 228E, "&UpperLeftArrow;" => [8598] 2196, "&UpperRightArrow;" => [8599] 2197, "&Upsi;" => [978] 03D2, "&upsi;" => [965] 03C5, "&upsih;" => [978] 03D2, "&Upsilon;" => [933] 03A5, "&upsilon;" => [965] 03C5, "&UpTee;" => [8869] 22A5, "&UpTeeArrow;" => [8613] 21A5, "&upuparrows;" => [8648] 21C8, "&urcorn;" => [8989] 231D, "&urcorner;" => [8989] 231D, "&urcrop;" => [8974] 230E, "&Uring;" => [366] 016E, "&uring;" => [367] 016F, "&urtri;" => [9721] 25F9, "&Uscr;" => [119984] D835\uDCB0, "&uscr;" => [120010] D835\uDCCA, "&utdot;" => [8944] 22F0, "&Utilde;" => [360] 0168, "&utilde;" => [361] 0169, "&utri;" => [9653] 25B5, "&utrif;" => [9652] 25B4, "&uuarr;" => [8648] 21C8, "&Uuml;" => [220] 00DC, "&Uuml" => [220] 00DC, "&uuml;" => [252] 00FC, "&uuml" => [252] 00FC, "&uwangle;" => [10663] 29A7, "&vangrt;" => [10652] 299C, "&varepsilon;" => [1013] 03F5, "&varkappa;" => [1008] 03F0, "&varnothing;" => [8709] 2205, "&varphi;" => [981] 03D5, "&varpi;" => [982] 03D6, "&varpropto;" => [8733] 221D, "&vArr;" => [8661] 21D5, "&varr;" => [8597] 2195, "&varrho;" => [1009] 03F1, "&varsigma;" => [962] 03C2, "&varsubsetneq;" => [8842, 65024] 228A\uFE00, "&varsubsetneqq;" => [10955, 65024] 2ACB\uFE00, "&varsupsetneq;" => [8843, 65024] 228B\uFE00, "&varsupsetneqq;" => [10956, 65024] 2ACC\uFE00, "&vartheta;" => [977] 03D1, "&vartriangleleft;" => [8882] 22B2, "&vartriangleright;" => [8883] 22B3, "&Vbar;" => [10987] 2AEB, "&vBar;" => [10984] 2AE8, "&vBarv;" => [10985] 2AE9, "&Vcy;" => [1042] 0412, "&vcy;" => [1074] 0432, "&VDash;" => [8875] 22AB, "&Vdash;" => [8873] 22A9, "&vDash;" => [8872] 22A8, "&vdash;" => [8866] 22A2, "&Vdashl;" => [10982] 2AE6, "&Vee;" => [8897] 22C1, "&vee;" => [8744] 2228, "&veebar;" => [8891] 22BB, "&veeeq;" => [8794] 225A, "&vellip;" => [8942] 22EE, "&Verbar;" => [8214] 2016, "&verbar;" => [124] 007C, "&Vert;" => [8214] 2016, "&vert;" => [124] 007C, "&VerticalBar;" => [8739] 2223, "&VerticalLine;" => [124] 007C, "&VerticalSeparator;" => [10072] 2758, "&VerticalTilde;" => [8768] 2240, "&VeryThinSpace;" => [8202] 200A, "&Vfr;" => [120089] D835\uDD19, "&vfr;" => [120115] D835\uDD33, "&vltri;" => [8882] 22B2, "&vnsub;" => [8834, 8402] 2282\u20D2, "&vnsup;" => [8835, 8402] 2283\u20D2, "&Vopf;" => [120141] D835\uDD4D, "&vopf;" => [120167] D835\uDD67, "&vprop;" => [8733] 221D, "&vrtri;" => [8883] 22B3, "&Vscr;" => [119985] D835\uDCB1, "&vscr;" => [120011] D835\uDCCB, "&vsubnE;" => [10955, 65024] 2ACB\uFE00, "&vsubne;" => [8842, 65024] 228A\uFE00, "&vsupnE;" => [10956, 65024] 2ACC\uFE00, "&vsupne;" => [8843, 65024] 228B\uFE00, "&Vvdash;" => [8874] 22AA, "&vzigzag;" => [10650] 299A, "&Wcirc;" => [372] 0174, "&wcirc;" => [373] 0175, "&wedbar;" => [10847] 2A5F, "&Wedge;" => [8896] 22C0, "&wedge;" => [8743] 2227, "&wedgeq;" => [8793] 2259, "&weierp;" => [8472] 2118, "&Wfr;" => [120090] D835\uDD1A, "&wfr;" => [120116] D835\uDD34, "&Wopf;" => [120142] D835\uDD4E, "&wopf;" => [120168] D835\uDD68, "&wp;" => [8472] 2118, "&wr;" => [8768] 2240, "&wreath;" => [8768] 2240, "&Wscr;" => [119986] D835\uDCB2, "&wscr;" => [120012] D835\uDCCC, "&xcap;" => [8898] 22C2, "&xcirc;" => [9711] 25EF, "&xcup;" => [8899] 22C3, "&xdtri;" => [9661] 25BD, "&Xfr;" => [120091] D835\uDD1B, "&xfr;" => [120117] D835\uDD35, "&xhArr;" => [10234] 27FA, "&xharr;" => [10231] 27F7, "&Xi;" => [0x] 039E, "&xi;" => [0x] 03BE, "&xlArr;" => [0x] 27F8, "&xlarr;" => [0x] 27F5, "&xmap;" => [0x] 27FC, "&xnis;" => [0x] 22FB, "&xodot;" => [0x] 2A00, "&Xopf;" => [0x, 0x] D835\uDD4F, "&xopf;" => [0x, 0x] D835\uDD69, "&xoplus;" => [0x] 2A01, "&xotime;" => [0x] 2A02, "&xrArr;" => [0x] 27F9, "&xrarr;" => [0x] 27F6, "&Xscr;" => [0x, 0x] D835\uDCB3, "&xscr;" => [0x, 0x] D835\uDCCD, "&xsqcup;" => [0x] 2A06, "&xuplus;" => [0x] 2A04, "&xutri;" => [0x25B3] , "&xvee;" => [0x22C1] , "&xwedge;" => [0x22C0] , "&Yacute;" => [0xDD] 00, "&Yacute" => [0xDD] 00, "&yacute;" => [0xFD] 00, "&yacute" => [0xFD] 00, "&YAcy;" => [0x42F] 0, "&yacy;" => [0x44F] 0, "&Ycirc;" => [0x176] 0, "&ycirc;" => [0x177] 0, "&Ycy;" => [0x42B] 0, "&ycy;" => [0x44B] 0, "&yen;" => [0xA5] 00, "&yen" => [0xA5], "&Yfr;" => [0x, 0x] D835\uDD1C, "&yfr;" => [0x, 0x] D835\uDD36, "&YIcy;" => [0x] 0407, "&yicy;" => [0x] 0457
		
		*/

		"&Yopf;" => [0x1D550], "&yopf;" => [0x1D56A], "&Yscr;" => [0x1D4B4], "&yscr;" => [0x1D4CE], "&YUcy;" => [0x42E], "&yucy;" => [0x44E], "&Yuml;" => [0x178], "&yuml;" => [0xFF], 
		"&yuml" => [0xFF], "&Zacute;" => [0x179], "&zacute;" => [0x17A], "&Zcaron;" => [0x17D], "&zcaron;" => [0x17E], "&Zcy;" => [0x417], "&zcy;" => [0x437], "&Zdot;" => [0x17B], 
		"&zdot;" => [0x17C], "&zeetrf;" => [0x2128], "&ZeroWidthSpace;" => [0x200B], "&Zeta;" => [0x396], "&zeta;" => [0x3B6], "&Zfr;" => [0x2128], "&zfr;" => [0x1D537], 
		"&ZHcy;" => [0x416], "&zhcy;" => [0x436], "&zigrarr;" => [0x21DD], "&Zopf;" => [0x2124], "&zopf;" => [0x1D56B], "&Zscr;" => [0x1D4B5], "&zscr;" => [0x1D4CF], 
		"&zwj;" => [0x200D], "&zwnj;" => [0x200C] ];
	}

	/**
	 * 
	 */
	private var data : String;
	/**
	 * 
	 */
	private var currCharI : Int;
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#insertion-point
	 */
	var ip : Int;
	
	/**
	 * 
	 */
	//public function new( data : Bytes )
	public function new( data : String )
	{
		// TODO convert to unicode code points ? This has to be cross-platform...
		// @see http://www.w3.org/TR/html5/syntax.html#overview-of-the-parsing-model
		// @see http://www.w3.org/TR/html5/infrastructure.html#unicode-code-point
		// @see http://haxe.org/manual/encoding
		this.data = data;

		currCharI = -1;
	}
	
	
	/**
	 * The next input character is the first character in the input stream that 
	 * has not yet been consumed or explicitly ignored by the requirements in this
	 * section.
	 * 
	 * Initially, the next input character is the first character in the input.
	 * 
	 * @return the next input char code or -1 if EOF
	 */
	public function nextInputChar() : Int
	{ //trace("before nextInputChar "+data.charAt(currCharI));trace("nextInputChar "+data.charAt(currCharI+1));
		return ( currCharI++ < data.length && !StringTools.isEof(data.fastCodeAt(currCharI)) ) ? data.fastCodeAt(currCharI) : -1 ;
	}
	
	/**
	 * The current input character is the last character to have been consumed.
	 * 
	 * @return the current input char code or -1 if EOF
	 */
	public function currentInputChar() : Int
	{
		return ( currCharI >= 0 && currCharI < data.length && !StringTools.isEof(data.fastCodeAt(currCharI)) ) ? data.fastCodeAt(currCharI) : -1;
	}
	
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#consume-a-character-reference
	 * 
	 * @return [-2] if nothing
	 */
	public function nextCharRef( ?additionalAllowedCharacter : Int = -2 ) : Array<Int>
	{
		var c = nextInputChar();

		switch ( c )
		{
			case x if( Lambda.has([-1, 0x9, 0xA, 0xC, 0x20, 0x3C, 0x26, additionalAllowedCharacter], x) ): // EOF, "tab", "LF", "FF", SPACE, '<', '&', additionalAllowedCharacter
				return [-2]; //Not a character reference. No characters are consumed, and nothing is returned. (This is not an error, either.)
			
			case 0x23: // '#' char
				c = nextInputChar();
				var isHexa : Bool = false;
				if ( c == 0x58 || c == 0x78 ) // starts with 'x' or 'X'
				{
					c = nextInputChar(); // consume the x char
					isHexa = true;
				}
				var buf : StringBuf = new StringBuf();
				while ( isHexa && isDigit(c, true) || !isHexa && isDigit(c, false)  )
				{
					buf.addChar(c);
					c = nextInputChar();
				}
				if ( buf.toString().length == 0 ) //If no characters match the range
				{
					unconsumeUntil( 0x23 ); //then don't consume any characters (and unconsume the U+0023 NUMBER SIGN character and, if appropriate, the X character)
					
					//TODO This is a parse error; nothing is returned.
					return [-2];
				}
				if ( c == 0x3B ) //If the next character is a U+003B SEMICOLON, consume that too.
				{
					c = nextInputChar();
				}
				else
				{
					//If it isn't, there is a parse error.
					// TODO
				}
				//If one or more characters match the range, then take them all and interpret the string of characters as a number (either 
				//hexadecimal or decimal as appropriate).
				var num = isHexa ? Std.parseInt( "0x" + buf.toString() ) : Std.parseInt( buf.toString() );
				
				if ( charRefReplacements().exists( num ) )
				{
					//If that number is one of the *charRefReplacements*, then this is a parse error.
					//return a character token for the Unicode character given as a replacement.
					return [charRefReplacements().get( num )];
				}
				if ( num >= 0xD800 && num <= 0xDFFF || num > 0x10FFFF )
				{
					// TODO this is a parse error. 
					// Return a U+FFFD REPLACEMENT CHARACTER.
					return [0xFFFD];
				}
				if ( num >= 0x1 && num <= 0x8 || num >= 0xE && num <= 0x1F || num >= 0x7F && num <= 0x9F || num >= 0xFDD0 && num <= 0xFDEF ||
					Lambda.has([0xB, 0xFFFE, 0xFFFF, 0x1FFFE, 0x1FFFF, 0x2FFFE, 0x2FFFF, 0x3FFFE, 0x3FFFF, 0x4FFFE, 0x4FFFF, 0x5FFFE, 0x5FFFF,
					0x6FFFE, 0x6FFFF, 0x7FFFE, 0x7FFFF, 0x8FFFE, 0x8FFFF, 0x9FFFE, 0x9FFFF, 0xAFFFE, 0xAFFFF, 0xBFFFE, 0xBFFFF, 0xCFFFE, 0xCFFFF,
					0xDFFFE, 0xDFFFF, 0xEFFFE, 0xEFFFF, 0xFFFFE, 0xFFFFF, 0x10FFFE, 0x10FFFF], num) )
				{
					//TODO then this is a parse error.
				}				
				//Otherwise, return a character token for the Unicode character whose code point is that number.
				return [num];
				
			case _:
				// consume chars until a match is found in namedCharRef()
				var s : String = String.fromCharCode(c);
				var possibleMatch : Bool = true;
				var lastExactMatch : String = null;
				var inRange : Bool = true;

				while ( possibleMatch )
				{
					if ( inRange && !isASCIIDigitOrLetter(c) )
					{
						inRange = false;
					}
					possibleMatch = false;

					for ( crs in namedCharRef().keys() ) // TODO optimize :S
					{
						if ( crs.substr(1) == s )
						{
							lastExactMatch = crs;
						}
						if ( crs.substr(1, s.length) == s )
						{
							possibleMatch = true;
						}
					}
					possibleMatch = possibleMatch && (c != ';'.code); // do not continue if encounter ';'

					c = nextInputChar();
					s += String.fromCharCode(c);
				}
				if (lastExactMatch == null)
				{
					if ( inRange )
					{
						//TODO there is a parse error.
					}
				}
				else
				{
					if ( lastExactMatch == s )
					{
						if ( c != ';'.code )
						{
							//TODO there is a parse error.
						}
						return namedCharRef().get( s );
					}
					// here, lastExactMatch != null
					unconsume( s.length - lastExactMatch.length );
					//TODO there is a parse error.
					return namedCharRef().get( lastExactMatch );
				}
				unconsume( s.length );
				return [-2]; // nothing is returned
		}
	}

	/**
	 * 
	 * @return
	 */
	public function isASCIIDigitOrLetter( c : Int) : Bool
	{
		if ( c >= 0x30 && c <= 0x39 || c >= 0x61 && c <= 0x7A || c >= 0x41 && c <= 0x5A )
		{
			return true;
		}
		return false;
	}
	/**
	 * Checks is a given char code in within the decimal or hexadecimal char codes range.
	 * @param	c
	 * @param	isHexa
	 * @return
	 */
	private function isDigit( c : Int, isHexa : Bool ) : Bool
	{
		if ( c >= 0x30 && c <= 0x39 ) // is it a ASCII digit ?
		{
			return true;
		}
		// is it within U+0061 LATIN SMALL LETTER A to U+0066 LATIN SMALL LETTER F, 
		// and U+0041 LATIN CAPITAL LETTER A to U+0046 LATIN CAPITAL LETTER F range ?
		if ( isHexa && ( c >= 0x61 && c <= 0x66 || c >= 0x41 && c <= 0x46 ) )
		{
			return true;
		}
		return false;
	}
	/**
	 * 
	 * 
	 */
	public function consumeString( s : String, ?caseSensitive : Bool = true ) : Bool
	{
		for ( i in 0...s.length )
		{
			if ( s.fastCodeAt(i) != nextInputChar() || !caseSensitive && ( s.toLowerCase().fastCodeAt(i) != nextInputChar() || s.toUpperCase().fastCodeAt(i) != nextInputChar() ) )
			{
				unconsume( i + 1 );
				return false;
			}
		}
		return true;
	}
	/**
	 * Consumes until s is found or EOF. Returns consumed chars not including s or EOF.
	 */
	public function consumeUntilString( s : String ) : Array<Int>
	{
		var buf = new Array();
		currCharI++;

		//while ( currCharI++ < data.length && !StringTools.isEof( data.fastCodeAt( currCharI ) ) )
		while ( currCharI < data.length && !StringTools.isEof( data.fastCodeAt( currCharI ) ) )
		{
			if ( currCharI + s.length <= data.length && !StringTools.isEof( data.fastCodeAt( currCharI + s.length - 1 ) ) )
			{
				for ( i in 0...s.length )
				{
					if ( s.fastCodeAt( i ) != data.fastCodeAt( currCharI + i ) )
					{
						break;
					}
					else if ( i == s.length - 1 )
					{
						currCharI += i;
						return buf;
					}
				}
			}
			buf.push( data.fastCodeAt( currCharI ) );
			currCharI++;
		}
		return buf;
	}
	/**
	 * 
	 * @param	c
	 * @return
	 */
	public function unconsumeUntil( c : Int ) : Int
	{
		//while ( currCharI-- >= 0 && data.fastCodeAt(currCharI) != c ) { }
		currCharI--;
		while ( currCharI >= 0 && data.fastCodeAt(currCharI) != c ) { currCharI--; }
		return currCharI >= 0 ? data.fastCodeAt(currCharI) : -1 ;
	}
	/**
	 * 
	 * @param	nb	Int, the number of chars to unconsume
	 * @return	the current char code
	 */
	public function unconsume( nb : Int ) : Int
	{
		currCharI -= nb;
		return currCharI >= 0 ? data.fastCodeAt(currCharI) : -1 ;
	}
}