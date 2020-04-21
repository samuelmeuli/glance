import Cocoa
import Foundation
import os.log
import SwiftExec

/// View controller for previewing tarballs (may be gzipped).
class TARPreviewVC: OutlinePreviewVC, PreviewVC {
	let linesRegex = #"([\w-]{10})  \d+ .+ .+ + (\d+) (\w{3} \d+ +[\d:]+) (.*)"#

	let byteCountFormatter = ByteCountFormatter()
	let dateFormatter1 = DateFormatter()
	let dateFormatter2 = DateFormatter()

	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?, file: File) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, file: file)
		initDateFormatters()
	}

	/// Sets up `dateFormatter1` and `dateFormatter2` to parse date strings from `tar` output. Date
	/// strings may be in one of the following formats:
	///
	/// - "MMM dd HH:mm", e.g. "Mar 28 15:36" (date is in current year)
	/// - "MMM dd  yyyy", e.g. "Dec 29  2018"
	private func initDateFormatters() {
		// Set default date to today to parse dates in current year
		dateFormatter1.defaultDate = Date()

		// Specify date formats
		dateFormatter1.dateFormat = "MMM dd HH:mm"
		dateFormatter2.dateFormat = "MMM dd  yyyy"
	}

	/// Parses a date string from `tar` output to a `Date` object.
	private func parseDate(dateString: String) -> Date? {
		if dateString.contains(":") {
			return dateFormatter1.date(from: dateString)
		} else {
			return dateFormatter2.date(from: dateString)
		}
	}

	/// Parses the output of the `tar` command.
	private func parseTARFileTree(file: File, lines: String) -> FileTree {
		let fileTree = FileTree()

		// Create node for root directory (not contained in `tar` output)
		try! fileTree.addNode(
			path: file.url.lastPathComponent.components(separatedBy: ".")[0],
			isDirectory: true,
			size: 0,
			dateModified: file.attributes[FileAttributeKey.modificationDate] as? Date ?? Date()
		)

		// Content lines: "-rw-r--r--  0 user staff     642 Dec 29  2018 my-tar/file.ext"
		// - "-" as first character indicates a file, "d" a directory
		// - Digits before date indicate number of bytes
		let linesMatched = lines.matchRegex(regex: linesRegex)
		for match in linesMatched {
			do {
				// Add file/directory node to tree
				try fileTree.addNode(
					path: match[4],
					isDirectory: match[1].first == "d",
					size: Int(match[2]) ?? -1,
					dateModified: parseDate(dateString: match[3]) ?? Date()
				)
			} catch {
				os_log("%{public}s", log: Log.parse, type: .error, error.localizedDescription)
			}
		}

		return fileTree
	}

	func loadPreview() throws {
		// Run `tar` command
		let result = try exec(
			program: "/usr/bin/tar",
			arguments: [
				"--gzip", // Allows listing contents of `.tar.gz` files
				"--list",
				"--verbose",
				"--file",
				file.path,
			]
		)

		// Parse command output
		let fileTree = parseTARFileTree(file: file, lines: result.stdout ?? "")

		// Load data into outline view
		loadData(fileTree: fileTree, labelText: nil)
	}
}
