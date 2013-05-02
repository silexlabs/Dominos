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
		
	}
	//XMLDocument createDocument(DOMString? namespace, [TreatNullAs=EmptyString] DOMString qualifiedName, DocumentType? doctype);
	/*public function createDocument( namespace : DOMString, qualifiedName : DOMString, doctype : DocumentType ) : XMLDocument
	{
		
	}*/
	// Document createHTMLDocument(optional DOMString title);
	public function createHTMLDocument( ?title : DOMString ) : Document
	{
		//Let doc be a newly created document.
		var doc = new Document();
		//Mark doc as being an HTML document.
	//TODO
		//Set doc's content type to "text/html".
	//TODO
		//Create a doctype, with "html" as its name and with its node document set to doc. Append the newly created node to doc.
	//FIXME this is contradicting the HTML parsing algorithm where we parse doctype token and append it to the already created doc
		//Create an html element in the HTML namespace, and append it to doc.
	//TODO
		//Create a head element in the HTML namespace, and append it to the html element created in the previous step.
	//TODO
		//If the title argument is not omitted:
	//TODO
			//Create a title element in the HTML namespace, and append it to the head element created in the previous step.
	//TODO
			//Create a Text node, set its data to title (which could be the empty string), and append it to the title element created in the previous step. 
	//TODO
		//Create a body element in the HTML namespace, and append it to the html element created in the earlier step.
	//TODO
		//Return doc. 
		return doc;
	}
	//boolean hasFeature(DOMString feature, [TreatNullAs=EmptyString] DOMString version);
}