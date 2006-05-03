var svgNS = "http://www.w3.org/2000/svg";

function description(message)
{
    var description = document.getElementById("description");
    var text = document.createElementNS(svgNS, "text");
    text.appendChild(document.createTextNode(message));
    text.setAttributeNS(null, "font-size", "15px");
    description.appendChild(text);
}

var linePos = 0;

function printTestPassed(prefix, message)
{
    var console = document.getElementById("console");
    var text = document.createElementNS(svgNS, "text");
    text.setAttributeNS(null, "fill", "green");
    text.setAttributeNS(null, "font-size", "15px");
    text.setAttributeNS(null, "y", linePos);
    
    text.appendChild(document.createTextNode(prefix));
    console.appendChild(text);

    var messageText = document.createElementNS(svgNS, "text");
    messageText.setAttributeNS(null, "font-size", "15px");
    messageText.setAttributeNS(null, "x", 10 * (prefix.length + 1));
    messageText.setAttributeNS(null, "y", linePos);
    messageText.appendChild(document.createTextNode(" " + message));
    console.appendChild(messageText);

    linePos += 15;
}    

function printTestFailed(prefix, message)
{
    var console = document.getElementById("console");
    var text = document.createElementNS(svgNS, "text");
    text.setAttributeNS(null, "fill", "red");
    text.setAttributeNS(null, "font-size", "15px");
    text.setAttributeNS(null, "y", linePos);
    
    text.appendChild(document.createTextNode(prefix));
    console.appendChild(text);

    var messageText = document.createElementNS(svgNS, "text");
    messageText.setAttributeNS(null, "font-size", "15px");
    messageText.setAttributeNS(null, "x", 10 * (prefix.length + 1));
    messageText.setAttributeNS(null, "y", linePos);
    messageText.appendChild(document.createTextNode(" " + message));
    console.appendChild(messageText);

    linePos += 15;
}    
