/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.parser.html;

import dominos.dom.Document;

/**
 * Manage the current tag accross the different states.
 */
class CurrentTagHelper
{
	var n : String;
	var sc : Bool;
	var attrs : Map<String,String>;
	var can : Null<String>;
	var cav : Null<String>;
	var e : Bool;
	var lst : String;
	public function new()
	{
		lst = null;
	}
	public function nextTag( s : String, ?isEnd : Bool = false ):Void
	{
		n = s;
		e = isEnd;
		sc = false;
		attrs = new Map<String, String>();
		can = null;
		cav = null;
	}
	public function nextAttr( s : String ):Void
	{
		if (can != null)
		{
			attrs.set(can, cav);
		}
		can = s;
		cav = "";
	}
	public function appendToName( s : String ):Void
	{
		n += s;
	}
	public function appendToAttrName( s : String ):Void
	{
		can += s;
	}
	public function appendToAttrValue( s : String ):Void
	{
		cav += s;
	}
	public function isAppropriate():Bool
	{
		if ( lst != null && n == lst )
		{
			return true;
		}
		return false;
	}
	public function setSelfClosing():Void
	{
		sc = true;
	}
	public function generateToken():Token
	{
		if (can != null)
		{
			attrs.set(can, cav);
		}
		if (e)
		{
			return END_TAG( n, sc, attrs );
		}
		else
		{
			lst = n;
			return START_TAG( n, sc, attrs );
		}
	}
}
/**
 * 
 */
class CurrentCommentHelper
{
	var d : String;
	public function new() {}
	public function nextComment( s : String ):Void
	{
		d = s;
	}
	public function appendToData( s : String ):Void
	{
		d += s;
	}
	public function generateToken():Token
	{
		return COMMENT( d );
	}
}
/**
 * 
 */
class CurrentDoctypeHelper
{
	var n : String;
	var pid : String;
	var sid : String;
	var fq : Bool;
	public function new() {}
	public function nextDoctype( s : String ):Void
	{
		n = s;
		pid = null;
		sid = null;
		fq = false;
	}
	public function appendToName( s : String ):Void
	{
		n += s;
	}
	public function appendToPid( s : String ):Void
	{
		if (pid == null)
			pid = s;
		else
			pid += s;
	}
	public function appendToSid( s : String ):Void
	{
		if (sid == null)
			sid = s;
		else
			sid += s;
	}
	public function setForceQuirk():Void
	{
		fq = true;
	}
	public function generateToken():Token
	{
		return DOCTYPE( n, pid, sid, fq );
	}
}
  
/**
 * The Tokenizer class handles the tokenization of the HTML document.
 * 
 * @see http://www.w3.org/TR/html5/syntax.html#tokenization
 * 
 * @author Thomas Fétiveau
 */
class Tokenizer
{
	/**
	 * The associated Input Stream
	 */
	private var is : InputStream;
	/**
	 * The associated Tree Builder
	 */
	// private var tb : TreeBuilder;

	/**
	 * Builds a new Tokenizer for a given Input Stream, which ends up in building a new Tree Builder.
	 */
	public function new( is : InputStream ) 
	{
		this.is = is;
		//this.tb = new TreeBuilder( is, this );
	}


	///
	// API
	//

	/**
	 * Current Tokenizer state
	 */
	public var state (default, default) : State;

	public dynamic function onNewToken(t : Token) : Void { }


	///
	// INTERNALS
	//

	/**
	 * Parse the document.
	 */
	public function parse() : Void
	{
		state = DATA;
		
		var c : Int = 0; // avoids the compiler to complain about not initialized var. This initial value will never be used.

		var currentTag = new CurrentTagHelper();
		
		var currentComment = new CurrentCommentHelper();
		
		var currentDoctype = new CurrentDoctypeHelper();

		var tempBuffer : StringBuf = null;
		
		while ( state != null )
		{ //trace("tokenizer state= "+state.getName());
			switch (state)
			{
				case DATA:
					c = is.nextInputChar();

					switch(c)
					{
						case '&'.code:
							state = CHARACTER_REFERENCE_IN_DATA;
						case '<'.code:
							state = TAG_OPEN;
						case 0: // NULL char
							//TODO Parse error.
							onNewToken( CHAR( c ) );
						case -1: //EOF
							onNewToken( EOF );
							state = null;
						default:
							onNewToken( CHAR( c ) );
					}
				case CHARACTER_REFERENCE_IN_DATA:
					state = DATA;
					
					var cr : Array<Int> = is.nextCharRef(); //Attempt to consume a character reference, with no additional allowed character.

					if ( cr[0] == -2 ) // nothing returned
					{
						onNewToken( CHAR( '&'.code ) );
					}
					else
					{
						for (cri in cr)
						{
							onNewToken( CHAR( cri ) );
						}
					}
				case RCDATA:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '&'.code:
							state = CHARACTER_REFERENCE_IN_RCDATA;
						case '<'.code:
							state = RCDATA_LESS_THAN_SIGN;
						case 0:
							//TODO Parse error.
							
							onNewToken( CHAR( 0xFFFD ) );
						case -1: //EOF
							onNewToken( EOF );
						case _:
							onNewToken( CHAR( c ) );
					}
				case CHARACTER_REFERENCE_IN_RCDATA:
					state = RCDATA;
					
					var cr : Array<Int> = is.nextCharRef();
					
					if ( cr[0] == -2 ) // nothing returned
					{
						onNewToken( CHAR('&'.code) );
					}
					else
					{
						for (cri in cr)
						{
							onNewToken( CHAR(cri) );
						}
					}
				case RAWTEXT:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '<'.code:
							state = RAWTEXT_LESS_THAN_SIGN;
						case 0:
							// TODO parse error
							
							onNewToken( CHAR(0xFFFD) );
						case -1: //EOF
							onNewToken( EOF );
						case _:
							onNewToken( CHAR( c ) );
					}
				case SCRIPT_DATA:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '<'.code:
							state = SCRIPT_DATA_LESS_THAN_SIGN;
						case 0:
							// TODO parse error
							
							onNewToken( CHAR(0xFFFD) );
						case -1: //EOF
							onNewToken( EOF );
						case _:
							onNewToken( CHAR( c ) );
					}
				case PLAINTEXT:
					c = is.nextInputChar();

					switch(c)
					{
						case 0:
							// TODO parse error
							
							onNewToken( CHAR(0xFFFD) );
						case -1:
							onNewToken( EOF );
						case _:
							onNewToken( CHAR( c ) );
					}
				case TAG_OPEN:
					c = is.nextInputChar();

					switch(c)
					{
						case '!'.code:
							state = MARKUP_DECLARATION_OPEN;
						case '/'.code:
							state = END_TAG_OPEN;
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							//currentStartTagName = String.fromCharCode( c + 0x20 ); // WIP
							currentTag.nextTag( String.fromCharCode( c + 0x20 ) );
							state = TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							//currentStartTagName = String.fromCharCode( c ); // WIP
							currentTag.nextTag( String.fromCharCode( c ) );
							state = TAG_NAME;
						case '?'.code:
							// TODO parse error
							state = BOGUS_COMMENT;
						case _:
							// TODO parse error
							state = DATA;
							onNewToken( CHAR('<'.code) );
							//Reconsume the current input character
							is.unconsume( 1 );
					}
				case END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							//currentEndTagName = String.fromCharCode( c + 0x20 ); // WIP
							currentTag.nextTag( String.fromCharCode( c + 0x20 ), true );
							state = TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							//currentEndTagName = String.fromCharCode( c ); // WIP
							currentTag.nextTag( String.fromCharCode( c ), true );
							state = TAG_NAME;
						case '>'.code:
							// TODO parse error
							state = DATA;
						case -1:
							// TODO parse error
							state = DATA;
							onNewToken( CHAR('<'.code) );
							onNewToken( CHAR('/'.code) );
							// Reconsume the EOF
							is.unconsume( 1 );
						case _:
							// TODO parse error
							state = BOGUS_COMMENT;
					}
				case TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code:
							state = SELF_CLOSING_START_TAG;
						case '>'.code:
							state = DATA;
							onNewToken(currentTag.generateToken());  // WIP
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentTag.appendToName( String.fromCharCode( c + 0x20 ) ); // WIP
						case 0:
							//TODO parse error
							currentTag.appendToName( String.fromCharCode( 0xFFFD ) ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character.
							is.unconsume( 1 );
						case _:
							currentTag.appendToName( String.fromCharCode( c ) ); // WIP
					}
				case RCDATA_LESS_THAN_SIGN:
					c = is.nextInputChar();

					switch(c)
					{
						case '/'.code:
							tempBuffer = new StringBuf();
							state = RCDATA_END_TAG_OPEN;
						case _:
							state = RCDATA;
							onNewToken( CHAR( '<'.code ) );
							//Reconsume the current input character
							is.unconsume( 1 );
					}
				case RCDATA_END_TAG_OPEN:
					c = is.nextInputChar();

					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentTag.nextTag( String.fromCharCode( c + 0x20 ), true); // WIP
							tempBuffer.addChar( c );
							state = RCDATA_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentTag.nextTag( String.fromCharCode( c ), true); // WIP
							tempBuffer.addChar( c );
							state = RCDATA_END_TAG_NAME;
						case _:
							state = RCDATA;
							onNewToken( CHAR( '<'.code ) );
							onNewToken( CHAR( '/'.code ) );
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case RCDATA_END_TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if ( currentTag.isAppropriate() ):
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code if ( currentTag.isAppropriate() ):
							state = SELF_CLOSING_START_TAG;
						case '>'.code if ( currentTag.isAppropriate() ):
							state = DATA;
							onNewToken( currentTag.generateToken() );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current tag token's tag name.
							currentTag.appendToName( String.fromCharCode( c + 0x20 )); // WIP
							tempBuffer.addChar( c );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							// Append the current input character to the current tag token's tag name.
							currentTag.appendToName( String.fromCharCode( c )); // WIP
							tempBuffer.addChar( c );
						case _:
							state = RCDATA;
							onNewToken( CHAR( '>'.code ) );
							onNewToken( CHAR( '/'.code ) );
							var tcs : String = tempBuffer.toString();
							for (tci in 0...tcs.length)
							{
								onNewToken( CHAR( tcs.charCodeAt(tci) ) );
							}
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case RAWTEXT_LESS_THAN_SIGN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '/'.code:
							tempBuffer = new StringBuf();
							state = RAWTEXT_END_TAG_OPEN;
						case _:
							state = RAWTEXT;
							onNewToken( CHAR('<'.code) );
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case RAWTEXT_END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentTag.nextTag( String.fromCharCode( c + 0x20 ), true ); // WIP
							tempBuffer.add(c);
							state = RAWTEXT_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentTag.nextTag( String.fromCharCode( c ), true ); // WIP
							tempBuffer.add(c);
							state = RAWTEXT_END_TAG_NAME;
						case _:
							state = RAWTEXT;
							onNewToken( CHAR('<'.code) );
							onNewToken( CHAR('/'.code) );
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case RAWTEXT_END_TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if( currentTag.isAppropriate() ):
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code if( currentTag.isAppropriate() ):
							state = SELF_CLOSING_START_TAG;
						case '>'.code if( currentTag.isAppropriate() ):
							state = DATA;
							onNewToken( currentTag.generateToken() );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current tag token's tag name
							currentTag.appendToName( String.fromCharCode( c + 0x20 ) ); // WIP
							tempBuffer.add( c );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							// Append the current input character to the current tag token's tag name
							currentTag.appendToName( String.fromCharCode( c ) ); // WIP
							tempBuffer.add( c );
						case _:
							state = RAWTEXT;
							onNewToken( CHAR('<'.code) );
							onNewToken( CHAR('/'.code) );
							var tcs : String = tempBuffer.toString();
							for (tci in 0...tcs.length)
							{
								onNewToken( CHAR( tcs.charCodeAt(tci) ) );
							}
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_LESS_THAN_SIGN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '/'.code:
							tempBuffer = new StringBuf();
							state = SCRIPT_DATA_END_TAG_OPEN;
						case '!'.code:
							state = SCRIPT_DATA_ESCAPE_START;
							onNewToken( CHAR( '<'.code ) );
							onNewToken( CHAR( '!'.code ) );
						case _:
							state = SCRIPT_DATA;
							onNewToken( CHAR( '<'.code ) );
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentTag.nextTag( String.fromCharCode( c + 0x20 ), true ); // WIP
							tempBuffer.add(c);
							state = SCRIPT_DATA_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentTag.nextTag( String.fromCharCode( c ), true ); // WIP
							tempBuffer.add(c);
							state = SCRIPT_DATA_END_TAG_NAME;
						case _:
							state = DATA;
							onNewToken( CHAR( '<'.code ) );
							onNewToken( CHAR( '/'.code ) );
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_END_TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if( currentTag.isAppropriate() ):
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code if( currentTag.isAppropriate() ):
							state = SELF_CLOSING_START_TAG;
						case '>'.code if( currentTag.isAppropriate() ):
							state = DATA;
							onNewToken( currentTag.generateToken() );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current tag token's tag name
							currentTag.appendToName( String.fromCharCode( c + 0x20 ) ); // WIP
							tempBuffer.add( c );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							// Append the current input character to the current tag token's tag name
							currentTag.appendToName( String.fromCharCode( c ) ); // WIP
							tempBuffer.add( c );
						case _:
							state = SCRIPT_DATA;
							onNewToken( CHAR('<'.code) );
							onNewToken( CHAR('/'.code) );
							var tcs : String = tempBuffer.toString();
							for (tci in 0...tcs.length)
							{
								onNewToken( CHAR( tcs.charCodeAt(tci) ) );
							}
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPE_START:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_ESCAPE_START_DASH;
							onNewToken( CHAR('-'.code) );
						case _:
							state = SCRIPT_DATA;
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPE_START_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_ESCAPED_DASH_DASH;
							onNewToken( CHAR('-'.code) );
						case _:
							state = SCRIPT_DATA;
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPED:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_ESCAPED_DASH;
							onNewToken( CHAR('-'.code) );
						case '<'.code:
							state = SCRIPT_DATA_ESCAPED_LESS_THAN_SIGN;
						case 0:
							//TODO parse error
							onNewToken( CHAR(0xFFFD) );
						case -1:
							state = DATA;
							//TODO parse error
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							onNewToken( CHAR( c ) );
					}
				case SCRIPT_DATA_ESCAPED_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_ESCAPED_DASH_DASH;
							onNewToken( CHAR('-'.code) );
						case '<'.code:
							state = SCRIPT_DATA_ESCAPED_LESS_THAN_SIGN;
						case 0:
							//TODO parse error
							state = SCRIPT_DATA_ESCAPED;
							onNewToken( CHAR(0xFFFD) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							onNewToken( CHAR( c ) );
					}
				case SCRIPT_DATA_ESCAPED_DASH_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							onNewToken( CHAR('-'.code) );
						case '<'.code:
							state = SCRIPT_DATA_ESCAPED_LESS_THAN_SIGN;
						case '>'.code:
							state = SCRIPT_DATA;
							onNewToken( CHAR('>'.code) );
						case 0:
							//TODO parse error
							state = SCRIPT_DATA_ESCAPED;
							onNewToken( CHAR(0xFFFD) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							onNewToken( CHAR( c ) );
					}
				case SCRIPT_DATA_ESCAPED_LESS_THAN_SIGN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '/'.code:
							tempBuffer = new StringBuf();
							state = SCRIPT_DATA_ESCAPED_END_TAG_OPEN;
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							tempBuffer = new StringBuf();
							tempBuffer.add( x + 0x20 );
							state = SCRIPT_DATA_DOUBLE_ESCAPE_START;
							onNewToken( CHAR( '<'.code ) );
							onNewToken( CHAR( c ) );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							tempBuffer = new StringBuf();
							tempBuffer.add( x );
							state = SCRIPT_DATA_DOUBLE_ESCAPE_START;
							onNewToken( CHAR( '<'.code ) );
							onNewToken( CHAR( c ) );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							onNewToken( CHAR( '<'.code ) );
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPED_END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentTag.nextTag( String.fromCharCode( c + 0x20 ), true ); // WIP
							tempBuffer.add( c );
							state = SCRIPT_DATA_ESCAPED_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentTag.nextTag( String.fromCharCode( c ), true ); // WIP
							tempBuffer.add( c );
							state = SCRIPT_DATA_ESCAPED_END_TAG_NAME;
						case _:
							state = SCRIPT_DATA_ESCAPED;
							onNewToken( CHAR( '<'.code ) );
							onNewToken( CHAR( '/'.code ) );
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPED_END_TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if( currentTag.isAppropriate() ):
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code if( currentTag.isAppropriate() ):
							state = SELF_CLOSING_START_TAG;
						case '>'.code if( currentTag.isAppropriate() ):
							state = DATA;
							onNewToken( currentTag.generateToken() );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current tag token's tag name
							currentTag.appendToName( String.fromCharCode( c + 0x20 ) );
							tempBuffer.add( c );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							// Append the current input character to the current tag token's tag name
							currentTag.appendToName( String.fromCharCode( c ) );
							tempBuffer.add( c );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							onNewToken( CHAR('<'.code) );
							onNewToken( CHAR('/'.code) );
							for (tc in tempBuffer.toString().split("")) // FIXME find something more efficient
							{
								onNewToken( CHAR( tc.charCodeAt(0) ) ); // FIXME find something more efficient
							}
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPE_START:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20, '/'.code, '>'.code:
							if (tempBuffer.toString() == "script")
								state = SCRIPT_DATA_DOUBLE_ESCAPED;
							else
								state = SCRIPT_DATA_ESCAPED;
							onNewToken( CHAR ( c ) );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							tempBuffer.add( c + 0x20 );
							onNewToken( CHAR ( c ) );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							tempBuffer.add( c );
							onNewToken( CHAR ( c ) );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPED:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_DASH;
							onNewToken( CHAR ( '-'.code ) );
						case '<'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN;
							onNewToken( CHAR ( '<'.code ) );
						case 0:
							//TODO parse error
							onNewToken( CHAR ( 0xFFFD ) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							onNewToken( CHAR ( c ) );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPED_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH;
							onNewToken( CHAR ( '-'.code ) );
						case '<'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN;
							onNewToken( CHAR ( '<'.code ) );
						case 0:
							//TODO parse error
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							onNewToken( CHAR ( 0xFFFD ) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							onNewToken( CHAR ( c ) );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							onNewToken( CHAR ( '-'.code ) );
						case '<'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN;
							onNewToken( CHAR ( '<'.code ) );
						case '>'.code:
							state = SCRIPT_DATA;
							onNewToken( CHAR ( '>'.code ) );
						case 0:
							//TODO parse error
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							onNewToken( CHAR ( 0xFFFD ) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							onNewToken( CHAR ( c ) );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '/'.code:
							tempBuffer = new StringBuf();
							state = SCRIPT_DATA_DOUBLE_ESCAPE_END;
							onNewToken( CHAR ( '/'.code ) );
						case _:
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPE_END:
					c = is.nextInputChar();
					
					switch( c )
					{
						case 0x9, 0xA, 0xC, 0x20, '/'.code, '>'.code:
							if (tempBuffer.toString() == "script")
								state = SCRIPT_DATA_ESCAPED;
							else
								state = SCRIPT_DATA_DOUBLE_ESCAPED;
							onNewToken( CHAR ( c ) );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							tempBuffer.add( c + 0x20 );
							onNewToken( CHAR ( c ) );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							tempBuffer.add( c );
							onNewToken( CHAR ( c ) );
						case _:
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							// Reconsume the current input character
							is.unconsume( 1 );
					}
				case BEFORE_ATTRIBUTE_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case '/'.code:
							state = SELF_CLOSING_START_TAG;
						case '>'.code:
							state = DATA;
							onNewToken( currentTag.generateToken() );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Start a new attribute in the current tag token. 
							// Set that attribute's name to the lowercase version of the current input character (add 0x0020 to the character's code point), 
							// and its value to the empty string
							currentTag.nextAttr( String.fromCharCode( c + 0x20) ); // WIP
							state = ATTRIBUTE_NAME;
						case 0:
							//TODO parse error
							
							// Start a new attribute in the current tag token. 
							// Set that attribute's name to a U+FFFD REPLACEMENT CHARACTER character, 
							// and its value to the empty string
							currentTag.nextAttr( String.fromCharCode( 0xFFFD ) ); // WIP
							state = ATTRIBUTE_NAME;
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							if (Lambda.has([0x22, 0x27, '<'.code, '='.code], c))// quotation mark, apostrophe, ...
							{
								//TODO parse error
							}
							//Start a new attribute in the current tag token. Set that attribute's name to the current input character, and its value to the empty string.
							currentTag.nextAttr( String.fromCharCode( c ) ); // WIP
							state = ATTRIBUTE_NAME;
					}
				case ATTRIBUTE_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = AFTER_ATTRIBUTE_NAME;
						case '/'.code:
							state = SELF_CLOSING_START_TAG;
						case '='.code:
							state = BEFORE_ATTRIBUTE_VALUE;
						case '>'.code:
							state = DATA;
							onNewToken( currentTag.generateToken() ); // WIP
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current attribute's name.
							currentTag.appendToAttrName( String.fromCharCode(c + 0x20) ); // WIP
						case 0:
							//TODO parse error
							// Append a U+FFFD REPLACEMENT CHARACTER character to the current attribute's name.
							currentTag.appendToAttrName( String.fromCharCode( 0xFFFD ) ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							if (Lambda.has([0x22, 0x27, '<'.code], c))// quotation mark, apostrophe, ...
							{
								//TODO parse error
							}
							// Append the current input character to the current attribute's name.
							currentTag.appendToAttrName( String.fromCharCode( c ) ); // WIP
					}
					/*
					TODO
					When the user agent leaves the attribute name state (and before emitting the tag token, if appropriate), 
					the complete attribute's name must be compared to the other attributes on the same token; if there is 
					already an attribute on the token with the exact same name, then this is a parse error and the new attribute
					must be dropped, along with the value that gets associated with it (if any).
					*/ 
				case AFTER_ATTRIBUTE_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case '/'.code:
							state = SELF_CLOSING_START_TAG;
						case '='.code:
							state = BEFORE_ATTRIBUTE_VALUE;
						case '>'.code:
							state = DATA;
							onNewToken( currentTag.generateToken() );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Start a new attribute in the current tag token. 
							// Set that attribute's name to the lowercase version of the current input character (add 0x0020 to the character's code point), 
							// and its value to the empty string
							currentTag.nextAttr( String.fromCharCode( c + 0x20 ) ); // WIP
							state = ATTRIBUTE_NAME;
						case 0:
							//TODO parse error
							// Start a new attribute in the current tag token. 
							// Set that attribute's name to a U+FFFD REPLACEMENT CHARACTER character, and its value to the empty string.
							currentTag.nextAttr( String.fromCharCode( 0xFFFD ) ); // WIP
							state = ATTRIBUTE_NAME;
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							if (Lambda.has([0x22, 0x27, '<'.code], c))// quotation mark, apostrophe, ...
							{
								//TODO parse error
							}
							// Start a new attribute in the current tag token. Set that attribute's name to the current input character, and its value to the empty string.
							currentTag.nextAttr( String.fromCharCode( c ) ); // WIP
							state = ATTRIBUTE_NAME;
					}
				case BEFORE_ATTRIBUTE_VALUE:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case 0x22: //quotation mark
							state = ATTRIBUTE_VALUE_STATE( DOUBLE_QUOTED );
						case '&'.code:
							state = ATTRIBUTE_VALUE_STATE( UNQUOTED );
							// Reconsume the current input character
							is.unconsume( 1 );
						case 0x27: //apostrophe
							state = ATTRIBUTE_VALUE_STATE( SINGLE_QUOTED );
						case 0:
							//TODO parse error
							//Append a U+FFFD REPLACEMENT CHARACTER character to the current attribute's value.
							currentTag.appendToAttrValue( String.fromCharCode(0xFFFD) ); // WIP
							state = ATTRIBUTE_VALUE_STATE( UNQUOTED );
						case '>'.code:
							//TODO parse error
							state = DATA;
							onNewToken( currentTag.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							if (Lambda.has(['<'.code, '='.code, 0x60], c))
							{
								//TODO parse error
							}
							//Append the current input character to the current attribute's value.
							currentTag.appendToAttrValue( String.fromCharCode(c) ); // WIP
							state = ATTRIBUTE_VALUE_STATE( UNQUOTED );
					}
				case ATTRIBUTE_VALUE_STATE( q ): // DOUBLE_QUOTED & SINGLE_QUOTED & UNQUOTED
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if (q == UNQUOTED):
							state = BEFORE_ATTRIBUTE_NAME;
						case x if (x == 0x22 && q == DOUBLE_QUOTED || x == 0x27 && q == SINGLE_QUOTED):
							state = AFTER_ATTRIBUTE_VALUE_QUOTED;
						case '&'.code:
							state = CHARACTER_REFERENCE_IN_ATTRIBUTE_VALUE( q );
						case '>'.code if (q == UNQUOTED):
							state = DATA;
							onNewToken( currentTag.generateToken() ); // WIP
						case 0:
							//TODO parse error
							//Append a U+FFFD REPLACEMENT CHARACTER character to the current attribute's value.
							currentTag.appendToAttrValue( String.fromCharCode( 0xFFFD ) ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							if ( q == UNQUOTED && Lambda.has([0x22, 0x27, 0x3C, 0x3D, 0x60], c) )
							{
								//TODO parse error
							}
							//Append the current input character to the current attribute's value.
							currentTag.appendToAttrValue( String.fromCharCode( c ) ); // WIP
					}
				case CHARACTER_REFERENCE_IN_ATTRIBUTE_VALUE( q ):
					var cr = is.nextCharRef( q == DOUBLE_QUOTED ? 0x22 : ( q == UNQUOTED ? '>'.code : 0x27 ) );
					
					if ( cr[0] == -2 )
					{
						// append a U+0026 AMPERSAND character (&) to the current attribute's value.
						currentTag.appendToAttrValue( String.fromCharCode( 0x26 ) ); // WIP
					}
					else
					{
						for ( cri in cr )
						{
							// append the returned character tokens to the current attribute's value.
							currentTag.appendToAttrValue( String.fromCharCode( cri ) ); // WIP
						}
					}
					state = ATTRIBUTE_VALUE_STATE( q );
				case AFTER_ATTRIBUTE_VALUE_QUOTED:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code:
							state = SELF_CLOSING_START_TAG;
						case '>'.code:
							state = DATA;
							//Emit the current tag token.
							onNewToken( currentTag.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							state = BEFORE_ATTRIBUTE_NAME;
							// Reconsume the character
							is.unconsume( 1 );
					}
				case SELF_CLOSING_START_TAG:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '>'.code:
							//Set the self-closing flag of the current tag token.
							currentTag.setSelfClosing(); // WIP
							state = DATA;
							onNewToken( currentTag.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							state = BEFORE_ATTRIBUTE_NAME;
							// Reconsume the character
							is.unconsume( 1 );
					}
				case BOGUS_COMMENT:
					var cd = new StringBuf();

					while ( c != '>'.code && c != -1 )
					{
						cd.add( c );

						c = is.nextInputChar();
						if ( c == 0 )
						{
							c = 0xFFFD;
						}
					}
					onNewToken( COMMENT( cd.toString() ) );

					state = DATA;

					// If the end of the file was reached, reconsume the EOF character.
					if ( c == -1 )
					{
						is.unconsume( 1 );
					}
				case MARKUP_DECLARATION_OPEN:
					if ( is.consumeString("--") )
					{
						// create a comment token whose data is the empty string,
						currentComment.nextComment( "" ); // WIP
						state = COMMENT_START;
					}
					else if ( is.consumeString("DOCTYPE") )
					{
						state = DOCTYPE;
					}
					else if ( /* *if there is a current node and it is not an element in the HTML namespace* && */ is.consumeString("[CDATA[") )
					{
						state = CDATA_SECTION;
					}
					else
					{
						//TODO parse error
						state = BOGUS_COMMENT;
						c = is.nextInputChar(); // FIXME? should it be here?
					}
				case COMMENT_START:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = COMMENT_START_DASH;
						case 0:
							//TODO parse error
							//Append a U+FFFD REPLACEMENT CHARACTER character to the comment token's data
							currentComment.appendToData( String.fromCharCode( 0xFFFD ) ); // WIP
							state = COMMENT;
						case '>'.code:
							//TODO parse error
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//Append the current input character to the comment token's data.
							currentComment.appendToData( String.fromCharCode( c ) ); // WIP
							state = COMMENT;
					}
				case COMMENT_START_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = COMMENT_END;
						case 0:
							//TODO parse error
							// Append a "-" (U+002D) character and a U+FFFD REPLACEMENT CHARACTER character to the comment token's data.
							currentComment.appendToData( String.fromCharCode( 0x2D )+String.fromCharCode( 0xFFFD ) ); // WIP
							state = COMMENT;
						case '>'.code:
							//TODO parse error
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							// Append a "-" (U+002D) character and the current input character to the comment token's data.
							currentComment.appendToData( String.fromCharCode(0x2D) + String.fromCharCode(c) ); // WIP
							state = COMMENT;
					}
				case COMMENT:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = COMMENT_END_DASH;
						case 0:
							//TODO parse error
							// Append a U+FFFD REPLACEMENT CHARACTER character to the comment token's data.
							currentComment.appendToData( String.fromCharCode(0xFFFD) ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//Append the current input character to the comment token's data.
							currentComment.appendToData( String.fromCharCode(c) ); // WIP
					}
				case COMMENT_END_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = COMMENT_END;
						case 0:
							//TODO parse error
							// Append a "-" (U+002D) character and a U+FFFD REPLACEMENT CHARACTER character to the comment token's data.
							currentComment.appendToData( String.fromCharCode(0x2D) + String.fromCharCode(0xFFFD) ); // WIP
							state = COMMENT;
						case -1:
							//TODO parse error
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							// Append a "-" (U+002D) character and the current input character to the comment token's data
							currentComment.appendToData( String.fromCharCode(0x2D) ); // WIP
							state = COMMENT;
					}
				case COMMENT_END:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '>'.code:
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
						case 0:
							//TODO parse error
							// Append two "-" (U+002D) characters and a U+FFFD REPLACEMENT CHARACTER character to the comment token's data.
							currentComment.appendToData( String.fromCharCode(0x2D) + String.fromCharCode(0xFFFD) ); // WIP
							state = COMMENT;
						case '!'.code:
							//TODO parse error
							state = COMMENT_END_BANG;
						case '-'.code:
							//TODO parse error
							// Append a "-" (U+002D) character to the comment token's data.
							currentComment.appendToData( String.fromCharCode(0x2D) ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							// Append two "-" (U+002D) characters and the current input character to the comment token's data.
							currentComment.appendToData( String.fromCharCode(0x2D) ); // WIP
							state = COMMENT;
					}
				case COMMENT_END_BANG:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							// Append two "-" (U+002D) characters and a "!" (U+0021) character to the comment token's data.
							currentComment.appendToData( "--!" ); // WIP
							state = COMMENT_END_DASH;
						case '>'.code:
							state = DATA;
							onNewToken( currentComment.generateToken() ); // WIP
						case 0:
							//TODO parse error
							// Append two "-" (U+002D) characters, a "!" (U+0021) character, and a U+FFFD REPLACEMENT CHARACTER character to the comment token's data
							currentComment.appendToData( "--!"+String.fromCharCode(0xFFFD) ); // WIP
							state = COMMENT;
					}
				case DOCTYPE:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = BEFORE_DOCTYPE_NAME;
						case -1:
							//TODO parse error
							state = DATA;
							onNewToken( DOCTYPE( "", "", "", true ) );
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							state = BEFORE_DOCTYPE_NAME;
							// Reconsume the character
							is.unconsume( 1 );
					}
				case BEFORE_DOCTYPE_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Create a new DOCTYPE token. Set the token's name to the lowercase version of the current input character (add 0x0020 to the character's code point).
							currentDoctype.nextDoctype( String.fromCharCode( c + 0x20 ) ); // WIP
							state = DOCTYPE_NAME;
						case 0:
							//TODO parse error
							// Create a new DOCTYPE token. Set the token's name to a U+FFFD REPLACEMENT CHARACTER character
							currentDoctype.nextDoctype( String.fromCharCode( 0xFFFD ) ); // WIP
							state = DOCTYPE_NAME;
						case '>'.code:
							//TODO parse error
							state = DATA;
							onNewToken( DOCTYPE( null, null, null, true ) );
						case _:
							// Create a new DOCTYPE token. Set the token's name to the current input character.
							currentDoctype.nextDoctype( String.fromCharCode( c ) ); // WIP
							state = DOCTYPE_NAME;
					}
				case DOCTYPE_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = DOCTYPE_NAME;
						case '>'.code:
							state = DATA;
							onNewToken( currentDoctype.generateToken() ); // WIP
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current DOCTYPE token's name.
							currentDoctype.appendToName( String.fromCharCode( c + 0x20 ) ); // WIP
						case 0:
							//TODO parse error
							// Append a U+FFFD REPLACEMENT CHARACTER character to the current DOCTYPE token's name.
							currentDoctype.appendToName( String.fromCharCode( c + 0xFFFD ) ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token. 
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							// Append the current input character to the current DOCTYPE token's name.
							currentDoctype.appendToName( String.fromCharCode( c ) ); // WIP
					}
				case AFTER_DOCTYPE_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case '>'.code:
							state = DATA;
							onNewToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token. 
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							if ( is.consumeString("PUBLIC", false) )
							{
								state = AFTER_DOCTYPE_PUBLIC_KEYWORD;
							}
							else if ( is.consumeString("SYSTEM", false) )
							{
								state = AFTER_DOCTYPE_SYSTEM_KEYWORD;
							}
							else
							{
								//TODO parse error
								// Set the DOCTYPE token's force-quirks flag to on
								currentDoctype.setForceQuirk(); // WIP
								state = BOGUS_DOCTYPE;
							}
					}
				case AFTER_DOCTYPE_PUBLIC_KEYWORD:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = BEFORE_DOCTYPE_PUBLIC_IDENTIFIER;
						case 0x22:
							//TODO parse error
							// Set the DOCTYPE token's public identifier to the empty string (not missing)
							currentDoctype.appendToPid(""); // WIP
							state = DOCTYPE_PUBLIC_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO parse error
							// Set the DOCTYPE token's public identifier to the empty string (not missing)
							currentDoctype.appendToPid(""); // WIP
							state = DOCTYPE_PUBLIC_IDENTIFIER( SINGLE_QUOTED );
						case '>'.code:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on. Switch to the data state. Emit that DOCTYPE token.
							currentDoctype.setForceQuirk(); // WIP
							onNewToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on
							currentDoctype.setForceQuirk(); // WIP
							state = BOGUS_DOCTYPE;
					}
				case BEFORE_DOCTYPE_PUBLIC_IDENTIFIER:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case 0x22:
							// Set the DOCTYPE token's public identifier to the empty string (not missing)
							currentDoctype.appendToPid(""); // WIP
							state = DOCTYPE_PUBLIC_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							// Set the DOCTYPE token's public identifier to the empty string (not missing)
							currentDoctype.appendToPid(""); // WIP
							state = DOCTYPE_PUBLIC_IDENTIFIER( SINGLE_QUOTED );
						case '>'.code:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							state = DATA;
							// Emit that DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							state = BOGUS_DOCTYPE;
					}
				case DOCTYPE_PUBLIC_IDENTIFIER( q ): // DOUBLE_QUOTED & SINGLE_QUOTED
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( q == DOUBLE_QUOTED && x == 0x22 || q == SINGLE_QUOTED && x == 0x27 ):
							state = AFTER_DOCTYPE_PUBLIC_IDENTIFIER;
						case 0:
							//TODO parse error
							// Append a U+FFFD REPLACEMENT CHARACTER character to the current DOCTYPE token's public identifier.
							currentDoctype.appendToPid( String.fromCharCode(0xFFFD) );
						case '>'.code:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Switch to the data state.
							state = DATA;
							// Emit that DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							// Append the current input character to the current DOCTYPE token's public identifier.
							currentDoctype.appendToPid( String.fromCharCode( c ) ); // WIP
					}
				case AFTER_DOCTYPE_PUBLIC_IDENTIFIER:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = BETWEEN_DOCTYPE_PUBLIC_AND_SYSTEM_IDENTIFIERS;
						case '>'.code:
							state = DATA;
							// Emit the current DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
						case 0x22:
							//TODO parse error
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid("");
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO parse error
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid("");
							state = DOCTYPE_SYSTEM_IDENTIFIER( SINGLE_QUOTED );
						case -1:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token. 
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							state = BOGUS_DOCTYPE;
					}
				case BETWEEN_DOCTYPE_PUBLIC_AND_SYSTEM_IDENTIFIERS:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case '>'.code:
							state = DATA;
							// Emit the current DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
						case 0x22:
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid(""); // WIP
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid(""); // WIP
							state = DOCTYPE_SYSTEM_IDENTIFIER( SINGLE_QUOTED );
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token. 
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							state = BOGUS_DOCTYPE;
					}
				case AFTER_DOCTYPE_SYSTEM_KEYWORD:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = BEFORE_DOCTYPE_SYSTEM_IDENTIFIER;
						case 0x22:
							//TODO parse error
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid(""); // WIP
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO parse error
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid(""); // WIP
							state = DOCTYPE_SYSTEM_IDENTIFIER( SINGLE_QUOTED );
						case '>'.code:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							state = BOGUS_DOCTYPE;
					}
				case BEFORE_DOCTYPE_SYSTEM_IDENTIFIER:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case 0x22:
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid(""); // WIP
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid(""); // WIP
							state = DOCTYPE_SYSTEM_IDENTIFIER( SINGLE_QUOTED );
						case '>'.code:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. Emit that DOCTYPE token.
							currentDoctype.setForceQuirk(); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token. 
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							state = BOGUS_DOCTYPE;
					}
				case DOCTYPE_SYSTEM_IDENTIFIER( q ): // DOUBLE_QUOTED & SINGLE_QUOTED
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x == 0x22 && q.equals(DOUBLE_QUOTED) || x == 0x27 && q.equals(SINGLE_QUOTED) ):
							state = DOCTYPE_SYSTEM_IDENTIFIER( q );
						case 0:
							//TODO parse error
							// Append a U+FFFD REPLACEMENT CHARACTER character to the current DOCTYPE token's system identifier.
							currentDoctype.appendToSid( String.fromCharCode( 0xFFFD ) ); // WIP
						case '>'.code:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. Emit that DOCTYPE token.
							currentDoctype.setForceQuirk(); // WIP
							onNewToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							// Append the current input character to the current DOCTYPE token's system identifier.
							currentDoctype.appendToSid( String.fromCharCode( c ) ); // WIP
					}
				case AFTER_DOCTYPE_SYSTEM_IDENTIFIER:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case '>'.code:
							state = DATA;
							// Emit the current DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token. 
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//TODO parse error
							state = BOGUS_DOCTYPE; // This does not set the DOCTYPE token's force-quirks flag to on.
					}
				case BOGUS_DOCTYPE:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '>'.code:
							state = DATA;
							// Emit the DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
						case -1:
							state = DATA;
							// Emit the DOCTYPE token.
							onNewToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							is.unconsume( 1 );
						case _:
							//Ignore the character.
					}
				case CDATA_SECTION:
					state = DATA;

					for ( ci in is.consumeUntilString("]]>") )
					{
						onNewToken( CHAR( ci ) );
					}
					if ( is.currentInputChar() == -1 )
					{
						// reconsume the EOF character
						is.unconsume( 1 );
					}
				//case _:
					//throw "ERROR: unknown Tokenizer state";
			}
		}
	}
}
