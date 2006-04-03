shouldBeTrue("successfullyParsed");

printTestPassed("", "");

if (testFailCount == 0) {
    printTestPassed("TEST COMPLETE", "(all " + testPassCount + " of " + (testFailCount + testPassCount) + " assertions passed)");
} else {
    printTestFailed("TEST FAILED", "(" + testFailCount + " of " + (testFailCount + testPassCount) + " assertions failed)");
}