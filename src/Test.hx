package ;

/**
 * ...
 * @author Thomas Fétiveau
 */
class Test
{

	static public function main() 
	{
		#if neko
			//Dominos.parse(sys.io.File.getContent("../bin/test.html"), "text/html");
			trace();
		#else
			//trace("launching...");
			//var file : flash.filesystem.File = flash.filesystem.File.applicationDirectory.resolvePath("test.html");
			//var file : flash.filesystem.File = flash.filesystem.File.applicationStorageDirectory;
			//trace( file.type + "  " + file.size );
			//trace( file.name );
			/*
			 * var fileStream : flash.filesystem.FileStream = new flash.filesystem.FileStream();
			fileStream.open(file, flash.filesystem.FileMode.READ);
			var str : String = fileStream.readUTFBytes( Std.int(file.size) );
			fileStream.close();
			*/
			//var str = "<!DOCTYPE html>
//<html lang=\"en-US\" dir=\"ltr\" id=\"developer-mozilla-org\" xmlns:fb=\"http://www.facebook.com/2008/fbml\" xmlns:og=\"http://ogp.me/ns#\">
//<head>
  //<title>Document Object Model (DOM) | MDN</title>
//</head>
//<body>
//<p>Bonjour!</p>
//</body>
//</html>";
//
			//Dominos.parse(str, "text/html");
		#end
		trace('&'.code);
	}
	
}