package dominos.dom;

/**
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#documentfragment
 * @author Thomas Fétiveau
 */
class DocumentFragment extends Node
{
	//////////////////
	// PROPERTIES
	//////////////////
	override public function get_nodeType() : Int
	{
		return Node.DOCUMENT_FRAGMENT_NODE;
	}
	override public function get_nodeName() : DOMString
	{
		return "#document-fragment";
	}
	override public function get_textContent() : Null<DOMString>
	{
		throw "Not Implemented!"; return null;
	}
	override public function set_textContent( nv : DOMString ) : Null<DOMString>
	{
		throw "Not Implemented!"; return null;
	}
}