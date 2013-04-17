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
 * Documentation for this class was provided by <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-1950641247">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class Node
{
	// NodeType
	//const unsigned short
	static inline var ELEMENT_NODE : Int                   = 1;
	static inline var ATTRIBUTE_NODE : Int                 = 2;
	static inline var TEXT_NODE : Int                      = 3;
	static inline var CDATA_SECTION_NODE : Int             = 4;
	static inline var ENTITY_REFERENCE_NODE : Int          = 5;
	static inline var ENTITY_NODE : Int                    = 6;
	static inline var PROCESSING_INSTRUCTION_NODE : Int    = 7;
	static inline var COMMENT_NODE : Int                   = 8;
	static inline var DOCUMENT_NODE : Int                  = 9;
	static inline var DOCUMENT_TYPE_NODE : Int             = 10;
	static inline var DOCUMENT_FRAGMENT_NODE : Int         = 11;
	static inline var NOTATION_NODE : Int                  = 12;

	//readonly attribute DOMString        nodeName;
	public var nodeName( default, never ) : DOMString;

	public var nodeValue:DOMString;
							// raises(DOMException) on setting
							// raises(DOMException) on retrieval

	//readonly attribute unsigned short   nodeType;
	public var nodeType( default, never ) : Int;
	
	//readonly attribute Node             parentNode;
	public var parentNode( default, never ) : Node;
	
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
	
	//readonly attribute NamedNodeMap     attributes;
	public var attributes( default, never ) : NamedNodeMap;
	
	// Modified in DOM Level 2:
	//readonly attribute Document         ownerDocument;
	public var ownerDocument( default, never ) : Document;
	
	// Modified in DOM Level 3:
	//Node               insertBefore(in Node newChild, 
					  //in Node refChild)
							//raises(DOMException);
	public function insertBefore( newChild:Node, refChild:Node ) : Node { }

	// Modified in DOM Level 3:
	//Node               replaceChild(in Node newChild, 
					  //in Node oldChild)
							//raises(DOMException);
	public function replaceChild( newChild:Node, oldChild:Node ) : Node { }

	// Modified in DOM Level 3:
	//Node               removeChild(in Node oldChild)
							//raises(DOMException);
	public function removeChild( oldChild:Node ) : Node { }

	// Modified in DOM Level 3:
	//Node               appendChild(in Node newChild)
							//raises(DOMException);
	public function appendChild( newChild:Node ) : Node { }

	//boolean            hasChildNodes();
	public function hasChildNodes() : Bool { }

	//Node               cloneNode(in boolean deep);
	public function cloneNode( deep:Bool) { }
	
	// Modified in DOM Level 2:
	public function normalize() : Void {  }
	
	// Introduced in DOM Level 2:
	//boolean            isSupported(in DOMString feature, 
	//							 in DOMString version);
	public function isSupported( feature : DOMString, version : DOMString ) : Bool { }
	
	// Introduced in DOM Level 2:
	//readonly attribute DOMString       namespaceURI;
	public var namespaceURI( default, never ) : DOMString;
	
	// Introduced in DOM Level 2:
	//	   attribute DOMString       prefix;
										// raises(DOMException) on setting
	public var prefix : DOMString;

	// Introduced in DOM Level 2:
	//readonly attribute DOMString       localName;
	public var localName( default, never ) : DOMString;
	
	// Introduced in DOM Level 2:
	//boolean            hasAttributes();
	public function hasAttributes() : Bool { }
	
	// Introduced in DOM Level 3:
	//readonly attribute DOMString       baseURI;
	public var baseURI( default, never ) : DOMString;

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

	// Introduced in DOM Level 3:
	//unsigned short     compareDocumentPosition(in Node other)
										//raises(DOMException);
	public function compareDocumentPosition( other : Node ) : Int { }
	// Introduced in DOM Level 3:
	//	   attribute DOMString       textContent;
										// raises(DOMException) on setting
										// raises(DOMException) on retrieval
	public var textContent : DOMString;

	// Introduced in DOM Level 3:
	//boolean            isSameNode(in Node other);
	public function isSameNode( other : Node ) : Bool { }
	
	// Introduced in DOM Level 3:
	//DOMString          lookupPrefix(in DOMString namespaceURI);
	public function lookupPrefix( namespaceURI : DOMString ) : DOMString { }
	
	// Introduced in DOM Level 3:
	//boolean            isDefaultNamespace(in DOMString namespaceURI);
	public function isDefaultNamespace( namespaceURI : DOMString ) : Bool { }
	
	// Introduced in DOM Level 3:
	//DOMString          lookupNamespaceURI(in DOMString prefix);
	public function lookupNamespaceURI( prefix : DOMString ) : DOMString { }
	
	// Introduced in DOM Level 3:
	//boolean            isEqualNode(in Node arg);
	public function isEqualNode( arg : Node ) : Bool { }
	
	// Introduced in DOM Level 3:
	//DOMObject          getFeature(in DOMString feature, 
								//in DOMString version);
	public function getFeature( feature : DOMString, version : DOMString ) : DOMObject { }

	 //Introduced in DOM Level 3:
	//DOMUserData        setUserData(in DOMString key, 
								 //in DOMUserData data, 
								 //in UserDataHandler handler);
	public function setUserData( key : DOMString, data : DOMUserData, handler : UserDataHandler ) : DOMUserData { };

	// Introduced in DOM Level 3:
	//DOMUserData        getUserData(in DOMString key);
	public function getUserData( key : DOMString ) : DOMUserData { };
}