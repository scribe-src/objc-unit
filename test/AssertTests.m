#import "UnitTest.h"

TEST_SUITE(AssertTests)

FORK(NO)

TEST(AssertTrue)
  Assert(true);
END_TEST

TEST(AssertFalse)
  AssertFalse(false);
END_TEST

TEST(AssertNull)
  AssertNull(NULL);
END_TEST

TEST(AssertNil)
  AssertNil(nil);
END_TEST

TEST(AssertNotNil)
  AssertNotNil(@"ok");
END_TEST

TEST(AssertEqual)
  AssertEqual(NULL, NULL);
END_TEST

TEST(AssertIntEqual)
  AssertIntEqual(1, 1);
END_TEST

TEST(AssertStrEqual)
  AssertStrEqual("xyz", "xyz");
END_TEST

TEST(AssertObjEqual)
  AssertObjEqual(@"xyz", @"xyz");
END_TEST

TEST(AssertNotEqual)
  AssertNotEqual(NULL, "abc");
END_TEST

TEST(AssertIntNotEqual)
  AssertIntNotEqual(1, 2);
END_TEST

TEST(AssertStrNotEqual)
  AssertStrNotEqual("abc", "xyz");
END_TEST

TEST(AssertObjNotEqual)
  AssertObjNotEqual(@"abc", @"xyz");
END_TEST

TEST(AssertInstanceOfClass)
  AssertInstanceOfClass(@"abc", [NSString class]);
END_TEST

END_TEST_SUITE