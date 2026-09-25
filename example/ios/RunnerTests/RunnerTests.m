@import XCTest;
@import integration_test;

@interface RunnerTests : XCTestCase
@end

@implementation RunnerTests

- (void)testIntegrationTest {
  __block NSUInteger testCount = 0;
  __block NSMutableArray<NSString *> *failures = [NSMutableArray array];

  [[FLTIntegrationTestRunner new]
      testIntegrationTestWithResults:^(SEL testSelector, BOOL success, NSString *failureMessage) {
        testCount += 1;
        if (!success) {
          [failures addObject:[NSString
                                  stringWithFormat:@"%@: %@", NSStringFromSelector(testSelector), failureMessage]];
        }
      }];

  XCTAssertGreaterThan(testCount, 0U);
  XCTAssertEqual(failures.count, 0U, @"%@", [failures componentsJoinedByString:@"\n"]);
}

@end
