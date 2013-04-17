package dominos.dom;

/**
 * The NodeList interface provides the abstraction of an ordered collection of nodes,
 * without defining or constraining how this collection is implemented. NodeList 
 * objects in the DOM are <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#td-live">live</a>.
 * 
 * The items in the NodeList are accessible via an integral index, starting from 0.
 * 
 * Documentation for this class was provided by <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-536297177">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class NodeList
{
	//Node               item(in unsigned long index);
	public function item( index : Int ) : Node { }
	
	//readonly attribute unsigned long   length;
	public var length( default, never ) : Int;
}