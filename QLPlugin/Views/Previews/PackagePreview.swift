import Foundation
import os.log
import SwiftExec

/// View controller for previewing packages.
class PackagePreview: Preview {
	let filesRegex = #"^([^\t]+)\t+(.{10})[ \t]*(\d*)\t*(\d*)$"#
	let signatureRegex = #"Status: (.*)$"#

	let byteCountFormatter = ByteCountFormatter()
	let numberFormatter = NumberFormatter()

	/// Sandboxed home directory:
	/// `/Users/samuel/Library/Containers/com.samuelmeuli.Glance.QLPlugin/Data/`
	let sandboxRootURL = FileManager.default.homeDirectoryForCurrentUser

	required init() {
		numberFormatter.maximumFractionDigits = 1
		numberFormatter.numberStyle = .percent
	}

	private func runPackageCommand(filePath: String) throws -> String {
		// Export the specified package's BOM file ("Bill Of Materials", contains information about
		// the files to install/uninstall/modify). The command `pkgutil --bom PKG_PATH` usually
		// exports the BOM file to `/tmp/BOM_PATH` and writes that path to stdout. Because Glance is
		// sandboxed, however, this operation fails, `(null)/BOM_PATH` is returned and the file is
		// written to `~/Library/Containers/com.samuelmeuli.Glance.QLPlugin/Data/` instead.
		let pkgutilResult = try exec(program: "/usr/sbin/pkgutil", arguments: ["--bom", filePath])
		let nullBomPath = pkgutilResult.stdout ?? ""
		// Remove "(null)/" from start of string
		let relativeBomPath = String(nullBomPath[
			nullBomPath.index(nullBomPath.startIndex, offsetBy: 7) ..< nullBomPath.endIndex
		])

		// Use `lsbom` to read the contents of the BOM. The command returns a file list with
		// configurable columns.
		//
		// HACK: Due to the behavior mentioned above, instead of the BOM's path under `/tmp/`, its
		// actual location in the app container is used.
		let lsbomResult = try exec(
			program: "/usr/bin/lsbom",
			arguments: [
				"-p", // Parameters
				"fMst", // File name (f), symbolic file mode (M), file size (s), mod time (t)
				sandboxRootURL.appendingPathComponent(relativeBomPath).path,
			]
		)
		// TODO: Delete BOM file

		return lsbomResult.stdout ?? ""
	}

	private func runSignatureCommand(filePath: String) throws -> String {
		do {
			let result = try exec(
				program: "/usr/sbin/pkgutil",
				arguments: ["--check-signature", filePath]
			)
			return result.stdout ?? ""
		} catch {
			// The command returns exit code 1 if there is no signature
			let error = error as! ExecError
			return error.execResult.stdout ?? ""
		}
	}

	private func parsePackageFiles(lines: String) -> (fileTree: FileTree, sizeUncompressed: Int) {
		let fileTree = FileTree()
		var sizeUncompressed = 0 // Calculate package size by adding the sizes of all files

		// List entry format: "./hello-world.txt\t-rw-r--r-- \t13\t1587628964"
		// - Column 1: File path
		// - Column 2: Permissions ("-" as first character indicates a file, "d" a directory)
		// - Column 3: File size in bytes (missing for directories)
		// - Column 4: Date modified (Unix format, missing for directories)
		let fileMatches = lines.matchRegex(regex: filesRegex)
		for fileMatch in fileMatches {
			let path = fileMatch[1]
			let permissions = fileMatch[2]
			let size = fileMatch.count > 3 ? Int(fileMatch[3]) ?? 0 : 0
			let dateModified = fileMatch.count > 4
				? Date(timeIntervalSince1970: TimeInterval(Int(fileMatch[4]) ?? 0))
				: nil

			// Non-existent root directories seem to be represented by ".\t?---------". These
			// directories should be ignored.
			if permissions == "?---------" {
				continue
			}

			do {
				// Add file/directory node to tree
				try fileTree.addNode(
					path: path,
					isDirectory: permissions.first == "d",
					size: size,
					dateModified: dateModified
				)
				sizeUncompressed += size
			} catch {
				os_log("%{public}s", log: Log.parse, type: .error, error.localizedDescription)
			}
		}

		return (fileTree, sizeUncompressed)
	}

	private func parseSignature(lines: String) -> String {
		let signatureMatches = lines.matchRegex(regex: signatureRegex)
		if signatureMatches.count != 1 {
			os_log(
				"Could not obtain package signature: %{public}d regex matches for string \"%{public}s\"",
				log: Log.parse,
				type: .error,
				signatureMatches.count,
				lines
			)
			return "Could not obtain package signature"
		}
		return signatureMatches[0][1].firstCapitalized
	}

	func createPreviewVC(file: File) throws -> PreviewVC {
		// Parse package contents
		let filesOutput = try runPackageCommand(filePath: file.path)
		let (fileTree, sizeUncompressed) = parsePackageFiles(lines: filesOutput)
		let compressionRatio = NSNumber(value: Double(file.size) / Double(sizeUncompressed))

		// Parse signature
		let signatureOutput = try runSignatureCommand(filePath: file.path)
		let signature = parseSignature(lines: signatureOutput)

		// Build label
		let labelText = """
		Compressed: \(byteCountFormatter.string(for: file.size) ?? "--")
		Uncompressed: \(byteCountFormatter.string(for: sizeUncompressed) ?? "--")
		Compression ratio: \(numberFormatter.string(from: compressionRatio) ?? "--")
		\(signature)
		"""

		return OutlinePreviewVC(rootNodes: fileTree.root.childrenList, labelText: labelText)
	}
}
