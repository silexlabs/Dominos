package dominos.dom;

/**
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#domimplementation
 * 
 * @author Thomas Fétiveau
 */
class DOMImplementation
{
	//DocumentType createDocumentType(DOMString qualifiedName, DOMString publicId, DOMString systemId);
	public function createDocumentType( qualifiedName : DOMString, publicId : DOMString, systemId : DOMString ) : DocumentType
	{
		//If qualifiedName does not match the Name production, throw an "InvalidCharacterError" exception and terminate these steps.

		//If qualifiedName does not match the QName production in, throw a "NamespaceError" exception and terminate these steps.

		//Return a new doctype, with qualifiedName as its name, publicId as its public ID, and systemId as its system ID, and with its node document set to the associated document of the context object. 
		return new DocumentType( qualifiedName, publicId, systemId);
		//Note: No check is performed that the publicId matches the PublicChar or that the systemId does not contain both a '"' and "'". 
	//}
	//XMLDocument createDocument(DOMString? namespace, [TreatNullAs=EmptyString] DOMString qualifiedName, DocumentType? doctype);
	/*public function createDocument( namespace : DOMString, qualifiedName : DOMString, doctype : DocumentType ) : XMLDocument
	{
		//Let document be a new XMLDocument.

		//This method creates an XMLDocument rather than a normal document. They are identical except for the addition of the load() method deployed content relies upon. [HTML]

		//Let element be null.

		//If qualifiedName is not the empty string, set element to the result of invoking the createElementNS() method with the arguments namespace and qualifiedName on document. If that threw an exception, re-throw the exception and terminate these steps.

		//If doctype is not null, append doctype to document.

		//If element is not null, append element to document.

		//Return document. 
	//}*/
	// Document createHTMLDocument(optional DOMString title);
	public function createHTMLDocument( ?title : DOMString ) : Document
	{
		//Let doc be a newly created document.
		var doc = new Document();
		//Mark doc as being an HTML document.
	//TODO How ?
		//Set doc's content type to "text/html".
	//TODO
		//Create a doctype, with "html" as its name and with its node document set to doc. Append the newly created node to doc.
	//FIXME this is contradicting the HTML parsing algorithm where we parse doctype token and append it to the already created doc
		//Create an html element in the HTML namespace, and append it to doc.
	//FIXME this is contradicting the HTML parsing algorithm
		//Create a head element in the HTML namespace, and append it to the html element created in the previous step.
	//FIXME this is contradicting the HTML parsing algorithm
		//If the title argument is not omitted:
	//FIXME this is contradicting the HTML parsing algorithm
			//Create a title element in the HTML namespace, and append it to the head element created in the previous step.
	//FIXME this is contradicting the HTML parsing algorithm
			//Create a Text node, set its data to title (which could be the empty string), and append it to the title element created in the previous step. 
	//FIXME this is contradicting the HTML parsing algorithm
		//Create a body element in the HTML namespace, and append it to the html element created in the earlier step.
	//FIXME this is contradicting the HTML parsing algorithm
		//Return doc. 
		return doc;
	}
	//boolean hasFeature(DOMString feature, [TreatNullAs=EmptyString] DOMString version);
}