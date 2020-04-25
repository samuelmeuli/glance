import os.log
import SwiftCSV

class TSVPreview: Preview {
	required init() {}

	func createPreviewVC(file: File) throws -> PreviewVC {
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

		return TablePreviewVC(tableData: csv.namedRows)
	}
}
