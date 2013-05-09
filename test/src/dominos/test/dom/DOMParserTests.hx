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
	}
}