description(
'This test checks testable assertions related to the <code>document</code> attribute that the <code>DocumentWindow</code> interface inherits from the <code>DocumentView</code> interface.'
);

// A document that implements the DOM Core Document interface and is
// presented in a browsing context MUST also implement the
// DocumentWindow interface.

shouldNotThrow("document.defaultView");
shouldBeFalse("typeof document.defaultView == 'undefined'");

// The value of the defaultView property inherited by objects that
// implement the DocumentWindow interface from the AbstractView
// interface MUST be the default view for the browsing context
// presenting the document, if any. 

shouldBeFalse("typeof document.defaultView == 'null'");
shouldBeTrue("document.defaultView == window");
shouldBe("document.defaultView", "window");

// In addition to the AbstractView interface, the default view MUST
// implement the Window interface. 

shouldBeTrue("document.defaultView.window == window");
shouldBe("document.defaultView.window", "window");
shouldBeTrue("document.defaultView.self == self");
shouldBe("document.defaultView.self", "self");
shouldBeTrue("document.defaultView.document == document");
shouldBe("document.defaultView.document", "document");
