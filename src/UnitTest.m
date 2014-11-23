#import "UnitTest.h"

//
// Unit test helpers
//

int $seed;
NSString *$currentTest;
NSString *$currentSuite;
unsigned int testsRan = 0;
unsigned int testsPassed = 0;
NSPipe *exceptionPipe;
NSMutableArray *failingTests;


void Assert(int conditional) {
  if (!conditional) {
    [NSException raise:@"False Assertion" format:@"Expected true.", nil];
  }
}

void AssertFalse(int conditional) {
  if (conditional) {
    [NSException raise:@"True Assertion" format:@"Expected false.", nil];
  }
}

void AssertNotNull(void* ptr) {
  if (ptr == NULL) {
    [NSException raise:@"False Assertion" format:@"Expected %p not to be NULL.", ptr, nil];
  }
}

void AssertNotNil(void* obj) {
  if (obj == nil) {
    [NSException raise:@"False Assertion" format:@"Expected %p not to be nil.", obj, nil];
  }
}

void AssertEqual(void* a, void* b) {
  if (a != b) {
    [NSException raise:@"False Assertion" format:
      @"Expected %p to equal %p.", a, b, nil
    ];
  }
}

void AssertIntEqual(int a, int b) {
  if (a != b) {
    [NSException raise:@"False Assertion" format:
      @"Expected %d to equal %d.", a, b, nil
    ];
  }
}

void AssertStrEqual(char* a, char* b) {
  if (strcmp((const char*)a, (const char*)b)) {
    [NSException raise:@"False Assertion" format:
      @"Expected %s to equal %s.", a, b, nil
    ];
  }
}


void AssertObjEqual(id a, id b) {
  if (![a isEqual: b]) {
    [NSException raise:@"False Assertion" format:
      @"Expected %@ to equal %@.", a, b, nil
    ];
  }
}

void AssertNotEqual(void* a, void* b) {
  if (a == b) {
    [NSException raise:@"False Assertion" format:
      @"Expected %p not to equal %p.", a, b, nil
    ];
  }
}


void AssertIntNotEqual(int a, int b) {
  if (a == b) {
    [NSException raise:@"False Assertion" format:
      @"Expected %d not to equal %d.", a, b, nil
    ];
  }
}


void AssertStrNotEqual(void* a, void* b) {
  if (!strcmp((const char*)a, (const char*)b)) {
    [NSException raise:@"False Assertion" format:
      @"Expected %s not to equal %s.", a, b, nil
    ];
  }
}

void AssertObjNotEqual(id a, id b) {
  if ([a isEqual: b]) {
    [NSException raise:@"False Assertion" format:
      @"Expected %@ not to equal %@.", a, b, nil
    ];
  }
}


void AssertNull(void* ptr) {
  if (ptr != NULL) {
    [NSException raise:@"False Assertion" format:
      @"Expected %p to be NULL.", ptr, nil
    ];
  }
}

void AssertNil(void* obj) {
  if (obj != nil) {
    [NSException raise:@"False Assertion" format:
      @"Expected %@ to be nil.", obj, nil
    ];
  }
}

void AssertInstanceOfClass(id instance, Class klass) {
  if (![instance isKindOfClass: klass]) {
    [NSException raise:@"False Assertion" format:
      @"Expected %@ to be instance of %@.", instance, klass
    ];
  }
}

//
// Unit test management/running procedures
//

@implementation TestSuite
- (void) suiteInitialize {}
- (BOOL) shouldFork { return NO; }
@end


BOOL matches(NSString *klassName, char* envVar) {
  char* match = getenv(envVar);
  if (match && strlen(match)) {
    NSString *regex = [NSString stringWithCString: match encoding: NSUTF8StringEncoding];
    return ([klassName rangeOfString: regex options: NSRegularExpressionSearch].location != NSNotFound);
  } else {
    return YES;
  }
}


NSArray *ClassGetSubclasses(Class parentClass) {
  int numClasses = objc_getClassList(NULL, 0);
  Class *classes = NULL;
 
  classes = malloc(sizeof(Class) * numClasses);
  numClasses = objc_getClassList(classes, numClasses);
   
  NSMutableArray *result = [NSMutableArray array];
  for (NSInteger i = 0; i < numClasses; i++) {
    Class superClass = classes[i];
    do {
      superClass = class_getSuperclass(superClass);
    } while(superClass && superClass != parentClass);
     
    if (superClass == nil) {
      continue;
    }
     
    [result addObject:classes[i]];
  }
 
  free(classes);
   
  return result;
}

void PrintGood(NSString *msg) {
  printf("\033[0;32;40m%s\033[0m", msg.UTF8String);
}

void PrintBold(NSString *msg) {
  printf("\033[1m%s\033[0m", msg.UTF8String);
}

void PrintBad(NSString *msg) {
  printf("\033[0;31;40m%s\033[0m", msg.UTF8String);
}

void Print(NSString *msg) {
  printf("%s", msg.UTF8String);
}

void ReportSpecSuccess(NSString *name) {
  testsRan++;
  testsPassed++;
  Print(@"\n    Running ");
  PrintBold(name);
  Print(@"...");
  PrintGood(@"\xE2\x9C\x93");
}

void ReportSpecFailure(NSString *name, NSString *details) {
  testsRan++;
  Print(@"\n    Running ");
  PrintBold(name);
  Print(@"...");
  PrintBad(@"X\n    ");
  PrintBad(@"Test failed: ");
  PrintBad(details);
}

void ReportException(NSString *exception) {
  NSData *data = [exception dataUsingEncoding:NSUTF8StringEncoding];
  [[exceptionPipe fileHandleForWriting] writeData: data]; 
}

void SignalHandler(int sig) {
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMutableString *backtraceStr = [NSMutableString string];
  int callstack[128];
  int  frames = backtrace((void**) callstack, 128);
  char **syms = backtrace_symbols((void**) callstack, frames);

  for (int i = 1; i < frames; i++) {
    NSString *frame = [NSString stringWithCString: syms[i] encoding: NSUTF8StringEncoding];
    [backtraceStr appendString: frame];
    [backtraceStr appendString: @"\n"];
  }

  NSString *signal = nil;
  switch (sig) {
    case SIGABRT:
      signal = @"SIGABRT\n";
      break;
    case SIGFPE:
      signal = @"SIGFPE\n";
      break;
    case SIGILL:
      signal = @"SIGILL\n";
      break;
    case SIGINT:
      signal = @"SIGINT\n";
      break;
    case SIGSEGV:
      signal = @"SIGSEGV\n";
      break;
    case SIGTERM:
      signal = @"SIGTERM\n";
      break;
    case SIGTRAP:
      signal = @"SIGTRAP\n";
      break;
    case SIGBUS:
      signal = @"SIGBUS\n";
      break;
    case SIGPIPE:
      signal = @"SIGPIPE\n";
      break;
    default:
      signal = @"UNKNOWN\n";
  }

  [backtraceStr insertString: signal atIndex: 0];

  // if FORKING
  // ReportException(backtraceStr);
  // else

  PrintBad([NSString stringWithFormat: @"Signal caught:\n%@", backtraceStr]);
  [pool drain];
  exit(1);
}

void InstallSignalHandlers() {
  signal(SIGABRT, SignalHandler);
  signal(SIGFPE,  SignalHandler);
  signal(SIGILL,  SignalHandler);
  signal(SIGINT,  SignalHandler);
  signal(SIGSEGV, SignalHandler);
  signal(SIGTERM, SignalHandler);
  signal(SIGTRAP, SignalHandler);
  signal(SIGBUS, SignalHandler);
  signal(SIGPIPE, SignalHandler);
}

unsigned int RunTests(id klass) {
  // keep an anonymous instance so we can access instance methods,
  // which prevents the need from filtering out class methods that
  // are not tests
  TestSuite *instance = (TestSuite *)[[klass new] autorelease];

  // do any test-suite-level setup
  [instance suiteInitialize];

  unsigned int numMethods = 0;
  unsigned int numPassed  = 0;
  Method *methodsArr = class_copyMethodList(object_getClass(klass), &numMethods);
  NSMutableArray *methods = [[NSMutableArray new] autorelease];
  for (unsigned int i = 0; i < numMethods; i++) {
    id value = [NSValue value: &methodsArr[i] withObjCType: @encode(Method)];
    [methods addObject: value];
  }

  while ([methods count] > 0) {
    int randIdx = random()%[methods count];
    Method m;
    [[methods objectAtIndex: randIdx] getValue: &m];
    [methods removeObjectAtIndex: randIdx];

    struct objc_method_description *m_desc = method_getDescription(m);
    $currentTest = NSStringFromSelector(m_desc->name);

    if (!matches($currentTest, "TEST_MATCH")) {
      continue;
    }

    Print(@"  Running ");
    PrintBold($currentTest);
    Print(@"... ");
    fflush(stdout);

    

    BOOL passed = true;
    NSException *failure = nil;
    NSString *failureMessage = nil;
    testsRan++;

    BOOL isChild = NO;
    exceptionPipe = [NSPipe pipe];

    if ([instance shouldFork]) {

      if (fork()) { // parent
        int status;        
        wait(&status);

        if (status != 0) {
          passed = false;
          NSData *data = [[exceptionPipe fileHandleForReading] availableData];
          failureMessage = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        }
      } else {
        isChild = YES;
        InstallSignalHandlers();
      }
    }

    if (![instance shouldFork] || isChild) {
      @try {
        method_getImplementation(m)(klass, m_desc->name);
      } @catch (NSException *e) {
        passed = false;
        failure = e;
      }

      NSData *data = nil;
      if (!passed) {
        NSMutableString *message = [NSMutableString string];
        [message appendFormat: @"%@: %@\n", [failure name], [failure reason]];
        for (NSString *sym in [failure callStackSymbols]) {
          [message appendFormat: @"%@\n", sym];
        }

        data = [message dataUsingEncoding:NSUTF8StringEncoding];
        [[exceptionPipe fileHandleForWriting] writeData: data];
      }
    }

    if ([instance shouldFork]) {
      if (isChild) exit((passed) ? 0 : 1);
    } else {
      if (!passed) {
        NSData *data = [[exceptionPipe fileHandleForReading] availableData];
        failureMessage = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
      }
    }

    if (passed) {
      numPassed++;
      testsPassed++;

      PrintGood(@"\xE2\x9C\x93");
    } else {
      PrintBad(@"X\n    ");
      PrintBad(failureMessage);
      NSString *bottomFormat = [NSString stringWithFormat:
        @"%@: %@", NSStringFromClass(klass), NSStringFromSelector(m_desc->name), nil
      ];
      [failingTests addObject: bottomFormat];
    }

    $currentTest = NULL;
    Print(@"\n");
  }

  return numPassed;
}

void HandleSeed() {
  char* seedStr = getenv("SEED");
  if (seedStr && strlen(seedStr)) {
    $seed = (int)strtol(seedStr, NULL, 16);
  } else {
    srandom(time(NULL));
    $seed = random();
  }
  srandom($seed);
  printf("Running with seed ");
  PrintGood([NSString stringWithFormat: @"%X", $seed]);
  printf("\n");
}

int main() {
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  InstallSignalHandlers();
  HandleSeed();

  failingTests = [NSMutableArray new];
  NSMutableArray *classes = [[ClassGetSubclasses([TestSuite class]) mutableCopy] autorelease];

  while ([classes count] > 0) {
    int randIdx = random()%[classes count];
    id klass = [classes objectAtIndex: randIdx];
    [classes removeObjectAtIndex: randIdx];
    NSString *klassName = NSStringFromClass(klass);
    $currentSuite = klassName;
    if (matches(klassName, "MATCH")) {
      Print(@"\nRunning test suite ");
      PrintBold(klassName);
      Print(@"\n");
      RunTests(klass);
    }
    $currentSuite = NULL;
  }

  Print(@"\n=====================================================\n");
  PrintBold(@"Tests complete: ");

  NSString *status = [NSString stringWithFormat:@"%d/%d passed.", testsPassed, testsRan, nil];
  if (testsRan == testsPassed) {
    PrintGood(@"SUCCESSFUL. ");
    PrintGood(status);
  } else {
    PrintBad(@"FAILED. ");
    PrintBad(status);
    Print(@"\n\nFailing specs:\n");
    for (NSString *testName in failingTests) {
      PrintBad(testName);
      Print(@"\n");
    }
  }

  Print([NSString stringWithFormat: @"\nSeed: %X\n\n", $seed]);
  exit(testsRan - testsPassed);

  [pool drain];

  return 0;
}
