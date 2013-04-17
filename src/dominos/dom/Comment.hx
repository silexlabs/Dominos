package dominos.dom;

/**
 * This interface inherits from CharacterData and represents the content of a comment, 
 * i.e., all the characters between the starting '<!--' and ending '-->'. Note that 
 * this is the definition of a comment in XML, and, in practice, HTML, although some 
 * HTML tools may implement the full SGML comment structure.
 * 
 * No lexical check is done on the content of a comment and it is therefore possible 
 * to have the character sequence "--" (double-hyphen) in the content, which is 
 * illegal in a comment per section 2.5 of [XML 1.0]. The presence of this character
 * sequence must generate a fatal error during serialization. 
 * 
 * Documentation for this class was provided by <a href="http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-1728279322">W3C</a>
 * 
 * @author Thomas Fétiveau
 */
class Comment extends CharacterData
{
	
}