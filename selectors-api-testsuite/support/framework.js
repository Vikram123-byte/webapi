function fail(message) {
	throw new Error(message);
}
function assert(condition, message) {
	if (!condition)
		fail(message);
}
function assertEquals(expression, value, message) {
	if (expression != value) {
		expression = (""+expression).replace(/[\r\n]+/g, "\\n");
		value = (""+value).replace(/\r?\n/g, "\\n");
		fail("expected '" + value + "' but got '" + expression + "' - " + message);
	}
}

function TestSuite() {
	var results = new Array();

	this.runTests = function(tests) {
		for (var i = 0; i < tests.length; i++) {
			try {
				tests[i]();
				this.result(i, true, "");
			} catch (e) {
				this.result(i, false, e.message);
			}
		}
	}

	this.result = function(testID, result, message) {
		results.push({"id": testID, "result": result, "message": message})
	}

	this.publish = function() {
		var ol = document.createElement("ol");
		document.body.appendChild(ol);
		var li, text;
		for (var i = 0; i < results.length; i++) {
			li = document.createElement("li");
			if (results[i].result) {
				text = document.createTextNode("PASS");
			} else {
				text = document.createTextNode("FAIL, " + results[i].message);				
			}
			li.appendChild(text);
			ol.appendChild(li);
		}
	}
	
}

var testsuite = new TestSuite();