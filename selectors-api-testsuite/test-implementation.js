/**
 * This set tests that the APIs have been implemented on objects implementing
 * various interfaces
 */
var tests = [
// Test support for NodeSelector on Objects implementing the Document interface
function() {
	ts.assert(document.querySelector != undefined, "querySelector is not implemented on document object");
	ts.assert(document.querySelectorAll != undefined, "querySelectorAll is not implemented on document object");
	return true;
},
function() {
	var doc = document.implementation.createDocument("http://www.w3.org/1999/xhtml", "html", null);
	ts.assert(doc.querySelector != undefined, "querySelector is not implemented on an object implementing the HTMLDocument interface");
	ts.assert(doc.querySelectorAll != undefined, "querySelectorAll is not implemented on an object implementing the HTMLDocument interface");
	return true;
},
function() {
	var doc = document.implementation.createDocument("http://www.w3.org/2000/svg", "svg:svg", null);
	ts.assert(doc.querySelector != undefined, "querySelector is not implemented on an object implementing the SVGDocument interface");
	ts.assert(doc.querySelectorAll != undefined, "querySelectorAll is not implemented on an object implementing the SVGDocument interface");
	return true;
},
function() {
	var doc = document.implementation.createDocument("", "test", null);
	ts.assert(doc.querySelector != undefined, "querySelector is not implemented on an object implementing the Document interface");
	ts.assert(doc.querySelectorAll != undefined, "querySelectorAll is not implemented on an object implementing the Document interface");
	return true;
},

// Test support for NodeSelector on Objects implementing the Element interface
function() {
	ts.assert(document.documentElement.querySelector != undefined, "querySelector is not implemented on the root Element");
	ts.assert(document.documentElement.querySelectorAll != undefined, "querySelectorAll is not implemented on the root Element");
	return true;
},
function() {
	var element = document.createElement("div");
	ts.assert(element.querySelector != undefined, "querySelector is not implemented on an HTMLElement");
	ts.assert(element.querySelectorAll != undefined, "querySelectorAll is not implemented on an HTMLElement");
	return true;
},
function() {
	var element = document.createElementNS("http://www.w3.org/2000/svg", "svg");
	ts.assert(element.querySelector != undefined, "querySelector is not implemented on an SVGElement");
	ts.assert(element.querySelectorAll != undefined, "querySelectorAll is not implemented on an SVGElement");
	return true;
}
];
