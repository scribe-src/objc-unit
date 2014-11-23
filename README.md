[![Build Status](https://travis-ci.org/scribe-src/objc-unit.svg?branch=master)](https://travis-ci.org/scribe-src/objc-unit)

### objc-unit

The `objc-unit` module implements a tiny, minimal unit testing framework built to test small OSX applications. It consists of one `.m` file and one `.h` file: simply drop it in to your project, add the files to your test target, define some specs, compile and run!

#### How does it work?

Test suites are simply defined as subclasses of the `TestSuite` class, with each test implemented as a separate class method. The Objective-C runtime is queried for a list of subclasses of `TestSuite`, and the class methods of the subclasses are called one-by-one.

#### Usage

A set of macros is provided for a minimal definition style:

    // AppDelegateTests.m

    #import "UnitTest.h"

    TEST_SUITE(AppDelegateTests)

    TEST(MissingPlistFile)
      @try {
        AppDelegate *appDelegate = [[AppDelegate new] autorelease];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath: [appDelegate plistPath] error: nil];
        [appDelegate readInfoPlist];
        Assert(false);
      } @catch (NSException *e) {
        AssertObjEqual([e name], @"Missing Info.plist");
      }
    END_TEST

    END_TEST_SUITE

You can also define your test suites directly in Objective-C (this might be helpful to your syntax highlighter):

    // AppDelegateTests.m

    #import "UnitTest.h"

    @interface AppDelegateTests: TestSuite
    @end

    @implementation AppDelegateTests

      + (void) MissingPlistFile {
        @try {
          AppDelegate *appDelegate = [[AppDelegate new] autorelease];
          NSFileManager *fileManager = [NSFileManager defaultManager];
          [fileManager removeItemAtPath: [appDelegate plistPath] error: nil];
          [appDelegate readInfoPlist];
          Assert(false);
        } @catch (NSException *e) {
          AssertObjEqual([e name], @"Missing Info.plist");
        }
      }

    @end

#### Output

Tests are logged line-by-line, grouped to their suite by indent-level:

    Running test suite ScribeEngineTests
      Running InjectNil... ✓
      Running InjectIntoValidContext... ✓
      Running InjectIntoValidContextReturnsScribeEngine... ✓
      Running AfterInjectScribeShouldBeDefined... ✓
      Running AfterInjectScribeDotEngineShouldBeDefined... ✓
      Running AfterInjectScribeDotLogShouldBeDefined... ✓
      Running AfterInjectConsoleShouldBeDefined... ✓
      Running AfterInjectConsoleDotLogShouldBeDefined... ✓
    Running test suite SetTimeoutTests
      Running SetTimeoutShouldBeDefined... ✓
      Running SetTimeoutShouldReturnPositiveNumber... ✓
      Running SetTimeoutShouldRunFunction... ✓
      Running CancelledTimeoutShouldNotRunFunction... ✓
      Running SetIntervalShouldCallMultipleTimes... ✓
      Running CancelledIntervalShouldNotCall... ✓

#### Assertion helpers

Several assertion helpers are provided:

    void Assert(int conditional);
    void AssertFalse(int conditional);
    void AssertNull(void* obj);
    void AssertNotNull(void* ptr);
    void AssertNil(void* obj);
    void AssertNotNil(void* obj);
    void AssertEqual(void* a, void* b);
    void AssertIntEqual(int a, int b);
    void AssertStrEqual(char* a, char* b);
    void AssertObjEqual(id a, id b);
    void AssertNotEqual(void* a, void* b);
    void AssertIntNotEqual(int a, int b);
    void AssertStrNotEqual(void* a, void* b);
    void AssertObjNotEqual(id a, id b);
    void AssertInstanceOfClass(id instance, Class klass);

#### Filtering test suites

The test suites can be filtered at runtime using the `MATCH` environment variable. To only run test suites that match the regular expression "FluxCapacitor":

    $ MATCH=FluxCapacitor make test

#### Seeding the test case randomizer

By default the order of test suites and cases is randomized. After a run ends, its unique "seed" value will be printed:

    =====================================================
    Tests complete: SUCCESSFUL. 17/17 passed.
    Seed: 2EDE34DE

To replicate the order of tests across multiple runs, you must pass the `SEED` environment variable.

    $ SEED=2EDE34DE make test
