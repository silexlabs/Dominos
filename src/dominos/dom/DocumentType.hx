package dominos.dom;

/**
 * ...
 * @author Thomas Fétiveau
 */
class DocumentType extends Node
{
	//readonly attribute DOMString name;
	public var name( default, never ) : DOMString;
	//readonly attribute DOMString publicId;
	public var publicId( default, never ) : DOMString;
	//readonly attribute DOMString systemId;
	public var systemId( default, never ) : DOMString;

	// NEW
	//void before((Node or DOMString)... nodes);
	
	//void after((Node or DOMString)... nodes);
	
	//void replace((Node or DOMString)... nodes);
	
	//void remove();
	
}