package dominos.dom;

import dominos.parser.HTMLParser;

/**
 * @see http://domparsing.spec.whatwg.org/#the-domparser-interface
 * 
 * @author Thomas Fétiveau
 */
class DOMParser
{
	//enum SupportedType
	//{
	  //"text/html",
	  //"text/xml",
	  //"application/xml",
	  //"application/xhtml+xml",
	  //"image/svg+xml"
	//};
	static public inline var TEXT_HTML_TYPE : String = "text/html";
	static public inline var TEXT_XML_TYPE : String = "text/xml";
	static public inline var APPLICATION_XML_TYPE : String = "application/xml";
	static public inline var APPLICATION_XHTML_TYPE : String = "application/xhtml+xml";
	static public inline var IMAGE_SVG_TYPE : String = "image/svg+xml";

	/**
	 * The DOMParser() constructor must return a new DOMParser object. 
	 */
	public function new() { }
	
	//Document parseFromString(DOMString str, SupportedType type);
	public function parseFromString( str : String, contentType : String ) : Document
	{
		switch ( contentType )
		{
			case TEXT_HTML_TYPE:
				return HTMLParser.parse( str );
				//TODO The scripting flag must be set to "disabled". 
				
				//Note: meta elements are not taken into account for the encoding used, as a Unicode stream is passed into the parser.
				//Note: script elements get marked unexecutable and the contents of noscript get parsed as markup. 
			case TEXT_XML_TYPE, APPLICATION_XML_TYPE, APPLICATION_XHTML_TYPE, IMAGE_SVG_TYPE:
				//TODO
				throw "Error: XML parsing not implemented yet. Use haxe.xml.Parser instead.";
			default:
				throw "Error: unknown content type!";
		}
	}
}