import Cocoa
import Foundation
import os.log
import SwiftCSV

/// View controller for previewing CSV/TSV files
class CSVPreviewVC: TablePreviewVC, PreviewVC {
	func loadPreview() throws {
		// Determine delimiter based on file extension
		let delimiter: Character = file.url.pathExtension == "csv" ? "," : "\t"

		// Read and parse CSV/TSV file
		var csv: CSV
		do {
			csv = try CSV(url: file.url, delimiter: delimiter)
		} catch {
			os_log(
				"Could not parse CSV file: %s",
				type: .error,
				error.localizedDescription
			)
			throw error
		}

		loadData(tableData: csv.namedRows)
	}
}
