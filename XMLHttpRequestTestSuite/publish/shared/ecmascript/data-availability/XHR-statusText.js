description(
'This test checks whether the statusText of an XHR object is available for readyState 3 and 4 .'
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


function testResponseText() {
  var xhr = getXHR();
  
   try {
     noFailures = true;

     xhr.open("GET", ".",true);
     xhr.onreadystatechange=function() {
      if (noFailures && xhr.readyState >= 3) {
        try { 
          if (xhr.statusText == '' || xhr.statusText == 'undefined' || xhr.statusText == null ) {
            testFailed("readyState was " + xhr.readyState + " and responseText was not available");
            noFailures = false;
          }
        }
        catch( e ) {
          testFailed("accessing statusText threw exception in readyState " + xhr.readyState + ": " + e.message);
          noFailures = false;
        }
      }

      if (noFailures && xhr.readyState == 4) {
        testPassed("statusText was available for both readyState 3 and readyState 4");
      }
     }
     xhr.send(null)
   }
   catch (e) {
    testFailed("caught exception when opening location: " + e.message);
   } 
}

testResponseText();
var successfullyParsed = true;
var successfullyParsed = true;