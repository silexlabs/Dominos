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

	//readonly attribute unsigned short   nodeType;
	public var nodeType( default, never ) : Int;

	//readonly attribute DOMString        nodeName;
	public var nodeName( default, never ) : DOMString;

	//TODO readonly attribute DOMString? baseURI;

	//readonly attribute Document? ownerDocument;
	public var ownerDocument( default, never ) : Document;

	//readonly attribute Node             parentNode;
	public var parentNode( default, never ) : Node;
	
	//TODO readonly attribute Element? parentElement;
	
	//readonly attribute NodeList         childNodes;
	public var childNodes( default, never ) : NodeList;
	
	//readonly attribute Node             firstChild;
	public var firstChild( default, never ) : Node;
	
	//readonly attribute Node             lastChild;
	public var lastChild( default, never ) : Node;
	
	//readonly attribute Node             previousSibling;
	public var previousSibling( default, never ) : Node;
	
	//readonly attribute Node             nextSibling;
	public var nextSibling( default, never ) : Node;
	
	//attribute DOMString? nodeValue;
	public var nodeValue:DOMString;
	
	//attribute DOMString? textContent;
	public var textContent : DOMString;
	
	public function new()
	{
		//init childNodes list
		childNodes = [];
	}
	
	//Node insertBefore(Node node, Node? child);
	public function insertBefore( newChild:Node, refChild:Node ) : Node { }
	
	
	//Node appendChild(Node node);
	public function appendChild( newChild:Node ) : Node { }
	
	//Node replaceChild(Node node, Node child);
	public function replaceChild( newChild:Node, oldChild:Node ) : Node { }
	
	//Node removeChild(Node child);
	public function removeChild( oldChild:Node ) : Node { }
	
	//void normalize();
	public function normalize() : Void {  }
	
	//Node cloneNode(optional boolean deep = true);
	public function cloneNode( ?deep:Bool = true ) { }
	
	//boolean isEqualNode(Node? node);
	public function isEqualNode( node : Node ) : Bool { }
	
		// DocumentPosition
	//const unsigned short      DOCUMENT_POSITION_DISCONNECTED = 0x01;
	static inline var DOCUMENT_POSITION_DISCONNECTED			= 0x01;
	//const unsigned short      DOCUMENT_POSITION_PRECEDING    = 0x02;
	static inline var DOCUMENT_POSITION_PRECEDING				= 0x02;
	//const unsigned short      DOCUMENT_POSITION_FOLLOWING    = 0x04;
	static inline var DOCUMENT_POSITION_FOLLOWING				= 0x04;
	//const unsigned short      DOCUMENT_POSITION_CONTAINS     = 0x08;
	static inline var DOCUMENT_POSITION_CONTAINS				= 0x08;
	//const unsigned short      DOCUMENT_POSITION_CONTAINED_BY = 0x10;
	static inline var DOCUMENT_POSITION_CONTAINED_BY			= 0x10;
	//const unsigned short      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 0x20;
	static inline var DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC	= 0x20;
	
	//unsigned short compareDocumentPosition(Node other);
	public function compareDocumentPosition( other : Node ) : Int { }

	//TODO boolean contains(Node? other);

	//DOMString? lookupPrefix(DOMString? namespace);
	public function lookupPrefix( namespaceURI : DOMString ) : DOMString { }

	//DOMString? lookupNamespaceURI(DOMString? prefix);
	public function lookupNamespaceURI( prefix : DOMString ) : DOMString { }
	
	//boolean isDefaultNamespace(DOMString? namespace);
	public function isDefaultNamespace( namespaceURI : DOMString ) : Bool { }
}