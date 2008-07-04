/**
 * Core framework for Selectors API test suite
 * This framework invokes each test, records the results and outputs the results
 * into the page.
 *
 * The runTests method accepts an array of test functions. Each function must
 * return true when it completes successfully, or throw an exception if the test
 * fails. If the test is waiting for additional resources to load before it can
 * continue the test must return false.  It will then be invoked again after a
 * short delay, but will only be invoked a maximum of 500 times before being
 * considered a failure.
 */
function TestSuite() {
	var self = this;

	var results = null; // Store all test results
	var tests   = null; // Array of all the test functions
	var notify  = null; // Callback function to be invokend when all tests are finished

	var inProgress = false; // In-progress flag, set to true while tests are being executed.

	// Variables to manage test execution
	var index = 0; // Current test index
	var retry = 0; // Retry count for current test
	var delay = 10; // Delay between tests in ms

	// iframe for use by tests to load external resources when needed
	// Need to add utility functions to allow tests to access this
	var iframe = document.createElement("iframe");

	var recordResult = function(testID, result, message) {
		results.push({"id": testID, "result": result, "message": message})
		retry = 0; // Reset retry count
		index++; // Move to the next test
//		alert(results[results.length - 1]);
	}

	var fail = function(message) {
		throw new Error(message);
	}

	var finished = function() {
		inProgress = false;
		notify();
	}

	var callNext = function(self) {
		return function(){
			self.nextTest();
		}	
	}

	this.nextTest = function() {
		if (index < tests.length) {
			var result = false;
			try {
				result = tests[index]();
				if (result == false) {
					// Test is incomplete, need to try again.
					retry++;
					if (retry == 500) {
						// Maximum number of attempts reached, record failure
						fail("timeout -- could be a networking issue");
					}
				} else {
					recordResult(index, true, ""); // Record success and move to next test
				}
			} catch (e) {
				recordResult(index, false, e.message);  // Record failure and move to next test
			}
			setTimeout(callNext(this), delay);
		} else {
			finished();
		}
	}

	this.runTests = function(testArray, callback) {
		if (!inProgress) {
			inProgress = true; // Can only execute one set of tests at a time
			index = 0;

			results = new Array(); // Clear previous results
			tests = testArray;
			notify = callback || function(){};

			this.nextTest();
			return true;
		}
		return false;
	}

	this.assert = function(condition, message) {
		if (!condition) {
			fail(message);
		}
	}

	this.assertEquals = function(expression, value, message) {
		if (expression != value) {
			expression = (""+expression).replace(/[\r\n]+/g, "\\n");
			value = (""+value).replace(/\r?\n/g, "\\n");
			fail("expected '" + value + "' but got '" + expression + "' - " + message);
		}
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

var ts = new TestSuite();