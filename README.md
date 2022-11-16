# HumioLogger

**Requirements**: iOS 14.0+ &bull; Swift 5.7+ / Xcode 14+

## Usage

### Add Humio ingest token and dataspace name to Info.plist
```xml
        <key>HUMIO_INGEST_TOKEN</key>
        <string>$(HUMIO_INGEST_TOKEN)</string>
        <key>HUMIO_DATA_SPACE</key>
        <string>$(HUMIO_DATA_SPACE)</string>
```

### Call setup once and use logging methods
```swift
import HumioLogger

// Call setup
Humio.setup(level: .info)

// Log statements
Humio.debug("This is a debug statement that is not delivered to Humio")
Humio.info("This is a info statement that will be sent to Humio")
```

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) automates the distribution of Swift code. To use GRDB with SPM, add a dependency to `https://github.com/CodeReaper/HumioLogger.git`
