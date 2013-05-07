package ;

import dominos.parser.HTMLParser;

/**
 * ...
 * @author Thomas Fétiveau
 */
class Dominos
{

	static public function parse( str : String, mime : String ) 
	{
		if (mime != "text/html")
		{
			throw "Mime type "+mime+" not supported!";
		}
		var doc = HTMLParser.parse( str );
	}
}