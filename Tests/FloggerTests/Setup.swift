import Foundation
@testable import Flogger

extension HumioLogger {
    func syncCache() {
        cacheQueue.sync { {}() } // awaits a sync operation enqueued on the cache worker to wait any outstanding operation
    }
}
