package dominos.dom;

/**
 * Objects implementing the NamedNodeMap interface are used to represent 
 * collections of nodes that can be accessed by name. Note that NamedNodeMap 
 * does not inherit from NodeList; NamedNodeMaps are not maintained in any 
 * particular order. Objects contained in an object implementing NamedNodeMap 
 * may also be accessed by an ordinal index, but this is simply to allow 
 * convenient enumeration of the contents of a NamedNodeMap, and does not 
 * imply that the DOM specifies an order to these Nodes.
 * 
 * NamedNodeMap objects in the DOM are <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#td-live">live</a>.
 * 
 * Documentation for this class was provided by <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-1780488922">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class NamedNodeMap
{
	//Node               getNamedItem(in DOMString name);
	public function getNamedItem( name : DOMString ) : Node { }

	//Node               setNamedItem(in Node arg)
										//raises(DOMException);
	public function setNamedItem( arg : Node ) : Node { }

	//Node               removeNamedItem(in DOMString name)
										//raises(DOMException);
	public function removeNamedItem( name : DOMString ) : Node { }

	//Node               item(in unsigned long index);
	public function item( index : Int ) : Node { }

	//readonly attribute unsigned long   length;
	public var length( default, never ) : Int;

	// Introduced in DOM Level 2:
	//Node               getNamedItemNS(in DOMString namespaceURI, 
									//in DOMString localName)
										//raises(DOMException);
	public function getNamedItemNS( namespaceURI : DOMString, localName : DOMString ) : Node { }

	// Introduced in DOM Level 2:
	//Node               setNamedItemNS(in Node arg)
										//raises(DOMException);
	public function setNamedItemNS( arg : Node ) : Node { }

	// Introduced in DOM Level 2:
	//Node               removeNamedItemNS(in DOMString namespaceURI, 
									   //in DOMString localName)
										//raises(DOMException);
	public function removeNamedItemNS( namespaceURI : DOMString, localName : DOMString ) : Node { }
}