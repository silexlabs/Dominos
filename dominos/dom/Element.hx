/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.dom;

import dominos.html.HTMLCollection;

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
 * @see http://dom.spec.whatwg.org/#element
 * @author Thomas Fétiveau
 */
class Element extends Node
{
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-namespaceuri
	 */
	public var namespaceURI( default, null ) : Null<DOMString>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-prefix
	 */
	public var prefix( default, null ) : Null<DOMString>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-localname
	 */
	public var localName( default, null ) : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-tagname
	 */
	public var tagName( get, never ) : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-id
	 */
	public var id : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-classname
	 */
	public var className : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-classlist
	 */
	//TODO readonly attribute DOMTokenList classList;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-attributes
	 */
	public var attributes( default, null ) : Array<Attr>;
	
	//TODO readonly attribute HTMLCollection children;
	//TODO readonly attribute Element? firstElementChild;
	//TODO readonly attribute Element? lastElementChild;
	//TODO readonly attribute Element? previousElementSibling;
	//TODO readonly attribute Element? nextElementSibling;
	//TODO readonly attribute unsigned long childElementCount;

	/*
	[TreatNullAs=EmptyString]
                attribute DOMString innerHTML;
    */
    public var innerHTML (get, set) : String;

    /*
    [TreatNullAs=EmptyString]
                attribute DOMString outerHTML;
    */
	
	@:allow(dominos.dom.Document.createElement)
	private function new( localName : String, ?namespaceURI : Null<DOMString> = null, ?prefix : Null<DOMString> = null )
	{
		super();
		this.attributes = [];
		this.localName = localName;
		this.namespaceURI = namespaceURI;
		this.prefix = prefix;
	}
	
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-getattribute
	 */
	public function getAttribute( name : DOMString ) : Null<DOMString>
	{
		//If the context object is in the HTML namespace and its node document is an HTML document, let name be converted to ASCII lowercase. 
		var a : Null<Attr> = DOMInternals.firstAttr( this, name.toLowerCase() );
		return (a != null) ? a.value : null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-getattributens
	 */
	public function getAttributeNS( namespaceURI : Null<DOMString>, localName : DOMString ) : Null<DOMString>
	{
		throw "Not implemented!"; return null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-setattribute
	 */
	public function setAttribute( name : DOMString , value : DOMString ) : Void
	{
		if ( !DOMInternals.isValid( name, "Name") )
		{
			throw "InvalidCharacterError";
		}
		//If the context object is in the HTML namespace and its node document is an HTML document, let name be converted to ASCII lowercase.
		name = name.toLowerCase(); //FIXME one day Dominos could manage other formats than HTML
		
		var a : Null<Attr> = DOMInternals.firstAttr( this, name );
		
		if (a == null)
		{
			a = new Attr( name, value );
			attributes.push( a );
		}
		else
		{
			//Not implemented: Queue a mutation record of "attributes" for context object with name attribute's local name, namespace attribute's namespace, and oldValue attribute's value.
			
			//Set attribute's value to value. 
			a.value = value;
		}
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-setattributens
	 */
	public function setAttributeNS( namespaceURI : DOMString, qualifiedName : DOMString, value : DOMString ) : Void
	{
		throw "Not implemented!";
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-removeattribute
	 */
	public function removeAttribute( name : DOMString ) : Void
	{
		throw "Not implemented!";
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-removeattributens
	 */
	public function removeAttributeNS( namespaceURI : DOMString, localName : DOMString) : Void
	{
		throw "Not implemented!";
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-hasattribute
	 */
	public function hasAttribute( name : DOMString ) : Bool
	{
		return ( getAttribute(name) != null );
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-hasattributens
	 */
	public function hasAttributeNS( namespaceURI : DOMString, localName : DOMString ) : Bool
	{
		throw "Not implemented!"; return false;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-getelementsbytagname
	 */
	public function getElementsByTagName( name : DOMString ) : HTMLCollection
	{
		throw "Not implemented!"; return [];
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-getelementsbytagnamens
	 */
	public function getElementsByTagNameNS( namespaceURI : DOMString, localName : DOMString ) : HTMLCollection
	{
		throw "Not implemented!"; return [];
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-element-getelementsbyclassname
	 */
	public function getElementsByClassName( classNames : DOMString ) : HTMLCollection
	{
		throw "Not implemented!"; return [];
	}

	//////////////////////////
	// PROPERTIES
	//////////////////////////

	public function get_innerHTML() : String {

		return dominos.parser.HTMLSerializer.serialize(this);
	}

	public function set_innerHTML(markup : String) : String {

		var fe : DocumentFragment = new DocumentFragment();

		for (c in dominos.parser.HTMLParser.parseFragment(markup, this)) {

			fe.appendChild(c);
		}
		DOMInternals.replaceAll(fe, this);

		return markup;
	}
	
	public function get_tagName() : DOMString
	{
		//TODO If context object's namespace prefix is not null, let qualified name be its namespace prefix, followed by a ":" (U+003A), followed by its local name. 
		//Otherwise, let qualified name be its local name. 
		
		//If the context object is in the HTML namespace and its node document is an HTML document, let qualified name be converted to ASCII uppercase. 
		return localName.toUpperCase();
	}
	override public function get_nodeType() : Int
	{
		return Node.ELEMENT_NODE;
	}
	override public function get_nodeName() : DOMString
	{
		return tagName;
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