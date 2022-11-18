import XCTest
@testable import Flogger

final class HumioLoggerTests: XCTestCase {
    func make(level: Flogger.Level = .debug, enabled: Bool = true, allowsCellularAccess: Bool = true, frequencyTrigger: TimeInterval = 10, amountTrigger: Int = 10, tags: [String : String] = [:]) -> HumioLogger {
        return HumioLogger(token: "", space: "", tags: tags, allowsCellularAccess: allowsCellularAccess, frequencyTrigger: frequencyTrigger, amountTrigger: amountTrigger)
    }

    func testInstancesSetupAValidTimer() async throws {
        let humio = make(frequencyTrigger: 5)
        try await Task.sleep(nanoseconds: 10) // waits for timer to be setup on main queue

        XCTAssertNotNil(humio.timer)
        guard let timer = humio.timer else { return }
        XCTAssertTrue(timer.isValid)
    }

    func testInstancesIsObserving() async throws {
        let humio = make()
        XCTAssertNotNil(humio.observer)
    }

    func testDefaultTagsReportContainsProperKeys() {
        let keys = make().tags.keys
        XCTAssertTrue(keys.contains("platform"))
        XCTAssertTrue(keys.contains("bundleIdentifier"))
        XCTAssertTrue(keys.contains("CFBundleVersion"))
        XCTAssertTrue(keys.contains("CFBundleShortVersionString"))
        XCTAssertTrue(keys.contains("systemVersion"))
        XCTAssertTrue(keys.contains("deviceModel"))
    }

    func testDefaultTagsReportOSAsIOS() {
        let tags = make().tags
        let value = tags["platform"]
        XCTAssertNotNil(value)
        XCTAssertEqual(value, "ios")
    }

    func testAdditionalTagsAreIncluded() {
        let tags = make(tags: ["extra": "data"]).tags
        let value = tags["extra"]
        XCTAssertNotNil(value)
        XCTAssertEqual(value, "data")
    }

    func testDisabledDoesNotQueue() {
        let humio = make(enabled: false)
        humio.debug("hi!")
        XCTAssertTrue(humio.cache.isEmpty)
    }

    func testEnabledDoesQueue() {
        let humio = make()
        humio.debug("hi!")
        humio.syncCache()
        XCTAssertFalse(humio.cache.isEmpty)
    }

    func testAllLevelsIsPutIntoQueue() {
        let humio = make()
        humio.debug("hi!")
        humio.info("hi!")
        humio.warn("hi!")
        humio.error("hi!")
        humio.syncCache()
        XCTAssertEqual(humio.cache.count, 4)
    }
}
