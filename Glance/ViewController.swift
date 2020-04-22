import Cocoa

class ViewController: NSViewController {
	@IBOutlet private var totalStatsValueLabel: NSTextField!
	@IBOutlet private var dailyAverageStatsValueLabel: NSTextField!
	@IBOutlet private var fileTypeStatsValueLabel: NSTextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		updateStats()
	}

	@IBAction private func openSupportedFilesWindow(_: NSButton) {
		let supportedFilesWC = SupportedFilesWC(windowNibName: NSNib.Name("SupportedFilesWC"))
		supportedFilesWC.showWindow(nil)
	}

	/// Updates the statistics text fields with the actual usage data
	private func updateStats() {
		let stats = Stats()
		let extensionCounts = stats.getExtensionCounts()

		let nrPreviews = stats.getTotalCount()
		let averagePreviewsPerDay = nrPreviews == 0
			? 0
			: lround(Double(nrPreviews) / Double(stats.getDateCounts().count))
		let mostPopularExtension = extensionCounts.max { a, b in a.value < b.value }

		totalStatsValueLabel.stringValue = String(nrPreviews)
		dailyAverageStatsValueLabel.stringValue = String(averagePreviewsPerDay)
		fileTypeStatsValueLabel.stringValue = mostPopularExtension?.key ?? "None"
	}
}
