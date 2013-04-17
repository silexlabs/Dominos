package dominos.dom;

/**
 * @see http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-637646024
 * 
 * @author Thomas Fétiveau
 */
class Attr
{
	//readonly attribute DOMString       name;
	public var name( default, never ) : DOMString;

	//readonly attribute boolean         specified;
	public var specified( default, never ) : Bool;
	//attribute DOMString       value;
								// raises(DOMException) on setting
	public var value( default, never ) : DOMString;

	// Introduced in DOM Level 2:
	//readonly attribute Element         ownerElement;
	public var ownerElement( default, never ) : Element;

	// Introduced in DOM Level 3:
	//readonly attribute TypeInfo        schemaTypeInfo;
	public var schemaTypeInfo( default, never ) : TypeInfo;

	// Introduced in DOM Level 3:
	//readonly attribute boolean         isId;
	public var isId( default, never ) : Bool;
}