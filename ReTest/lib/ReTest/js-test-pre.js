
var testPassCount = 0;
var testFailCount = 0;

function testPassed(msg)
{
    printTestPassed("PASS", msg);
    ++testPassCount;
}

function testFailed(msg)
{
    printTestFailed("FAIL", msg);
    ++testFailCount;
}

function shouldBe(_a, _b)
{
  if (typeof _a != "string" || typeof _b != "string") {
    testFailed("WARN: shouldBe() expects string arguments");
    return;
  }
  var exception;
  var _av;
  try {
     _av = eval(_a);
  } catch (e) {
     exception = e;
  }
  var _bv = eval(_b);

  if (exception)
    testFailed(_a + " should be " + _b + " which is " + _bv + ". Threw exception " + exception);
  else if (_av === _bv)
    testPassed(_a + " is " + _b);
  else {
    testFailed(_a + " should be " + _b + " (" + _bv + " of type " + typeof _bv 
               + "). Was " + _av + " (of type " + typeof _av + ").");
  }
}

function shouldBeTrue(_a) { shouldBe(_a, "true"); }

function shouldBeFalse(_a) { shouldBe(_a, "false"); }

function shouldBeNaN(_a)
{
  var exception;
  var _av;
  try {
     _av = eval(_a);
  } catch (e) {
     exception = e;
  }

  if (exception)
    testFailed(_a + " should be NaN. Threw exception " + exception + ".");
  else if (isNaN(_av))
    testPassed(_a + " is NaN.");
  else
    testFailed(_a + " should be NaN. Was " + _av + ".");
}


function shouldBeUndefined(_a)
{
  var exception;
  var _av;
  try {
     _av = eval(_a);
  } catch (e) {
     exception = e;
  }

  if (exception)
    testFailed(_a + " should be undefined. Threw exception " + exception);
  else if (typeof _av == "undefined")
    testPassed(_a + " is undefined.");
  else
    testFailed(_a + " should be undefined. Was " + _av);
}


function shouldThrow(_a, _e)
{
  var exception;
  var _av;
  try {
     _av = eval(_a);
  } catch (e) {
     exception = e;
  }

  var _ev;
  if (_e)
      _ev =  eval(_e);

  if (exception) {
    if (typeof _e == "undefined" || exception == _ev)
      testPassed(_a + " threw exception " + exception + ".");
    else
      testFailed(_a + " should throw exception " + _ev + ". Threw exception " + exception + ".");
  } else if (typeof _av == "undefined")
    testFailed(_a + " should throw exception " + _e + ". Was undefined.");
  else
    testFailed(_a + " should throw exception " + _e + ". Was " + _av + ".");
}

function shouldNotThrow(_a)
{
  var exception;
  var _av;
  try {
     _av = eval(_a);
  } catch (e) {
     exception = e;
  }

  if (exception)
    testFailed(_a + " should not throw. Threw exception " + exception + ".");
  else
    testPassed(_a + " did not throw exception.");
}
