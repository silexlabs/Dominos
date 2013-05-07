package dominos.parser;

import dominos.parser.html.InputStream;
import dominos.parser.html.Tokenizer;

import dominos.dom.Element;

/**
 * ...
 * @author Thomas Fétiveau
 */
class HTMLParser
{
	static public function parse( data : String )
	{
		//var tokenizer = new Tokenizer( new InputStream( haxe.io.Bytes.ofString( data ) ) );
		var tokenizer = new Tokenizer( new InputStream( data ) );
		var domDoc = tokenizer.parse();
		trace("parsing finished");
	}

	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#concept-frag-parse-context
	 */
	static public function parseFragment( input : String, ?context : Element = null )
	{
		//TODO
	}
}