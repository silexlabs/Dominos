package dominos.dom;

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
class Document
{
	// Modified in DOM Level 3:
	//readonly attribute DocumentType    doctype;
	public var doctype( default, never ) : DocumentType;

	//readonly attribute DOMImplementation implementation;
	public var implementation : DOMImplementation;
	
	//readonly attribute DOMString compatMode;
	public var compatMode( default, never ) : DOMString;

	//readonly attribute Element         documentElement;
	public var documentElement : Element;

	//Element            createElement(in DOMString tagName)
	public function createElement( tagName : DOMString ) : Element { };

	//DocumentFragment   createDocumentFragment();
	public function createDocumentFragment() : DocumentFragment { };

	//Text               createTextNode(in DOMString data);
	public function createTextNode( data : DOMString ) : Text { };

	//Comment            createComment(in DOMString data);
	public function createComment( data : DOMString ) : Comment { };

	//CDATASection       createCDATASection(in DOMString data)
										//raises(DOMException);
	public function createCDATASection( data : DOMString ) : CDATASection { }

	//ProcessingInstruction createProcessingInstruction(in DOMString target, 
													//in DOMString data)
										//raises(DOMException);
	public function createProcessingInstruction( target : DOMString, data : DOMString ) : ProcessingInstruction { }

	//Attr               createAttribute(in DOMString name)
										//raises(DOMException);
	public function createAttribute( name : DOMString ) : Attr { }

	//EntityReference    createEntityReference(in DOMString name)
										//raises(DOMException);
	public function createEntityReference( name : DOMString ) : EntityReference { }

	//NodeList           getElementsByTagName(in DOMString tagname);
	public function getElementsByTagName( tagname : DOMString ) : NodeList { }

	// Introduced in DOM Level 2:
	//Node               importNode(in Node importedNode, 
								//in boolean deep)
										//raises(DOMException);
	public function importNode( importedNode : Node, deep : Bool) : Node { }

	// Introduced in DOM Level 2:
	//Element            createElementNS(in DOMString namespaceURI, 
									 //in DOMString qualifiedName)
										//raises(DOMException);
	public function createElementNS( namespaceURI : DOMString, qualifiedName : DOMString ) : Element { }

	// Introduced in DOM Level 2:
	//Attr               createAttributeNS(in DOMString namespaceURI, 
									   //in DOMString qualifiedName)
										//raises(DOMException);
	public function createAttributeNS( namespaceURI : DOMString, qualifiedName : DOMString ) : Attr { }

	// Introduced in DOM Level 2:
	//NodeList           getElementsByTagNameNS(in DOMString namespaceURI, 
											//in DOMString localName);
	public function getElementsByTagNameNS( namespaceURI : DOMString, localName : DOMString ) : NodeList { }

	// Introduced in DOM Level 2:
	//Element            getElementById(in DOMString elementId);
	public function getElementById( elementId : DOMString ) : Element { }

	// Introduced in DOM Level 3:
	//readonly attribute DOMString       inputEncoding;
	public var inputEncoding( default, never ) : DocumentType;

	// Introduced in DOM Level 3:
	//readonly attribute DOMString       xmlEncoding;
	public var xmlEncoding( default, never ) : DocumentType;

	// Introduced in DOM Level 3:
		   //attribute boolean         xmlStandalone;
										// raises(DOMException) on setting
	public var xmlStandalone : Bool;

	// Introduced in DOM Level 3:
		   //attribute DOMString       xmlVersion;
										// raises(DOMException) on setting
	public var xmlVersion : DOMString;

	// Introduced in DOM Level 3:
		   //attribute boolean         strictErrorChecking;
	public var strictErrorChecking : Bool;

	// Introduced in DOM Level 3:
		   //attribute DOMString       documentURI;
	public var documentURI : DOMString;

	// Introduced in DOM Level 3:
	//Node               adoptNode(in Node source)
										//raises(DOMException);
	public function adoptNode( source : Node ) : Node { }

	// Introduced in DOM Level 3:
	//readonly attribute DOMConfiguration domConfig;
	public var domConfig : DOMConfiguration;

	// Introduced in DOM Level 3:
	//void               normalizeDocument();
	public function normalizeDocument() : Void { }

	// Introduced in DOM Level 3:
	//Node               renameNode(in Node n, 
								//in DOMString namespaceURI, 
								//in DOMString qualifiedName)
										//raises(DOMException);
	public function renameNode( n : Node, namespaceURI : DOMString, qualifiedName : DOMString ) : Node { }
}