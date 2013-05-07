package dominos.parser;

import dominos.parser.html.InputStream;
import dominos.parser.html.Tokenizer;
import dominos.parser.html.TreeBuilder;

import dominos.dom.Document;
import dominos.dom.Element;

/**
 * ...
 * @author Thomas Fétiveau
 */
class HTMLParser
{
	static public function parse( data : String ) : Document
	{
		//var tokenizer = new Tokenizer( new InputStream( haxe.io.Bytes.ofString( data ) ) );
		var tb = new TreeBuilder( new Tokenizer( new InputStream( data ) ) );
		var domDoc = tb.parse();
		trace("parsing finished");
		trace("serialized result: "+domDoc);
	}

	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#concept-frag-parse-context
	 */
	static public function parseFragment( input : String, ?context : Element = null )
	{
		//TODO
	}
}