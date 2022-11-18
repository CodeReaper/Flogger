import XCTest
@testable import Flogger

final class FloggerTests: XCTestCase {
    func testIgnoredLevelAreNotPutIntoQueue() {
        let logger = CountLogger()
        var flogger = Flogger(level: .info)
        flogger.add(logger)
        flogger.debug("hi!")
        flogger.debug("hi!")
        flogger.info("hi!")
        flogger.info("hi!")
        XCTAssertEqual(logger.count, 2)
    }

    func testIgnoringLevelsDebugAndInfo() {
        let logger = CountLogger()
        var flogger = Flogger(level: .warn)
        flogger.add(logger)
        flogger.debug("hi!")
        flogger.info("hi!")
        flogger.warn("hi!")
        flogger.warn("hi!")
        flogger.error("hi!")
        flogger.error("hi!")
        XCTAssertEqual(logger.count, 4)
    }

    func testIgnoredLevelAreNotPutIntoQueueAndThatErrorCannotBeIgnored() {
        let logger = CountLogger()
        var flogger = Flogger(level: .error)
        flogger.add(logger)
        flogger.debug("hi!")
        flogger.info("hi!")
        flogger.warn("hi!")
        flogger.error("hi!")
        flogger.error("hi!")
        XCTAssertEqual(logger.count, 2)
    }
}

private class CountLogger: Logger {
    var count: Int = 0

    public init() { }

    public func debug(_ message: String, _ file: String, _ line: Int) {
        count += 1
    }

    public func info(_ message: String, _ file: String, _ line: Int) {
        count += 1
    }

    public func warn(_ message: String, _ file: String, _ line: Int) {
        count += 1
    }

    public func error(_ message: String, _ file: String, _ line: Int) {
        count += 1
    }
}
