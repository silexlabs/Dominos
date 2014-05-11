package dominos.test.dom;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

import dominos.dom.DOMParser;
import dominos.dom.Document;
import dominos.dom.Element;

import dominos.parser.HTMLSerializer;

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

	public function testParseHtmlFragment()
	{
		trace("*** TESTING HTML FRAGMENT PARSING ***");
		var docStr : String = "<html><head><title></title></head><body><h1>heading</h1><p id='ih'></p><p id='re' class='toto'>paragraph</p><body></html>";
		var dp : DOMParser = new DOMParser();
		var doc : Document = dp.parseFromString(docStr, DOMParser.TEXT_HTML_TYPE);
		trace(HTMLSerializer.serialize(doc));
		Assert.notNull( doc );
		//dumpNode(doc);

		var ip : Element = doc.getElementById("ih");
		ip.innerHTML = "<span>Dominos is</span> <i>SO</i> <b>COOL</b>!";

		//dumpNode(doc);
		trace(HTMLSerializer.serialize(doc));

		trace("ip outerHTML is:");
		trace(ip.outerHTML);
		ip.outerHTML = "<div><p>Very</p> <span>Cool!</span></div>";
		//dumpNode(doc);
		trace(HTMLSerializer.serialize(doc));
	}
/*
	public function testParseSimpleHtml()
	{
		trace("*** TESTING SIMPLE HTML PARSING ***");
		var docStr : String = "<html><head><title></title></head><body><h1>heading</h1><p>paragraph</p><body></html>";
		var dp : DOMParser = new DOMParser();
		var doc : Document = dp.parseFromString( docStr, DOMParser.TEXT_HTML_TYPE );
		trace(HTMLSerializer.serialize(doc));
		Assert.notNull( doc );
		dumpNode(doc);
	}

	public function testParseRemotePage()
	{
		trace("*** TESTING REMOTE HTML PAGE PARSING ***");
		var url : String = "http://www.w3.org/TR/html5/Overview.html#contents";
		var docStr: String = haxe.Http.requestUrl( url );
		
		var dp : DOMParser = new DOMParser();
		var doc : Document = dp.parseFromString( docStr, DOMParser.TEXT_HTML_TYPE );
		trace(HTMLSerializer.serialize(doc));
		Assert.notNull( doc );
		dumpNode(doc);
	}
*/
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