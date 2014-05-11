/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.parser;

import dominos.dom.Element;
import dominos.dom.DocumentFragment;
import dominos.dom.NodeList;

/**
 * HTML Parser API
 * @author Thomas Fétiveau
 */
class DOMParser
{
	/**
	 * @see http://domparsing.spec.whatwg.org/#concept-parse-fragment
	 */
	static public function parseFragment( markup : String, ? context : Element = null ) : DocumentFragment
	{
		// If the context element's node document is an HTML document: let algorithm be the HTML fragment parsing algorithm.

		// If the context element's node document is an XML document: let algorithm be the XML fragment parsing algorithm.

		// Invoke algorithm with markup as the input, and context element as the context element.
		// Let new children be the nodes returned.
		var newChildren : NodeList = HTMLParser.parseFragment(markup, context);

		// Let fragment be a new DocumentFragment whose node document is context element's node document.
		var fragment : DocumentFragment = new DocumentFragment();
		fragment.ownerDocument = context.ownerDocument;

		// Append each node in new children to fragment (in order).
		for (n in newChildren) {

			fragment.appendChild(n);
		}
		return fragment;
	}
}