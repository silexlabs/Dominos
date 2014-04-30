/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.parser.html;

import dominos.dom.Document;
import dominos.dom.DOMImplementation;
import dominos.dom.Node;
import dominos.dom.Element;
import dominos.dom.Text;

import dominos.parser.html.Tokenizer.Token;
import dominos.parser.html.Tokenizer.State;

/**
 * The document quirks mode
 * @see http://dom.spec.whatwg.org/#concept-document-no-quirks
 */
enum QuirksMode
{
	NO_QUIRKS;
	QUIRKS;
	LIMITED_QUIRKS;
}
/**
 * 
 */
enum InsertionMode
{
	INITIAL;
	BEFORE_HTML;
	BEFORE_HEAD;
	IN_HEAD;
	IN_HEAD_NOSCRIPT;
	AFTER_HEAD;
	IN_BODY;
	TEXT;
	IN_TABLE;
	IN_TABLE_TEXT;
	IN_CAPTION;
	IN_COLUMN_GROUP;
	IN_TABLE_BODY;
	IN_ROW;
	IN_CELL;
	IN_SELECT;
	IN_SELECT_IN_TABLE;
	AFTER_BODY;
	IN_FRAMESET;
	AFTER_FRAMESET;
	AFTER_AFTER_BODY;
	AFTER_AFTER_FRAMESET;
}
/**
 * Return value of processToken(). It sometimes useful to know what happened to a token while processing.
 */
enum TokenProcessRet
{
	VOID;
	IGNORED;
}
/**
 * Little structure associating an active formatting element with the token for which it was created.
 */
typedef ActiveFormattingElt = 
{
	var e:Node;
	var t:Token;
}

/**
 * The TreeBuilder class handles the <a href="http://www.w3.org/TR/html5/syntax.html#tree-construction">Tree Construction</a> 
 * steps of the HTML parsing algorithm.
 * 
 * TODO
 *  - manage scrips
 *  - manage fragment parsing
 *  - manage few cases where (if next char is a LF, then ignore it)
 *  - IN_TABLE => case _
 *  - TEXT => case END_TAG( "script", selfClosing, attrs )
 *  - BEFORE_HTML => case START_TAG( "html", _, _ )
 *  - 
 * 
 *  - warn about the use of obsolete features ? like marquee for example...
 * 
 * @author Thomas Fétiveau
 */
class TreeBuilder
{
	/**
	 * 
	 */
	static inline var isindexStr = "This is a searchable index. Enter search keywords: (input field)";
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#special
	 */
	inline function specials() : Array<String>
	{
		return ["address", "applet", "area", "article", "aside", "base", "basefont", "bgsound", "blockquote", "body", "br", "button", "caption", 
		"center", "col", "colgroup", "command", "dd", "details", "dir", "div", "dl", "dt", "embed", "fieldset", "figcaption", "figure", "footer", 
		"form", "frame", "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html", "iframe", "img", "input", "isindex", 
		"li", "link", "listing", "marquee", "menu", "meta", "nav", "noembed", "noframes", "noscript", "object", "ol", "p", "param", "plaintext", "pre", 
		"script", "section", "select", "source", "style", "summary", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "title", "tr", "track", 
		"ul", "wbr", "xmp",/* MathML */ "mi", "mo", "mn", "ms", "mtext", "annotation-xml", /* SVG */ "foreignObject", "desc", "title"];
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#formatting
	 */
	inline function formattingElementsList() : Array<String>
	{
		return ["a", "b", "big", "code", "em", "font", "i", "nobr", "s", "small", "strike", "strong", "tt", "u"];
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#list-of-active-formatting-elements
	 */
	inline function scopeMarkersList() : Array<String>
	{
		return ["applet", "button", "object", "marquee", "td", "caption"];
	}
	/**
	 * 
	 */
	inline function getPublicIdsStartWith() : Array<String>
	{
		return [ "+//Silmaril//dtd html Pro v0r11 19970101//",
				"-//AdvaSoft Ltd//DTD HTML 3.0 asWedit + extensions//",
				"-//AS//DTD HTML 3.0 asWedit + extensions//",
				"-//IETF//DTD HTML 2.0 Level 1//",
				"-//IETF//DTD HTML 2.0 Level 2//",
				"-//IETF//DTD HTML 2.0 Strict Level 1//",
				"-//IETF//DTD HTML 2.0 Strict Level 2//",
				"-//IETF//DTD HTML 2.0 Strict//",
				"-//IETF//DTD HTML 2.0//",
				"-//IETF//DTD HTML 2.1E//",
				"-//IETF//DTD HTML 3.0//",
				"-//IETF//DTD HTML 3.2 Final//",
				"-//IETF//DTD HTML 3.2//",
				"-//IETF//DTD HTML 3//",
				"-//IETF//DTD HTML Level 0//",
				"-//IETF//DTD HTML Level 1//",
				"-//IETF//DTD HTML Level 2//",
				"-//IETF//DTD HTML Level 3//",
				"-//IETF//DTD HTML Strict Level 0//",
				"-//IETF//DTD HTML Strict Level 1//",
				"-//IETF//DTD HTML Strict Level 2//",
				"-//IETF//DTD HTML Strict Level 3//",
				"-//IETF//DTD HTML Strict//",
				"-//IETF//DTD HTML//",
				"-//Metrius//DTD Metrius Presentational//",
				"-//Microsoft//DTD Internet Explorer 2.0 HTML Strict//",
				"-//Microsoft//DTD Internet Explorer 2.0 HTML//",
				"-//Microsoft//DTD Internet Explorer 2.0 Tables//",
				"-//Microsoft//DTD Internet Explorer 3.0 HTML Strict//",
				"-//Microsoft//DTD Internet Explorer 3.0 HTML//",
				"-//Microsoft//DTD Internet Explorer 3.0 Tables//",
				"-//Netscape Comm. Corp.//DTD HTML//",
				"-//Netscape Comm. Corp.//DTD Strict HTML//",
				"-//O'Reilly and Associates//DTD HTML 2.0//",
				"-//O'Reilly and Associates//DTD HTML Extended 1.0//",
				"-//O'Reilly and Associates//DTD HTML Extended Relaxed 1.0//",
				"-//SoftQuad Software//DTD HoTMetaL PRO 6.0::19990601::extensions to HTML 4.0//",
				"-//SoftQuad//DTD HoTMetaL PRO 4.0::19971010::extensions to HTML 4.0//",
				"-//Spyglass//DTD HTML 2.0 Extended//",
				"-//SQ//DTD HTML 2.0 HoTMetaL + extensions//",
				"-//Sun Microsystems Corp.//DTD HotJava HTML//",
				"-//Sun Microsystems Corp.//DTD HotJava Strict HTML//",
				"-//W3C//DTD HTML 3 1995-03-24//",
				"-//W3C//DTD HTML 3.2 Draft//",
				"-//W3C//DTD HTML 3.2 Final//",
				"-//W3C//DTD HTML 3.2//",
				"-//W3C//DTD HTML 3.2S Draft//",
				"-//W3C//DTD HTML 4.0 Frameset//",
				"-//W3C//DTD HTML 4.0 Transitional//",
				"-//W3C//DTD HTML Experimental 19960712//",
				"-//W3C//DTD HTML Experimental 970421//",
				"-//W3C//DTD W3 HTML//",
				"-//W3O//DTD W3 HTML 3.0//",
				"-//WebTechs//DTD Mozilla HTML 2.0//",
				"-//WebTechs//DTD Mozilla HTML//" ];
	}

	
	/**
	 * The insertion mode is a state variable that controls the primary operation of the tree construction stage.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-insertion-mode
	 */
	private var im : InsertionMode;
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#original-insertion-mode
	 */
	private var om : InsertionMode;
	
	/**
	 * The DOMImplementation
	 */
	private var dom : DOMImplementation;
	/**
	 * The associated DOM Document
	 */
	private var doc : Document;

	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#pending-table-character-tokens
	 */
	private var ptct : Array<Token>;

	/**
	 * The stack of open elements
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-stack-of-open-elements
	 */
	private var stack : Array<Element>;
	
	/**
	 * The list of active formatting elements
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#list-of-active-formatting-elements
	 */
	private var lafe : Array<ActiveFormattingElt>;
	
	/**
	 * Once a head element has been parsed (whether implicitly or explicitly) the head 
	 * element pointer gets set to point to this node.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-element-pointers
	 */
	private var hp : Element;
	/**
	 * The form element pointer points to the last form element that was opened and 
	 * whose end tag has not yet been seen. It is used to make form controls associate 
	 * with forms in the face of dramatically bad markup, for historical reasons.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-element-pointers
	 */
	private var fp : Element;

	/**
	 * The scripting flag is set to "enabled" if scripting was enabled for the Document 
	 * with which the parser is associated when the parser was created, and "disabled" otherwise.
	 * 
	 * The scripting flag can be enabled even when the parser was originally created for the 
	 * HTML fragment parsing algorithm, even though script elements don't execute in that case.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#scripting-flag
	 */
	private var scriptingEnabled : Bool;
	/**
	 * The frameset-ok flag is set to "ok" when the parser is created. It is set to "not ok" 
	 * after certain tokens are seen.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#other-parsing-state-flags
	 */
	private var framesetOK : Bool;
	
	/**
	 * a reference to the tokenizer to change its state
	 */
	private var tok : Tokenizer;
	/**
	 * a reference to the input stream
	 */
	private var is : InputStream;
	
	/**
	 * The currently being parsed document's mode.
	 */
	private var qm : QuirksMode;

	/**
	 * returns the doc if it's parsed
	 */
	public function getDoc() : Document
	{
		if (doc.readyState == "complete")
		{
			return doc;
		}
		throw "Error: did not finish parsing and assembling document yet!";
	}
	
	/**
	 * Creates a new TreeBuilder object for a given input stream and tokenizer
	 * @param	tokenizer
	 */
	public function new( is : InputStream, tok : Tokenizer ) 
	{
		dom = new DOMImplementation();
		//the document that will result of the HTML parsing
		doc = dom.createHTMLDocument();
		// need ref to tokenizer
		this.tok = tok;
		// and to the input stream
		this.is = is;
		// init stack of open elts
		stack = [];
		//init list of active formatting elts to empty array
		lafe = [];
		//init insertion mode
		this.im = INITIAL;
	}
	
	/**
	 * Process a HTML token.
	 * 
	 * Note: this method is able to modify any private field of the DOM entities.
	 * 
	 * @param	t	the Token to process
	 * @param ?utrf	The "using the rules for" parameter.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#using-the-rules-for
	 */
	@:access(dominos.dom)
	public function processToken( t : Token, ?utrf : Null<InsertionMode> = null ) : TokenProcessRet
	{ //trace("utrf null? "+(utrf==null));
		// @see http://www.w3.org/TR/html5/syntax.html#using-the-rules-for
		var m = ( utrf != null && Lambda.exists( [IN_HEAD, IN_BODY, IN_TABLE, IN_SELECT], function(v:InsertionMode) { return Type.enumEq(utrf, v); } ) ) ? utrf : im;
		// @see http://www.w3.org/TR/html5/syntax.html#acknowledge-self-closing-flag
		var ack = false; //trace("m ? "+(m.getName()));
		switch ( m )
		{
			case INITIAL:
				switch ( t )
				{
					case CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20):
						return IGNORED;
					case COMMENT(d):
						//Append a Comment node to the Document object with the data attribute set to the data given in the comment token.
						doc.appendChild(doc.createComment(d));
					case DOCTYPE( name, publicId, systemId, forceQuirks ):
						if ( name != "html" )
						{
							// TODO parse error
						}
						else
						{
							if ( publicId != null  )
							{
								if ( !(publicId == "-//W3C//DTD HTML 4.0//EN" && (systemId == null || systemId == "http://www.w3.org/TR/REC-html40/strict.dtd" || systemId == "http://www.w3.org/TR/html4/strict.dtd"))
									&& (publicId == "-//W3C//DTD XHTML 1.0 Strict//EN" && (systemId == null || systemId == "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"))
									&& (publicId == "-//W3C//DTD XHTML 1.1//EN" && (systemId == null || systemId == "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd")) )
								{
									// TODO parse error
								}
							} else if ( systemId != null && systemId != "about:legacy-compat" )
							{
								// TODO parse error
							}
						}
						// Not supported:
						//Conformance checkers may, based on the values (including presence or lack thereof) of the DOCTYPE token's name, 
						//public identifier, or system identifier, switch to a conformance checking mode for another language (e.g. based 
						//on the DOCTYPE token a conformance checker could recognize that the document is an HTML4 - era document, and defer 
						//to an HTML4 conformance checker.)

						//Append a DocumentType node to the Document node
						var dt = dom.createDocumentType( name != null ? name : "", publicId != null ? publicId : "", systemId != null ? systemId : "" );
						doc.appendChild( dt );
						//And associate it with the Document object
						doc.doctype = dt;

						if ( forceQuirks || name != "html" || 
							publicId != null && (Lambda.exists(getPublicIdsStartWith(), function(pi:String) { return publicId.toLowerCase().indexOf(pi.toLowerCase()) == 0; } ) || Lambda.exists(["-//W3O//DTD W3 HTML Strict 3.0//EN//", "-/W3C/DTD HTML 4.0 Transitional/EN", "HTML"], function(pi:String) { return pi.toLowerCase() == publicId.toLowerCase(); } )) || 
							systemId != null && systemId.toLowerCase() == "http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd" ||
							systemId == null && (publicId!=null && Lambda.exists( ["-//W3C//DTD HTML 4.01 Frameset//", "-//W3C//DTD HTML 4.01 Transitional//"], function(pi:String){ return publicId.toLowerCase().indexOf(pi.toLowerCase()) == 0; } )) )
						{
							//set the Document to quirks mode
							qm = QUIRKS;
						}
						else if ( publicId != null && 
							(Lambda.exists(["-//W3C//DTD XHTML 1.0 Frameset//", "-//W3C//DTD XHTML 1.0 Transitional//"], function(pi:String) { return publicId.indexOf(pi) == 0; } ) || 
							systemId != null && Lambda.exists(["-//W3C//DTD HTML 4.01 Frameset//", "-//W3C//DTD HTML 4.01 Transitional//"], function(pi:String) { return publicId.indexOf(pi) == 0; } ) ) )
						{
							//set the Document to limited-quirks mode
							qm = LIMITED_QUIRKS;
						}
						im = BEFORE_HTML;
					case _:
						//TODO If the document is not an iframe srcdoc document, then this is a parse error; set the Document to quirks mode.
						
						//In any case, switch the insertion mode to "before html", then reprocess the current token.
						im = BEFORE_HTML;
						processToken( t );
						//@see Document.compatMode
						//@see http://www.w3.org/TR/html5/embedded-content-0.html#an-iframe-srcdoc-document
				}
			case BEFORE_HTML:
				switch ( t )
				{
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case COMMENT(d):
						doc.appendChild(doc.createComment(d));
					case CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20):
						return IGNORED;
					case START_TAG( "html", _, _ ):
						var e = createElement( t );
						doc.appendChild( e );
						stack.push( e );
						
						//TODO If the Document is being loaded as part of navigation of a browsing context, 
						// then: if the newly created element has a manifest attribute whose value is not the 
						// empty string, then resolve the value of that attribute to an absolute URL, relative 
						// to the newly created element, and if that is successful, run the application cache 
						// selection algorithm with the resulting absolute URL with any <fragment> component removed; 
						// otherwise, if there is no such attribute, or its value is the empty string, or resolving 
						// its value fails, run the application cache selection algorithm with no manifest. 
						// The algorithm must be passed the Document object.
						
						im = BEFORE_HEAD;
					case END_TAG(tg,_,_) if (tg!="head" && tg!="body" && tg!="html" && tg!="br"):
						//TODO parse error
						return IGNORED;
					case _:
						var e = doc.createElement( "html" );
						doc.appendChild( e );
						stack.push( e );
						
						//TODO If the Document is being loaded as part of navigation of a browsing context, 
						// then: run the application cache selection algorithm with no manifest, passing it the Document object.
						
						im = BEFORE_HEAD;
						//then reprocess the current token
						processToken(t);
				}
			case BEFORE_HEAD:
				switch ( t )
				{
					case CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20):
						return IGNORED;
					case COMMENT(d):
						currentNode().appendChild(doc.createComment(d));
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY);
					case START_TAG( "head", _, _ ):
						// Set the head element pointer to the newly created head element.
						hp = insertHTMLElement( t );
						im = IN_HEAD;
					case END_TAG( tg, _, _ ) if (tg!="head" && tg!="body" && tg!="html" && tg!="br"):
						//TODO parse error
						return IGNORED;
					case _:
						processToken( START_TAG( "head", false, new Map() ) );
						//then reprocess the current token
						processToken( t );
				}
			case IN_HEAD:
				switch (t)
				{
					case CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20):
						insertChar( currentNode(), t );
					case COMMENT( d ):
						currentNode().appendChild( doc.createComment( d ) );
					case DOCTYPE( _, _, _, _ ):
						// TODO parse ERROR
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY );
					case START_TAG( tg, sc, _ ) if( Lambda.has(["base", "basefont", "bgsound", "command", "link"], tg) ):
						insertHTMLElement( t );
						stack.pop();
						if ( sc )
						{
							ack = true;
						}
					case START_TAG( "meta", sc, _ ):
						insertHTMLElement( t );
						stack.pop();
						if ( sc )
						{
							ack = true;
						}
						
						//TODO If the element has a charset attribute, and its value is either a supported ASCII-compatible 
						//character encoding or a UTF - 16 encoding, and the confidence is currently tentative, then change the 
						//encoding to the encoding given by the value of the charset attribute.
						
						//TODO Otherwise, if the element has an http-equiv attribute whose value is an ASCII case-insensitive match 
						//for the string "Content-Type", and the element has a content attribute, and applying the algorithm for extracting 
						//a character encoding from a meta element to that attribute's value returns a supported ASCII-compatible character 
						//encoding or a UTF-16 encoding, and the confidence is currently tentative, then change the encoding to the extracted encoding.
					case START_TAG( "title", _, _ ):
						parseRcdata( t );
					case START_TAG( tg, _, _ ) if ((scriptingEnabled && tg=="noscript") || tg=="noframes" || tg=="style"):
						parseRawText( t );
					case START_TAG( "noscript", _, _ ) if (!scriptingEnabled):
						insertHTMLElement( t );
						im = IN_HEAD_NOSCRIPT;
					case START_TAG( "script", _, _ ):
						//Create an element for the token in the HTML namespace.
						var e = createElement( t );
						//TODO Mark the element as being "parser-inserted" and unset the element's "force-async" flag.
						
						//TODO If the parser was originally created for the HTML fragment parsing algorithm, then mark the script element as "already started". (fragment case)
						
						//Append the new element to the current node and push it onto the stack of open elements.
						currentNode().appendChild(e);
						stack.push(e);
						//Switch the tokenizer to the script data state.
						tok.switchState(SCRIPT_DATA);
						//Let the original insertion mode be the current insertion mode.
						om = im;
						//Switch the insertion mode to "text".
						im = TEXT;
					case END_TAG( "head", _, _ ):
						stack.pop();
						im = AFTER_HEAD;
					case START_TAG( "head", _, _ ):
						//TODO parse error
						return IGNORED;
					case END_TAG( tg, _, _ ) if(tg!="body"&&tg!="html"&&tg!="br"):
						//TODO parse error
						return IGNORED;
					case _:
						// Act as if an end tag token with the tag name "head" had been seen, and reprocess the current token.
						processToken( END_TAG( "head", false, new Map() ) );
						processToken(t);
				}
			case IN_HEAD_NOSCRIPT:
				switch (t)
				{
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY);
					case END_TAG( "noscript", _, _ ):
						//Pop the current node (which will be a noscript element) from the stack of open elements; the new current node will be a head element.
						stack.pop();
						im = IN_HEAD;
					case CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20)|COMMENT(_)|START_TAG("basefont",_,_)|START_TAG("bgsound",_,_)|START_TAG("link",_,_)|START_TAG("meta",_,_)|START_TAG("noframes",_,_)|START_TAG("style",_,_):
						processToken( t, IN_HEAD);
					case END_TAG(tg,_,_ ) if (tg!="br"):
						// TODO parse error
						return IGNORED;
					case START_TAG("head",_,_)|START_TAG("noscript",_,_):
						// TODO parse error
						return IGNORED;
					case _:
						//TODO parse error
						//Act as if an end tag with the tag name "noscript" had been seen and reprocess the current token.
						processToken( END_TAG( "noscript", false, new Map() ) );
						processToken(t);
				}
			case AFTER_HEAD:
				switch (t)
				{
					case CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20):
						insertChar( currentNode(), t );
					case COMMENT( d ):
						currentNode().appendChild( doc.createComment( d ) );
					case DOCTYPE( _ ):
						// TODO parse error
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY);
					case START_TAG( "body", _, _ ):
						insertHTMLElement( t );
						framesetOK = false;
						im = IN_BODY;
					case START_TAG( "frameset", _, _ ):
						insertHTMLElement( t );
						im = IN_FRAMESET;
					case START_TAG("base", _, _)|START_TAG("basefont", _, _)|START_TAG("bgsound", _, _)|START_TAG("link", _, _)|START_TAG("meta",_,_)|START_TAG("noframes",_,_)|START_TAG("script",_,_)|START_TAG("style",_,_)|START_TAG("title", _, _):
						//TODO parse error
						stack.push( hp ); // The head element pointer cannot be null at this point.
						processToken( t, IN_HEAD );
						//Remove the node pointed to by the head element pointer from the stack of open elements.
						stack.remove( hp );
					case START_TAG("head",_,_)|END_TAG("body",_,_)|END_TAG("html",_,_)|END_TAG("br",_,_):
						//TODO parse error
						return IGNORED;
					case _:
						//Act as if a start tag token with the tag name "body" and no attributes had been seen, then set the frameset-ok flag back to "ok", 
						//and then reprocess the current token.
						processToken( START_TAG( "body", false, new Map() ) );
						framesetOK = true;
						processToken(t);
				}
			case IN_BODY: //trace( "Token = "+t.getName() + "  with: " + t.getParameters() );
				switch (t)
				{
					case CHAR(0):
						//TODO parse error
						return IGNORED;
					case CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20):
						reconstructActiveFormattingElements();
						insertChar( currentNode(), t);
					case CHAR(_):
						reconstructActiveFormattingElements();
						insertChar( currentNode(), t);
						framesetOK = false;
					case COMMENT( d ):
						currentNode().appendChild( doc.createComment(d) );
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case START_TAG( "html", _, attrs ):
						//TODO parse error
						//For each attribute on the token, check to see if the attribute is already present on the top element of the stack of open elements. 
						//If it is not, add the attribute and its corresponding value to that element.
						for ( attr in attrs.keys() )
						{
							if (!stack[0].hasAttribute(attr))
							{
								stack[0].setAttribute( attr, attrs.get( attr ) );
							}
						}
					case START_TAG("base", _, _) | START_TAG("basefont", _, _) | START_TAG("bgsound", _, _) | START_TAG("command", _, _) | START_TAG("link", _, _) | 
						START_TAG("meta", _, _) | START_TAG("noframes", _, _) | START_TAG("script", _, _) | START_TAG("style", _, _) | START_TAG("title", _, _):
							processToken( t, IN_HEAD );
					case START_TAG( "body", _, attrs ):
						//TODO parse error
						if ( stack.length > 1 && stack[1].tagName == "body" )
						{
							framesetOK = false;
							for ( attr in attrs.keys() )
							{
								if (!stack[1].hasAttribute(attr))
								{
									stack[1].setAttribute( attr, attrs.get(attr));
								}
							}
						}
					case START_TAG( "frameset", _, _ ):
						// TODO parse error
						if ( stack.length > 1 && stack[1].tagName == "body" && framesetOK )
						{
							//Remove the second element on the stack of open elements from its parent node, if it has one.
							var b = stack[1];
							if (b.parentNode!=null)
							{
								b.parentNode.removeChild(b);
							}
							//Pop all the nodes from the bottom of the stack of open elements, from the current node up to, but not including, the root html element.
							stack = stack.slice(0, 1);
							//Insert an HTML element for the token.
							insertHTMLElement(t);
							//Switch the insertion mode to "in frameset".
							im = IN_FRAMESET;
						}
					case EOF:
						if (Lambda.exists( stack, function(e) { return Lambda.has(["dd", "dt", "li", "p", "tbody", "td", "tfoot", "th", "thead", "tr", "body", "html"], e.tagName); } ))
						{
							//TODO parse error
						}
						stopParsing();
					case END_TAG( "body", _, _ ):
						if ( !isEltInScope( ["body"] ) )
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							if (Lambda.exists( stack, function(e) { return Lambda.exists(["dd","dt","li","optgroup","option","p","rp","rt","tbody","td","tfoot","th","thead","tr","body","html"], function(n) { return n == e.nodeName.toLowerCase(); } ); } ) )
							{
								//TODO parse error
							}
							im = AFTER_BODY;
						}
					case END_TAG( "html", _, _ ): 
						// Act as if an end tag with tag name "body" had been seen, 
						switch ( processToken( END_TAG( "body", false, new Map() ) ) )
						{
							case IGNORED:
								//nothing
							case _:
								//then, if that token wasn't ignored, reprocess the current token.
								processToken( t );
						}
					case START_TAG("address", _, _) | START_TAG("article", _, _) | START_TAG("aside", _, _) | START_TAG("blockquote", _, _) | START_TAG("center", _, _) | START_TAG("details", _, _) | START_TAG("dialog", _, _) | START_TAG("dir", _, _) | START_TAG("div", _, _) | START_TAG("dl", _, _) | START_TAG("fieldset", _, _) | START_TAG("figcaption", _, _) | START_TAG("figure", _, _) | START_TAG("footer", _, _) | START_TAG("header", _, _) | START_TAG("hgroup", _, _) | START_TAG("menu", _, _) | START_TAG("nav", _, _) | START_TAG("ol", _, _) | START_TAG("p", _, _) | START_TAG("section", _, _) | START_TAG("summary", _, _) | START_TAG("ul", _, _):
						if ( isEltInButtonScope( ["p"] ) )
						{
							// act as if an end tag with the tag name "p" had been seen.
							processToken( END_TAG( "p", false, new Map()) );
						}
						if ( Lambda.exists(["h1", "h2", "h3", "h4", "h5", "h6"], function(e) { return currentNode().nodeName.toLowerCase() == e; } ) )
						{
							//TODO parse error
							stack.pop();
						}
						insertHTMLElement(t);
					case START_TAG("pre", _, _) | START_TAG("listing", _, _):
						if (isEltInButtonScope(["p"]))
						{
							// act as if an end tag with the tag name "p" had been seen.
							processToken( END_TAG( "p", false, new Map()) );
						}
						insertHTMLElement(t);
						
						// TODO If the next token is a "LF" (U+000A) character token, then ignore that token and move on to the next one. 
						//(Newlines at the start of pre blocks are ignored as an authoring convenience.)
						
						framesetOK = false;
					case START_TAG("form", _, _):
						if ( fp != null )
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							if (isEltInButtonScope(["p"]))
							{
								processToken( END_TAG( "p", false, new Map()) );
							}
							fp = insertHTMLElement(t);
						}
					case START_TAG("li", _, _):
						framesetOK = false;
						
						var i = stack.length - 1;
						//while (i-- > 0) Crash on Neko
						while (i > 0)
						{
							if ( stack[i].nodeName.toLowerCase() == "li" )
							{
								processToken( END_TAG("li", false, new Map()) );
								break;
							}
							if ( stack[i].nodeName.toLowerCase() != "address" && stack[i].nodeName.toLowerCase() != "div" && stack[i].nodeName.toLowerCase() != "p" && 
								Lambda.exists(specials(), function(e) { return e == stack[i].nodeName.toLowerCase(); } ) )
							{
								break;
							}
							i--;
						}
						if (isEltInButtonScope(["p"]))
						{
							processToken( END_TAG( "p", false, new Map()) );
						}
						fp = insertHTMLElement(t);
					case START_TAG("dd", _, _) | START_TAG("dt", _, _):
						framesetOK = false;
						
						var i = stack.length - 1;
						while (i > 0)
						{
							if ( stack[i].nodeName.toLowerCase() == "dd" || stack[i].nodeName.toLowerCase() == "dt" )
							{
								processToken( END_TAG(stack[i].nodeName.toLowerCase(), false, new Map()) );
								break;
							}
							if ( stack[i].nodeName.toLowerCase() != "address" && stack[i].nodeName.toLowerCase() != "div" && stack[i].nodeName.toLowerCase() != "p" && 
								Lambda.exists(specials(), function(e) { return e == stack[i].nodeName.toLowerCase(); } ) )
							{
								break;
							}
							i--;
						}
						if (isEltInButtonScope(["p"]))
						{
							processToken( END_TAG( "p", false, new Map()) );
						}
						fp = insertHTMLElement(t);
					case START_TAG("plaintext", _, _):
						if ( isEltInButtonScope(["p"]) )
						{
							processToken( END_TAG( "p", false, new Map() ) );
						}
						insertHTMLElement(t);
						//note: Once a start tag with the tag name "plaintext" has been seen, that will be the last token ever seen other 
						//than character tokens (and the end-of-file token), because there is no way to switch out of the PLAINTEXT state.
						tok.switchState(PLAINTEXT);
					case START_TAG("button", _, _):
						if ( isEltInScope( ["button"] ) )
						{
							//TODO parse error
							processToken(END_TAG("button", false, new Map()));
							processToken(t);
						}
						else
						{
							reconstructActiveFormattingElements();
							insertHTMLElement(t);
							framesetOK = false;
						}
					case END_TAG(tg, _, _) if (Lambda.exists(["address", "article", "aside", "blockquote", "button", "center", "details", "dialog", "dir", "div", "dl", "fieldset", "figcaption", "figure", "footer", "header", "hgroup", "listing", "menu", "nav", "ol", "pre", "section", "summary", "ul"], function(e) { return tg == e; } )):
						if (!isEltInScope([tg]))
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							genImpliedEndTags();
							if ( tg != currentNode().nodeName.toLowerCase() )
							{
								//TODO parse error
							}
							var i = stack.length - 1; var found = false;
							//while ( i-- >= 0 && !found ) Does'nt work on Neko
							while ( i >= 0 && !found )
							{
								if ( stack[i].nodeName.toLowerCase() == tg )
								{
									found = true;
								}
								stack.pop();
								i--;
							}
						}
					case END_TAG( "form", _, _ ):
						var node = fp;
						fp = null;
						if ( node == null || !isEltInScope([node.nodeName.toLowerCase()]) )
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							genImpliedEndTags();
							if ( currentNode() != node )
							{
								//TODO parse error
							}
							stack.remove( node );
						}
					case END_TAG( "p", _, _ ):
						if (!isEltInButtonScope(["p"]))
						{
							//TODO parse error
							processToken( START_TAG("p", false, new Map()) );
							processToken(t);
						}
						else
						{
							genImpliedEndTags( ["p"] );
							if ( currentNode().nodeName.toLowerCase() != "p" )
							{
								//TODO parse error
							}
							var i = stack.length - 1; var found = false;
							//while ( i-- >= 0 && !found)
							while ( i >= 0 && !found)
							{
								if ( stack[i].nodeName.toLowerCase() == "p" )
								{
									found = true;
								}
								stack.pop();
								i--;
							}
						}
					case END_TAG( "li", _, _ ):
						if ( !isEltInListItemScope(["li"]) )
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							genImpliedEndTags( ["li"] );
							if ( currentNode().nodeName.toLowerCase() != "li" )
							{
								//TODO parse error
							}
							var i = stack.length - 1; var found = false;
							//while ( i-- >= 0 && !found )
							while ( i >= 0 && !found )
							{
								if ( stack[i].nodeName.toLowerCase() == "li" )
								{
									found = true;
								}
								stack.pop();
								i--;
							}
						}
					case END_TAG( tg, _, _ ) if (tg == "dd" || tg == "dt"):
						if ( !isEltInListItemScope([tg]) )
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							genImpliedEndTags( [tg] );
							if ( currentNode().nodeName.toLowerCase() != tg )
							{
								//TODO parse error
							}
							var i = stack.length - 1; var found = false;
							//while ( i-- >= 0 && !found )
							while ( i >= 0 && !found )
							{
								if ( stack[i].nodeName.toLowerCase() == tg )
								{
									found = true;
								}
								stack.pop();
								i--;
							}
						}
					case END_TAG( tg, _, _ ) if (tg == "h1" || tg == "h2" || tg == "h3" || tg == "h4" || tg == "h5" || tg == "h6"):
						if ( !isEltInListItemScope( ["h1", "h2", "h3", "h4", "h5", "h6"] ) )
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							genImpliedEndTags();
							if ( currentNode().nodeName.toLowerCase() != tg )
							{
								//TODO parse error
							}
							var i = stack.length - 1; var found = false;
							//while ( i-- >= 0 && !found )
							while ( i >= 0 && !found )
							{
								if ( Lambda.exists(["h1", "h2", "h3", "h4", "h5", "h6"], function(e) { return stack[i].nodeName.toLowerCase() == e; } ) )
								{
									found = true;
								}
								stack.pop();
								i--;
							}
						}
					case START_TAG( "a", _, _ ):
						var i : Int = lafe.length - 1;
						//while ( i-- >= 0 ) doesn't work on Neko (i-- is done after the test)
						while ( i >= 0 && !Lambda.has( scopeMarkersList(), lafe[i].e.nodeName.toLowerCase() ) )
						{
							if ( lafe[i].e.nodeName.toLowerCase() == "a" )
							{
								var fe = lafe[i];
								//TODO parse error
								processToken( END_TAG("a", false, new Map()) );
								if ( fe.e.nodeName.toLowerCase() == "a" ) // check if still there
								{
									lafe.remove( fe );
									stack.remove( cast fe.e );
								}
								i = 0; // quit the loop
							}
							i--;
						}
						reconstructActiveFormattingElements();
						lafe.push( { e:insertHTMLElement( t ), t:t } );
					case START_TAG("b",_,_)|START_TAG("big",_,_)|START_TAG("code",_,_)|START_TAG("em",_,_)|START_TAG("font",_,_)|START_TAG("i",_,_)|START_TAG("s",_,_)|START_TAG("small",_,_)|START_TAG("strike",_,_)|START_TAG("strong",_,_)|START_TAG("tt",_,_)|START_TAG("u",_,_):
						reconstructActiveFormattingElements();
						lafe.push( { e:insertHTMLElement( t ), t:t } );
					case START_TAG("nobr", _, _):
						reconstructActiveFormattingElements();
						if ( isEltInScope( ["nobr"] ) )
						{
							//TODO parse error
							processToken( END_TAG("nobr", false, new Map()) );
							reconstructActiveFormattingElements();
						}
						lafe.push( { e:insertHTMLElement( t ), t:t } );
					case END_TAG(tg,_,_) if(tg=="a"||tg=="b"||tg=="big"||tg=="code"||tg=="em"||tg=="font"||tg=="i"||tg=="nobr"||tg=="s"||tg=="small"||tg=="strike"||tg=="strong"||tg=="tt"||tg=="u"):
						var oc = 0;
						while ( oc < 8 )
						{
							oc++;
							var fe : ActiveFormattingElt = null;
							var fei = lafe.length - 1;
							//while ( fe == null && fei-- >= 0 && !Lambda.has( scopeMarkersList(), lafe[fei].e.nodeName.toLowerCase()) )
							while ( fe == null && fei >= 0 && !Lambda.has( scopeMarkersList(), lafe[fei].e.nodeName.toLowerCase()) )
							{
								if ( lafe[fei].e.nodeName.toLowerCase() == tg )
								{
									fe = lafe[fei];
								}
								fei--;
							}
							//If there is no such node, then abort these steps and instead act as described in the "any other end tag" entry below.
							if ( fe == null )
							{
								return processToken( END_TAG("sarcasm",false,new Map()) );
							}
							//if there is such a node, but that node is not in the stack of open elements, then this is a parse error; remove the 
							//element from the list, and abort these steps.
							if ( !Lambda.has(stack, cast fe.e ) )
							{
								//TODO parse error
								lafe.remove(fe);
								return VOID;
							}
							//if there is such a node, and that node is also in the stack of open elements, but the element is not in scope, then 
							//this is a parse error; ignore the token, and abort these steps.
							if ( !isEltInScope( [tg] ) )
							{
								//TODO parse error
								return IGNORED;
							}
							//If the element is not the current node
							if ( fe.e != currentNode() )
							{
								//TODO parse error
							}
							//Let the furthest block be the topmost node in the stack of open elements that is lower in the stack than the formatting element,
							//and is an element in the special category. There might not be one.
							var fb : Element = null;
							var fbi = Lambda.indexOf( stack, cast fe.e ) + 1;
							//while ( fbi++ < stack.length && fb == null ) // doesn't work on Neko
							while ( fbi < stack.length && fb == null )
							{
								if ( Lambda.has(specials(), stack[fbi].nodeName.toLowerCase()) )
								{
									fb = stack[fbi];
								}
								fbi++;
							}
							// If there is no furthest block, then the UA must first pop all the nodes from the bottom of the stack of open elements, from the 
							// current node up to and including the formatting element, then remove the formatting element from the list of active formatting 
							// elements, and finally abort these steps.
							if ( fb == null )
							{
								stack = stack.slice(0, Lambda.indexOf( stack, cast fe.e ));
								lafe.remove(fe);
								return VOID;
							}
							//Let the common ancestor be the element immediately above the formatting element in the stack of open elements.
							var ca : Element = stack[Lambda.indexOf( stack, cast fe.e ) - 1];
							//Let a bookmark note the position of the formatting element in the list of active formatting elements relative to 
							//the elements on either side of it in the list.
							var bm = lafe[ Lambda.indexOf(lafe,fe)-1 ]; // choose the previous afe in lafe to bm position
							//Let node and last node be the furthest block.
							var n = fb, ln = fb;
							var ic = 0;
							while ( ic < 3 )
							{
								ic++;
								//Let node be the element immediately above node in the stack of open elements, or if node is no longer in the stack of open elements 
								//(e.g. because it got removed by the next step), the element that was immediately above node in the stack of open elements before node was removed.
								var ni = Lambda.indexOf(stack, n);
								n = stack[ni - 1];
								//If node is not in the list of active formatting elements,
								if ( !Lambda.exists(lafe, function(e) { return e.e == n; } ) )
								{
									//then remove node from the stack of open elements and then go back to the step labeled inner loop.
									stack.remove(n);
									n = stack[ni]; // necessary for "n = stack[ni - 1];" to work at next iteration
								}
								else
								{
									//if node is the formatting element, 
									if ( n == fe.e )
									{
										//then go to the next step in the overall algorithm.
										break;
									}
									//Create an element for the token for which the element node was created, replace the entry for node in the list of active formatting 
									//elements with an entry for the new element, replace the entry for node in the stack of open elements with an entry for the new element, 
									//and let node be the new element.
									var li = lafe.length - 1;
									var found = false;
									//while (!found && li-- >= 0) Doesn't work on Neko
									while (!found && li >= 0)
									{
										if (lafe[li].e == n)
										{
											var e = createElement( lafe[li].t );
											lafe[li] = { e:e, t:lafe[li].t };
											stack[ ni -1 ] = e; // n is at ni - 1
											n = e;
											found = true;
										}
										li--;
									}
									//If last node is the furthest block, then move the aforementioned bookmark to be immediately after the new node in the list of active formatting elements.
									if (fb == ln)
									{
										bm = lafe[li+1];
									}
									//Insert last node into node, first removing it from its previous parent node if any.
									ln.parentNode.removeChild(ln);
									n.appendChild(ln);
									ln = n;
								}
							}
							//If the common ancestor node is a table, tbody, tfoot, thead, or tr element,
							if ( Lambda.has(["table", "tbody", "tfoot", "thead", "tr"], ca.nodeName.toLowerCase()) )
							{
								//foster parent whatever last node ended up being in the previous step, first removing it from its previous parent node if any.
								fosterParent( ln );
							}
							else
							{
								//append whatever last node ended up being in the previous step to the common ancestor node, first removing it from its previous parent node if any.
								if (ln.parentNode!=null) ln.parentNode.removeChild(ln);
								ca.appendChild(ln);
							}
							//Create an element for the token for which the formatting element was created.
							var e : Node = createElement( fe.t );
							//Take all of the child nodes of the furthest block and append them to the element created in the last step.
							for (c in fb.childNodes)
							{
								fb.removeChild(c);
								e.appendChild(c);
							}
							//Append that new element to the furthest block.
							fb.appendChild(e);
							//Remove the formatting element from the list of active formatting elements,
							lafe.remove(fe);
							//and insert the new element into the list of active formatting elements at the position of the aforementioned bookmark.
							lafe.insert( Lambda.indexOf(lafe,bm), {e:e,t:fe.t} );
							//Remove the formatting element from the stack of open elements,
							stack.remove( cast fe.e );
							//and insert the new element into the stack of open elements immediately below the position of the furthest block in that stack.
							stack.insert( Lambda.indexOf(stack,fb)+1, cast e );
						}
						//Note: Because of the way this algorithm causes elements to change parents, it has been dubbed the "adoption agency algorithm" 
						//(in contrast with other possible algorithms for dealing with misnested content, which included the "incest algorithm", the 
						//"secret affair algorithm", and the "Heisenberg algorithm").
					case START_TAG( "applet", _, _ )|START_TAG( "marquee", _, _ )|START_TAG( "object", _, _ ):
						reconstructActiveFormattingElements();
						var e = insertHTMLElement( t );
						//Insert a marker at the end of the list of active formatting elements.
						lafe.push( { e:e, t:t } );
						framesetOK = false;
					case END_TAG( tg, _, _ ) if (tg == "applet" || tg == "marquee" || tg == "object"):
						if (!isEltInScope( [tg] ))
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							genImpliedEndTags();
							if (currentNode().nodeName.toLowerCase() != tg)
							{
								//TODO parse error
							}
							while ( stack.length > 0 )
							{
								if (stack.pop().nodeName.toLowerCase() == tg)
								{
									break;
								}
							}
							clearLafeUntilLastMarker();
						}
					case START_TAG( "table", _, _ ):
						if ( !qm.equals(QUIRKS) && isEltInButtonScope(["p"]) )
						{
							processToken( END_TAG( "p", false, new Map() ) );
						}
						insertHTMLElement( t );
						framesetOK = false;
						im = IN_TABLE;
					case START_TAG("area",sc,_)|START_TAG("br",sc,_)|START_TAG("embed",sc,_)|START_TAG("img",sc,_)|START_TAG("keygen",sc,_)|START_TAG("wbr",sc,_):
						reconstructActiveFormattingElements();
						insertHTMLElement( t );
						stack.pop();
						if ( sc )
						{
							ack = true;
						}
						framesetOK = false;
					case START_TAG("param",sc,_)|START_TAG("source",sc,_)|START_TAG("track",sc,_):
						insertHTMLElement( t );
						stack.pop();
						if ( sc )
						{
							ack = true;
						}
					case START_TAG( "hr", sc, _ ):
						if ( isEltInButtonScope(["p"]) )
						{
							processToken( END_TAG("p", false, new Map()) );
						}
						insertHTMLElement( t );
						stack.pop();
						if ( sc )
						{
							ack = true;
						}
						framesetOK = false;
					case START_TAG( "image", sc, attrs ):
						//TODO parse error
						processToken( START_TAG( "img", sc, attrs ) );
					case START_TAG( "isindex", sc, attrs ):
						//TODO parse error
						//If the form element pointer is not null, then ignore the token.
						if (fp == null)
						{
							if ( sc )
							{
								ack = true;
							}
							processToken( START_TAG( "form", false, new Map() ) );
							//If the token has an attribute called "action", set the action attribute on the resulting form element 
							//to the value of the "action" attribute of the token.
							if (attrs.get("action") != null)
							{
								fp.setAttribute("action", attrs.get("action"));
							}
							processToken( START_TAG( "hr", false, new Map() ) );
							processToken( START_TAG( "label", false, new Map() ) );
							//Act as if a stream of character tokens had been seen (see below for what they should say).
							var str = attrs.get("prompt") == null ? isindexStr : attrs.get("prompt");
							for(i in 0...str.length)
							{
								processToken( CHAR( str.charCodeAt(i) ) );
							}
							processToken( START_TAG( "label", false, new Map() ) );
							//Act as if a start tag token with the tag name "input" had been seen, with all the attributes from the "isindex" 
							//token except "name", "action", and "prompt". Set the name attribute of the resulting input element to the value "isindex".
							var inAttrs = attrs;
							inAttrs.remove("name");
							inAttrs.remove("action");
							inAttrs.remove("prompt");
							inAttrs.set("name", "isindex");
							processToken( START_TAG( "input", false, inAttrs ) );
							// Act as if a stream of character tokens had been seen (see below for what they should say).
							for(i in 0...str.length)
							{
								processToken( CHAR( str.charCodeAt(i) ) );
							}
							processToken( END_TAG( "label", false, new Map() ) );
							processToken( START_TAG( "hr", false, new Map() ) );
							processToken( END_TAG( "form", false, new Map() ) );
						}
					case START_TAG( "textarea", _, _ ):
						//Insert an HTML element for the token.
						insertHTMLElement( t );
						//TODO If the next token is a "LF" (U+000A) character token, then ignore that token and move on to the next one. 
						//(Newlines at the start of textarea elements are ignored as an authoring convenience.)
						
						//Switch the tokenizer to the RCDATA state.
						tok.switchState( RCDATA );
						//Let the original insertion mode be the current insertion mode.
						om = im;
						//Set the frameset-ok flag to "not ok".
						framesetOK = false;
						//Switch the insertion mode to "text".
						im = TEXT;
					case START_TAG( "xmp", _, _ ):
						if (isEltInButtonScope(["p"]))
						{
							processToken(END_TAG("p", false, new Map()));
						}
						reconstructActiveFormattingElements();
						framesetOK = false;
						//Follow the generic raw text element parsing algorithm.
						parseRawText( t );
					case START_TAG( "iframe", _, _ ):
						framesetOK = false;
						parseRawText( t );
					case START_TAG( "noembed", _, _ ):
					//TODO case START_TAG( "noscript", _, _ ) // if the scripting flag is enabled:
						parseRawText( t );
					case START_TAG( "select", _, _ ):
						reconstructActiveFormattingElements();
						insertHTMLElement( t );
						framesetOK = false;
						if ( Lambda.exists([IN_TABLE,IN_CAPTION,IN_TABLE_BODY,IN_ROW,IN_CELL], function(m:InsertionMode) { return m.equals(im); } ) )
						{
							im = IN_SELECT_IN_TABLE;
						}
						else
						{
							im = IN_SELECT;
						}
					case START_TAG( "optgroup", _, _ ) | START_TAG( "option", _, _ ):
						if ( currentNode().nodeName.toLowerCase() == "option" )
						{
							processToken(END_TAG("option", false, new Map()));
						}
						reconstructActiveFormattingElements();
						insertHTMLElement( t );
					case START_TAG( "rp", _, _ ) | START_TAG( "rt", _, _ ):
						if ( isEltInScope(["ruby"]) )
						{
							genImpliedEndTags();
							if ( currentNode().nodeName.toLowerCase() != "ruby" )
							{
								//TODO parse error
							}
						}
						insertHTMLElement( t );	
					case END_TAG( "br", _, _ ):
						//TODO parse error
						processToken( START_TAG( "br", false, new Map() ) );
						return IGNORED;
					case START_TAG( "math", sc, _ ):
						reconstructActiveFormattingElements();
						//TODO Adjust MathML attributes for the token. (This fixes the case of MathML attributes that are not all lowercase.)
						
						//TODO Adjust foreign attributes for the token. (This fixes the use of namespaced attributes, in particular XLink.)
						
						//TODO Insert a foreign element for the token, in the MathML namespace.
						
						//If the token has its self-closing flag set, pop the current node off the stack of open elements and acknowledge the token's self-closing flag.
						if ( sc )
						{
							stack.pop();
							ack = true;
						}
					case START_TAG( "svg", sc, _ ):
						reconstructActiveFormattingElements();
						//TODO Adjust SVG attributes for the token. (This fixes the case of SVG attributes that are not all lowercase.)
						
						//TODO Adjust foreign attributes for the token. (This fixes the use of namespaced attributes, in particular XLink in SVG.)
						
						//TODO Insert a foreign element for the token, in the SVG namespace.
						
						//If the token has its self-closing flag set, pop the current node off the stack of open elements and acknowledge the token's self-closing flag.
						if ( sc )
						{
							stack.pop();
							ack = true;
						}
					case START_TAG( tg, _, _ ) if ( Lambda.has(["caption", "col", "colgroup", "frame", "head", "tbody", "td", "tfoot", "th", "thead", "tr"], tg) ):
						//TODO parse error
						return IGNORED;
					case START_TAG(_, _, _):
						reconstructActiveFormattingElements();
						insertHTMLElement( t );
						//note: This element will be an ordinary element.
					case END_TAG(tg, _, _):
						var n = currentNode();
						while (true)
						{
							if ( tg == n.nodeName.toLowerCase() )
							{
								genImpliedEndTags( [tg] );
								if ( currentNode().nodeName.toLowerCase() != tg )
								{
									//TODO parse error
								}
								//Pop all the nodes from the current node up to node, including node, then stop these steps.
								stack = stack.slice(0, Lambda.indexOf(stack, n));
								return VOID;
							}
							else if (Lambda.has(specials(),n.nodeName.toLowerCase()))
							{
								//TODO parse error
								return IGNORED;
							}
							n = stack[ Lambda.indexOf(stack,cast n) - 1 ];
						}
				}
			case TEXT:
				switch (t)
				{
					case CHAR(_):
						insertChar( currentNode(), t );
						//Note: This can never be a U+0000 NULL character; the tokenizer converts those to U+FFFD REPLACEMENT CHARACTER characters.
					case EOF:
						//TODO parse error
						if (currentNode().nodeName.toLowerCase() == "script")
						{
							//TODO mark the script element as "already started".
						}
						stack.pop();
						im = om;
						processToken( t );
					case END_TAG( "script", _, _ ):
						//TODO Provide a stable state. @see http://www.w3.org/TR/html5/webappapis.html#provide-a-stable-state
						trace("WARNING: TEXT INSERTION MODE / END_TAG('script') NOT IMPLEMENTED !!!");
						var s = currentNode();
						stack.pop();
						im = om;
						
						//TODO TODO TODO TODO TODO TODO TODO TODO 
						
					case END_TAG( _, _, _ ):
						stack.pop();
						im = om;
					case _:
						throw "Error: unexpected Token: "+t.getName();
				}
			case IN_TABLE:
				switch (t)
				{
					case CHAR( _ ) if (Lambda.has(["table","tbody","tfoot","thead","tr"],currentNode().nodeName.toLowerCase())):
						ptct = new Array<Token>();
						om = im;
						im = IN_TABLE_TEXT;
						processToken( t );
					case COMMENT( d ):
						currentNode().appendChild( doc.createComment( d ) );
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case START_TAG( "caption", _, _ ):
						//Clear the stack back to a table context.
						clearStackBackToTableContext();
						//Insert a marker at the end of the list of active formatting elements.
						//Insert an HTML element for the token, then switch the insertion mode to "in caption".
						lafe.push({e:insertHTMLElement( t ), t:t});
						im = IN_CAPTION;
					case START_TAG( "colgroup", _, _ ):
						clearStackBackToTableContext();
						insertHTMLElement( t );
						im = IN_COLUMN_GROUP;
					case START_TAG( "col", _, _ ):
						processToken( START_TAG( "colgroup", false, new Map() ) );
						processToken( t );
					case START_TAG("tbody",_,_) | START_TAG("tfoot",_,_) | START_TAG("thead",_,_):
						clearStackBackToTableContext();
						insertHTMLElement( t );
						im = IN_TABLE_BODY;
					case START_TAG("td", _, _) | START_TAG("th", _, _) | START_TAG("tr", _, _):
						processToken( START_TAG("tbody",false,new Map()) );
						processToken( t );
					case START_TAG("table", _, _):
						//TODO parse error
						switch ( processToken( END_TAG("table", false, new Map()) ) )
						{
							case IGNORED:
								// nothing
							case _:
								//then, if that token wasn't ignored, reprocess the current token.
								processToken( t );
						}
						//Note: The fake end tag token here can only be ignored in the fragment case.
					case END_TAG( "table", _, _ ):
						if (!isEltInTableScope(["table"]))
						{
							//TODO parse error
							return IGNORED;
						}
						//Pop elements from this stack until a table element has been popped from the stack.
						while (stack.pop().nodeName.toLowerCase() != "table") { }
						//Reset the insertion mode appropriately.
						resetInsertionMode();
					case END_TAG(tg, _, _) if (Lambda.has(["body", "caption", "col", "colgroup", "html", "tbody", "td", "tfoot", "th", "thead", "tr"],tg)):
						//TODO parse error
						return IGNORED;
					case START_TAG("style", _, _) | START_TAG("script", _, _):
						processToken( t, IN_HEAD);
					case START_TAG("input", sc, attrs) if( attrs.get("type") != null && attrs.get("type") != "hidden" ):
						//TODO parse error
						insertHTMLElement( t );
						stack.pop();
						if ( sc )
						{
							ack = true;
						}
					case START_TAG("form", _, _):
						//TODO parse error
						if (fp != null)
						{
							fp = insertHTMLElement( t );
							stack.pop();
						}
					case EOF:
						//If the current node is not the root html element, then this is a parse error.
						//Note: The current node can only be the root html element in the fragment case.
						if (currentNode().nodeName.toLowerCase() != "html")
						{
							//TODO parse error
						}
						stopParsing();
					case _:
						//TODO parse error
						processToken( t, IN_BODY); // FIXME
						//TODO except that whenever a node would be inserted into the current node when the current node is a table, tbody, tfoot, thead, or tr element, 
						//then it must instead be foster parented.
				}
			case IN_TABLE_TEXT:
				switch (t)
				{
					case CHAR( 0 ):
						//TODO parse error
						return IGNORED;
					case CHAR( _ ):
						ptct.push( t );
					case _:
						//If any of the tokens in the pending table character tokens list are character tokens that are not space characters, 
						if (Lambda.exists( ptct, function(ct) { return !isSpaceChar(ct); } ))
						{
							//TODO reprocess the character tokens in the pending table character tokens list using the rules given in the 
							//"anything else" entry in the "in table" insertion mode. => create a ANYTHING ELSE TOKEN and a use rules entry in processToken ?
						}
						else
						{
							//Otherwise, insert the characters given by the pending table character tokens list into the current node.
							for (ct in ptct)
							{
								insertChar(currentNode(),ct);
							}
							//Switch the insertion mode to the original insertion mode and reprocess the token.
							im = om;
							processToken(t);
						}
				}
			case IN_CAPTION:
				switch (t)
				{
					case END_TAG( "caption", _, _ ):
						 //TODO this is fragment case
						//if (!isEltInTableScope("caption"))
						//{
							//TODO parse error
							//return IGNORED;
						//}
						//else
						//{
							genImpliedEndTags();
							if (currentNode().nodeName.toLowerCase() == "caption")
							{
								//TODO parse error
							}
							//Pop elements from this stack until a caption element has been popped from the stack.
							while (stack.pop().nodeName.toLowerCase() != "caption") { }
							clearLafeUntilLastMarker();
							im = IN_TABLE;
						//}
					case START_TAG("caption",_,_)|START_TAG("col",_,_)|START_TAG("colgroup",_,_)|START_TAG("tbody",_,_)|START_TAG("td",_,_)|START_TAG("tfoot",_,_)|START_TAG("th",_,_)|START_TAG("thead",_,_)|START_TAG("tr",_,_)|END_TAG("table",_,_):
						//TODO parse error
						//Act as if an end tag with the tag name "caption" had been seen,
						switch ( processToken( END_TAG("caption",false,new Map()) ) )
						{
							case IGNORED:
								// nothing
							case _:
								//then, if that token wasn't ignored, reprocess the current token.
								processToken( t );
						}
						
					case END_TAG("body",_,_)|END_TAG("col",_,_)|END_TAG("colgroup",_,_)|END_TAG("html",_,_)|END_TAG("tbody",_,_)|END_TAG("td",_,_)|END_TAG("tfoot",_,_)|END_TAG("th",_,_)|END_TAG("thead",_,_)|END_TAG("tr",_,_):
						//TODO parse error
						return IGNORED;
					case _:
						processToken( t, IN_BODY );
				}
			case IN_COLUMN_GROUP:
				switch (t)
				{
					case CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20):
						insertChar(currentNode(), t);
					case COMMENT( d ):
						currentNode().appendChild(doc.createComment(d));
					case DOCTYPE(_,_,_,_):
						//TODO parse error
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY );
					case START_TAG( "col", sc, _ ):
						insertHTMLElement(t);
						stack.pop();
						if ( sc )
						{
							ack = true;
						}
					case END_TAG( "colgroup", _, _ ):
						//TODO If the current node is the root html element, then this is a parse error; ignore the token. (fragment case)
						stack.pop();
						im = IN_TABLE;
					case END_TAG( "col", _, _ ):
						//TODO parse error
						return IGNORED;
					//case EOF://TODO If the current node is the root html element, then stop parsing. (fragment case) Otherwise, act as described in the "anything else" entry below.
					case _:
						//Act as if an end tag with the tag name "colgroup" had been seen
						switch ( processToken( END_TAG( "col", false, new Map() ) ) )
						{
							case IGNORED:
								// nothing
							case _:
								// and then, if that token wasn't ignored, reprocess the current token.
								processToken( t );
						}
						//Note: The fake end tag token here can only be ignored in the fragment case.
				}
			case IN_TABLE_BODY:
				switch (t)
				{
					case START_TAG( "tr", _, _ ):
						clearStackBackToTableBodyContext();
						insertHTMLElement( t );
						im = IN_ROW;
					case START_TAG("th", _, _) | START_TAG("td", _, _):
						//TODO parse error
						processToken( START_TAG( "tr", false, new Map() ) );
						processToken( t );
					case END_TAG(tg, _, _) if(tg=="tbody"||tg=="tfoot"||tg=="thead"):
						if (!isEltInTableScope([tg]))
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							clearStackBackToTableBodyContext();
						}
						stack.pop();
						im = IN_TABLE;
					case START_TAG("caption",_,_)|START_TAG("col",_,_)|START_TAG("colgroup",_,_)|START_TAG("tbody",_,_)|START_TAG("tfoot",_,_)|START_TAG("thead",_,_)|END_TAG("table",_,_):
						// TODO If the stack of open elements does not have a tbody, thead, or tfoot element in table scope, this is a parse error. Ignore the token. (fragment case)
						clearStackBackToTableBodyContext();
						processToken( END_TAG( currentNode().nodeName.toLowerCase(), false, new Map() ) );
						processToken( t );
					case END_TAG("body", _, _) | END_TAG("caption", _, _) | END_TAG("col", _, _) | END_TAG("colgroup", _, _) | END_TAG("html", _, _) | END_TAG("td", _, _) | END_TAG("th", _, _) | END_TAG("tr", _, _):
						//TODO parse error
						return IGNORED;
					case _:
						processToken( t, IN_TABLE );
				}
			case IN_ROW:
				switch (t)
				{
					case START_TAG("th", _, _) | START_TAG("td", _, _):
						clearStackBackToTableRowContext();
						lafe.push({e:insertHTMLElement( t ),t:t});
						//Insert a marker at the end of the list of active formatting elements
						im = IN_CELL;
					case END_TAG( "tr", _, _ ):
						//TODO If the stack of open elements does not have an element in table scope with the same tag name as the token, 
						//this is a parse error. Ignore the token. (fragment case)
						clearStackBackToTableRowContext();
						stack.pop();
						im = IN_TABLE_BODY;
					case END_TAG(tg, _, _) if (tg == "tbody" || tg == "tfoot" || tg == "thead"):
						if (!isEltInTableScope([tg]))
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							processToken( END_TAG("tr", false, new Map()) );
							processToken( t );
						}
					case END_TAG(tg, _, _) if (tg == "body" || tg == "caption" || tg == "col" || tg == "colgroup" || tg == "html" || tg == "td" || tg == "th"):
						//TODO parse error
						return IGNORED;
					case _:
						processToken( t, IN_TABLE );
				}
			case IN_CELL:
				switch (t)
				{
					case END_TAG(tg, _, _) if(tg=="td"||tg=="th"):
						if (!isEltInTableScope([tg]))
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							genImpliedEndTags();
							if (currentNode().nodeName.toLowerCase() != tg)
							{
								//TODO parse error
							}
							while (stack.pop().nodeName.toLowerCase() != tg) { }
							clearLafeUntilLastMarker();
							im = IN_ROW;
						}
					case START_TAG("caption",_,_)|START_TAG("col",_,_)|START_TAG("colgroup",_,_)|START_TAG("tbody",_,_)|START_TAG("td",_,_)|START_TAG("tfoot",_,_)|START_TAG("th",_,_)|START_TAG("thead",_,_)|START_TAG("tr",_,_):
						//TODO If the stack of open elements does not have a td or th element in table scope, then this is a parse error; ignore the token. (fragment case)
						closeCell();
						processToken( t );
					case END_TAG("body",_,_)|END_TAG("caption",_,_)|END_TAG("col",_,_)|END_TAG("colgroup",_,_)|END_TAG("html",_,_):
						//TODO parse error
						return IGNORED;
					case END_TAG(tg, _, _) if (tg == "table" || tg == "tbody" || tg == "tfoot" || tg == "thead" || tg == "tr"):
						if (!isEltInTableScope([tg]))
						{
							//TODO parse error
							return IGNORED;
						}
						else
						{
							closeCell();
							processToken( t );
						}
					case _:
						processToken( t, IN_BODY );
				}
			case IN_SELECT:
				switch (t)
				{
					case CHAR( 0 ):
						//TODO parse error
						return IGNORED;
					case CHAR( _ ):
						insertChar( currentNode(), t );
					case COMMENT( d ):
						currentNode().appendChild( doc.createComment( d ) );
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY );
					case START_TAG( "option", _, _ ):
						if ( currentNode().nodeName.toLowerCase() == "caption" )
						{
							processToken( END_TAG( "caption", false, new Map() ) );
						}
						insertHTMLElement( t );
					case START_TAG( "optgroup", _, _ ):
						if ( currentNode().nodeName.toLowerCase() == "option" )
						{
							processToken( END_TAG( "option", false, new Map() ) );
						}
						if ( currentNode().nodeName.toLowerCase() == "optgroup" )
						{
							processToken( END_TAG( "optgroup", false, new Map() ) );
						}
						insertHTMLElement( t );
					case END_TAG( "optgroup", _, _ ):
						if ( currentNode().nodeName.toLowerCase() == "option" && stack[stack.length-2].nodeName.toLowerCase() == "optgroup" )
						{
							processToken( END_TAG( "option", false, new Map() ) );
						}
						if ( currentNode().nodeName.toLowerCase() == "optgroup" )
						{
							stack.pop();
							//TODO parse error
							return IGNORED;
						}
					case END_TAG( "option", _, _ ):
						if ( currentNode().nodeName.toLowerCase() == "option" )
						{
							stack.pop();
						}
						else
						{
							//TODO parse error
							return IGNORED;
						}
					case END_TAG( "select", _, _ ):
						//TODO If the stack of open elements does not have an element in select scope with the same tag name as the token, this is a parse error. 
						//Ignore the token. (fragment case)
						//if (!isEltInSelectScope("select"))
						//{
							//TODO parse error
							//return IGNORED;
						//}
						//else
						//{
							while ( stack.pop().nodeName.toLowerCase() != "select" ) { }
							resetInsertionMode();
						//}
					case START_TAG("select", sc, attrs):
						//TODO parse error
						processToken( END_TAG( "select", sc, attrs ) );
					case START_TAG("input", _, _) | START_TAG("keygen", _, _) | START_TAG("textarea", _, _):
						//TODO parse error
						//TODO If the stack of open elements does not have a select element in select scope, ignore the token. (fragment case)
						//else
						processToken( END_TAG( "select", false, new Map() ) );
						processToken( t );
					case START_TAG( "script", _, _ ):
						processToken( t, IN_HEAD );
					case EOF:
						if ( currentNode() != stack [0] ) //If the current node is not the root html element,
						{
							//TODO parse error
						}
						stopParsing();
					case _:
						//TODO parse error
				}
			case IN_SELECT_IN_TABLE:
				switch (t)
				{
					case START_TAG("caption",_,_)|START_TAG("table",_,_)|START_TAG("tbody",_,_)|START_TAG("tfoot",_,_)|START_TAG("thead",_,_)|START_TAG("tr",_,_)|START_TAG("td",_,_)|START_TAG("th",_,_):
						//TODO parse error
						processToken( END_TAG( "select", false, new Map() ) );
						processToken( t );
					case END_TAG(tg,_,_) if(tg=="caption" || tg=="table" || tg=="tbody" || tg=="tfoot" || tg=="thead" || tg=="tr" || tg=="td" || tg=="th"):
						//TODO parse error
						if (isEltInTableScope([tg]))
						{
							processToken( END_TAG( "select", false, new Map() ) );
						}
						else
						{
							return IGNORED;
						}
					case _:
						processToken( t, IN_SELECT );
				}
			case AFTER_BODY:
				switch (t)
				{
					case CHAR( 0x9 ) | CHAR( 0xA ) | CHAR( 0xC ) | CHAR( 0xD ) | CHAR( 0x20 ) :
						processToken( t, IN_BODY );
					case COMMENT( d ):
						stack[0].appendChild( doc.createComment(d) );
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY );
					case END_TAG("html",_,_):
						//TODO If the parser was originally created as part of the HTML fragment parsing algorithm, this is a parse error; ignore the token. (fragment case)
						//else
						//{
							im = AFTER_AFTER_BODY;
						//}
					case EOF:
						stopParsing();
					case _:
						//TODO parse error
						im = IN_BODY;
						processToken(t);
				}
			case IN_FRAMESET:
				switch (t)
				{
					case CHAR( 0x9 ) | CHAR( 0xA ) | CHAR( 0xC ) | CHAR( 0xD ) | CHAR( 0x20 ) :
						insertChar( currentNode(), t );
					case COMMENT( d ):
						currentNode().appendChild( doc.createComment(d) );
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY );
					case START_TAG( "frameset", _, _ ):
						insertHTMLElement( t );
					case END_TAG( "frameset", _, _ ):
						//TODO If the current node is the root html element, then this is a parse error; ignore the token. (fragment case)
						//else
						stack.pop();
						//TODO If the parser was not originally created as part of the HTML fragment parsing algorithm (fragment case), 
						//and the current node is no longer a frameset element, then switch the insertion mode to "after frameset".
						if (currentNode().nodeName.toLowerCase() != "frameset")
						{
							im = AFTER_FRAMESET;
						}
					case START_TAG( "frame", sc, _ ):
						insertHTMLElement( t );
						stack.pop();
						if ( sc )
						{
							ack = true;
						}
					case START_TAG( "noframes", _, _ ):
						processToken( t, IN_HEAD );
					case EOF:
						if (currentNode() != stack[0])
						{
							//TODO parse error
						}
						stopParsing();
					case _:
						//TODO parse error
						return IGNORED;
				}
			case AFTER_FRAMESET:
				switch (t)
				{
					case CHAR( 0x9 ) | CHAR( 0xA ) | CHAR( 0xC ) | CHAR( 0xD ) | CHAR( 0x20 ) :
						insertChar( currentNode(), t );
					case COMMENT( d ):
						currentNode().appendChild( doc.createComment(d) );
					case DOCTYPE( _, _, _, _ ):
						//TODO parse error
						return IGNORED;
					case START_TAG( "html", _, _ ):
						processToken( t, IN_BODY );
					case END_TAG( "html", _, _ ):
						im = AFTER_AFTER_FRAMESET;
					case START_TAG( "noframes", _, _ ):
						processToken( t, IN_HEAD );
					case EOF:
						stopParsing();
					case _:
						//TODO parse error
						return IGNORED;
				}
			case AFTER_AFTER_BODY:
				switch (t)
				{
					case COMMENT( d ):
						doc.appendChild( doc.createComment(d) );
					case DOCTYPE(_,_,_,_)|CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20)|START_TAG("html",_,_):
						processToken( t, IN_BODY );
					case EOF:
						stopParsing();
					case _:
						//TODO parse error
						im = IN_BODY;
						processToken( t );
				}
			case AFTER_AFTER_FRAMESET:
				switch (t)
				{
					case COMMENT( d ):
						doc.appendChild(doc.createComment(d));
					case DOCTYPE(_,_,_,_)|CHAR(0x9)|CHAR(0xA)|CHAR(0xC)|CHAR(0xD)|CHAR(0x20)|START_TAG("html",_,_):
						processToken( t, IN_BODY );
					case EOF:
						stopParsing();
					case START_TAG( "noframes", _, _ ):
						processToken( t, IN_HEAD );
					case _:
						//TODO parse error
						return IGNORED;
				}
		}
		//@see http://www.w3.org/TR/html5/syntax.html#acknowledge-self-closing-flag
		switch ( t )
		{
			case START_TAG(_, sc, _):
				if (sc && !ack)
				{
					//TODO parse error
				}
			case _:
				//nothing
		}
		return VOID;
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#stop-parsing
	 */
	@:access(dominos.dom.Document)
	function stopParsing() : Void
	{
		//Set the current document readiness to "interactive"
		doc.readyState = "interactive";
		//TODO  and the insertion point to undefined.

		//Pop all the nodes off the stack of open elements.

		//TODO If the list of scripts that will execute when the document has finished parsing is not empty, run these substeps:

			//Spin the event loop until the first script in the list of scripts that will execute when the document has finished parsing has its 
			//"ready to be parser-executed" flag set and the parser's Document has no style sheet that is blocking scripts.

			//Execute the first script in the list of scripts that will execute when the document has finished parsing.

			//Remove the first script element from the list of scripts that will execute when the document has finished parsing (i.e. shift out the first entry in the list).

			//If the list of scripts that will execute when the document has finished parsing is still not empty, repeat these substeps again from substep 1.

		//Queue a task to fire a simple event that bubbles named DOMContentLoaded at the Document.

		//Spin the event loop until the set of scripts that will execute as soon as possible and the list of scripts that will execute in order as soon as possible are empty.

		//Spin the event loop until there is nothing that delays the load event in the Document.

		//Queue a task to run the following substeps:

			//Set the current document readiness to "complete".

			//If the Document is in a browsing context, fire a simple event named load at the Document's Window object, but with its target set to the Document object 
			//(and the currentTarget set to the Window object).

		//If the Document is in a browsing context, then queue a task to run the following substeps:

			//If the Document's page showing flag is true, then abort this task (i.e. don't fire the event below).

			//Set the Document's page showing flag to true.

			//Fire a pageshow event at the Window object of the Document, but with its target set to the Document object (and the currentTarget set to the Window object), 
			//using the PageTransitionEvent interface, with the persisted attribute initialized to false. This event must not bubble, must not be cancelable, and has no default action.

		//If the Document has any pending application cache download process tasks, then queue each such task in the order they were added to the list of pending application cache 
		//download process tasks, and then empty the list of pending application cache download process tasks. The task source for these tasks is the networking task source.

		//If the Document's print when loaded flag is set, then run the printing steps.

		//The Document is now ready for post-load tasks.

		//Queue a task to mark the Document as completely loaded.
		doc.readyState = "complete";
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#reset-the-insertion-mode-appropriately
	 */
	function resetInsertionMode() : Void
	{
		var l = false;
		var n = currentNode();
		do
		{
			// TODO If node is the first node in the stack of open elements, then set last to true and set node to the context element. (fragment case)
			//if (n == stack[0])
			//{
				//l = true;
				//
			//}
			// TODO If node is a select element, then switch the insertion mode to "in select" and abort these steps. (fragment case)
			//if ()
			//{
				//
			//}
			//If node is a td or th element and last is false, then switch the insertion mode to "in cell" and abort these steps.
			if (!l && (n.nodeName.toLowerCase() == "td" || n.nodeName.toLowerCase() == "th"))
			{
				im = IN_CELL;
				return;
			}
			//If node is a tr element, then switch the insertion mode to "in row" and abort these steps.
			if (n.nodeName.toLowerCase() == "tr")
			{
				im = IN_ROW;
				return;
			}
			//If node is a tbody, thead, or tfoot element, then switch the insertion mode to "in table body" and abort these steps.
			if (n.nodeName.toLowerCase() == "tbody" || n.nodeName.toLowerCase() == "thead" || n.nodeName.toLowerCase() == "tfoot")
			{
				im = IN_TABLE_BODY;
				return;
			}
			//If node is a caption element, then switch the insertion mode to "in caption" and abort these steps.
			if (n.nodeName.toLowerCase() == "caption")
			{
				im = IN_CAPTION;
			}
			// TODO If node is a colgroup element, then switch the insertion mode to "in column group" and abort these steps. (fragment case)
			//if ()
			//{
				//
			//}
			//If node is a table element, then switch the insertion mode to "in table" and abort these steps.
			if (n.nodeName.toLowerCase() == "table")
			{
				im = IN_TABLE;
				return;
			}
			// TODO If node is a head element, then switch the insertion mode to "in body" ("in body"! not "in head"!) and abort these steps. (fragment case)
			//if ()
			//{
				//
			//}
			//If node is a body element, then switch the insertion mode to "in body" and abort these steps.
			if (n.nodeName.toLowerCase() == "body")
			{
				im = IN_BODY;
				return;
			}
			// TODO If node is a frameset element, then switch the insertion mode to "in frameset" and abort these steps. (fragment case)
			//if ()
			//{
				//
			//}
			// TODO If node is an html element, then switch the insertion mode to "before head" Then, abort these steps. (fragment case)
			//if ()
			//{
				//
			//}
			// TODO If last is true, then switch the insertion mode to "in body" and abort these steps. (fragment case)
			//if ()
			//{
				//
			//}
			//Let node now be the node before node in the stack of open elements.
			n = stack[ Lambda.indexOf( stack, cast n ) - 1 ];
		} while (true);
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#close-the-cell
	 */
	function closeCell() : Void
	{
		//Note: The stack of open elements cannot have both a td and a th element in table scope at the same time, 
		//nor can it have neither when the close the cell algorithm is invoked.
		if (isEltInTableScope(["td"]))
		{
			processToken( END_TAG( "td", false, new Map() ) );
		}
		else // has a th element in table scope
		{
			processToken( END_TAG( "th", false, new Map() ) );
		}
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#clear-the-stack-back-to-a-table-row-context
	 */
	function clearStackBackToTableRowContext() : Void
	{
		while (currentNode().nodeName.toLowerCase() != "html" && currentNode().nodeName.toLowerCase() != "tr")
		{
			stack.pop();
		}
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#clear-the-stack-back-to-a-table-body-context
	 */
	function clearStackBackToTableBodyContext() : Void
	{
		while (currentNode().nodeName.toLowerCase() != "html" && currentNode().nodeName.toLowerCase() != "thead" && currentNode().nodeName.toLowerCase() != "tbody" && currentNode().nodeName.toLowerCase() != "tfoot")
		{
			stack.pop();
		}
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#clear-the-stack-back-to-a-table-context
	 * Note: The current node being an html element after this process is a fragment case.
	 */
	function clearStackBackToTableContext() : Void
	{
		while (currentNode().nodeName.toLowerCase() != "html" && currentNode().nodeName.toLowerCase() != "table")
		{
			stack.pop();
		}
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#clear-the-list-of-active-formatting-elements-up-to-the-last-marker
	 */
	function clearLafeUntilLastMarker() : Void
	{
		while ( lafe.length > 0 )
		{
			if ( Lambda.has( scopeMarkersList(), lafe.pop().e.nodeName.toLowerCase() ) )
			{
				return;
			}
		}
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#foster-parent
	 */
	function fosterParent( e : Element ) : Void
	{
		e.parentNode.removeChild(e);
		var i = stack.length - 1;
		var f : Element = null;
		while ( i >= 0 && f == null )
		{
			if (stack[i].nodeName.toLowerCase() == "table")
			{
				if (stack[i].parentNode==null || stack[i].parentNode.nodeType!=Node.ELEMENT_NODE)
				{
					f = stack[i - 1];
				}
				else
				{
					f = stack[i];
					f.parentNode.insertBefore(e, f);
					return;
				}
			}
			i--;
		}
		if (f == null)
		{
			f = stack[0];
		}
		f.parentNode.appendChild(e);
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#generate-implied-end-tags
	 */
	function genImpliedEndTags( ?exclude : Array<String> = null ) : Void
	{
		var list : Array<String> = ["dd", "dt", "li", "option", "optgroup", "p", "rp", "rt"];
		if (exclude != null)
		{
			for (e in exclude)
			{
				list.remove(e);
			}
		}
		if ( Lambda.exists(list, function(e) { return e == currentNode().nodeName.toLowerCase(); }) )
		{
			stack.pop();
		}
	}
	/**
	 * 
	 * @param	eltTagName
	 * @param	list
	 * @return
	 */
	function isEltInSpecificScope ( eltTagNames : Array<String>, list : Array<String> ) : Bool
	{
		var i = stack.length - 1;
		while ( i > 0 )
		{// trace( "stack[i].nodeName= "+stack[i].nodeName.toLowerCase() ); trace( "eltTagNames= "+eltTagNames ); trace( "list= "+list );
			if ( Lambda.exists( eltTagNames, function(e) { return e == stack[i].nodeName.toLowerCase(); }) ) // FIXME temp fix toLowerCase() but here might be something cleaner
			{
				return true;
			}
			if ( Lambda.exists( list, function(e) { return stack[i].nodeName.toLowerCase() == e; } ) ) // FIXME temp fix toLowerCase() but here might be something cleaner
			{
				return false;
			}
			i--;
		}
		return false;
	}
	/**
	 * 
	 * @param	eltTagName
	 * @param	?additionnalList
	 * @return
	 */
	function isEltInScope ( eltTagNames : Array<String>, ?additionnalList : Array<String> = null ) : Bool
	{
		var list : Array<String> = ["applet", "caption", "html", "table", "td", "th", "marquee", "object", "mi", "mo", "mn", "ms", "mtext", "annotation-xml", "foreignObject", "desc", "title" ];
		
		if ( additionnalList != null )
		{
			list = list.concat( additionnalList );
		}
		return isEltInSpecificScope( eltTagNames, list );
	}
	/**
	 * 
	 * @param	eltTagName
	 * @return
	 */
	function isEltInListItemScope ( eltTagNames : Array<String> ) : Bool
	{
		return isEltInScope ( eltTagNames, ["ol","ul"] );
	}
	/**
	 * 
	 * @param	eltTagName
	 * @return
	 */
	function isEltInButtonScope ( eltTagNames : Array<String> ) : Bool
	{
		return isEltInScope ( eltTagNames, ["button"] );
	}
	/**
	 * 
	 * @param	eltTagName
	 * @return
	 */
	function isEltInTableScope ( eltTagNames : Array<String> ) : Bool
	{
		return isEltInSpecificScope ( eltTagNames, ["html","table"] );
	}
	/**
	 * 
	 * @param	eltTagName
	 * @return
	 */
	function isEltInSelectScope ( eltTagNames : Array<String> ) : Bool
	{
		return isEltInSpecificScope ( eltTagNames, ["optgroup","option"] );
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#reconstruct-the-active-formatting-elements
	 */
	function reconstructActiveFormattingElements() : Void
	{
		if ( Lambda.empty(lafe) )
			return;

		if ( Lambda.exists(stack, function(e) { return lafe[lafe.length - 1].e == e; } ) || 
				Lambda.exists(scopeMarkersList(), function(e) { return lafe[lafe.length - 1].e.nodeName.toLowerCase() == e; } ) )
			return;

		var ei : Int = 1;
		while ( lafe[0].e != lafe[lafe.length - ei].e )
		{
			ei++;

			if ( Lambda.exists(stack, function(e) { return lafe[lafe.length - ei].e == e; } ) || 
				Lambda.exists(scopeMarkersList(), function(e) { return lafe[lafe.length - ei].e.nodeName.toLowerCase() == e; } ) )
			{
				ei--; //step 7
				break;
			}
		}
		do
		{
			//Create an element for the token for which the element entry was created, to obtain new element.
			var ne = createElement( lafe[lafe.length - ei].t );
			//Append new element to the current node and push it onto the stack of open elements so that it is the new current node.
			currentNode().appendChild(ne);
			stack.push(ne);
			//Replace the entry for entry in the list with an entry for new element.
			lafe[lafe.length - ei] = { e:ne, t:lafe[lafe.length - ei].t };
			ei--;
		}
		while (ei >= 1); //If the entry for new element in the list of active formatting elements is not the last entry in the list, return to step 7.
	}
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#creating-and-inserting-elements
	 * FIXME create Elements implementing corresponding interface
	 */
	function createElement( t : Token ) : Element
	{
		switch (t)
		{
			case START_TAG( tagName, _, attrs):
				var e = doc.createElement(tagName);
				for ( att in attrs.keys() )
				{
					e.setAttribute( att, attrs.get(att) );
				}
				return e;
			case _:
				throw "ERROR cannot create an element for that token";
		}
	}
	/**
	 * 
	 * @param	t
	 * @see http://www.w3.org/TR/html5/syntax.html#generic-rcdata-element-parsing-algorithm
	 */
	function parseRawText( t : Token ) : Void
	{
		insertHTMLElement( t );
		tok.switchState( RAWTEXT );
		om = im;
		im = TEXT;
	}
	function parseRcdata( t : Token ) : Void
	{
		insertHTMLElement( t );
		tok.switchState( RCDATA );
		om = im;
		im = TEXT;
	}
	/**
	 * 
	 * @param	t
	 * @see http://www.w3.org/TR/html5/syntax.html#insert-an-html-element
	 */
	function insertHTMLElement( t : Token ) : Element
	{
		var e = createElement( t );
		currentNode().appendChild( e );
		stack.push( e );
		return e;
	}
	/**
	 * 
	 * @return
	 * @see http://www.w3.org/TR/html5/syntax.html#current-node
	 */
	function currentNode() : Element
	{
		return stack[stack.length - 1];
	}
	/**
	 * 
	 * @param	node
	 * @param	c
	 * @see http://www.w3.org/TR/html5/syntax.html#insert-a-character
	 */
	function insertChar( node : Node, ct : Token ) : Void
	{
		var tn : Text;
		if ( !node.hasChildNodes() || node.lastChild.nodeType != Node.TEXT_NODE )
		{
			tn = doc.createTextNode( "" );
			node.appendChild(tn);
		}
		else
		{
			tn = cast node.lastChild;
		}
		switch(ct)
		{
			case CHAR(c):
				tn.appendData( String.fromCharCode( c ) );// trace(String.fromCharCode(c));
			case _:
				throw "Error: CHAR token expected";
		}
	}
	/**
	 * @see http://www.w3.org/TR/html5/infrastructure.html#space-character
	 */
	function isSpaceChar( ct : Token )
	{
		switch (ct)
		{
			case CHAR(c) if( c == 0x20 || c == 0x9 || c == 0xA || c == 0xC || c == 0xD ):
				return true;
			case CHAR(_):
				return false;
			case _:
				throw "Error: CHAR token expected";
		}
	}
}