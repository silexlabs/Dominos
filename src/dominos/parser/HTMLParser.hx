package dominos.parser;

import dominos.parser.html.InputStream;
import dominos.parser.html.Tokenizer;

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

	static public function parseFragment()
	{
		
	}
}