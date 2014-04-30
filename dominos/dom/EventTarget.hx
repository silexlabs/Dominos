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
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#eventlistener
 */
typedef EventListener =
{
	var handleEvent : Event -> Void;
}
/**
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#event
 */
typedef Event =
{
	var type : DOMString;
}

/**
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#eventtarget
 * 
 * @author Thomas Fétiveau
 */
class EventTarget
{
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-eventtarget-addeventlistener
	 */
	public function addEventListener( type : DOMString, ?callback : EventListener, ?capture : Bool = false)
	{
		throw "Error: Dominos doesn't implement DOM Events";
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-eventtarget-removeeventlistener
	 */
	public function removeEventListener( type : DOMString, callback : EventListener, ?capture : Bool = false)
	{
		throw "Error: Dominos doesn't implement DOM Events";
	}
	/**
	 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#dom-eventtarget-dispatchevent
	 */
	public function dispatchEvent(event : EventListener)
	{
		throw "Error: Dominos doesn't implement DOM Events";
	}
}