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
 * The Document interface represents the entire HTML or XML document. Conceptually, it is the root of the document tree, 
 * and provides the primary access to the document's data.
 * 
 * Since elements, text nodes, comments, processing instructions, etc. cannot exist outside the context of a Document, 
 * the Document interface also contains the factory methods needed to create these objects. The Node objects created have
 * a ownerDocument attribute which associates them with the Document within whose context they were created. 
 * 
 * Documentation for this class was provided by <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#i-Document">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
@:allow(dominos.dom.DOMImplementation.createHTMLDocument)
class Document extends Node
{
	//Possible compat modes
	static private inline var COMPAT_QUIRKS : String = "BackCompat";
	static private inline var COMPAT_NO_OR_LIMITIED_QUIRKS : String = "CSS1Compat";
	
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-implementation
	 */
	public var implementation( default, null ) : DOMImplementation;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-url
	 */
	public var URL( default, null ) : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-documenturi
	 */
	public var documentURI( default, null ) : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-compatmode
	 */
	public var compatMode( default, null ) : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-characterset
	 */
	public var characterSet( default, null ) : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-contenttype
	 */
	public var contentType( default, null ) : DOMString;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-doctype
	 */
	public var doctype( default, null ) : DocumentType;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-documentelement
	 */
	public var documentElement( get, null ) : Element;
	
	//TODO When the value is set, the user agent must fire a simple event named readystatechange at the Document object.
	//@see http://www.whatwg.org/specs/web-apps/current-work/multipage/dom.html#dom-document-readystate
	//readonly attribute DocumentReadyState readyState;
	public var readyState( default, null ) : String; // can be "loading", "interactive", "complete"

	/**
	 * TODO The Document() constructor must return a new document whose origin is an alias to the origin of the global object's associated document, 
	 * and effective script origin is an alias to the effective script origin of the global object's associated document.
	 */
	private function new()
	{
		super();
	}

	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-getelementsbytagname
	 */
	public function getElementsByTagName( tagname : DOMString ) : HTMLCollection
	{
		throw "Not implemented!"; return [];
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-getelementsbytagnamens
	 */
	public function getElementsByTagNameNS( namespaceURI : Null<DOMString>, localName : DOMString ) : HTMLCollection
	{
		throw "Not implemented!"; return [];
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-getelementsbyclassname
	 */
	public function getElementsByClassName( classNames : DOMString ) : HTMLCollection
	{
		throw "Not implemented!"; return [];
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-getelementbyid
	 */
	public function getElementById(elementId : DOMString) : Null<Element>
	{
		return doGetElementById(documentElement, elementId);
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createelement
	 */
	public function createElement( localName : DOMString ) : Element
	{
		if ( !DOMInternals.isValid( localName, "Name" ) )
		{
			throw "InvalidCharacterError";
		}
		//If the context object is an HTML document, let localName be converted to ASCII lowercase. 
		localName = localName.toLowerCase(); // FIXME for the moment dominos support only HTML...
		
		var ne : Element = new Element( localName, DOMInternals.HTML_NAMESPACE ); // FIXME implement HTML element interfaces
		
		//switch ( localName )
		//{
			//case 
		//}
		
		DOMInternals.setNodeDocument( ne, this );

		return ne;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createelementns
	 */
	public function createElementNS( namespaceURI : Null<DOMString>, qualifiedName : DOMString ) : Element
	{
		throw "Not implemented!"; return null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createdocumentfragment
	 */
	public function createDocumentFragment() : DocumentFragment
	{
		throw "Not implemented!"; return null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createtextnode
	 */
	public function createTextNode( data : DOMString ) : Text
	{
		var t = new Text( data );
		DOMInternals.setNodeDocument( t, this );
		return t;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createcomment
	 */
	public function createComment( data : DOMString ) : Comment
	{
		var c = new Comment();
		c.data = data;
		DOMInternals.setNodeDocument( c, this );
		
		return c;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createprocessinginstruction
	 */
	public function createProcessingInstruction( target : DOMString, data : DOMString ) : ProcessingInstruction
	{
		throw "Not implemented!"; return null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-importnode
	 */
	public function importNode( node : Node, ?deep : Bool = true) : Node
	{
		throw "Not implemented!"; return null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-adoptnode
	 */
	public function adoptNode( node : Node ) : Node
	{
		return DOMInternals.adopt( node, this );
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createevent
	 */
	//Event createEvent(DOMString interface);
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createrange
	 */
	//Range createRange();
	
	// NodeFilter.SHOW_ALL = 0xFFFFFFFF
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createnodeiterator
	 */
	//NodeIterator createNodeIterator(Node root, optional unsigned long whatToShow = 0xFFFFFFFF, optional NodeFilter? filter = null);
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-document-createtreewalker
	 */
	//TreeWalker createTreeWalker(Node root, optional unsigned long whatToShow = 0xFFFFFFFF, optional NodeFilter? filter = null);
	
	//////////////////////////////////
	// PROPERTIES
	//////////////////////////////////

	public function get_documentElement() : Element {

		for (c in childNodes) {

			switch(c.nodeType) {

				case Node.ELEMENT_NODE:

					return cast c;

				default: // nothing
			}
		}
		return null; // that's bad !
	}
	
	override public function get_nodeType() : Int
	{
		return Node.DOCUMENT_NODE;
	}
	override public function get_nodeName() : DOMString
	{
		return "#document";
	}
	override public function get_ownerDocument() : Null<Document>
	{
		return null;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Actually return the Element matching the
	 * elementId, by traversing recursively the 
	 * DOM tree
	 */
	private function doGetElementById(node:Element, elementId:String):Element
	{
trace("doGetElementById node = "+node.tagName);
		//ID can only be matched by element node or descendant of element node
		if (node.nodeType == Node.ELEMENT_NODE)
		{
trace("node.getAttribute('id')= "+node.getAttribute("id")+"     elementId= "+elementId);
			// check ID attribute, returns null if no ID attribute for this node
			if (node.getAttribute("id") == elementId)
			{
				return node;
			}

			if (node.hasChildNodes() == true)
			{
				var length:Int = node.childNodes.length;
				for (i in 0...length)
				{
					if (node.childNodes[i].nodeType == Node.ELEMENT_NODE)
					{
						var matchingElement:Element = doGetElementById(cast(node.childNodes[i]), elementId);
						//if a matching element is found, return it
						if (matchingElement != null)
						{
							return matchingElement;
						}
					}
				}
			}
		}
		
		//at this point no element with a matching Id was found
		return null;
	}
}