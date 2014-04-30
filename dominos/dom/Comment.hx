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
 * This interface inherits from CharacterData and represents the content of a comment, 
 * i.e., all the characters between the starting '<!--' and ending '-->'. Note that 
 * this is the definition of a comment in XML, and, in practice, HTML, although some 
 * HTML tools may implement the full SGML comment structure.
 * 
 * No lexical check is done on the content of a comment and it is therefore possible 
 * to have the character sequence "--" (double-hyphen) in the content, which is 
 * illegal in a comment per section 2.5 of [XML 1.0]. The presence of this character
 * sequence must generate a fatal error during serialization. 
 * 
 * Documentation for this class was provided by <a href="https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#comment">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class Comment extends CharacterData
{
	
	@:allow(dominos.dom.Document.createComment)
	private function new()
	{
		super();
	}
	
	//////////////////////////////
	// PROPERTIES
	//////////////////////////////
	
	override public function get_nodeType() : Int
	{
		return Node.COMMENT_NODE;
	}
	override public function get_nodeName() : DOMString
	{
		return "#comment";
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