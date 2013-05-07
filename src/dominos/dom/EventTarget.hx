package dominos.dom;

/**
 * @see https://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#eventtarget
 * 
 * @author Thomas Fétiveau
 */
class EventTarget
{
	//void addEventListener(DOMString type, EventListener? callback, optional boolean capture = false);
	public function addEventListener( type : DOMString, ?callback : EventListener, ?capture : Bool = false) { }

	//void removeEventListener(DOMString type, EventListener? callback, optional boolean capture = false);
	public function removeEventListener( type : DOMString, callback : EventListener, ?capture : Bool = false) { }

	//boolean dispatchEvent(Event event);
	public function dispatchEvent(event : EventListener) { }
}