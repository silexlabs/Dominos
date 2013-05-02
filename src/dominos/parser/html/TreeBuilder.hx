package dominos.parser.html;

import dominos.dom.Document;
import dominos.dom.DOMImplementation;
import dominos.dom.Element;
import dominos.dom.Node;
import dominos.parser.html.Tokenizer;

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
 * The TreeBuilder class handles the <a href="http://www.w3.org/TR/html5/syntax.html#tree-construction">Tree Construction</a> 
 * steps of the HTML parsing algorithm.
 * 
 * @author Thomas Fétiveau
 */
class TreeBuilder
{
	/**
	 * CONSTANTS
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
	 * The stack of open elements
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-stack-of-open-elements
	 */
	private var stack : Array<Node>;
	
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#list-of-active-formatting-elements
	 */
	private var activeFormatting : Map<Node, Node>;
	
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
	 * @see http://www.w3.org/TR/html5/syntax.html#other-parsing-state-flags
	 */
	private var scriptingEnabled : Bool;
	/**
	 * The frameset-ok flag is set to "ok" when the parser is created. It is set to "not ok" 
	 * after certain tokens are seen.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#other-parsing-state-flags
	 */
	private var framesetOK : Bool;

	public function new() 
	{
		dom = new DOMImplementation();
		doc = dom.createHTMLDocument();
	}
	
	/**
	 * The current node is the bottommost node in this stack.
	 */
	public getCurrentNode() : Node
	{
		
	}
	/**
	 * The current table is the last table element in the stack of open elements, 
	 * if there is one. If there is no table element in the stack of open elements 
	 * (fragment case), then the current table is the first element in the stack of 
	 * open elements (the html element).
	 */
	public getCurrentTable : Node
	{
		
	}
	
	/**
	 * Process a HTML token.
	 * @param
	 * @param ?utrf	The "using the rules for" parameter.
	 * @see http://www.w3.org/TR/html5/syntax.html#using-the-rules-for
	 */
	public function processToken( t : Token, ?utrf : InsertionMode = null )
	{
		// @see http://www.w3.org/TR/html5/syntax.html#using-the-rules-for
		var m = utrf != null && Lambda.exists([IN_HEAD, IN_BODY, IN_TABLE, IN_SELECT], function(v:InsertionMode) { return Type.enumEq(utrf, v); } ) ? utrf : im;
		switch ( m )
		{
			case INITIAL:
				switch ( t )
				{
					case CHAR(c) if(c == 0x9 || c == 0xA || c == 0xC || c == 0xD || c == 0x20): // CHARACTER TABULATION, "LF", "FF", "CR" or SPACE
						//Ignore the token.
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
						doc.appendChild( dom.createDocumentType( name != null ? name : "", publicId != null ? publicId : "", systemId != null ? systemId : "" ) );
						//TODO And associate it with the Document object
						
						if ( forceQuirks || name != "html" || 
							publicId != null && (Lambda.exists(getPublicIdsStartWith(), function(pi:String) { return publicId.toLowerCase().indexOf(pi.toLowerCase()) == 0; } ) || Lambda.exists(["-//W3O//DTD W3 HTML Strict 3.0//EN//", "-/W3C/DTD HTML 4.0 Transitional/EN", "HTML"], function(pi:String) { return pi.toLowerCase() == publicId.toLowerCase(); } )) || 
							systemId.toLowerCase() == "http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd" ||
							systemId == null && (publicId!=null && Lambda.exists( ["-//W3C//DTD HTML 4.01 Frameset//", "-//W3C//DTD HTML 4.01 Transitional//"], function(pi:String){ return publicId.toLowerCase().indexOf(pi.toLowerCase()) == 0; } )) )
						{
							//TODO set the Document to quirks mode
						}
						else if ( publicId != null && 
							(Lambda.exists(["-//W3C//DTD XHTML 1.0 Frameset//", "-//W3C//DTD XHTML 1.0 Transitional//"], function(pi:String) { return publicId.indexOf(pi) == 0; } ) || 
							systemId != null && Lambda.exists(["-//W3C//DTD HTML 4.01 Frameset//", "-//W3C//DTD HTML 4.01 Transitional//"], function(pi:String) { return publicId.indexOf(pi) == 0; } ) ) )
						{
							//TODO set the Document to limited-quirks mode
						}
						im = BEFORE_HTML;
					case _:
						//TODO
						//If the document is not an iframe srcdoc document, then this is a parse error; set the Document to quirks mode.
						//In any case, switch the insertion mode to "before html", then reprocess the current token.
						//@see Document.compatMode
						//@see http://www.w3.org/TR/html5/embedded-content-0.html#an-iframe-srcdoc-document
				}
			case BEFORE_HTML:
				switch ( t )
				{
					case DOCTYPE( name, publicId, systemId, forceQuirks ):
						//TODO parse error
						//ignore the token
					case COMMENT(d):
						doc.appendChild(doc.createComment(d));
					case CHAR( c ) if (c == 0x9 || c == 0xA || c == 0xC || c == 0xD || c == 0x20):
						// ignore the token
					case START_TAG( tagName, selfClosing, attrs ) if (tagName == "html"):
						var e = doc.createElement( tagName );
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
					case END_TAG( tagName, selfClosing, attrs ) if (tagName!="head" && tagName!="body" && tagName!="html" && tagName!="br"):
						//TODO parse error
						//ignore the token
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
					case CHAR( c ) if (c == 0x9 || c == 0xA || c == 0xC || c == 0xD || c == 0x20):
						//ignore the token
					case COMMENT(d):
						stack[stack.length-1].appendChild(doc.createComment(d));
					case DOCTYPE( name, publicId, systemId, forceQuirks ):
						//TODO parse error
						//ignore the token
					case START_TAG( tagName, selfClosing, attrs ) if (tagName == "html"):
						processToken( t, IN_BODY);
					case START_TAG( tagName, selfClosing, attrs ) if (tagName == "head"):
						var e = doc.createElement( tagName );
						stack[stack.length-1].appendChild( e );
						stack.push( e );
						// Set the head element pointer to the newly created head element.
						hp = e;
						im = IN_HEAD;
					case END_TAG( tagName, selfClosing, attrs ) if (tagName!="head" && tagName!="body" && tagName!="html" && tagName!="br"):
						//TODO parse error
						//ignore the token
					case _:
						// Act as if a start tag token with the tag name "head" and no attributes had been seen
						var e = doc.createElement( "head" );
						stack[stack.length-1].appendChild( e );
						stack.push( e );
						// Set the head element pointer to the newly created head element.
						hp = e;
						im = IN_HEAD;
						//then reprocess the current token
						processToken( t );
				}
			case IN_HEAD:
			case IN_HEAD_NOSCRIPT:
			case AFTER_HEAD:
			case IN_BODY:
			case TEXT:
			case IN_TABLE:
			case IN_TABLE_TEXT:
			case IN_CAPTION:
			case IN_COLUMN_GROUP:
			case IN_TABLE_BODY:
			case IN_ROW:
			case IN_CELL:
			case IN_SELECT:
			case IN_SELECT_IN_TABLE:
			case AFTER_BODY:
			case IN_FRAMESET:
			case AFTER_FRAMESET:
			case AFTER_AFTER_BODY:
			case AFTER_AFTER_FRAMESET:
		}
	}
}