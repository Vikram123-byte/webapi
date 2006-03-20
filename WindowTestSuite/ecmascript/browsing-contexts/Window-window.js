description(
'This test checks testable assertions related to the <code>window</code> attribute of the <code>Window</code> interface'
);

// Each view of a Document presented in a browsing context MUST be
// represented by an object that implements the Window interface.

// Window objects MUST implement the following attributes:
// ... window

shouldNotThrow("window");
shouldBeFalse("typeof window == 'undefined'");
shouldBeFalse("typeof window == 'null'");

// The window attribute MUST be a reference to the same Window object that
// has the attribute (a self-reference).

shouldBeTrue("window == this");
shouldBe("window", "this");
shouldBeTrue("window.window == window");
shouldBe("window.window", "window");
