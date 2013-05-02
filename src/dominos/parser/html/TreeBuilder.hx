package dominos.parser.html;

import dominos.dom.Node;
import dominos.parser.html.Tokenizer;

enum InsertionMode
{
	INITIAL;
	BEFORE_HTML;
	BEFORE_HEAD;
	IN_HEAD;
	IN_HEAD_NOSCRIPT;
	AFTER_HEAD;
	IN_BODY;
	TEXT;
	IN_TABLE;
	IN_TABLE_TEXT;
	IN_CAPTION;
	IN_COLUMN_GROUP;
	IN_TABLE_BODY;
	IN_ROW;
	IN_CELL;
	IN_SELECT;
	IN_SELECT_IN_TABLE;
	AFTER_BODY;
	IN_FRAMESET;
	AFTER_FRAMESET;
	AFTER_AFTER_BODY;
	AFTER_AFTER_FRAMESET;
}

/**
 * The TreeBuilder class handles the 
 * @author Thomas Fétiveau
 */
class TreeBuilder
{
	/**
	 * The insertion mode is a state variable that controls the primary operation of the tree construction stage.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-insertion-mode
	 */
	private var mode : InsertionMode;
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#original-insertion-mode
	 */
	private var originalMode : InsertionMode;
	
	/**
	 * The stack of open elements
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-stack-of-open-elements
	 */
	private var stack : Array<Node>;
	
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#list-of-active-formatting-elements
	 */
	private var activeFormatting : Map<Node, Node>;
	
	/**
	 * Once a head element has been parsed (whether implicitly or explicitly) the head 
	 * element pointer gets set to point to this node.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-element-pointers
	 */
	private var headPointer : Node;
	/**
	 * The form element pointer points to the last form element that was opened and 
	 * whose end tag has not yet been seen. It is used to make form controls associate 
	 * with forms in the face of dramatically bad markup, for historical reasons.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#the-element-pointers
	 */
	private var formPointer : Node;

	/**
	 * The scripting flag is set to "enabled" if scripting was enabled for the Document 
	 * with which the parser is associated when the parser was created, and "disabled" otherwise.
	 * 
	 * The scripting flag can be enabled even when the parser was originally created for the 
	 * HTML fragment parsing algorithm, even though script elements don't execute in that case.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#other-parsing-state-flags
	 */
	private var scriptingEnabled : Bool;
	/**
	 * The frameset-ok flag is set to "ok" when the parser is created. It is set to "not ok" 
	 * after certain tokens are seen.
	 * 
	 * @see http://www.w3.org/TR/html5/syntax.html#other-parsing-state-flags
	 */
	private var framesetOK : Bool;

	public function new() 
	{
		
	}
	
	/**
	 * The current node is the bottommost node in this stack.
	 */
	public getCurrentNode() : Node
	{
		
	}
	/**
	 * The current table is the last table element in the stack of open elements, 
	 * if there is one. If there is no table element in the stack of open elements 
	 * (fragment case), then the current table is the first element in the stack of 
	 * open elements (the html element).
	 */
	public getCurrentTable : Node
	{
		
	}
	
	/**
	 * 
	 */
	public function consumeToken( t : Token )
	{
		switch ( mode )
		{
			case INITIAL:
				switch ( t )
				{
					case CHAR(c) if(c.code == 0x9 || c.code == 0xA || c.code == 0xC || c.code == 0xD || c.code == 0x20): // CHARACTER TABULATION, "LF", "FF", "CR" or SPACE
						//Ignore the token.
					case COMMENT(d):
						//TODO
						//Append a Comment node to the Document object with the data attribute set to the data given in the comment token.
					case DOCTYPE( forceQuirks ):
						//TODO
						//@see http://www.w3.org/TR/html5/syntax.html#the-initial-insertion-mode
						
						mode = BEFORE_HTML;
					case _:
						//TODO
						//If the document is not an iframe srcdoc document, then this is a parse error; set the Document to quirks mode.
						//In any case, switch the insertion mode to "before html", then reprocess the current token.
						//@see Document.compatMode
				}
			case BEFORE_HTML:
			case BEFORE_HEAD:
			case IN_HEAD:
			case IN_HEAD_NOSCRIPT:
			case AFTER_HEAD:
			case IN_BODY:
			case TEXT:
			case IN_TABLE:
			case IN_TABLE_TEXT:
			case IN_CAPTION:
			case IN_COLUMN_GROUP:
			case IN_TABLE_BODY:
			case IN_ROW:
			case IN_CELL:
			case IN_SELECT:
			case IN_SELECT_IN_TABLE:
			case AFTER_BODY:
			case IN_FRAMESET:
			case AFTER_FRAMESET:
			case AFTER_AFTER_BODY:
			case AFTER_AFTER_FRAMESET:
		}
	}
}