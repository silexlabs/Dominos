package dominos.parser.html;

// tokens list
//DOCTYPE, start tag, end tag, comment, character, end - of - file

/**
 * DOCTYPE tokens have a name, a public identifier, a system identifier, and a force-quirks flag.
 * When a DOCTYPE token is created, its name, public identifier, and system identifier must be marked
 * as missing (which is a distinct state from the empty string), and the force-quirks flag must be set
 * to off (its other state is on).
 */

/**
 * Start and end tag tokens have a tag name, a self-closing flag, and a list of attributes, each of 
 * which has a name and a value. When a start or end tag token is created, its self-closing flag must 
 * be unset (its other state is that it be set), and its attributes list must be empty. 
 */

/**
 * Comment and character tokens have data.
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
	TAG_NAME( isEnd : Bool ); // isEnd indicates if it's the current start tag name (false), or the current end tag name (true)
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
 * 
 */
enum Token
{
	EOF;
	CHAR( c : Int );
	COMMENT( d : String );
	DOCTYPE( forceQuirks : Bool );
	START_TAG( tagName : String );
	END_TAG( tagName : String );
}
  
/**
 * The Tokenize class handle the tokenization of the HTML document.
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
		
		//TODO create a structure/class that manages the both string + isAppropriate? 
		var currentStartTagName : String = null;
		var currentEndTagName : String = null;
		
		var tempBuffer : StringBuf = null;
		
		while ( state != null ) // TODO determine while condition
		{
			switch (state)
			{
				case DATA:
					c = is.nextInputChar(); // fastCodeAt(0)

					switch(c)
					{
						case '&'.code:
							state = CHARACTER_REFERENCE_IN_DATA;
						case '<'.code:
							state = TAG_OPEN;
						case 0: // NULL char
							//TODO Parse error.
							
							//Emit the current input character as a character token.
							tb.consumeToken( CHAR(c) );
						case -1: //EOF
							//Emit an end-of-file token.
							tb.consumeToken( EOF );
						default:
							//Emit the current input character as a character token. 
							tb.consumeToken( CHAR(c) );
					}
				case CHARACTER_REFERENCE_IN_DATA:
					state = DATA;
					
					var cr : Array<Int> = is.nextCharRef(); //Attempt to consume a character reference, with no additional allowed character.
					
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
							
							tb.consumeToken( 0xFFFD );
						case -1: //EOF
							tb.consumeToken( EOF )
						case _:
							tb.consumeToken( CHAR(c) );
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
							tb.consumeToken( CHAR(c) );
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
							tb.consumeToken( CHAR(c) );
					}
				case PLAINTEXT:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0:
							// TODO parse error
							
							tb.consumeToken( 0xFFFD );
						case -1: //EOF
							tb.consumeToken( EOF );
						case _:
							tb.consumeToken( CHAR(c) );
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
							currentStartTagName = String.fromCharCode( c + 0x20 );
							state = TAG_NAME(false);
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentStartTagName = String.fromCharCode( c );
							state = TAG_NAME(false);
						case '?'.code:
							// TODO parse error
							state = BOGUS_COMMENT;
						case _:
							// TODO parse error
							state = DATA;
							tb.consumeToken( CHAR('<'.code) );
							//TODO Reconsume the current input character ?!
					}
				case END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentEndTagName = String.fromCharCode( c + 0x20 );
							state = TAG_NAME(true);
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentEndTagName = String.fromCharCode( c );
							state = TAG_NAME(true);
						case '>'.code:
							// TODO parse error
							state = DATA;
						case -1:
							// TODO parse error
							state = DATA;
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							// TODO Reconsume the EOF ?!
						case _:
							// TODO parse error
							state = BOGUS_COMMENT;
					}
				case TAG_NAME(isEnd):
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code:
							state = SELF_CLOSING_START_TAG;
						case '>'.code:
							state = DATA;
							if (isEnd)
								tb.consumeToken( END_TAG( currentEndTagName ) );
							else
								tb.consumeToken( START_TAG ( currentStartTagName ) );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							if (isEnd)
								currentEndTagName += String.fromCharCode( c + 0x20 );
							else
								currentStartTagName += String.fromCharCode( c + 0x20 );
						case 0:
							//TODO parse error
							if (isEnd)
								currentEndTagName += String.fromCharCode( 0xFFFD );
							else
								currentStartTagName += String.fromCharCode( 0xFFFD );
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Reconsume the EOF character. ?
						case _:
							if (isEnd)
								currentEndTagName += String.fromCharCode( c );
							else
								currentStartTagName += String.fromCharCode( c );
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
							//Reconsume the current input character ?!
					}
				case RCDATA_END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentEndTagName = String.fromCharCode( c + 0x20 );
							tempBuffer.addChar( c );
							state = RCDATA_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentEndTagName = String.fromCharCode( c );
							tempBuffer.addChar( c );
							state = RCDATA_END_TAG_NAME;
						case _:
							state = RCDATA;
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( '/'.code ) );
							//TODO Reconsume the current input character ?!
					}
				case RCDATA_END_TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if ( currentStartTagName == currentEndTagName ):
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code if ( currentStartTagName == currentEndTagName ):
							state = SELF_CLOSING_START_TAG;
						case '>'.code if ( currentStartTagName == currentEndTagName ):
							state = DATA;
							tb.consumeToken( /* TODO emit the current tag token. Base determination of start or end on the CurrentTag class */ );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							//TODO Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current tag token's tag name.
							tempBuffer.addChar( c );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							//TODO Append the current input character to the current tag token's tag name.
							tempBuffer.addChar( c );
						case _:
							state = RCDATA;
							tb.consumeToken( CHAR( '>'.code ) );
							tb.consumeToken( CHAR( '/'.code ) );
							for (tc in tempBuffer)
							{
								tb.consumeToken( CHAR( tc ) );
							}
							//TODO Reconsume the current input character.
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
							//TODO Reconsume the current input character.
					}
				case RAWTEXT_END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentEndTagName = String.fromCharCode( c + 0x20 );
							tempBuffer.add(c);
							state = RAWTEXT_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentEndTagName = String.fromCharCode( c );
							tempBuffer.add(c);
							state = RAWTEXT_END_TAG_NAME;
						case _:
							state = RAWTEXT;
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							//TODO Reconsume the current input character.
					}
				case RAWTEXT_END_TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if(currentEndTagName == currentStartTagName):
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code if(currentEndTagName == currentStartTagName):
							state = SELF_CLOSING_START_TAG;
						case '>'.code if(currentEndTagName == currentStartTagName):
							state = DATA;
							tb.consumeToken( /* TODO manage end and start tokens in CurrentToken class */ );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// TODO manage CurrentToken name
							// TODO Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current tag token's tag name
							tempBuffer.add( c );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							// TODO manage CurrentToken name
							// TODO Append the current input character to the current tag token's tag name
							tempBuffer.add( c );
						case _:
							state = RAWTEXT;
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							for (tc in tempBuffer)
							{
								tb.consumeToken( CHAR( tc ) );
							}
							//TODO Reconsume the current input character.
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
							//TODO Reconsume the current input character.
					}
					
				case SCRIPT_DATA_END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentEndTagName = String.fromCharCode( c + 0x20 );
							tempBuffer.add(c);
							state = SCRIPT_DATA_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentEndTagName = String.fromCharCode( c );
							tempBuffer.add(c);
							state = SCRIPT_DATA_END_TAG_NAME;
						case _:
							state = DATA;
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( '/'.code ) );
							//TODO Reconsume the current input character.
					}
				case SCRIPT_DATA_END_TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if(currentEndTagName == currentStartTagName):
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code if(currentEndTagName == currentStartTagName):
							state = SELF_CLOSING_START_TAG;
						case '>'.code if(currentEndTagName == currentStartTagName):
							state = DATA;
							tb.consumeToken( /* TODO manage end and start tokens in CurrentToken class */ );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// TODO manage CurrentToken name
							// TODO Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current tag token's tag name
							tempBuffer.add( c );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							// TODO manage CurrentToken name
							// TODO Append the current input character to the current tag token's tag name
							tempBuffer.add( c );
						case _:
							state = SCRIPT_DATA;
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							for (tc in tempBuffer)
							{
								tb.consumeToken( CHAR( tc ) );
							}
							//TODO Reconsume the current input character.
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
							// TODO Reconsume the current input character.
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
							// TODO Reconsume the current input character.
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
							//TODO Reconsume the EOF character.
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
							//TODO Reconsume the EOF character.
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
							//TODO Reconsume the EOF character.
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
							//TODO Reconsume the current input character.
					}
				case SCRIPT_DATA_ESCAPED_END_TAG_OPEN:
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							currentEndTagName = String.fromCharCode( c + 0x20 );
							tempBuffer.add( c );
							state = SCRIPT_DATA_ESCAPED_END_TAG_NAME;
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							currentEndTagName = String.fromCharCode( c );
							tempBuffer.add( c );
							state = SCRIPT_DATA_ESCAPED_END_TAG_NAME;
						case _:
							state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR( '<'.code ) );
							tb.consumeToken( CHAR( '/'.code ) );
							//TODO Reconsume the current input character.
					}
				case SCRIPT_DATA_ESCAPED_END_TAG_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20 if(currentEndTagName == currentStartTagName):
							state = BEFORE_ATTRIBUTE_NAME;
						case '/'.code if(currentEndTagName == currentStartTagName):
							state = SELF_CLOSING_START_TAG;
						case '>'.code if(currentEndTagName == currentStartTagName):
							state = DATA;
							tb.consumeToken( /* TODO manage end and start tokens in CurrentToken class */ );
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// TODO manage CurrentToken name
							// TODO Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current tag token's tag name
							tempBuffer.add( c );
						case x if ( x >= 'a'.code && x <= 'z'.code ):
							// TODO manage CurrentToken name
							// TODO Append the current input character to the current tag token's tag name
							tempBuffer.add( c );
						case _:
							state = SCRIPT_DATA_ESCAPED;
							tb.consumeToken( CHAR('<'.code) );
							tb.consumeToken( CHAR('/'.code) );
							for (tc in tempBuffer)
							{
								tb.consumeToken( CHAR( tc ) );
							}
							//TODO Reconsume the current input character.
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
							//TODO Reconsume the current input character.
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
							//TODO Reconsume the EOF character.
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
							//TODO Reconsume the EOF character.
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
							//TODO Reconsume the EOF character.
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
							//TODO Reconsume the current input character.
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
							//TODO Reconsume the current input character.
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
							// TODO manage CurrentToken
							// TODO Start a new attribute in the current tag token. 
							//		Set that attribute's name to the lowercase version of the current input character (add 0x0020 to the character's code point), 
							//		and its value to the empty string
							state = ATTRIBUTE_NAME;
						case 0:
							//TODO parse error
							// TODO manage CurrentToken
							// TODO Start a new attribute in the current tag token. 
							//		Set that attribute's name to a U+FFFD REPLACEMENT CHARACTER character, 
							//		and its value to the empty string
							state = ATTRIBUTE_NAME;
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Reconsume the EOF character.
						case _:
							if (Lambda.has([0x22, 0x27, '<'.code, '='.code], c))// quotation mark, apostrophe, ...
							{
								//TODO parse error
							}
							// TODO manage CurrentToken
							//TODO Start a new attribute in the current tag token. Set that attribute's name to the current input character, and its value to the empty string.
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
							//TODO Emit the current tag token.
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// TODO manage CurrentToken
							// TODO Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current attribute's name.
						case 0:
							//TODO parse error
							// TODO manage CurrentToken
							// TODO Append a U+FFFD REPLACEMENT CHARACTER character to the current attribute's name.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Reconsume the EOF character.
						case _:
							if (Lambda.has([0x22, 0x27, '<'.code], c))// quotation mark, apostrophe, ...
							{
								//TODO parse error
							}
							// TODO manage CurrentToken
							//TODO Append the current input character to the current attribute's name.
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
							//TODO Emit the current tag token.
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							// TODO manage CurrentToken
							// TODO Start a new attribute in the current tag token. 
							//		Set that attribute's name to the lowercase version of the current input character (add 0x0020 to the character's code point), 
							//		and its value to the empty string
							state = ATTRIBUTE_NAME;
						case 0:
							//TODO parse error
							// TODO manage CurrentToken
							// TODO Start a new attribute in the current tag token. 
							//		Set that attribute's name to a U+FFFD REPLACEMENT CHARACTER character, and its value to the empty string.
							state = ATTRIBUTE_NAME;
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Reconsume the EOF character.
						case _:
							if (Lambda.has([0x22, 0x27, '<'.code], c))// quotation mark, apostrophe, ...
							{
								//TODO parse error
							}
							// TODO manage CurrentToken
							//TODO Start a new attribute in the current tag token. Set that attribute's name to the current input character, and its value to the empty string.
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
							//TODO  Reconsume the current input character.
						case 0x27: //apostrophe
							state = ATTRIBUTE_VALUE_STATE( SINGLE_QUOTED );
						case 0:
							//TODO parse error
							//TODO Append a U+FFFD REPLACEMENT CHARACTER character to the current attribute's value.
							state = ATTRIBUTE_VALUE_STATE( UNQUOTED );
						case '>'.code:
							//TODO parse error
							state = DATA;
							// TODO Emit the current tag token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Reconsume the EOF character.
						case _:
							if (Lambda.has(['<'.code, '='.code, 0x60], c))
							{
								//TODO parse error
							}
							// TODO manage CurrentToken
							//TODO Append the current input character to the current attribute's value.
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
							//TODO Emit the current tag token.
						case 0:
							//TODO parse error
							//TODO Append a U+FFFD REPLACEMENT CHARACTER character to the current attribute's value.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Reconsume the EOF character.
						case _:
							if ( q == UNQUOTED && Lambda.has([0x22, 0x27, 0x3C, 0x3D, 0x60], c) )
							{
								//TODO parse error
							}
							//TODO Append the current input character to the current attribute's value.
					}
				case CHARACTER_REFERENCE_IN_ATTRIBUTE_VALUE( q ):
					var cr = is.nextCharRef( q == DOUBLE_QUOTED ? 0x22 : ( q == UNQUOTED ? '>'.code : 0x27 ) );
					
					if ( cr[0] == -2 )
					{
						//TODO append a U+0026 AMPERSAND character (&) to the current attribute's value.
					}
					else
					{
						for ( cri in cr )
						{
							// TODO append the returned character tokens to the current attribute's value.
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
							//TODO Emit the current tag token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							state = BEFORE_ATTRIBUTE_NAME;
							//TODO Reconsume the character.
					}
				case SELF_CLOSING_START_TAG:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '>'.code:
							//TODO Set the self-closing flag of the current tag token.
							state = DATA;
							//TODO Emit the current tag token.
						case -1:
							//TODO parse error
							state = DATA;
							// TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							state = BEFORE_ATTRIBUTE_NAME;
							//TODO Reconsume the character.
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

					//TODO If the end of the file was reached, reconsume the EOF character.
				case MARKUP_DECLARATION_OPEN:
					if ( is.consumeString("--") )
					{
						//TODO create a comment token whose data is the empty string,
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
							//TODO Append a U+FFFD REPLACEMENT CHARACTER character to the comment token's data
							state = COMMENT;
						case '>'.code:
							//TODO parse error
							state = DATA;
							//TODO Emit the comment token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Emit the comment token.
							//TODO Reconsume the EOF character.
						case _:
							//TODO Append the current input character to the comment token's data.
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
							//TODO Append a "-" (U+002D) character and a U+FFFD REPLACEMENT CHARACTER character to the comment token's data. 
							state = COMMENT;
						case '>'.code:
							//TODO parse error
							state = DATA;
							//TODO Emit the comment token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Emit the comment token. 
							//TODO Reconsume the EOF character.
						case _:
							//TODO Append a "-" (U+002D) character and the current input character to the comment token's data.
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
							//TODO Append a U+FFFD REPLACEMENT CHARACTER character to the comment token's data.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Emit the comment token.
							//TODO Reconsume the EOF character.
						case _:
							//TODO Append the current input character to the comment token's data.
					}
				case COMMENT_END_DASH:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							state = COMMENT_END;
						case 0:
							//TODO parse error
							//TODO Append a "-" (U+002D) character and a U+FFFD REPLACEMENT CHARACTER character to the comment token's data.
							state = COMMENT;
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Emit the comment token.
							//TODO Reconsume the EOF character.
						case _:
							//TODO Append a "-" (U+002D) character and the current input character to the comment token's data
							state = COMMENT;
					}
				case COMMENT_END:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '>'.code:
							state = DATA;
							//TODO Emit the comment token.
						case 0:
							//TODO parse error
							//TODO Append two "-" (U+002D) characters and a U+FFFD REPLACEMENT CHARACTER character to the comment token's data.
							state = COMMENT;
						case '!'.code:
							//TODO parse error
							state = COMMENT_END_BANG;
						case '-'.code:
							//TODO parse error
							//TODO Append a "-" (U+002D) character to the comment token's data.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Emit the comment token.
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							//TODO Append two "-" (U+002D) characters and the current input character to the comment token's data.
							state = COMMENT;
					}
				case COMMENT_END_BANG:
					c = is.nextInputChar();
					
					switch(c)
					{
						case '-'.code:
							//TODO Append two "-" (U+002D) characters and a "!" (U+0021) character to the comment token's data.
							state = COMMENT_END_DASH;
						case '>'.code:
							state = DATA;
							//TODO Emit the comment token.
						case 0:
							//TODO parse error
							//TODO Append two "-" (U+002D) characters, a "!" (U+0021) character, and a U+FFFD REPLACEMENT CHARACTER character to the comment token's data
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
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							state = BEFORE_DOCTYPE_NAME;
							//TODO Reconsume the character.
					}
				case BEFORE_DOCTYPE_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							//TODO Create a new DOCTYPE token. Set the token's name to the lowercase version of the current input character (add 0x0020 to the character's code point). 
							state = DOCTYPE_NAME;
						case 0:
							//TODO parse error
							//TODO Create a new DOCTYPE token. Set the token's name to a U+FFFD REPLACEMENT CHARACTER character
							state = DOCTYPE_NAME;
						case '>'.code:
							//TODO parse error
							state = DATA;
							tb.consumeToken( DOCTYPE( true ) );
						case _:
							//TODO Create a new DOCTYPE token. Set the token's name to the current input character.
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
							//TODO Emit the current DOCTYPE token.
						case x if ( x >= 'A'.code && x <= 'Z'.code ):
							//TODO Append the lowercase version of the current input character (add 0x0020 to the character's code point) to the current DOCTYPE token's name.
						case 0:
							//TODO parse error
							//TODO Append a U+FFFD REPLACEMENT CHARACTER character to the current DOCTYPE token's name.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							//TODO Emit that DOCTYPE token. 
							//TODO Reconsume the EOF character.
						case _:
							//TODO Append the current input character to the current DOCTYPE token's name.
					}
				case AFTER_DOCTYPE_NAME:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case '>'.code:
							state = DATA;
							//TODO Emit the current DOCTYPE token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							//TODO Emit that DOCTYPE token. 
							//TODO Reconsume the EOF character.
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
								//TODO Set the DOCTYPE token's force-quirks flag to on
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
							//TODO Set the DOCTYPE token's public identifier to the empty string (not missing)
							state = DOCTYPE_PUBLIC_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO parse error
							//TODO Set the DOCTYPE token's public identifier to the empty string (not missing)
							state = DOCTYPE_PUBLIC_IDENTIFIER( SINGLE_QUOTED );
						case '>'.code:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on. Switch to the data state. Emit that DOCTYPE token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on.
							//TODO Emit that DOCTYPE token.
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on
							state = BOGUS_DOCTYPE;
					}
				case BEFORE_DOCTYPE_PUBLIC_IDENTIFIER:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case 0x22:
							//TODO Set the DOCTYPE token's public identifier to the empty string (not missing)
							state = DOCTYPE_PUBLIC_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO Set the DOCTYPE token's public identifier to the empty string (not missing)
							state = DOCTYPE_PUBLIC_IDENTIFIER( SINGLE_QUOTED );
						case '>'.code:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							state = DATA;
							//TODO Emit that DOCTYPE token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on.
							//TODO Emit that DOCTYPE token.
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on.
							state = BOGUS_DOCTYPE;
					}
				case DOCTYPE_PUBLIC_IDENTIFIER( q : Quotation ): // DOUBLE_QUOTED & SINGLE_QUOTED
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( q == DOUBLE_QUOTED && x == 0x22 || q == SINGLE_QUOTED && x == 0x27 ):
							state = AFTER_DOCTYPE_PUBLIC_IDENTIFIER;
						case 0:
							//TODO parse error
							//TODO Append a U+FFFD REPLACEMENT CHARACTER character to the current DOCTYPE token's public identifier.
						case '>'.code:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on.
							//TODO Switch to the data state.
							//TODO Emit that DOCTYPE token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on.
							//TODO Emit that DOCTYPE token.
							//TODO Reconsume the EOF character.
						case _:
							//TODO Append the current input character to the current DOCTYPE token's public identifier.
					}
				case AFTER_DOCTYPE_PUBLIC_IDENTIFIER:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							state = BETWEEN_DOCTYPE_PUBLIC_AND_SYSTEM_IDENTIFIERS;
						case '>'.code:
							state = DATA;
							//TODO Emit the current DOCTYPE token.
						case 0x22:
							//TODO parse error
							//TODO Set the DOCTYPE token's system identifier to the empty string (not missing)
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO parse error
							//TODO Set the DOCTYPE token's system identifier to the empty string (not missing)
							state = DOCTYPE_SYSTEM_IDENTIFIER( SINGLE_QUOTED );
						case -1:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							//TODO Emit that DOCTYPE token. 
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on.
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
							//TODO Emit the current DOCTYPE token.
						case 0x22:
							//TODO Set the DOCTYPE token's system identifier to the empty string (not missing)
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO Set the DOCTYPE token's system identifier to the empty string (not missing)
							state = DOCTYPE_SYSTEM_IDENTIFIER( SINGLE_QUOTED );
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							//TODO Emit that DOCTYPE token. 
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on.
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
							//TODO Set the DOCTYPE token's system identifier to the empty string (not missing)
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO parse error
							//TODO Set the DOCTYPE token's system identifier to the empty string (not missing)
							state = DOCTYPE_SYSTEM_IDENTIFIER( SINGLE_QUOTED );
						case '>'.code:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							//TODO Emit that DOCTYPE token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on.
							//TODO Emit that DOCTYPE token.
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on.
							state = BOGUS_DOCTYPE;
					}
				case BEFORE_DOCTYPE_SYSTEM_IDENTIFIER:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case 0x22:
							//TODO Set the DOCTYPE token's system identifier to the empty string (not missing)
							state = DOCTYPE_SYSTEM_IDENTIFIER( DOUBLE_QUOTED );
						case 0x27:
							//TODO Set the DOCTYPE token's system identifier to the empty string (not missing)
							state = DOCTYPE_SYSTEM_IDENTIFIER( SINGLE_QUOTED );
						case '>'.code:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. Emit that DOCTYPE token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							//TODO Emit that DOCTYPE token. 
							//TODO Reconsume the EOF character.
						case _:
							//TODO parse error
							//TODO Set the DOCTYPE token's force-quirks flag to on.
							state = BOGUS_DOCTYPE;
					}
				case DOCTYPE_SYSTEM_IDENTIFIER( q : Quotation ): // DOUBLE_QUOTED & SINGLE_QUOTED
					c = is.nextInputChar();
					
					switch(c)
					{
						case x if ( x == 0x22 && q == DOUBLE_QUOTED || x == 0x27 && q == SINGLE_QUOTED ):
							state = DOCTYPE_SYSTEM_IDENTIFIER;
						case 0:
							//TODO parse error
							//TODO Append a U+FFFD REPLACEMENT CHARACTER character to the current DOCTYPE token's system identifier.
						case '>'.code:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. Emit that DOCTYPE token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							//TODO Emit that DOCTYPE token. 
							//TODO Reconsume the EOF character.
						case _:
							//TODO Append the current input character to the current DOCTYPE token's system identifier.
					}
				case AFTER_DOCTYPE_SYSTEM_IDENTIFIER:
					c = is.nextInputChar();
					
					switch(c)
					{
						case 0x9, 0xA, 0xC, 0x20:
							//Ignore the character.
						case '>'.code:
							state = DATA;
							//TODO Emit the current DOCTYPE token.
						case -1:
							//TODO parse error
							state = DATA;
							//TODO Set the DOCTYPE token's force-quirks flag to on. 
							//TODO Emit that DOCTYPE token. 
							//TODO Reconsume the EOF character.
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
							//TODO Emit the DOCTYPE token.
						case -1:
							state = DATA;
							//TODO Emit the DOCTYPE token.
							//TODO Reconsume the EOF character.
						case _:
							//Ignore the character.
					}
				case CDATA_SECTION:
					state = DATA;
					
					//TODO Consume every character up to the next occurrence of the three character sequence U+005D RIGHT SQUARE BRACKET U+005D RIGHT SQUARE BRACKET U+003E GREATER-THAN SIGN (]]>), or the end of the file (EOF), whichever comes first. Emit a series of character tokens consisting of all the characters consumed except the matching three character sequence at the end (if one was found before the end of the file).

					//TODO If the end of the file was reached, reconsume the EOF character.
				case _:
					throw "ERROR unknown Tokenizer state";
			}
		}
		
	}
}