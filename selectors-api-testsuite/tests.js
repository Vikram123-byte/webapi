var tests = [
// Test support for NodeSelector on Objects implementing the Document interface
function() {
	assert(document.querySelector != undefined, "querySelector is not implemented on document object");
	assert(document.querySelectorAll != undefined, "querySelectorAll is not implemented on document object");
	return true;
},
function() {
	var doc = document.implementation.createDocument("http://www.w3.org/1999/xhtml", "html", null);
	assert(doc.querySelector != undefined, "querySelector is not implemented on an object implementing the HTMLDocument interface");
	assert(doc.querySelectorAll != undefined, "querySelectorAll is not implemented on an object implementing the HTMLDocument interface");
	return true;
},
function() {
	var doc = document.implementation.createDocument("http://www.w3.org/2000/svg", "svg:svg", null);
	assert(doc.querySelector != undefined, "querySelector is not implemented on an object implementing the SVGDocument interface");
	assert(doc.querySelectorAll != undefined, "querySelectorAll is not implemented on an object implementing the SVGDocument interface");
	return true;
},
function() {
	var doc = document.implementation.createDocument("", "test", null);
	assert(doc.querySelector != undefined, "querySelector is not implemented on an object implementing the Document interface");
	assert(doc.querySelectorAll != undefined, "querySelectorAll is not implemented on an object implementing the Document interface");
	return true;
},

// Test support for NodeSelector on Objects implementing the Element interface
function() {
	assert(document.documentElement.querySelector != undefined, "querySelector is not implemented on the root Element");
	assert(document.documentElement.querySelectorAll != undefined, "querySelectorAll is not implemented on the root Element");
	return true;
},
function() {
	var element = document.createElement("div");
	assert(element.querySelector != undefined, "querySelector is not implemented on an HTMLElement");
	assert(element.querySelectorAll != undefined, "querySelectorAll is not implemented on an HTMLElement");
	return true;
},
function() {
	var element = document.createElementNS("http://www.w3.org/2000/svg", "svg");
	assert(element.querySelector != undefined, "querySelector is not implemented on an SVGElement");
	assert(element.querySelectorAll != undefined, "querySelectorAll is not implemented on an SVGElement");
	return true;
}
];
