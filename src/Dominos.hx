package ;

/**
 * ...
 * @author Thomas Fétiveau
 */
class Dominos
{

	static public function parse( str:String, mime:String ) 
	{
		if (mime != "text/html")
		{
			throw "Mime type "+mime+" not supported!";
		}
		
	}
}