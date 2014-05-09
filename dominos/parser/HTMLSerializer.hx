/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.parser;

import dominos.dom.Comment;
import dominos.dom.Node;
import dominos.dom.Element;
import dominos.dom.ProcessingInstruction;
import dominos.dom.Text;

/**
 * There is no actual HTMLSerializer interface in the specs however there is a XMLSerializer. It thus seems 
 * logical to have a HTMLSerializer as well...
 * 
 * @see http://www.whatwg.org/specs/web-apps/current-work/multipage/the-end.html#serializing-html-fragments
 * 
 * @author Thomas Fétiveau
 */
class HTMLSerializer
{
	static public function serialize( node : Node ) : String
	{
		var s : StringBuf = new StringBuf();

		for ( currentNode in node.childNodes )
		{ trace("currentNode= "+currentNode.nodeName+"  type= "+currentNode.nodeType);
			if ( currentNode.nodeType == Node.ELEMENT_NODE )
			{
				var ce : Element = cast currentNode;
				//TODO If current node is an element in the HTML namespace, the MathML namespace, or the SVG namespace, then let tagname be current node's local name. Otherwise, 
				//let tagname be current node's qualified name.
				
				s.addChar( 0x3C );
				//Note: For HTML elements created by the HTML parser or Document.createElement(), tagname will be lowercase.
				s.add(ce.nodeName.toLowerCase());
				
				for ( attr in ce.attributes )
				{
					s.addChar( 0x20 );
					s.add( serializeAttributeName( attr.name ) );
					s.addChar( 0x3D );
					s.addChar( 0x22 );
					s.add( escape( attr.value ) );
					s.addChar( 0x22 );
				}
				s.addChar(0x3E);
				
				if ( ce.nodeName.toLowerCase() == "area" || ce.nodeName.toLowerCase() == "base" || ce.nodeName.toLowerCase() == "basefont" || ce.nodeName.toLowerCase() == "bgsound" || ce.nodeName.toLowerCase() == "br" || 
					ce.nodeName.toLowerCase() == "col" || ce.nodeName.toLowerCase() == "embed" || ce.nodeName.toLowerCase() == "frame" || ce.nodeName.toLowerCase() == "hr" || ce.nodeName.toLowerCase() == "img" || 
					ce.nodeName.toLowerCase() == "input" || ce.nodeName.toLowerCase() == "keygen" || ce.nodeName.toLowerCase() == "link" || ce.nodeName.toLowerCase() == "menuitem" || ce.nodeName.toLowerCase() == "meta" || 
					ce.nodeName.toLowerCase() == "param" || ce.nodeName.toLowerCase() == "source" || ce.nodeName.toLowerCase() == "track" || ce.nodeName.toLowerCase() == "wbr" )
				{
					continue; // next child processing
				}
				if (ce.nodeName.toLowerCase() == "pre" || ce.nodeName.toLowerCase() == "textarea" || ce.nodeName.toLowerCase() == "listing")
				{
					if ( ce.childNodes.length > 0 && ce.childNodes[0].nodeType == Node.TEXT_NODE && cast(ce.childNodes[0], Text).data.charCodeAt(0) == 0xA )
					{
						s.addChar( 0xA );
					}
				}
				s.add( serialize( ce ) );
				s.addChar(0x3C);
				s.addChar(0x2F);
				s.add(ce.nodeName.toLowerCase());
				s.addChar(0x3E);
			}
			else if ( currentNode.nodeType == Node.TEXT_NODE )
			{
				var t : Text = cast currentNode;
				//TODO add "if the parent of current node is noscript element and scripting is enabled for the node" to the below condition
				if ( t.parentNode != null && (t.parentNode.nodeName.toLowerCase() == "style" ||  t.parentNode.nodeName.toLowerCase() == "script" || t.parentNode.nodeName.toLowerCase() == "xmp" || 
						t.parentNode.nodeName.toLowerCase() == "iframe" || t.parentNode.nodeName.toLowerCase() == "noembed" || 
							t.parentNode.nodeName.toLowerCase() == "noframes" || t.parentNode.nodeName.toLowerCase() == "plaintext") )
				{ // FIXME why t.parentNode can be null ?
					s.add( t.data );
				}
				else
				{
					s.add( escape( t.data ) );
				}
			}
			else if ( currentNode.nodeType == Node.COMMENT_NODE )
			{
				var c : Comment = cast currentNode;
				s.addChar( 0x3C );
				s.addChar( 0x21 );
				s.addChar( 0x2D );
				s.addChar( 0x2D );
				s.add( c.data );
				s.addChar( 0x2D );
				s.addChar( 0x2D );
				s.addChar( 0x3E );
			}
			else if ( currentNode.nodeType == Node.PROCESSING_INSTRUCTION_NODE )
			{
				var pi : ProcessingInstruction = cast currentNode;
				s.addChar( 0x3C );
				s.addChar( 0x3F );
				s.add( pi.target );
				s.addChar( 0x20 );
				s.add( pi.data );
				s.addChar( 0x3E );
			}
			else if ( currentNode.nodeType == Node.DOCUMENT_TYPE_NODE )
			{
				s.addChar( 0x3C );
				s.addChar( 0x21 );
				s.addChar( 0x44 );
				s.addChar( 0x4F );
				s.addChar( 0x43 );
				s.addChar( 0x54 );
				s.addChar( 0x59 );
				s.addChar( 0x50 );
				s.addChar( 0x45 );
				s.addChar( 0x20 );
				s.add( currentNode.nodeName.toLowerCase() );
				s.addChar( 0x3E );
			}
			else
			{
				throw "Error: Node expected.";
			}
		}
		return s.toString();
	}
	
	/**
	 * TODO implement the specified algorithm...
	 * 
	 * @see http://www.whatwg.org/specs/web-apps/current-work/multipage/the-end.html#attribute%27s-serialized-name
	 */
	static function serializeAttributeName( s : String ) : String
	{
		//If the attribute has no namespace

			//The attribute's serialized name is the attribute's local name.

				//Note: For attributes on HTML elements set by the HTML parser or by Element.setAttribute(), the local name will be lowercase.
		
		//If the attribute is in the XML namespace

			//The attribute's serialized name is the string "xml:" followed by the attribute's local name.
		
		//If the attribute is in the XMLNS namespace and the attribute's local name is xmlns

			//The attribute's serialized name is the string "xmlns".
		
		//If the attribute is in the XMLNS namespace and the attribute's local name is not xmlns

			//The attribute's serialized name is the string "xmlns:" followed by the attribute's local name.
		
		//If the attribute is in the XLink namespace

			//The attribute's serialized name is the string "xlink:" followed by the attribute's local name.
		
		//If the attribute is in some other namespace

			//The attribute's serialized name is the attribute's qualified name.
		
		return s;
	}

	/**
	 * @see http://www.whatwg.org/specs/web-apps/current-work/multipage/the-end.html#escapingString
	 */
	static function escape( s : String, ?attributeMode : Bool = false ) : String
	{
		s = StringTools.replace( s, "&", "&amp;" );
		s = StringTools.replace( s, String.fromCharCode(0xA0), "&nbsp;" );
		if ( attributeMode )
		{
			s = StringTools.replace( s, String.fromCharCode(0x22), "&quot;" );
		}
		else
		{
			s = StringTools.replace( s, String.fromCharCode(0x3C), "&lt;" );
			s = StringTools.replace( s, String.fromCharCode(0x3E), "&gt;" );
		}
		return s;
	}
}