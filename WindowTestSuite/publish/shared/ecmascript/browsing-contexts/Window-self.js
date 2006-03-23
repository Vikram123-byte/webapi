description(
'This test checks testable assertions related to the <code>self</code> attribute of the <code>Window</code> interface.'
);

// Each view of a Document presented in a browsing context MUST be
// represented by an object that implements the Window interface.

// Window objects MUST implement the following attributes:
// ... self

shouldNotThrow("self");
shouldBeFalse("typeof self == 'undefined'");
shouldBeFalse("typeof self == 'null'");

// The self attribute MUST be a reference to the same Window object that
// has the attribute (a self-reference).

shouldBeTrue("self == this");
shouldBe("self", "this");
shouldBeTrue("self.self == self");
shouldBe("self.self", "self");

// Consequently, it also MUST be a reference to the same object as the
// window attribute.

shouldBeTrue("self == window");
shouldBe("self", "window");
shouldBeTrue("window.self == self");
shouldBe("window.self", "self");
shouldBeTrue("self.window == self");
shouldBe("self.window", "self");
var successfullyParsed = true;