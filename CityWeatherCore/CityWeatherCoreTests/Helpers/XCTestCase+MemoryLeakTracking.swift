import XCTest

// Track memory leak extension
extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject,
                             file: StaticString = #file,
                             line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dellocated. Potential memory leak.", file: file, line: line)
        }
    }
}
