import Cocoa
import Foundation
import os.log
import SwiftExec

class ZIPPreviewVC: OutlinePreviewVC, PreviewVC {
	let filesRegex = #"([\w-]{10})  .* \w+ +(\d+) \w+ \w+ (\d{2}-\w{3}-\d{2} \d{2}:\d{2}) (.*)"#
	let sizeRegex = #"^\d+ files, (\d+) bytes uncompressed, \d+ bytes compressed: +([\d.]+)%$"#

	let byteCountFormatter = ByteCountFormatter()
	let dateFormatter = DateFormatter()

	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?, file: File) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, file: file)
		dateFormatter.dateFormat = "yy-MMM-dd HH:mm" // Date format used in `zipinfo` output
	}

	private func runZIPInfoCommand(filePath _: String) throws -> String {
		let result = try exec(
			program: "/usr/bin/zipinfo",
			arguments: [file.path]
		)
		return result.stdout ?? ""
	}

	/// Parses the output of the `zipinfo` command
	private func parseZIPInfo(lines: String) -> (
		fileTree: FileTree,
		sizeUncompressed: Int?,
		compressionRatio: Double?
	) {
		let fileTree = FileTree()
		let linesSplit = lines.split(separator: "\n")

		// Content lines: "drwxr-xr-x  2.0 unx        0 bx stor 20-Jan-13 19:38 my-zip/dir/"
		// - "-" as first character indicates a file, "d" a directory
		// - "0 bx" indicates the number of bytes
		let filesString = linesSplit[2 ... linesSplit.count - 2].joined(separator: "\n")
		let fileMatches = filesString.matchRegex(regex: filesRegex)
		for fileMatch in fileMatches {
			let permissions = fileMatch[1]
			let size = Int(fileMatch[2]) ?? 0
			let dateModified = dateFormatter.date(from: fileMatch[3]) ?? Date()
			let path = fileMatch[4]
			// Ignore "__MACOSX" subdirectory (ZIP resource fork created by macOS)
			if !path.hasPrefix("__MACOSX") {
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
		}

		// Last line: "152 files, 192919 bytes uncompressed, 65061 bytes compressed:  66.3%"
		let sizeMatches = String(linesSplit.last ?? "").matchRegex(regex: sizeRegex)
		let sizeUncompressed = Int(sizeMatches[0][1])
		let compressionRatio = Double(sizeMatches[0][2])

		return (fileTree, sizeUncompressed, compressionRatio)
	}

	func loadPreview() throws {
		let zipInfoOutput = try runZIPInfoCommand(filePath: file.path)

		// Parse command output
		let (fileTree, sizeUncompressed, compressionRatio) = parseZIPInfo(lines: zipInfoOutput)

		// Load data into outline view
		loadData(
			fileTree: fileTree,
			labelText: """
			Compressed: \(byteCountFormatter.string(for: file.size) ?? "--")
			Uncompressed: \(byteCountFormatter.string(for: sizeUncompressed) ?? "--")
			Compression ratio: \(compressionRatio == nil ? "--" : String(compressionRatio!)) %
			"""
		)
	}
}
