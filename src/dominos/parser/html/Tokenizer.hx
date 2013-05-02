package dominos.parser.html;

/**
 * The states of the Tokenizer machine.
 */
enum State
{
	DATA;
	CHARACTER_REFERENCE_IN_DATA;
	RCDATA;
	CHARACTER_REFERENCE_IN_RCDATA;
	RAWTEXT;
	SCRIPT_DATA;
	PLAINTEXT;
	TAG_OPEN;
	END_TAG_OPEN;
	TAG_NAME;
	RCDATA_LESS_THAN_SIGN;
	RCDATA_END_TAG_OPEN;
	RCDATA_END_TAG_NAME;
	RAWTEXT_LESS_THAN_SIGN;
	RAWTEXT_END_TAG_OPEN;
	RAWTEXT_END_TAG_NAME;
	SCRIPT_DATA_LESS_THAN_SIGN;
	SCRIPT_DATA_END_TAG_OPEN;
	SCRIPT_DATA_END_TAG_NAME;
	SCRIPT_DATA_ESCAPE_START;
	SCRIPT_DATA_ESCAPE_START_DASH;
	SCRIPT_DATA_ESCAPED;
	SCRIPT_DATA_ESCAPED_DASH;
	SCRIPT_DATA_ESCAPED_DASH_DASH;
	SCRIPT_DATA_ESCAPED_LESS_THAN_SIGN;
	SCRIPT_DATA_ESCAPED_END_TAG_OPEN;
	SCRIPT_DATA_ESCAPED_END_TAG_NAME;
	SCRIPT_DATA_DOUBLE_ESCAPE_START;
	SCRIPT_DATA_DOUBLE_ESCAPED;
	SCRIPT_DATA_DOUBLE_ESCAPED_DASH;
	SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH;
	SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN;
	SCRIPT_DATA_DOUBLE_ESCAPE_END;
	BEFORE_ATTRIBUTE_NAME;
	ATTRIBUTE_NAME;
	AFTER_ATTRIBUTE_NAME;
	BEFORE_ATTRIBUTE_VALUE;
	ATTRIBUTE_VALUE_STATE( q : Quotation ); // DOUBLE_QUOTED & SINGLE_QUOTED & UNQUOTED
	CHARACTER_REFERENCE_IN_ATTRIBUTE_VALUE( q : Quotation );
	AFTER_ATTRIBUTE_VALUE_QUOTED;
	SELF_CLOSING_START_TAG;
	BOGUS_COMMENT;
	MARKUP_DECLARATION_OPEN;
	COMMENT_START;
	COMMENT_START_DASH;
	COMMENT;
	COMMENT_END_DASH;
	COMMENT_END;
	COMMENT_END_BANG;
	DOCTYPE;
	BEFORE_DOCTYPE_NAME;
	DOCTYPE_NAME;
	AFTER_DOCTYPE_NAME;
	AFTER_DOCTYPE_PUBLIC_KEYWORD;
	BEFORE_DOCTYPE_PUBLIC_IDENTIFIER;
	DOCTYPE_PUBLIC_IDENTIFIER( q : Quotation ); // DOUBLE_QUOTED & SINGLE_QUOTED
	AFTER_DOCTYPE_PUBLIC_IDENTIFIER;
	BETWEEN_DOCTYPE_PUBLIC_AND_SYSTEM_IDENTIFIERS;
	AFTER_DOCTYPE_SYSTEM_KEYWORD;
	BEFORE_DOCTYPE_SYSTEM_IDENTIFIER;
	DOCTYPE_SYSTEM_IDENTIFIER( q : Quotation ); // DOUBLE_QUOTED & SINGLE_QUOTED
	AFTER_DOCTYPE_SYSTEM_IDENTIFIER;
	BOGUS_DOCTYPE;
	CDATA_SECTION;
}
enum Quotation
{
	DOUBLE_QUOTED;
	SINGLE_QUOTED;
	UNQUOTED;
}

/**
 * DOCTYPE tokens have a name, a public identifier, a system identifier, and a force-quirks flag.
 * When a DOCTYPE token is created, its name, public identifier, and system identifier must be marked
 * as missing (which is a distinct state from the empty string), and the force-quirks flag must be set
 * to off (its other state is on).
 *
 * Start and end tag tokens have a tag name, a self-closing flag, and a list of attributes, each of 
 * which has a name and a value. When a start or end tag token is created, its self-closing flag must 
 * be unset (its other state is that it be set), and its attributes list must be empty. 
 * 
 * Comment and character tokens have data.
 */
enum Token
{
	EOF;
	CHAR( c : Int );
	COMMENT( d : String );
	DOCTYPE( name : String, publicId : String, systemId : String, forceQuirks : Bool );
	START_TAG( tagName : String, selfClosing : Bool, attrs : Map<String,String> );
	END_TAG( tagName : String, selfClosing : Bool, attrs : Map<String,String> );
}

/**
 * Manage the current tag accross the different states.
 */
class CurrentTagHelper
{
	var n : String;
	var sc : Bool;
	var attrs : Map<String,String>;
	var ca : String;
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
		attrs = [];
		can = null;
	}
	public function nextAttr( s : String ):Void
	{
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
 * TODO manage current tag token
 * 		manage doctype and comment token (when not consumed right after creation)
 * 
 * @see http://www.w3.org/TR/html5/syntax.html#tokenization
 * 
 * @author Thomas Fétiveau
 */
class Tokenizer
{
	private var is : InputStream;
	
	private var tb : TreeBuilder;

	public function new( is : InputStream ) 
	{
		this.is = is;
		
		this.tb = new TreeBuilder();
	}
	
	public function parse()
	{
		var state : State = DATA;
		
		var c : Int;
		
		var currentTag = new CurrentTagHelper();
		
		var currentComment = new CurrentCommentHelper();
		
		var currentDoctype = new CurrentDoctypeHelper();
		
		var tempBuffer : StringBuf = null;
		
		while ( state != null )
		{
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
							tb.consumeToken( CHAR( c ) );
						case -1: //EOF
							tb.consumeToken( EOF );
							state = null;
						default:
							tb.consumeToken( CHAR( c ) );
					}
				case CHARACTER_REFERENCE_IN_DATA:
					state = DATA;
					
					var cr : Array<Int> = is.nextCharRef(); //Attempt to consume a character reference, with no additional allowed character.
					
					if ( cr[0] == -2 ) // nothing returned
					{
						tb.consumeToken( CHAR( '&'.code ) );
					}
					else
					{
						for (cri in cr)
						{
							tb.consumeToken( CHAR( cri ) );
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
							
							tb.consumeToken( CHAR( 0xFFFD ) );
						case -1: //EOF
							tb.consumeToken( EOF )
						case _:
							tb.consumeToken( CHAR( c ) );
					}
				case CHARACTER_REFERENCE_IN_RCDATA:
					state = RCDATA;
					
					var cr : Array<Int> = is.nextCharRef();
					
					if ( cr[0] == -2 ) // nothing returned
					{
						tb.consumeToken( CHAR('&') );
					}
					else
					{
						for (cri in cr)
						{
							tb.consumeToken( CHAR(cri) );
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
							
							tb.consumeToken( 0xFFFD );
						case -1: //EOF
							tb.consumeToken( EOF );
						case _:
							tb.consumeToken( CHAR( c ) );
					}
				case SCRIPT_DATA:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '<'.code:
							state = SCRIPT_DATA_LESS_THAN_SIGN;
						case 0:
							// TODO parse error
							
							tb.consumeToken( 0xFFFD );
						case -1: //EOF
							tb.consumeToken( EOF );
						case _:
							tb.consumeToken( CHAR( c ) );
					}
				case PLAINTEXT:
					c = is.nextInputChar();

					switch(c)
					{
						case 0:
							// TODO parse error
							
							tb.consumeToken( 0xFFFD );
						case -1:
							tb.consumeToken( EOF );
						case _:
							tb.consumeToken( CHAR( c ) );
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
							tb.consumeToken( CHAR('<'.code) );
							//Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							// Reconsume the EOF
							unconsume( 1 );
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
							tb.consumeToken(currentTag.generateToken());  // WIP
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentTag.appendToName( String.fromCharCode( c + 0x20 ) ); // WIP
						case 0:
							//TODO parse error
							currentTag.appendToName( String.fromCharCode( 0xFFFD ) ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character.
							unconsume( 1 );
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
							tb.consumeToken( CHAR( '<'.code ) );
							//Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( '/'.code ) );
							// Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( currentTag.generateToken() );
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
							tb.consumeToken( CHAR( '>'.code ) );
							tb.consumeToken( CHAR( '/'.code ) );
							for (tc in tempBuffer)
							{
								tb.consumeToken( CHAR( tc ) );
							}
							// Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( CHAR('<'.code) );
							// Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							// Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( currentTag.tagToken( true ) );
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
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							for (tc in tempBuffer)
							{
								tb.consumeToken( CHAR( tc ) );
							}
							// Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( '!'.code ) );
						case _:
							state = SCRIPT_DATA;
							tb.consumeToken( CHAR( '<'.code ) );
							// Reconsume the current input character
							unconsume( 1 );
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
							currentTag.nexTag( String.fromCharCode( c ), true ); // WIP
							tempBuffer.add(c);
							state = SCRIPT_DATA_END_TAG_NAME;
						case _:
							state = DATA;
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( '/'.code ) );
							// Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( currentTag.generateToken() );
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
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							for (tc in tempBuffer)
							{
								tb.consumeToken( CHAR( tc ) );
							}
							// Reconsume the current input character
							unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPE_START:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_ESCAPE_START_DASH;
							tb.consumeToken( CHAR('-'.code) );
						case _:
							state = SCRIPT_DATA;
							// Reconsume the current input character
							unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPE_START_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_ESCAPED_DASH_DASH;
							tb.consumeToken( CHAR('-'.code) );
						case _:
							state = SCRIPT_DATA;
							// Reconsume the current input character
							unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPED:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_ESCAPED_DASH;
							tb.consumeToken( CHAR('-'.code) );
						case '<'.code:
							state = SCRIPT_DATA_ESCAPED_LESS_THAN_SIGN;
						case 0:
							//TODO parse error
							tb.consumeToken( CHAR('0xFFFD'.code) );
						case -1:
							state = DATA;
							//TODO parse error
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							tb.consumeToken( CHAR( c ) );
					}
				case SCRIPT_DATA_ESCAPED_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_ESCAPED_DASH_DASH;
							tb.consumeToken( CHAR('-'.code) );
						case '<'.code:
							state = SCRIPT_DATA_ESCAPED_LESS_THAN_SIGN;
						case 0:
							//TODO parse error
							state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR('0xFFFD'.code) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR( c ) );
					}
				case SCRIPT_DATA_ESCAPED_DASH_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							tb.consumeToken( CHAR('-'.code) );
						case '<'.code:
							state = SCRIPT_DATA_ESCAPED_LESS_THAN_SIGN;
						case '>'.code:
							state = SCRIPT_DATA;
							tb.consumeToken( CHAR('>'.code) );
						case 0:
							//TODO parse error
							state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR('0xFFFD'.code) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR( c ) );
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
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( c ) );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							tempBuffer = new StringBuf();
							tempBuffer.add( x );
							state = SCRIPT_DATA_DOUBLE_ESCAPE_START;
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( c ) );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR( '<'.code ) );
							// Reconsume the current input character
							unconsume( 1 );
					}
				case SCRIPT_DATA_ESCAPED_END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentTag.nexTag( String.fromCharCode( c + 0x20 ), true ); // WIP
							tempBuffer.add( c );
							state = SCRIPT_DATA_ESCAPED_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentTag.nexTag( String.fromCharCode( c ), true ); // WIP
							tempBuffer.add( c );
							state = SCRIPT_DATA_ESCAPED_END_TAG_NAME;
						case _:
							state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( '/'.code ) );
							// Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( currentTag.generateToken() );
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
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							for (tc in tempBuffer)
							{
								tb.consumeToken( CHAR( tc ) );
							}
							// Reconsume the current input character
							unconsume( 1 );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPE_START:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20, '/'.code, '>'.code:
							if (tempBuffer.toString == "script")
								state = SCRIPT_DATA_DOUBLE_ESCAPED;
							else
								state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR ( c ) );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							tempBuffer.add( c + 0x20 );
							tb.consumeToken( CHAR ( c ) );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							tempBuffer.add( c );
							tb.consumeToken( CHAR ( c ) );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							// Reconsume the current input character
							unconsume( 1 );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPED:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_DASH;
							tb.consumeToken( CHAR ( '-'.code ) );
						case '<'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN;
							tb.consumeToken( CHAR ( '<'.code ) );
						case 0:
							//TODO parse error
							tb.consumeToken( CHAR ( 0xFFFD ) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							tb.consumeToken( CHAR ( c ) );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPED_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH;
							tb.consumeToken( CHAR ( '-'.code ) );
						case '<'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN;
							tb.consumeToken( CHAR ( '<'.code ) );
						case 0:
							//TODO parse error
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							tb.consumeToken( CHAR ( 0xFFFD ) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							tb.consumeToken( CHAR ( c ) );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							tb.consumeToken( CHAR ( '-'.code ) );
						case '<'.code:
							state = SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN;
							tb.consumeToken( CHAR ( '<'.code ) );
						case '>'.code:
							state = SCRIPT_DATA;
							tb.consumeToken( CHAR ( '>'.code ) );
						case 0:
							//TODO parse error
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							tb.consumeToken( CHAR ( 0xFFFD ) );
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							tb.consumeToken( CHAR ( c ) );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPED_LESS_THAN_SIGN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '/'.code:
							tempBuffer = new StringBuf();
							state = SCRIPT_DATA_DOUBLE_ESCAPE_END;
							tb.consumeToken( CHAR ( '/'.code ) );
						case _:
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							// Reconsume the current input character
							unconsume( 1 );
					}
				case SCRIPT_DATA_DOUBLE_ESCAPE_END:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20, '/'.code, '>'.code:
							if (tempBuffer.toString == "script")
								state = SCRIPT_DATA_ESCAPED;
							else
								state = SCRIPT_DATA_DOUBLE_ESCAPED;
							tb.consumeToken( CHAR ( c ) );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							tempBuffer.add( c + 0x20 );
							tb.consumeToken( CHAR ( c ) );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							tempBuffer.add( c );
							tb.consumeToken( CHAR ( c ) );
						case _:
							state = SCRIPT_DATA_DOUBLE_ESCAPED;
							// Reconsume the current input character
							unconsume( 1 );
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
							tb.consumeToken( /* TODO manage end and start tokens in CurrentToken class */ );
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
							unconsume( 1 );
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
							tb.consumeToken( currentTag.generateToken() ); // WIP
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
							unconsume( 1 );
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
							tb.consumeToken( currentTag.generateToken() );
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
							unconsume( 1 );
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
							unconsume( 1 );
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
							tb.consumeToken( currentTag.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentTag.generateToken() ); // WIP
						case 0:
							//TODO parse error
							//Append a U+FFFD REPLACEMENT CHARACTER character to the current attribute's value.
							currentTag.appendToAttrValue( String.fromCharCode( 0xFFFD ) ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentTag.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							//TODO parse error
							state = BEFORE_ATTRIBUTE_NAME;
							// Reconsume the character
							unconsume( 1 );
					}
				case SELF_CLOSING_START_TAG:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '>'.code:
							//Set the self-closing flag of the current tag token.
							currentTag.setSelfClosing(); // WIP
							state = DATA;
							tb.consumeToken( currentTag.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							//TODO parse error
							state = BEFORE_ATTRIBUTE_NAME;
							// Reconsume the character
							unconsume( 1 );
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
					tb.consumeToken( COMMENT( cd.toString() ) );

					state = DATA;

					// If the end of the file was reached, reconsume the EOF character.
					if ( c == -1 )
					{
						unconsume( 1 );
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
							tb.consumeToken( currentComment.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							tb.consumeToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentComment.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA
							tb.consumeToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentComment.generateToken() ); // WIP
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
							tb.consumeToken( currentComment.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentComment.generateToken() ); // WIP
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
							tb.consumeToken( DOCTYPE( true ) );
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							//TODO parse error
							state = BEFORE_DOCTYPE_NAME;
							// Reconsume the character
							unconsume( 1 );
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
							tb.consumeToken( DOCTYPE( null, null, null, true ) );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token. 
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on.
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							currentDoctype.appendToSid("") // WIP
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							// Set the DOCTYPE token's system identifier to the empty string (not missing)
							currentDoctype.appendToSid("") // WIP
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
						case x if ( x == 0x22 && q == DOUBLE_QUOTED || x == 0x27 && q == SINGLE_QUOTED ):
							state = DOCTYPE_SYSTEM_IDENTIFIER;
						case 0:
							//TODO parse error
							// Append a U+FFFD REPLACEMENT CHARACTER character to the current DOCTYPE token's system identifier.
							currentDoctype.appendToSid( String.fromCharCode( 0xFFFD ) ) // WIP
						case '>'.code:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. Emit that DOCTYPE token.
							currentDoctype.setForceQuirk(); // WIP
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token.
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							// Append the current input character to the current DOCTYPE token's system identifier.
							currentDoctype.appendToSid( String.fromCharCode( c ) ) // WIP
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
						case -1:
							//TODO parse error
							state = DATA;
							// Set the DOCTYPE token's force-quirks flag to on. 
							currentDoctype.setForceQuirk(); // WIP
							// Emit that DOCTYPE token. 
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
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
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
						case -1:
							state = DATA;
							// Emit the DOCTYPE token.
							tb.consumeToken( currentDoctype.generateToken() ); // WIP
							// Reconsume the EOF character
							unconsume( 1 );
						case _:
							//Ignore the character.
					}
				case CDATA_SECTION:
					state = DATA;

					for ( ci in is.consumeUntilString("]]>") )
					{
						tb.consumeToken( CHAR( ci ) );
					}
					if ( is.currentInputChar() == -1 )
					{
						// reconsume the EOF character
						unconsume( 1 );
					}
				case _:
					throw "ERROR: unknown Tokenizer state";
			}
		}
		
	}
}
