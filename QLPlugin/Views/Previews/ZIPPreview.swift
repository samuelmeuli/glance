import Foundation
import os.log
import SwiftExec

class ZIPPreview: Preview {
	let filesRegex =
		#"(.{10}) +.+ +.+ +(\d+) +.+ +.+ +(\d{2}-\w{3}-\d{2} +\d{2}:\d{2}) +(.+)"#
	let sizeRegex = #"\d+ files?, (\d+) bytes? uncompressed, \d+ bytes? compressed: +([\d.]+)%"#

	let byteCountFormatter = ByteCountFormatter()
	let dateFormatter = DateFormatter()

	required init() {
		dateFormatter.dateFormat = "yy-MMM-dd HH:mm" // Date format used in `zipinfo` output
	}

	private func runZIPInfoCommand(filePath: String) throws -> String {
		do {
			let result = try exec(
				program: "/usr/bin/zipinfo",
				arguments: [filePath]
			)
			return result.stdout ?? ""
		} catch {
			// Empty ZIP files are allowed, but return exit code 1
			let error = error as! ExecError
			let stdout = error.execResult.stdout ?? ""
			if error.execResult.exitCode == 1, stdout.hasSuffix("Empty zipfile.") {
				return stdout
			}
			throw error
		}
	}

	/// Parses the output of the `zipinfo` command.
	private func parseZIPInfo(lines: String) -> (
		fileTree: FileTree,
		sizeUncompressed: Int?,
		compressionRatio: Double?
	) {
		let fileTree = FileTree()
		let linesSplit = lines.split(separator: "\n")

		// List entry format: "drwxr-xr-x  2.0 unx        0 bx stor 20-Jan-13 19:38 my-zip/dir/"
		// - Column 1: Permissions ("-" as first character indicates a file, "d" a directory)
		// - Column 4: File size in bytes
		// - Columns 7-8: Date modified
		// - Column 9: File path
		let filesString = linesSplit[2 ..< linesSplit.count - 1].joined(separator: "\n")
		let fileMatches = filesString.matchRegex(regex: filesRegex)
		for fileMatch in fileMatches {
			let permissions = fileMatch[1]
			let size = Int(fileMatch[2]) ?? 0
			let dateModified = dateFormatter.date(from: fileMatch[3])
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

		// Last line:
		// - If not empty: "152 files, 192919 bytes uncompressed, 65061 bytes compressed:  66.3%"
		// - If empty: "Empty zipfile."
		if let lastLine = linesSplit.last, lastLine != "Empty zipfile." {
			let sizeMatches = String(lastLine).matchRegex(regex: sizeRegex)
			let sizeUncompressed = Int(sizeMatches[0][1])
			let compressionRatio = Double(sizeMatches[0][2])
			return (fileTree, sizeUncompressed, compressionRatio)
		} else {
			return (fileTree, 0, 0)
		}
	}

	func createPreviewVC(file: File) throws -> PreviewVC {
		let zipInfoOutput = try runZIPInfoCommand(filePath: file.path)

		// Parse command output
		let (fileTree, sizeUncompressed, compressionRatio) = parseZIPInfo(lines: zipInfoOutput)

		// Build label
		let labelText = """
		Compressed: \(byteCountFormatter.string(for: file.size) ?? "--")
		Uncompressed: \(byteCountFormatter.string(for: sizeUncompressed) ?? "--")
		Compression ratio: \(compressionRatio == nil ? "--" : String(compressionRatio!)) %
		"""

		return OutlinePreviewVC(rootNodes: fileTree.root.childrenList, labelText: labelText)
	}
}
