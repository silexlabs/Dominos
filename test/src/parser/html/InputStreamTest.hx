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
		Assert.same([-2], r);
		
		is = new InputStream( "Colone;" );
		r = is.nextCharRef();
		Assert.same([0x2A74], r);
		
		is = new InputStream( "rien" );
		r = is.nextCharRef();
		Assert.same([-2], r);
		
		is = new InputStream( "dfg56dfgd4;" );
		r = is.nextCharRef();
		Assert.same([-2], r);
		
		is = new InputStream( "j djz jzjkld zdke" );
		r = is.nextCharRef();
		Assert.same([-2], r);
		
		is = new InputStream( "Atilde" );
		r = is.nextCharRef();
		Assert.same([0xC3], r);
		
		is = new InputStream( "" );
		r = is.nextCharRef();
		Assert.same([-2], r);
		
		is = new InputStream( "#xCCCCCC;" );
		r = is.nextCharRef();
		Assert.same([0xFFFD], r);
	}
	
	public function testConsumeUntilString()
	{
		var is : InputStream = new InputStream( "blablabla ]]>" );
		var r = is.consumeUntilString("]]>");
		Assert.same([0x62, 0x6C, 0x61, 0x62, 0x6C, 0x61, 0x62, 0x6C, 0x61, 0x20], r);
		Assert.equals( '>'.code, is.currentInputChar() );
		
		var is : InputStream = new InputStream( "blablabla ]]> blablabla" );
		var r = is.consumeUntilString("]]>");
		Assert.same([0x62, 0x6C, 0x61, 0x62, 0x6C, 0x61, 0x62, 0x6C, 0x61, 0x20], r);
		Assert.equals( '>'.code, is.currentInputChar() );
		
		var is : InputStream = new InputStream( "tra" );
		var r = is.consumeUntilString("]]>");
		Assert.same([0x74, 0x72, 0x61], r);
		Assert.equals( -1, is.currentInputChar() );
		
		var is : InputStream = new InputStream( "" );
		var r = is.consumeUntilString("]]>");
		Assert.same([], r);
		Assert.equals( -1, is.currentInputChar() );
	}
	
}
