/**
 * This set tests that the methods return the correct matching element
 */
var tests = [
function() {
	// Tests that querySelector matches the correct element

	// XXX
	// This will be replaced later to use the TestSuite framework to dynamically load the correct page and wait for it to be ready
	// Currently, this script may fail if the iframe doc hasn't completed loading.
	var doc = document.getElementsByTagName("iframe")[0];

	var selectors = [
		{selector: "body", expected: document.getElementById("body"), description: "Element selector"},
		{selector: "body#body", expected: document.getElementById("body"), description: "Element selector with ID selector"},
		{selector: "ul#firstUL", expected: document.getElementById(""), description: "Element selector with ID selector"},
		{selector: "#firstp #simon1", expected: document.getElementById("simon1"), description: "ID selectors with descendant combinator"},
		{selector: "#台北Táiběi", expected: document.getElementById("台北Táiběi"), description: "ID Selector with Unicode characters (non-ASCII)"},
		{selector: "#one, #two", expected: document.getElementById("one"), description: "Multiple ID selectors"},
		{selector: "#two, #one", expected: document.getElementById("one"), description: "Multiple ID selectors"},
		{selector: "#one, #non-existent", expected: document.getElementById("one"), description: "Multiple ID selectors"},
		{selector: "#non-existent, #one", expected: document.getElementById("one"), description: "Multiple ID selectors"}
	//	{selector: "", expected: document.getElementById(""), description: ""},
	];

	var a, b, msg;

	for (var i = 0; i < selectors.length; i++) {
		a = doc.querySelector(selectors[i].selector);
		b = selectors[i].expected;
		msg = selectors[i].description + ": Incorrect element returned for Selector: " + selectors[i].selector;

		ts.assert(a === b, msg);
	}
	return true;
}
/*,
function() {
	// All these selectors should match no elements, returning null
	return true;
}*/
];
