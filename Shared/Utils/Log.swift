import Foundation
import os.log

struct Log {
	// Subsystems
	static let subsystem = Bundle.main.bundleIdentifier!

	// Categories
	static let general = OSLog(subsystem: subsystem, category: "general")
	static let parse = OSLog(subsystem: subsystem, category: "parse")
	static let render = OSLog(subsystem: subsystem, category: "render")
}
