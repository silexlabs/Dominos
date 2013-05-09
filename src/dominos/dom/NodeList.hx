package dominos.dom;

/**
 * The NodeList interface provides the abstraction of an ordered collection of nodes,
 * without defining or constraining how this collection is implemented. NodeList 
 * objects in the DOM are <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#td-live">live</a>.
 * 
 * The items in the NodeList are accessible via an integral index, starting from 0.
 * 
 * Documentation for this class was provided by <a href="https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#nodelist">W3C</a>
 * 
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#nodelist
 * @author Thomas Fétiveau
 */
typedef NodeList = Array<Node>;