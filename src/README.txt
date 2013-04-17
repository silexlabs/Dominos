Domino is a cross-platform DOM parser library. It aims to let you manipulate any DOM document (XML, HTML, SVG, XUL...).

Use cases: reading, edition, creation, validation of DOM documents.

The current implementation of Domino only supports partially the HTML 5 format.


http://www.w3.org/TR/DOM-Level-3-Core/core.html

DOM level 2 => DOMException, ExceptionCode, DOMImplementation, DocumentFragment, Document, Node, NodeList, NamedNodeMap, CharacterData, Attr, Element, Text, Comment

DOM level 3 adds => DOMStringList, NameList, DOMImplementationList, DOMImplementationSource, TypeInfo, UserDataHandler, DOMError, DOMErrorHandler, DOMLocator, DOMConfiguration
	
HTML DOM: http://www.w3.org/TR/DOM-Level-2-HTML/html.html

    HTMLCollection, HTMLOptionsCollection
    HTMLDocument
    HTMLElement
    HTMLHtmlElement, HTMLHeadElement, HTMLLinkElement, HTMLTitleElement, HTMLMetaElement, HTMLBaseElement, HTMLIsIndexElement, HTMLStyleElement, HTMLBodyElement, HTMLFormElement, 
	HTMLSelectElement, HTMLOptGroupElement, HTMLOptionElement, HTMLInputElement, HTMLTextAreaElement, HTMLButtonElement, HTMLLabelElement, HTMLFieldSetElement, HTMLLegendElement, 
	HTMLUListElement, HTMLOListElement, HTMLDListElement, HTMLDirectoryElement, HTMLMenuElement, HTMLLIElement, HTMLDivElement, HTMLParagraphElement, HTMLHeadingElement, HTMLQuoteElement, 
	HTMLPreElement, HTMLBRElement, HTMLBaseFontElement, HTMLFontElement, HTMLHRElement, HTMLModElement, HTMLAnchorElement, HTMLImageElement, HTMLObjectElement, HTMLParamElement, 
	HTMLAppletElement, HTMLMapElement, HTMLAreaElement, HTMLScriptElement, HTMLTableElement, HTMLTableCaptionElement, HTMLTableColElement, HTMLTableSectionElement, HTMLTableRowElement, 
	HTMLTableCellElement, HTMLFrameSetElement, HTMLFrameElement, HTMLIFrameElement

WARNING: This project is under heavy development. Packages and classes are likely to change in the next weeks. If you use it, be prepared to readapt your code in a few monthes.