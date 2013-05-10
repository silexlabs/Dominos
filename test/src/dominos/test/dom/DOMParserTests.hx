package dominos.test.dom;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

import dominos.dom.DOMParser;
import dominos.dom.Document;
import dominos.html.HTMLSerializer;

/**
 * ...
 * @author Thomas Fétiveau
 */
class DOMParserTests
{
	public static function main()
	{
        var runner = new Runner();
        runner.addCase(new DOMParserTests());
        Report.create(runner);
        runner.run();
    }
	
	public function new() { }

	public function testParseSimpleHtml()
	{
		var docStr : String = "<html><head><title></title></head><body><h1>heading</h1><p>paragraph</p><body></html>";
		var dp : DOMParser = new DOMParser();
		var doc : Document = dp.parseFromString( docStr, DOMParser.TEXT_HTML_TYPE );
		trace(HTMLSerializer.serialize(doc));
		Assert.notNull( doc );
		dumpNode(doc);
	}

	public function testParseRemotePage()
	{
		var url : String = "http://www.w3.org/TR/html5/Overview.html#contents";
		var docStr: String = haxe.Http.requestUrl( url );
		
		var dp : DOMParser = new DOMParser();
		var doc : Document = dp.parseFromString( docStr, DOMParser.TEXT_HTML_TYPE );
		trace(HTMLSerializer.serialize(doc));
		Assert.notNull( doc );
		dumpNode(doc);
	}
	
	static public function dumpNode( n : dominos.dom.Node, ?i : Int = 0 ) : Void
	{
		var indent : StringBuf = new StringBuf(); for ( y in 0...i) { indent.addChar( 0x20 ); }
		trace(  indent.toString() + n.nodeName );
		for (nc in n.childNodes)
		{
			dumpNode( nc, i + 1 );
		}
	}
}