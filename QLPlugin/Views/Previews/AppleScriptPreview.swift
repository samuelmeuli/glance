import SwiftExec

/// View controller for previewing AppleScript files:
///
/// - `.applescript`: AppleScript text file (can be read directly)
/// - `.scpt`: AppleScript binary (needs to be decompiled)
/// - `.scptd`: AppleScript bundle (includes a binary, which needs to be decompiled)
///
/// The class extends `CodePreview` so syntax highlighting is applied after the script's content has
/// been determined.
///
// TODO: Scripts can also be written in JavaScript (JXA). This language needs to be detected and
// passed to Chroma to get correct syntax highlighting.
class AppleScriptPreview: CodePreview {
	override func getSource(file: File) throws -> String {
		if file.url.pathExtension == "scpt" || file.url.pathExtension == "scptd" {
			let result = try exec(
				program: "/usr/bin/osadecompile",
				arguments: [file.path]
			)
			return result.stdout ?? ""
		}
		return try file.read()
	}
}
