import Cocoa
import Foundation
import os.log
import SwiftExec

struct ZIPInfo {
	/// Percentage by which the ZIP contents have been compressed
	let compressionFactor: Double
	/// Compressed content size in bytes
	let sizeCompressed: Int
	/// Uncompressed content size in bytes
	let sizeUncompressed: Int
	/// Files in the ZIP archive
	let fileTree: FileTree
}

class ZIPPreviewVC: OutlinePreviewVC, PreviewVC {
	let secondLineRegex = #"Zip file size: (\d+) bytes, number of entries: \d+"#
	let contentLinesRegex =
		#"([\w-]{10})  .* \w+ +(\d+) \w+ \w+ (\d{2}-\w{3}-\d{2} \d{2}:\d{2}) (.*)"#
	let lastLineRegex = #"^\d+ files, (\d+) bytes uncompressed, \d+ bytes compressed: +([\d.]+)%$"#

	let byteCountFormatter = ByteCountFormatter()
	let dateFormatter = DateFormatter()

	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?, file: File) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, file: file)
		dateFormatter.dateFormat = "yy-MMM-dd HH:mm" // Date format used in `zipinfo` output
	}

	/// Parses the output of the `zipinfo` command
	private func parseZIPInfo(lines: [String.SubSequence]) -> ZIPInfo {
		var compressionFactor: Double = 0
		var sizeCompressed: Int = 0
		var sizeUncompressed: Int = 0
		let fileTree = FileTree()

		// First line: "Archive:  my-zip.zip" -> Skip

		// Second line: "Zip file size: 99791 bytes, number of entries: 152"
		let secondLineMatched = String(lines[1]).matchRegex(regex: secondLineRegex)
		sizeCompressed = Int(secondLineMatched[0][1]) ?? -1

		// Content lines: "drwxr-xr-x  2.0 unx        0 bx stor 20-Jan-13 19:38 my-zip/dir/"
		// - "-" as first character indicates a file, "d" a directory
		// - "0 bx" indicates the number of bytes
		let contentLinesString = lines[2 ... lines.count - 2].joined(separator: "\n")
		let contentLinesMatched = contentLinesString.matchRegex(regex: contentLinesRegex)
		for match in contentLinesMatched {
			let permissions = match[1]
			let sizeString = match[2]
			let dateModifiedString = match[3]
			let path = match[4]
			// Ignore "__MACOSX" subdirectory (ZIP resource fork created by macOS)
			if !path.hasPrefix("__MACOSX") {
				do {
					// Add file/directory node to tree
					try fileTree.addNode(
						path: path,
						isDirectory: permissions.first == "d",
						size: Int(sizeString) ?? -1,
						dateModified: dateFormatter.date(from: dateModifiedString) ?? Date()
					)
				} catch {
					os_log("%{public}s", log: Log.parse, type: .error, error.localizedDescription)
				}
			}
		}

		// Last line: "152 files, 192919 bytes uncompressed, 65061 bytes compressed:  66.3%"
		let lastLineMatched = String(lines.last ?? "").matchRegex(regex: lastLineRegex)
		sizeUncompressed = Int(lastLineMatched[0][1]) ?? -1
		compressionFactor = Double(lastLineMatched[0][2]) ?? -1

		return ZIPInfo(
			compressionFactor: compressionFactor,
			sizeCompressed: sizeCompressed,
			sizeUncompressed: sizeUncompressed,
			fileTree: fileTree
		)
	}

	func loadPreview() throws {
		// Run `zipinfo` command
		let result = try exec(
			program: "/usr/bin/zipinfo",
			arguments: [file.path]
		)

		// Parse command output
		let stdoutLines = (result.stdout ?? "").split(separator: "\n")
		let zipInfo = parseZIPInfo(lines: stdoutLines)

		// Load data into outline view
		loadData(
			fileTree: zipInfo.fileTree,
			labelText: """
			Size uncompressed: \(byteCountFormatter.string(for: zipInfo.sizeUncompressed) ?? "--")
			Size compressed: \(byteCountFormatter.string(for: zipInfo.sizeCompressed) ?? "--")
			Compression factor: \(zipInfo.compressionFactor)
			"""
		)
	}
}
