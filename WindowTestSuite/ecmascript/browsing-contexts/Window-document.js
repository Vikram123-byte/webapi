description(
'This test checks testable assertions related to the <code>document</code> attribute that the <code>Window</code> interface inherits from the <code>AbstractView</code> interface.'
);

// Each view of a Document presented in a browsing context MUST be
// represented by an object that implements the Window interface.

// FIXME: is this testable?

// The value of the document property inherited by Window objects from
// the AbstractView interface MUST be the document for which the
// Window is a view.

shouldNotThrow("document");
shouldBeFalse("typeof document == 'undefined'");
shouldBeFalse("typeof document == 'null'");

// how to test the window is *a* view for this document? At best we
// can check it is the default view but this is already tested in the
// DocumentWindow-defaultView test.

// In addition to the DocumentView interface, the document MUST
// implement the Document and DocumentWindow interfaces. We'll just
// check for some common methods and attributes of the Document
// interface. Having the DocumentWindow interface is already tested by
// the DocumentWindow-defaultView test.

shouldNotThrow("document.getElementById");
shouldBeFalse("typeof document.getElementById == 'undefined'");
shouldBeFalse("typeof document.getElementById == 'null'");
shouldNotThrow("document.documentElement");
shouldBeFalse("typeof document.documentElement == 'undefined'");
shouldBeFalse("typeof document.documentElement == 'null'");

// When a DOM Events UIEvent is dispatched on any node in a Document
// presented in a browsing context, the value of the view attribute of
// the event MUST be the Window object where the user originated the
// event.

// this needs a separate test I guess, if we want to keep this assertion at all.
