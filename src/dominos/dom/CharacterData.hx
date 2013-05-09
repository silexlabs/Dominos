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
 * Documentation for this class was provided by <a href="https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#characterdata">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class CharacterData extends Node
{
	//[TreatNullAs=EmptyString] attribute DOMString data;
	public var data(get, set) : DOMString;

	//readonly attribute unsigned long   length;
	public var length( get, never ) : Int;

	//DOMString substringData(unsigned long offset, unsigned long count);
	public function substringData( offset : Int, count : Int ) : DOMString
	{
		throw "Not implemented";
	}

	//void appendData(DOMString data);
	public function appendData( arg : DOMString ) : Void
	{
		throw "Not implemented";
	}

	//void insertData(unsigned long offset, DOMString data);
	public function insertData( offset : Int, arg : DOMString ) : Void
	{
		throw "Not implemented";
	}

	//void deleteData(unsigned long offset, unsigned long count);
	public function deleteData( offset : Int, count : Int ) : Void
	{
		throw "Not implemented";
	}

	//void replaceData(unsigned long offset, unsigned long count, DOMString data);
	public function replaceData( offset : Int, count : Int, arg : DOMString ) : Void
	{
		throw "Not implemented";
	}
	
	//
	// PROPERTIES
	//
	
	public function get_data() : DOMString;
	{
		return (data != null) ? data : "" ;
	}
	public function set_data( d : DOMString ) : DOMString;
	{
		data = (d != null) ? d : "" ;
		return data;
	}
	public function get_length() : Int
	{
		return data.length;
	}
}