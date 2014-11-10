### objc-unit

The `objc-unit` module implements a tiny, DRY unit testing framework built to test small OSX applications. It consists of one `.m` file and one `.h` file: simply drop it in to your project, add the files to your test target, define some specs, compile and run!

#### How does it work?

Test suites are simply defined as subclasses of `UnitTest`, with each test implemented as a separate class method. The Objective-C runtime is queried for a list of subclasses of `UnitTest`, and the class methods of the subclasses are called one-by-one.

#### Usage

A set of macros is provided for a minimal definition style:

    // AppDelegateTests.m

    TEST_SUITE(AppDelegateTests)

    FORK(NO)

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

    @interface AppDelegateTests: UnitTest
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