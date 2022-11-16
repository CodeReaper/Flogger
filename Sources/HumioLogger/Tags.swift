import Foundation

extension Humio {
    static var tags: [String: String] {
        let version = ProcessInfo().operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        var sysinfo = utsname()
        uname(&sysinfo)
        let deviceIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return [
            "platform": "ios",
            "bundleIdentifier": Bundle.main.bundleIdentifier ?? "unknown",
            "CFBundleVersion": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown",
            "CFBundleShortVersionString": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "systemVersion": versionString,
            "deviceModel": deviceIdentifier
        ]
    }
}
