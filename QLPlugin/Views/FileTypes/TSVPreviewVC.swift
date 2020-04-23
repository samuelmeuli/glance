import Cocoa
import Foundation
import os.log
import SwiftCSV

/// View controller for previewing TSV files
class TSVPreviewVC: TablePreviewVC, PreviewVC {
	func loadPreview() throws {
		// Read and parse TSV file
		var csv: CSV
		do {
			csv = try CSV(url: file.url, delimiter: "\t")
		} catch {
			os_log(
				"Could not parse TSV file: %{public}s",
				log: Log.parse,
				type: .error,
				error.localizedDescription
			)
			throw error
		}

		loadData(tableData: csv.namedRows)
	}
}
