package dominos.dom;

/**
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-doctype
 * 
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

	/**
	 * When a doctype is created, its name is always given. Unless explicitly given when a doctype is created, its public ID and system ID are the empty string. 
	 * @param	name
	 * @param	?publicId
	 * @param	?systemId
	 */
	public function new( name : DOMString, ?publicId : DOMString = "", ?systemId : DOMString = "" )
	{
		super();
		this.name = name;
		this.publicId = publicId;
		this.systemId = systemId;
	}
	// NEW
	//void before((Node or DOMString)... nodes);
	
	//void after((Node or DOMString)... nodes);
	
	//void replace((Node or DOMString)... nodes);
	
	//void remove();
	
}