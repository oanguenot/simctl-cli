import XCTest

import simctl_cliTests

var tests = [XCTestCaseEntry]()
tests += simctl_cliTests.allTests()
XCTMain(tests)
