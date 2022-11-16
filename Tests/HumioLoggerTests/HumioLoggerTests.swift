import XCTest
@testable import HumioLogger

final class HumioLoggerTests: XCTestCase {
    func make(level: Humio.Level = .debug, enabled: Bool = true, allowsCellularAccess: Bool = true, frequencyTrigger: TimeInterval = 10, amountTrigger: Int = 10, tags: [String : String] = [:]) -> Humio {
        Humio(configuration: Configuration(level: level, enabled: enabled, printMessages: false, allowsCellularAccess: allowsCellularAccess, frequencyTrigger: frequencyTrigger, amountTrigger: amountTrigger, tags: tags), token: "", space: "-")
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

    func testIgnoredLevelAreNotPutIntoQueue() {
        let humio = make(level: .info)
        humio.debug("hi!")
        humio.debug("hi!")
        humio.info("hi!")
        humio.info("hi!")
        humio.syncCache()
        XCTAssertEqual(humio.cache.count, 2)
    }

    func testIgnoringLevelsDebugAndInfo() {
        let humio = make(level: .warn)
        humio.debug("hi!")
        humio.info("hi!")
        humio.warn("hi!")
        humio.warn("hi!")
        humio.error("hi!")
        humio.error("hi!")
        humio.syncCache()
        XCTAssertEqual(humio.cache.count, 4)
    }

    func testIgnoredLevelAreNotPutIntoQueueAndThatErrorCannotBeIgnored() {
        let humio = make(level: .error)
        humio.debug("hi!")
        humio.info("hi!")
        humio.warn("hi!")
        humio.error("hi!")
        humio.error("hi!")
        humio.syncCache()
        XCTAssertEqual(humio.cache.count, 2)
    }
}

extension Humio {
    func syncCache() {
        cacheQueue.sync { {}() } // awaits a sync operation enqueued on the cache worker to wait any outstanding operation
    }
}
