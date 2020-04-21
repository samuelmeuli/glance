import Foundation
import os.log

/// Class for reading and updating usage statistics. The values are stored in `UserDefaults` for the
/// application group (so they can be accessed by both the main app and Quick Look extension)
class Stats {
	private let dateCountsKey = "dateCount"
	private let extensionCountsKey = "extensionCount"
	private let totalCountKey = "totalCount"

	private let defaults: UserDefaults?

	init() {
		defaults = UserDefaults(suiteName: "group.com.samuelmeuli.glance")
		if defaults == nil {
			os_log(
				"Unable to initialize user defaults: Object is null",
				log: Log.general,
				type: .error
			)
		}
	}

	/// Returns the stored dictionary with number of previews generated per day
	func getDateCounts() -> [String: Int] {
		defaults!.dictionary(forKey: dateCountsKey) as? [String: Int] ?? [String: Int]()
	}

	/// Returns the stored dictionary with number of previews generated per file extension
	func getExtensionCounts() -> [String: Int] {
		defaults!.dictionary(forKey: extensionCountsKey) as? [String: Int] ?? [String: Int]()
	}

	/// Returns the total number of generated previews
	func getTotalCount() -> Int {
		defaults!.integer(forKey: totalCountKey)
	}

	/// Updates all statistics to record that a new preview has been generated
	func increaseStatsCounts(fileExtension: String) {
		let todayString = Date().toDateString()

		// Increase today's date count by 1
		var dateCounts = getDateCounts()
		dateCounts[todayString] = dateCounts[todayString, default: 0] + 1
		defaults!.set(dateCounts, forKey: dateCountsKey)

		// Increase file extension count by 1
		var extensionCounts = getExtensionCounts()
		extensionCounts[fileExtension] = extensionCounts[fileExtension, default: 0] + 1
		defaults!.set(extensionCounts, forKey: extensionCountsKey)

		// Increase total count by 1
		defaults!.set(getTotalCount() + 1, forKey: totalCountKey)
	}
}
