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
 * The Node interface is the primary datatype for the entire Document Object Model. 
 * It represents a single node in the document tree. While all objects implementing 
 * the Node interface expose methods for dealing with children, not all objects 
 * implementing the Node interface may have children. For example, Text nodes may 
 * not have children, and adding children to such nodes results in a DOMException 
 * being raised.
 * 
 * The attributes nodeName, nodeValue and attributes are included as a mechanism to 
 * get at node information without casting down to the specific derived interface. 
 * In cases where there is no obvious mapping of these attributes for a specific 
 * nodeType (e.g., nodeValue for an Element or attributes for a Comment), this 
 * returns null. Note that the specialized interfaces may contain additional and more 
 * convenient mechanisms to get and set the relevant information. 
 * 
 * Documentation for this class was provided by <a href="https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#node">W3C</a>
 * 
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#node
 * @author Thomas Fétiveau
 */
class Node extends EventTarget
{
	// NodeType
	//const unsigned short
	public static inline var ELEMENT_NODE : Int                   = 1;
	public static inline var ATTRIBUTE_NODE : Int                 = 2; // historical
	public static inline var TEXT_NODE : Int                      = 3;
	public static inline var CDATA_SECTION_NODE : Int             = 4; // historical
	public static inline var ENTITY_REFERENCE_NODE : Int          = 5; // historical
	public static inline var ENTITY_NODE : Int                    = 6; // historical
	public static inline var PROCESSING_INSTRUCTION_NODE : Int    = 7;
	public static inline var COMMENT_NODE : Int                   = 8;
	public static inline var DOCUMENT_NODE : Int                  = 9;
	public static inline var DOCUMENT_TYPE_NODE : Int             = 10;
	public static inline var DOCUMENT_FRAGMENT_NODE : Int         = 11;
	public static inline var NOTATION_NODE : Int                  = 12; // historical

	// Document Position
	static inline var DOCUMENT_POSITION_DISCONNECTED			= 0x01;
	static inline var DOCUMENT_POSITION_PRECEDING				= 0x02;
	static inline var DOCUMENT_POSITION_FOLLOWING				= 0x04;
	static inline var DOCUMENT_POSITION_CONTAINS				= 0x08;
	static inline var DOCUMENT_POSITION_CONTAINED_BY			= 0x10;
	static inline var DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC	= 0x20;

	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-nodetype
	 */
	public var nodeType( get, null ) : Int;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-nodename
	 */
	public var nodeName( get, null ) : DOMString;

	//TODO? readonly attribute DOMString? baseURI;

	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-ownerdocument
	 */
	public var ownerDocument( get, null ) : Null<Document>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-parentnode
	 */
	public var parentNode( default, null ) : Null<Node>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#parent-element
	 */
	public var parentElement( get, null ) : Null<Element>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-childnodes
	 */
	public var childNodes( default, null ) : NodeList;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-tree-first-child
	 */
	public var firstChild( get, never ) : Null<Node>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-lastchild
	 */
	public var lastChild( get, never ) : Null<Node>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-previoussibling
	 */
	public var previousSibling( get, never ) : Null<Node>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-nextsibling
	 */
	public var nextSibling( get, never ) : Null<Node>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-nodevalue
	 */
	public var nodeValue( get, set ) : Null<DOMString>;
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-textcontent
	 */
	public var textContent( get, set ) : Null<DOMString>;

	/**
	 * 
	 */
	public function new()
	{
		//init childNodes list
		childNodes = [];
	}

	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-haschildnodes
	 */
	public function hasChildNodes() : Bool
	{
		return (childNodes.length > 0);
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-insertbefore
	 */
	public function insertBefore( node:Node, child:Null<Node> ) : Node
	{
		return DOMInternals.preInsert( node, this, child );
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-appendchild
	 */
	public function appendChild( newChild:Node ) : Node
	{
		return DOMInternals.append( newChild, this );
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-replacechild
	 */
	public function replaceChild( newChild:Node, oldChild:Node ) : Node
	{
		throw "Not Implemented!"; return oldChild;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-removechild
	 */
	public function removeChild( child:Node ) : Node
	{
		return DOMInternals.preRemove( child, this );
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-normalize
	 */
	public function normalize() : Void
	{
		throw "Not Implemented!";
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-clonenode
	 */
	public function cloneNode( ?deep:Bool = true ) : Node
	{
		throw "Not Implemented!"; return null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-isequalnode
	 */
	public function isEqualNode( node : Node ) : Bool
	{
		throw "Not Implemented!"; return false;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-comparedocumentposition
	 */
	public function compareDocumentPosition( other : Node ) : Int
	{
		throw "Not Implemented!"; return 0;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-contains
	 */
	public function contains( other : Null<Node> ) : Bool
	{
		throw "Not Implemented!"; return false;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-lookupprefix
	 */
	public function lookupPrefix( namespaceURI : Null<DOMString> ) : Null<DOMString>
	{
		throw "Not Implemented!"; return null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-lookupnamespaceuri
	 */
	public function lookupNamespaceURI( prefix : Null<DOMString> ) : Null<DOMString>
	{
		throw "Not Implemented!"; return null;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-node-isdefaultnamespace
	 */
	public function isDefaultNamespace( namespaceURI : Null<DOMString> ) : Bool
	{
		throw "Not Implemented!"; return false;
	}
	
	////////////////////////////////////
	// PROPERTIES
	////////////////////////////////////
	
	public function get_nodeType() : Int
	{
		throw "Error: Unknown nodeType"; return nodeType;
	}
	public function get_nodeName() : DOMString
	{
		throw "Error: Unknown nodeName"; return nodeName;
	}
	public function get_ownerDocument() : Null<Document>
	{
		return ownerDocument;
	}
	public function get_parentElement() : Null<Element>
	{ trace(nodeName+" parentNode= "+parentNode);
		return ( parentNode != null && parentNode.nodeType != Node.ELEMENT_NODE ) ? null : cast parentNode;
	}
	public function get_firstChild() : Null<Node>
	{
		return ( childNodes.length > 0 ) ? childNodes[0] : null;
	}
	public function get_lastChild() : Null<Node>
	{
		return ( childNodes.length > 0 ) ? childNodes[childNodes.length-1] : null;
	}
	public function get_previousSibling() : Null<Node>
	{
		return DOMInternals.previousSibling( this );
	}
	public function get_nextSibling() : Null<Node>
	{
		return DOMInternals.nextSibling( this );
	}
	public function get_nodeValue() : Null<DOMString>
	{
		return null;
	}
	public function set_nodeValue( nv : DOMString ) : Null<DOMString>
	{
		//Do nothing.
		return null;
	}
	public function get_textContent() : Null<DOMString>
	{
		return null;
	}
	public function set_textContent( nv : DOMString ) : Null<DOMString>
	{
		//Do nothing.
		return null;
	}
}





















