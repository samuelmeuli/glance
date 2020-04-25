import Foundation
import os.log
import SwiftExec

/// View controller for previewing tarballs (may be gzipped).
class TARPreview: Preview {
	let filesRegex = #"([\w-]{10})  \d+ .+ .+ + (\d+) (\w{3} \d+ +[\d:]+) (.*)"#
	let sizeRegex = #" +\d+ +(\d+) +([\d.]+)% .+"#

	let byteCountFormatter = ByteCountFormatter()
	let dateFormatter1 = DateFormatter()
	let dateFormatter2 = DateFormatter()

	required init() {
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

	private func runTARFilesCommand(filePath: String) throws -> String {
		let result = try exec(
			program: "/usr/bin/tar",
			arguments: [
				"--gzip", // Allows listing contents of `.tar.gz` files
				"--list",
				"--verbose",
				"--file",
				filePath,
			]
		)
		return result.stdout ?? ""
	}

	private func runGZIPSizeCommand(filePath: String) throws -> String {
		let result = try exec(program: "/usr/bin/gzip", arguments: ["--list", filePath])
		return result.stdout ?? ""
	}

	/// Parses a date string from `tar` output to a `Date` object.
	private func parseDate(dateString: String) -> Date? {
		if dateString.contains(":") {
			return dateFormatter1.date(from: dateString)
		} else {
			return dateFormatter2.date(from: dateString)
		}
	}

	private func parseTARFiles(file: File, lines: String) -> FileTree {
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
		let fileMatches = lines.matchRegex(regex: filesRegex)
		for fileMatch in fileMatches {
			let permissions = fileMatch[1]
			let size = Int(fileMatch[2]) ?? 0
			let dateModified = parseDate(dateString: fileMatch[3]) ?? Date()
			let path = fileMatch[4]
			do {
				// Add file/directory node to tree
				try fileTree.addNode(
					path: path,
					isDirectory: permissions.first == "d",
					size: size,
					dateModified: dateModified
				)
			} catch {
				os_log("%{public}s", log: Log.parse, type: .error, error.localizedDescription)
			}
		}

		return fileTree
	}

	private func parseGZIPSize(lines: String)
		-> (sizeUncompressed: Int?, compressionRatio: Double?) {
		let sizeMatches = lines.matchRegex(regex: sizeRegex)
		let sizeUncompressed = Int(sizeMatches[0][1])
		let compressionRatio = Double(sizeMatches[0][2])
		return (sizeUncompressed, compressionRatio)
	}

	func createPreviewVC(file: File) throws -> PreviewVC {
		let isGzipped = file.path.hasSuffix(".tar.gz")

		// Parse TAR contents
		let filesOutput = try runTARFilesCommand(filePath: file.path)
		let fileTree = parseTARFiles(file: file, lines: filesOutput)
		var labelText =
			"\(isGzipped ? "Compressed" : "Size"): \(byteCountFormatter.string(for: file.size) ?? "--")"

		// If tarball is gzipped: Get compression information
		if isGzipped {
			let sizeOutput = try runGZIPSizeCommand(filePath: file.path)
			let (sizeUncompressed, compressionRatio) = parseGZIPSize(lines: sizeOutput)
			labelText += """

			Uncompressed: \(byteCountFormatter.string(for: sizeUncompressed) ?? "--")
			Compression ratio: \(compressionRatio == nil ? "--" : String(compressionRatio!)) %
			"""
		}

		return OutlinePreviewVC(root: fileTree.root, labelText: labelText)
	}
}
