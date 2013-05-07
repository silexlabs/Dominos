package dominos.html;

import dominos.dom.Element;
import dominos.dom.DOMString;

/**
 * @see http://www.w3.org/TR/html5/dom.html#htmlelement
 * 
 * @author Thomas Fétiveau
 */
class HTMLElement extends Element
{
	// metadata attributes
	//attribute DOMString title;
	var title : DOMString;
	//attribute DOMString lang;
	var lang : DOMString;
	//attribute boolean translate;
	var translate : Bool;
	//attribute DOMString dir;
	var dir : DOMString;
	//readonly attribute DOMStringMap dataset;
	//var dataset( default, never ) : DOMStringMap;

	// styling
	//readonly attribute CSSStyleDeclaration style;
}