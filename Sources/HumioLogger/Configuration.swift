import Foundation

struct Configuration {
    let level: Humio.Level
    let enabled: Bool
    let printMessages: Bool
    let allowsCellularAccess: Bool
    let frequencyTrigger: TimeInterval
    let amountTrigger: Int
    let tags: [String: String]
}
