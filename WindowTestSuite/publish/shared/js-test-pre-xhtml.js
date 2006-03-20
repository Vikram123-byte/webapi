
var xhtmlNS = "http://www.w3.org/1999/xhtml";

// FIXME: This test suite depends on the nonstandard innerHTML
// property. It would be much better to use standards but the result
// would be much more verbose.

function description(msg)
{
    document.getElementById("description").innerHTML = '<p>' + msg + '</p><p>On success, you will see a series of "<span class="pass">PASS</span>" messages, followed by "<span class="pass">TEST COMPLETE</span>".</p>';
}

function printTestPassed(prefix, message)
{
    var console = document.getElementById("console");
    var span = document.createElementNS(xhtmlNS, "span");
    span.setAttributeNS(null, "class", "pass");
    span.appendChild(document.createTextNode(prefix));
    console.appendChild(span);
    console.appendChild(document.createTextNode(" " + message));
    console.appendChild(document.createElementNS(xhtmlNS, "br"));
}    

function printTestFailed(prefix, message)
{
    var console = document.getElementById("console");
    var span = document.createElementNS(xhtmlNS, "span");
    span.setAttributeNS(null, "class", "fail");
    span.appendChild(document.createTextNode(prefix));
    console.appendChild(span);
    console.appendChild(document.createTextNode(" " + message));
    console.appendChild(document.createElementNS(xhtmlNS, "br"));
}    
