package dominos.dom;

/**
 * @see http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-637646024
 * 
 * @author Thomas Fétiveau
 */
class Attr
{
	/**
	 * @see http://dom.spec.whatwg.org/#dom-attr-localname
	 */
	public var localName( default, null ) : DOMString;
	/**
	 * @see http://dom.spec.whatwg.org/#dom-attr-value
	 */
	public var value : DOMString;
	/**
	 * @see http://dom.spec.whatwg.org/#dom-attr-name
	 */
	public var name( get, null ) : DOMString;
	/**
	 * @see http://dom.spec.whatwg.org/#dom-attr-namespaceuri
	 */
	public var namespaceURI( default, null ) : Null<DOMString>;
	/**
	 * @see http://dom.spec.whatwg.org/#dom-attr-prefix
	 */
	public var prefix( default, null ) : Null<DOMString>;
	
	@:allow(dominos.dom.Element.setAttribute)
	private function new( localName : DOMString, value : DOMString )
	{
		this.localName = localName;
		this.value = value;
	}
	
	////////////////////////
	// Properties
	////////////////////////
	
	public function get_name() : DOMString
	{
		return localName;
	}
}