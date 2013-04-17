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
 * Documentation for this class was provided by <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-745549614">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class Element extends Node
{
	//readonly attribute DOMString       tagName;
	public var tagName( default, never ) : DOMString;

	//DOMString          getAttribute(in DOMString name);
	public function getAttribute( name : DOMString ) : DOMString { }

	//void               setAttribute(in DOMString name, 
								  //in DOMString value)
										//raises(DOMException);
	public function setAttribute( name : DOMString , value : DOMString ) : Void { }

	//void               removeAttribute(in DOMString name)
										//raises(DOMException);
	public function removeAttribute( name : DOMString ) : Void { }

	//Attr               getAttributeNode(in DOMString name);
	public function getAttributeNode( name : DOMString ) : Attr { }

	//Attr               setAttributeNode(in Attr newAttr)
										//raises(DOMException);
	public function setAttributeNode( newAttr : Attr ) : Attr { }

	//Attr               removeAttributeNode(in Attr oldAttr)
										//raises(DOMException);
	public function removeAttributeNode( oldAttr : Attr ) : Attr { }

	//NodeList           getElementsByTagName(in DOMString name);
	public function getElementsByTagName( name : DOMString ) : NodeList { }
	
	
	// Introduced in DOM Level 2:
	//DOMString          getAttributeNS(in DOMString namespaceURI, 
									//in DOMString localName)
										//raises(DOMException);
	public function getAttributeNS( namespaceURI : DOMString, localName : DOMString ) : DOMString { }
										
										
	// Introduced in DOM Level 2:
	//void               setAttributeNS(in DOMString namespaceURI, 
									//in DOMString qualifiedName, 
									//in DOMString value)
										//raises(DOMException);
	public function setAttributeNS( namespaceURI : DOMString, qualifiedName : DOMString, value : DOMString ) : Void { }
										
										
	// Introduced in DOM Level 2:
	//void               removeAttributeNS(in DOMString namespaceURI, 
									   //in DOMString localName)
										//raises(DOMException);
	public function removeAttributeNS( namespaceURI : DOMString, localName : DOMString) : Void { }
										
	// Introduced in DOM Level 2:
	//Attr               getAttributeNodeNS(in DOMString namespaceURI, 
										//in DOMString localName)
										//raises(DOMException);
	public function getAttributeNodeNS( namespaceURI : DOMString, localName : DOMString ) : Attr { }
										
	// Introduced in DOM Level 2:
	//Attr               setAttributeNodeNS(in Attr newAttr)
										//raises(DOMException);
	public function setAttributeNodeNS( newAttr : Attr ) : Attr { }
										
	// Introduced in DOM Level 2:
	//NodeList           getElementsByTagNameNS(in DOMString namespaceURI, 
											//in DOMString localName)
										//raises(DOMException);
	public function getElementsByTagNameNS( namespaceURI : DOMString, localName : DOMString ) : NodeList
										
	// Introduced in DOM Level 2:
	//boolean            hasAttribute(in DOMString name);
	public function hasAttribute( name : DOMString ) : Bool { }

	// Introduced in DOM Level 2:
	//boolean            hasAttributeNS(in DOMString namespaceURI, 
									//in DOMString localName)
										//raises(DOMException);
	public function hasAttributeNS( namespaceURI : DOMString, localName : DOMString ) : Bool { }
										
	// Introduced in DOM Level 3:
	//readonly attribute TypeInfo        schemaTypeInfo;
	public var schemaTypeInfo( default, never ) : TypeInfo;

	// Introduced in DOM Level 3:
	//void               setIdAttribute(in DOMString name, 
									//in boolean isId)
										//raises(DOMException);
	public function setIdAttribute( name : DOMString, isId : Bool) : Void;
										
	// Introduced in DOM Level 3:
	//void               setIdAttributeNS(in DOMString namespaceURI, 
									  //in DOMString localName, 
									  //in boolean isId)
										//raises(DOMException);
	public function setIdAttributeNS( namespaceURI : DOMString, localName : DOMString, isId : Bool ) : Void { }
										
	// Introduced in DOM Level 3:
	//void               setIdAttributeNode(in Attr idAttr, 
										//in boolean isId)
										//raises(DOMException);
	public function setIdAttributeNode( idAttr : Attr, isId : Bool ) : Void
										
}