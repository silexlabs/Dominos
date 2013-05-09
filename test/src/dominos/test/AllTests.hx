package dominos.test;

import dominos.test.dom.DOMParserTests;
import dominos.test.html.InputStreamTests;

/**
 * ...
 * @author Thomas Fétiveau
 */
class AllTests
{
	public static function main()
	{
        var runner = new Runner();
        runner.addCase(new InputStreamTests());
        runner.addCase(new DOMParserTests());
        Report.create(runner);
        runner.run();
    }
	
}