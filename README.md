# Flogger

**Requirements**: iOS 14.0+ &bull; Swift 5.7+ / Xcode 14+

## Installation

The [Swift Package Manager](https://swift.org/package-manager/) automates the distribution of Swift code. To use Flogger with SPM, add a dependency to `https://github.com/CodeReaper/Flogger.git`

## Quick Start

```swift
import Flogger

// ...

// Setup loggers
Flogger(level: .info, [ConsoleLogger()])

// Log statements
Flog.debug("This is a debug statement that will not be printed")
Flog.info("This is a info statement")
```

## Loggers

### ConsoleLogger

This is a simple print-out logger that is useful during local development.

It will print the messages to console with a log level prefix.

### HumioLogger

This is a logger that will deliver log messages to a Humio instance.

Arguments:
- `token` - The ingest token for a Humio instance, will be auto-loaded from `HUMIO_INGEST_TOKEN` in Info.plist, if present.
- `space` - The data space for a Humio instance, will be auto-loaded from `HUMIO_DATA_SPACE` in Info.plist, if present.
- `tags` - Additional tags to mark messages with.
- `allowsCellularAccess` - Control whether or not to transfer log messages over cellular networks.
- `frequencyTrigger` - How often to automatically send pending messages. Cannot be set below 5 seconds.
- `amountTrigger` - Always send pending messages when a certain amount is reached. Amount is clamped between to be between 10 and 100.

#### Info.plist entries for token and data space
```xml
        <key>HUMIO_INGEST_TOKEN</key>
        <string>$(HUMIO_INGEST_TOKEN)</string>
        <key>HUMIO_DATA_SPACE</key>
        <string>$(HUMIO_DATA_SPACE)</string>
```
