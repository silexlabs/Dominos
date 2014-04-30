/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.dom; 

/**
 * The Text interface inherits from CharacterData and represents the textual content 
 * (termed character data in XML) of an Element or Attr. If there is no markup inside 
 * an element's content, the text is contained in a single object implementing the Text 
 * interface that is the only child of the element. If there is markup, it is parsed into 
 * the information items (elements, comments, etc.) and Text nodes that form the list of 
 * children of the element.
 * 
 * When a document is first made available via the DOM, there is only one Text node for 
 * each block of text. Users may create adjacent Text nodes that represent the contents of 
 * a given element without any intervening markup, but should be aware that there is no way 
 * to represent the separations between these nodes in XML or HTML, so they will not (in 
 * general) persist between DOM editing sessions. The Node.normalize() method merges any such 
 * adjacent Text objects into a single node for each block of text.
 * 
 * No lexical check is done on the content of a Text node and, depending on its position in 
 * the document, some characters must be escaped during serialization using character 
 * references; e.g. the characters "<&" if the textual content is part of an element or of an
 * attribute, the character sequence "]]>" when part of an element, the quotation mark 
 * character " or the apostrophe character ' when part of an attribute.
 * 
 * Documentation for this class was provided by <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-1312295772">W3C</a>
 * 
 * @see http://dom.spec.whatwg.org/#text
 * @author Thomas Fétiveau
 */
class Text extends CharacterData
{
	/**
	 * Returns the combined data of all direct Text node siblings. 
	 */
	public var wholeText( default, never ) : DOMString;
	
	/**
	 * Returns a new Text node whose data is data. 
	 */
	@:allow(dominos.dom.Document.createTextNode)
	private function new( ?data : DOMString = "" )
	{
		super();
		this.data = data;
	}
	
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-text-splittext
	 */
	public function splitText( offset : Int ) : Text
	{
		throw "Not implemented"; return this;
	}
	
	//////////////////
	// PROPERTIES
	//////////////////

	override public function get_nodeType() : Int
	{
		return Node.TEXT_NODE;
	}
	override public function get_nodeName() : DOMString
	{
		return "#text";
	}
	override public function get_nodeValue() : Null<DOMString>
	{
		return data;
	}
	override public function set_nodeValue( nv : DOMString ) : Null<DOMString>
	{
		DOMInternals.replaceData( this, 0, length, nv );
		return data;
	}
	override public function get_textContent() : Null<DOMString>
	{
		return data;
	}
	override public function set_textContent( nv : DOMString ) : Null<DOMString>
	{
		DOMInternals.replaceData( this, 0, length, nv );
		return data;
	}
}