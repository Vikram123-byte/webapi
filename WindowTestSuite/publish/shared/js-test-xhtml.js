function debug(msg)
{
    var span = document.createElementNS("http://www.w3.org/1999/xhtml", "span");
    alert(span);
    span.innerHTML = msg + '<br/>';
    document.getElementById("console").appendChild(span);
}

