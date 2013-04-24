package dominos.dom;

/**
 * The CharacterData interface extends Node with a set of attributes and methods 
 * for accessing character data in the DOM. For clarity this set is defined here 
 * rather than on each object that uses these attributes and methods. No DOM 
 * objects correspond directly to CharacterData, though Text and others do 
 * inherit the interface from it. All offsets in this interface start from 0.
 * 
 * As explained in the DOMString interface, text strings in the DOM are 
 * represented in UTF-16, i.e. as a sequence of 16-bit units. In the following, 
 * the term 16-bit units is used whenever necessary to indicate that indexing on 
 * CharacterData is done in 16-bit units.
 * 
 * Documentation for this class was provided by <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-FF21A306">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class CharacterData extends Node
{
	//attribute DOMString       data;
								// raises(DOMException) on setting
								// raises(DOMException) on retrieval
	public var data : DOMString;

	//readonly attribute unsigned long   length;
	public var length( default, never ) : Int;

	//DOMString          substringData(in unsigned long offset, 
						   //in unsigned long count)
								//raises(DOMException);
	public function substringData( offset : Int, count : Int ) : DOMString { }

	//void               appendData(in DOMString arg)
								//raises(DOMException);
	public function appendData( arg : DOMString ) : Void { }

	//void               insertData(in unsigned long offset, 
						//in DOMString arg)
								//raises(DOMException);
	public function insertData( offset : Int, arg : DOMString ) : Void { }

	//void               deleteData(in unsigned long offset, 
						//in unsigned long count)
								//raises(DOMException);
	public function deleteData( offset : Int, count : Int ) : Void { }

	//void               replaceData(in unsigned long offset, 
						 //in unsigned long count, 
						 //in DOMString arg)
								//raises(DOMException);
	public function replaceData( offset : Int, count : Int, arg : DOMString ) : Void { }
}