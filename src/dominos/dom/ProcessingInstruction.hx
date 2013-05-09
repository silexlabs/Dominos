package dominos.dom;

/**
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#processinginstruction
 * @author Thomas Fétiveau
 */
class ProcessingInstruction extends CharacterData
{
	//readonly attribute DOMString target;
	public var target(default, never) : DOMString;
	
	@:allow(dominos.dom.Document.createProcessingInstruction)
	private function new()
	{
		super();
	}
	
	////////////////////
	// PROPERTIES
	////////////////////
	override public function get_nodeType() : Int
	{
		return Node.PROCESSING_INSTRUCTION_NODE;
	}
	override public function get_nodeName() : DOMString
	{
		return target;
	}
	override public function get_nodeValue() : Null<DOMString>
	{
		return data;
	}
	override public function set_nodeValue( nv : DOMString ) : Null<DOMString>
	{
		data = DOMInternals.replaceData( this, 0, length, nv );
		return data;
	}
	override public function get_textContent() : Null<DOMString>
	{
		return data;
	}
	override public function set_textContent( nv : DOMString ) : Null<DOMString>
	{
		data = DOMInternals.replaceData( this, 0, length, nv );
		return data;
	}
}