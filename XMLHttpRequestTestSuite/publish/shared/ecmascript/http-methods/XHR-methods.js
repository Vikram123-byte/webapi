description(
'This test checks HTTP methods support by the <code>open</code> method of the <code>XMLHttpRequest</code> interface. This test is informative only.'
);

function getXHR() {
  var xmlhttp=false;
  /*@cc_on @*/
  /*@if (@_jscript_version >= 5)
  // JScript gives us Conditional compilation, we can cope with old IE versions.
  // and security blocked creation of the objects.
   try {
    xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
   } catch (e) {
    try {
     xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    } catch (E) {
     xmlhttp = false;
    }
   }
  @end @*/
  if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
    try {
      xmlhttp = new XMLHttpRequest();
    } catch (e) {
      xmlhttp=false;
    }
  }
  if (!xmlhttp && window.createRequest) {
    try {
      xmlhttp = window.createRequest();
    } catch (e) {
      xmlhttp=false;
    }
  }

  return xmlhttp;
}


function testMethod(method) {
  var xhr = getXHR();
  
   try {
     xhr.open(method, ".",true);
     xhr.onreadystatechange=function() {
      if (xhr.readyState==4) {
       testPassed("open supports " + method + " HTTP method");
      }
     }
     xhr.send(null)
   }
   catch (e) {
    testFailed("open threw exception when using " + method + " HTTP method: " + e.message);
   } 
}

testMethod("HEAD");
testMethod("GET");
testMethod("POST");
testMethod("PUT");
testMethod("DELETE");
testMethod("OPTIONS");
var successfullyParsed = true;
var successfullyParsed = true;