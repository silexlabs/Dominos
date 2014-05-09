/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.parser;

import dominos.parser.html.InputStream;
import dominos.parser.html.Tokenizer;
import dominos.parser.html.TreeBuilder;
import dominos.parser.html.Token;
import dominos.parser.html.State;

import dominos.dom.DOMImplementation;
import dominos.dom.Document;
import dominos.dom.Element;
import dominos.dom.NodeList;

/**
 * HTML Parser API
 * @author Thomas Fétiveau
 */
class HTMLParser
{
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#parsing
	 */
	static public function parse(data : String) : Document
	{
		var dom : DOMImplementation = new DOMImplementation();
		// the document that will result of the HTML parsing
		var doc : Document = dom.createHTMLDocument();

		var is : InputStream = new InputStream(data);

		var tk : Tokenizer = new Tokenizer(is);

		var tb : TreeBuilder = new TreeBuilder(dom, doc);

		tk.onNewToken = function(t : Token) {

				tb.processToken(t);
			}

		tb.onStateChangeRequest = function(s : State) {

				tk.state = s;
			}

		tk.parse();

		// if (doc.readyState == "complete") ?
		return tb.doc;
	}

	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#concept-frag-parse-context
	 * @see https://dvcs.w3.org/hg/innerhtml/raw-file/tip/index.html#dfn-concept-parse-fragment
	 */
	static public function parseFragment( input : String, ? context : Element = null ) : NodeList
	{
		var root : Element = null;

		/*
		1 - Create a new Document node, and mark it as being an HTML document.
		*/
		var dom : DOMImplementation = new DOMImplementation();
		// the document that will result of the HTML parsing
		var doc : Document = dom.createHTMLDocument();

		var is : InputStream = new InputStream(input);

		var tk : Tokenizer = new Tokenizer(is);

		var tb : TreeBuilder = new TreeBuilder(dom, doc);

		tk.onNewToken = function(t : Token) {

				tb.processToken(t);
			}

		tb.onStateChangeRequest = function(s : State) {

				tk.state = s;
			}

		/*
		2 - If there is a context element, and the Document of the context element is in quirks mode, 
		then let the Document be in quirks mode. Otherwise, if there is a context element, and the Document 
		of the context element is in limited-quirks mode, then let the Document be in limited-quirks mode. 
		Otherwise, leave the Document in no-quirks mode.
		*/
		// TODO

		/*
		3 - Create a new HTML parser, and associate it with the just created Document node.
		*/


		/*
		4 - If there is a context element, run these substeps:
		*/
		if (context != null) {
			/*
			1 - Set the state of the HTML parser's tokenization stage as follows:

				- If it is a title or textarea element
					Switch the tokenizer to the RCDATA state.
				- If it is a style, xmp, iframe, noembed, or noframes element
					Switch the tokenizer to the RAWTEXT state.
				- If it is a script element
					Switch the tokenizer to the script data state.
				- If it is a noscript element
					If the scripting flag is enabled, switch the tokenizer to the RAWTEXT state. 
					Otherwise, leave the tokenizer in the data state.
				- If it is a plaintext element
					Switch the tokenizer to the PLAINTEXT state.
				- Otherwise
					Leave the tokenizer in the data state.
				
				=> For performance reasons, an implementation that does not report errors and that uses the actual state 
				machine described in this specification directly could use the PLAINTEXT state instead of the RAWTEXT and 
				script data states where those are mentioned in the list above. Except for rules regarding parse errors, 
				they are equivalent, since there is no appropriate end tag token in the fragment case, yet they involve far 
				fewer state transitions.
			*/
			switch (context.tagName) {

				case "title", "textarea":

					tk.state = RCDATA;

				case "style", "xmp", "iframe", "noembed", "noframes":

					tk.state = RAWTEXT;

				case "noscript":

					// TODO
					tk.state = RAWTEXT;

				case "plaintext":

					tk.state = PLAINTEXT;
			}

			/*
			2 - Let root be a new html element with no attributes.
			*/
			root = doc.createElement("html");

			/*
			3 - Append the element root to the Document node created above.
			*/
			doc.appendChild(root);

			/*
			4 - Set up the parser's stack of open elements so that it contains just the single element root.
			*/
			tb.stack = [root];

			/*
			5 - If the context element is a template element, push "in template" onto the stack of template insertion 
			modes so that it is the new current template insertion mode.
			*/
			if (context.tagName == "template") {

				// TODO
				throw "not implemented yet!";
			}

			/*
			6 - Reset the parser's insertion mode appropriately.

				=> The parser will reference the context element as part of that algorithm.
			*/
			tb.resetInsertionMode(context);

			/*
			7 - Set the parser's form element pointer to the nearest node to the context element that is a form element 
			(going straight up the ancestor chain, and including the element itself, if it is a form element), if any. 
			(If there is no such form element, the form element pointer keeps its initial value, null.)
			*/
			var e : Element = context;

			while (e.tagName != "form" && e.parentElement != null) {

				e = e.parentElement;
			}
			if (e.tagName == "form") {

				tb.fp = e;
			}
		}
		/*
		5 - Place into the input stream for the HTML parser just created the input. The encoding confidence is irrelevant.
		*/
		// done

		/*
		6 - Start the parser and let it run until it has consumed all the characters just inserted into the input stream.
		*/
		tk.parse();

		/*
		7 - If there is a context element, return the child nodes of root, in tree order.
		*/
		if (context != null) {

			return root.childNodes;
		}

		/*
		8 - Otherwise, return the children of the Document object, in tree order.
		*/
		return doc.childNodes;
	}
}