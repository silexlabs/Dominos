/**
 * Dominos, HTML5 parser.
 * @see https://github.com/silexlabs/dominos
 *
 * @author Thomas Fétiveau, http://www.tokom.fr
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package dominos.dom; 

/**
 * A DOMString is a sequence of 16-bit units.
 * 
 * Applications must encode DOMString using UTF-16 (defined in [Unicode] and Amendment 1 of [ISO/IEC 10646]).
 * The UTF-16 encoding was chosen because of its widespread industry practice. Note that for both HTML and XML, 
 * the document character set (and therefore the notation of numeric character references) is based on UCS [ISO-10646]. 
 * A single numeric character reference in a source document may therefore in some cases correspond to two 16-bit 
 * units in a DOMString (a high surrogate and a low surrogate).
 * 
 * Note: Even though the DOM defines the name of the string type to be DOMString, bindings may use different names. 
 * For example for Java, DOMString is bound to the String type because it also uses UTF-16 as its encoding.
 * 
 * @author Thomas Fétiveau
 */
typedef DOMString = String; // For the moment, DOMString is an Alias of String. We will decide later if a Class has to be 
							// made to enforce the UTF-16 requirement on each platform.