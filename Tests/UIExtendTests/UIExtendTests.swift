import XCTest
@testable import UIExtend

final class UIExtendTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UIExtend().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
