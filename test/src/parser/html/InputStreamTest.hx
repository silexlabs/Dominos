package parser.html;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

import dominos.parser.html.InputStream;

/**
 * ...
 * @author Thomas Fétiveau
 */
class InputStreamTest
{
	public static function main() {
        var runner = new Runner();
        runner.addCase(new InputStreamTest());
        Report.create(runner);
        runner.run();
    }
	
	public function new() {}
	
	public function testNextCharRef()
	{
		var is : InputStream = new InputStream( "Colone" );
		var r = is.nextCharRef();
		Assert.equals([-2], r);
		
		is = new InputStream( "Colone;" );
		r = is.nextCharRef();
		Assert.equals([0x2A74], r);
		
		is = new InputStream( "rien" );
		r = is.nextCharRef();
		Assert.equals([-2], r);
		
		is = new InputStream( "dfg56dfgd4;" );
		r = is.nextCharRef();
		Assert.equals([-2], r);
		
		is = new InputStream( "j djz jzjkld zdke" );
		r = is.nextCharRef();
		Assert.equals([-2], r);
		
		is = new InputStream( "Atilde" );
		r = is.nextCharRef();
		Assert.equals([0xC3], r);
		
		is = new InputStream( "" );
		r = is.nextCharRef();
		Assert.equals([-2], r);
		
		is = new InputStream( "#xCCCCCC;" );
		r = is.nextCharRef();
		Assert.equals([-2], r);
	}
	
}
