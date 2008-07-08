/**
 * This set tests that the methods return the correct matching element
 */
var iframe = document.createElement("iframe");
var iframeLoaded = false;

iframe.onload = function() {
	iframeLoaded = true;
}

var tests = [
function() {
	// Tests that querySelector matches the correct element

	iframe.src = "support/test.html";
	if (!iframe.parentNode) {
		document.body.appendChild(iframe);
	}
	if (!iframeLoaded) {
		return false;
	}
	var doc = iframe.contentDocument;

	var selectors = [
		{selector: "body", expected: doc.getElementById("body"), description: "Element selector"},
		{selector: "body#body", expected: doc.getElementById("body"), description: "Element selector with ID selector"},
		{selector: "ul#firstUL", expected: doc.getElementById("firstUL"), description: "Element selector with ID selector"},
		{selector: "#firstp #simon1", expected: doc.getElementById("simon1"), description: "ID selectors with descendant combinator"},
		{selector: "#台北Táiběi", expected: doc.getElementById("台北Táiběi"), description: "ID Selector with Unicode characters (non-ASCII)"},
		{selector: "#one, #two", expected: doc.getElementById("one"), description: "Multiple ID selectors"},
		{selector: "#two, #one", expected: doc.getElementById("one"), description: "Multiple ID selectors"},
		{selector: "#one, #non-existent", expected: doc.getElementById("one"), description: "Multiple ID selectors"},
		{selector: "#non-existent, #one", expected: doc.getElementById("one"), description: "Multiple ID selectors"}
	//	{selector: "", expected: doc.getElementById(""), description: ""},
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
