package dominos.dom;

/**
 * Internal static methods used by several DOM entities.
 * 
 * @author Thomas Fétiveau
 */
@:allow(dominos.dom)
class DOMInternals
{
	////////////////////////
	// CONSTANTS
	////////////////////////
	
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#html-namespace
	 */
	static inline var HTML_NAMESPACE : String = "http://www.w3.org/1999/xhtml";
	
	/**
	 * HTML Elements tag names. TODO complete
	 */
	static inline var HTML_HTML_ELEMENT_TAGNAME : String = "html";
	static inline var HTML_HEAD_ELEMENT_TAGNAME : String = "head";
	static inline var HTML_TITLE_ELEMENT_TAGNAME : String = "title";
	static inline var HTML_BASE_ELEMENT_TAGNAME : String = "base";
	static inline var HTML_LINK_ELEMENT_TAGNAME : String = "link";
	static inline var HTML_META_ELEMENT_TAGNAME : String = "meta";
	static inline var HTML_STYLE_ELEMENT_TAGNAME : String = "style";
	static inline var HTML_SCRIPT_ELEMENT_TAGNAME : String = "script";
	static inline var HTML_NOSCRIPT_ELEMENT_TAGNAME : String = "noscript";
	static inline var HTML_BODY_ELEMENT_TAGNAME : String = "body";
	static inline var HTML_ARTICLE_ELEMENT_TAGNAME : String = "article";
	static inline var HTML_SECTION_ELEMENT_TAGNAME : String = "section";
	static inline var HTML_NAV_ELEMENT_TAGNAME : String = "nav";
	
	////////////////////////
	// METHODS
	////////////////////////
	
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-cd-replace
	 * FIXME temporary implementation, need to check more precisely what would be useful to Dominos from the specs
	 */
	static private function replaceData( node : CharacterData, offset : Int, count : Int, data : DOMString ) : Void
	{
		var l = node.length;
		if ( offset > l )
		{
			throw "IndexSizeError";
		}
		if ( offset + count > l )
		{
			count = l - offset;
		}
		// Not implemented: Queue a mutation record of "characterData" for node with oldValue node's data. 
		
		node.data = node.data.substr( 0, offset ) + data + node.data.substr( offset );
		
		var delOffset = offset + data.length;
		
		node.data = node.data.substr( 0, delOffset );
		
		// Not implemented: manage ranges
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-node-append
	 */
	static private function append( node : Node, parent : Node ) : Node
	{
		return preInsert( node, parent, null );
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-node-pre-insert
	 */
	static private function preInsert( node : Node, parent : Node, child : Null<Node> ) : Node
	{
		if ( parent.nodeType != Node.DOCUMENT_NODE && parent.nodeType != Node.DOCUMENT_FRAGMENT_NODE && parent.nodeType != Node.ELEMENT_NODE  )
		{
			throw "HierarchyRequestError";
		}
		if ( isIncluseAncestor( node, parent ) )
		{
			throw "HierarchyRequestError";
		}
		if ( child != null && child.parentNode != parent )
		{
			throw  "NotFoundError";
		}
		if ( parent.nodeType == Node.DOCUMENT_NODE )
		{
			if ( node.nodeType != Node.DOCUMENT_FRAGMENT_NODE && node.nodeType != Node.DOCUMENT_TYPE_NODE && node.nodeType != Node.ELEMENT_NODE && 
					node.nodeType != Node.PROCESSING_INSTRUCTION_NODE && node.nodeType != Node.COMMENT_NODE )
			{
				throw "HierarchyRequestError";
			}
			if ( node.nodeType == Node.DOCUMENT_FRAGMENT_NODE )
			{
				if ( hasChild( node, Node.ELEMENT_NODE, 1 ) || hasChild( node, Node.TEXT_NODE ) )
				{
					throw "HierarchyRequestError";
				}
				if ( hasChild( node, Node.ELEMENT_NODE ) && 
					( hasChild( parent, Node.ELEMENT_NODE ) || child.nodeType == Node.DOCUMENT_TYPE_NODE || child != null && isFollowing( child, Node.DOCUMENT_TYPE_NODE ) ) )
				{
					throw "HierarchyRequestError";
				}
			}
			if ( node.nodeType == Node.ELEMENT_NODE &&
				( hasChild( parent, Node.ELEMENT_NODE ) || child.nodeType == Node.DOCUMENT_TYPE_NODE || child != null && isFollowing( child, Node.DOCUMENT_TYPE_NODE) ) )
			{
				throw "HierarchyRequestError";
			}
			if ( node.nodeType == Node.DOCUMENT_TYPE_NODE && 
				( hasChild( parent, Node.DOCUMENT_TYPE_NODE ) || isPreceding( child, Node.ELEMENT_NODE ) || child == null ) && 
					hasChild( parent, Node.ELEMENT_NODE ) )
			{
				throw "HierarchyRequestError";
			}
		}
		else if ( node.nodeType != Node.DOCUMENT_FRAGMENT_NODE && node.nodeType != Node.ELEMENT_NODE && node.nodeType != Node.TEXT_NODE && 
					node.nodeType != Node.PROCESSING_INSTRUCTION_NODE && node.nodeType != Node.COMMENT_NODE )
		{
			throw "HierarchyRequestError";
		}
		var refChild = child;

		if ( refChild == node )
		{
			refChild = node.nextSibling;
		}
		adopt( node, parent.ownerDocument );
		
		insert( node, parent, child );
		
		return node;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-node-insert
	 * TODO? manage optional suppress observers flag
	 * TODO? manage node is inserted hook
	 * TODO? manage ranges
	 * TODO? manage DocumentFragment
	 * TODO? manage mutation records
	 */
	static private function insert( node : Node, parent : Node, child : Node ) : Void
	{
		if ( parent.childNodes.length == 0 || child == null )
		{
			parent.childNodes.push( node );
		}
		else
		{
			for ( i in 0...parent.childNodes.length )
			{
				if ( parent.childNodes[i] == child )
				{
					parent.childNodes.insert( i, node );
					return;
				}
			}
		}
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-node-adopt
	 */
	static private function adopt( node : Node, ownerDocument : Document ) : Node
	{
		//TODO? If node is an element, it is affected by a base URL change.

		if ( node.parentNode != null )
		{
			remove( node, node.parentNode );
		}
		setNodeDocument( node, ownerDocument );
		return node;
	}
	/**
	 * Set a node's node document.
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-node-document
	 */
	@:access(dominos.dom.Node.ownerDocument)
	static private function setNodeDocument( node : Node, ownerDocument : Document ) : Void
	{
		node.ownerDocument = ownerDocument;
		for ( cn in node.childNodes )
		{
			setNodeDocument( cn, ownerDocument );
		}
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-node-pre-remove
	 */
	static private function preRemove( child : Node, parent : Node ) : Node
	{
		if ( child.parentNode != parent )
		{
			throw  "NotFoundError";
		}
		remove( child, parent );
		return child;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-node-remove
	 * TODO? manage suppress observers flag
	 * TODO? manage ranges
	 */
	static private function remove( node : Node, parent : Node ) : Void
	{
		parent.childNodes.remove(node);
		//TODO? manage "node is removed" hook: https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#node-is-removed
	}
	/**
	 * Tells if a node has a previous sibling ( optionaly of a given type )
	 */
	static private function isPreceding( node : Node, ?typeFilter : Int ) : Bool
	{
		return ( previousSibling( node, typeFilter ) != null );
	}
	/**
	 * Returns node's previous sibling ( optionaly filter by type ).
	 */
	static private function previousSibling( node : Node, ?typeFilter : Int = -1 ) : Null<Node>
	{
		if ( node.parentNode == null || node.parentNode.childNodes.length <= 1 )
		{
			return null;
		}
		var ps : Null<Node> = null;
		for ( cn in node.parentNode.childNodes )
		{
			if ( cn == node )
			{
				if ( typeFilter != -1 && ps.nodeType != typeFilter )
				{
					return null;
				}
				return ps;
			}
			ps = cn;
		}
		return null;
	}
	/**
	 * Tells if a node has a next sibling ( optionaly of a given type )
	 */
	static private function isFollowing( node : Node, ?typeFilter : Int ) : Bool
	{
		return ( nextSibling( node, typeFilter ) != null );
	}
	/**
	 * Returns node's next sibling ( optionaly filter by type ).
	 */
	static private function nextSibling( node : Node, ?typeFilter : Int = -1 ) : Null<Node>
	{
		if ( node.parentNode == null || node.parentNode.childNodes.length <= 1 )
		{
			return null;
		}
		var f : Bool = false;
		for ( cn in node.parentNode.childNodes )
		{
			if ( f )
			{
				if ( typeFilter != -1 && cn.nodeType != typeFilter )
				{
					return null;
				}
				return cn;
			}
			f = (cn == node);
		}
		return null;
	}
	/**
	 * Tells if a node has a child ( optionaly of a given type )
	 */
	static private function hasChild( node : Node, ?typeFilter : Int = -1, ?moreThanCountFilter : Int = 0 ) : Bool
	{
		for ( cn in node.childNodes )
		{
			if ( typeFilter == -1 || cn.nodeType == typeFilter )
			{
				if ( moreThanCountFilter-- < 0 )
				{
					return true;
				}
			}
		}
		return false;
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-tree-ancestor
	 */
	static private function isAncestor( a : Node, d : Node ) : Bool
	{
		if ( d.parentNode == null )
		{
			return false;
		}
		if ( d.parentNode == a )
		{
			return true;
		}
		return isAncestor( a, d.parentNode );
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#concept-tree-inclusive-ancestor
	 */
	static private function isIncluseAncestor( a : Node, d : Node ) : Bool
	{
		if ( a == d )
		{
			return true;
		}
		return isAncestor( a, d );
	}
	/**
	 * @see http://www.w3.org/TR/xml/#NT-Name
	 */
	static private function isValid( name : String, checkLevel : String ) : Bool
	{
		//TODO implement checks
		return true;
	}
	/**
	 * Get the first attr of a node (optionaly with a name filter)
	 */
	static private function firstAttr( node : Element, ?name : Null<String> = null ) : Null<Attr>
	{
		for ( at in node.attributes )
		{
			if ( name == null || at.name == name )
			{
				return at;
			}
		}
		return null;
	}
}