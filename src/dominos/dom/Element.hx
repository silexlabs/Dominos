package dominos.dom;

/**
 * The Element interface represents an element in an HTML or XML document. 
 * Elements may have attributes associated with them; since the Element interface inherits from Node, 
 * the generic Node interface attribute attributes may be used to retrieve the set of all attributes 
 * for an element. There are methods on the Element interface to retrieve either an Attr object by 
 * name or an attribute value by name. In XML, where an attribute value may contain entity references, 
 * an Attr object should be retrieved to examine the possibly fairly complex sub-tree representing the
 * attribute value. On the other hand, in HTML, where all attributes have simple string values, methods
 * to directly access an attribute value can safely be used as a convenience.
 * 
 * Documentation for this class was provided by <a href="https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#element">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class Element extends Node
{
	//TODO readonly attribute DOMString? namespaceURI;
	//TODO readonly attribute DOMString? prefix;
	//TODO readonly attribute DOMString localName;
	//readonly attribute DOMString tagName;
	public var tagName( default, never ) : DOMString;

	//TODO attribute DOMString id;
	//TODO attribute DOMString className;
	//TODO readonly attribute DOMTokenList classList;

	/**
	 * The attributes attribute must return a read only array of the context object's attribute list. 
	 * TODO The returned read only array must be live. I.e. changes to the associated attributes are reflected.
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-attributes
	 */
	//readonly attribute Attr[] attributes;
	public var attributes( default, never ) : Array<Attr>;
	
	//DOMString? getAttribute(DOMString name);
	public function getAttribute( name : DOMString ) : DOMString { }

	//DOMString? getAttributeNS(DOMString? namespace, DOMString localName);
	public function getAttributeNS( namespaceURI : DOMString, localName : DOMString ) : DOMString { }

	//void setAttribute(DOMString name, DOMString value);
	public function setAttribute( name : DOMString , value : DOMString ) : Void { }
	
	//void setAttributeNS(DOMString? namespace, DOMString name, DOMString value);
	public function setAttributeNS( namespaceURI : DOMString, qualifiedName : DOMString, value : DOMString ) : Void { }

	//void removeAttribute(DOMString name);
	public function removeAttribute( name : DOMString ) : Void { }

	//void removeAttributeNS(DOMString? namespace, DOMString localName);
	public function removeAttributeNS( namespaceURI : DOMString, localName : DOMString) : Void { }

	//boolean hasAttribute(DOMString name);
	public function hasAttribute( name : DOMString ) : Bool { }

	//boolean hasAttributeNS(DOMString? namespace, DOMString localName);
	public function hasAttributeNS( namespaceURI : DOMString, localName : DOMString ) : Bool { }

	//HTMLCollection getElementsByTagName(DOMString localName);
	public function getElementsByTagName( name : DOMString ) : NodeList { } // FIXME return HTMLCollection?

	//HTMLCollection getElementsByTagNameNS(DOMString? namespace, DOMString localName);
	public function getElementsByTagNameNS( namespaceURI : DOMString, localName : DOMString ) : NodeList { } // FIXME return HTMLCollection?
	
	//HTMLCollection getElementsByClassName(DOMString classNames);
	public function getElementsByClassName( classNames : DOMString ) : NodeList { } // FIXME return HTMLCollection?

	//TODO readonly attribute HTMLCollection children;
	//TODO readonly attribute Element? firstElementChild;
	//TODO readonly attribute Element? lastElementChild;
	//TODO readonly attribute Element? previousElementSibling;
	//TODO readonly attribute Element? nextElementSibling;
	//TODO readonly attribute unsigned long childElementCount;

	// NEW
	//TODO void prepend((Node or DOMString)... nodes);
	//TODO void append((Node or DOMString)... nodes);
	//TODO void before((Node or DOMString)... nodes);
	//TODO void after((Node or DOMString)... nodes);
	//TODO void replace((Node or DOMString)... nodes);
	//TODO void remove();
}