import Foundation
import os.log

class CodeRenderer: Renderer {
	private let chromaBinUrl = Bundle.main.url(forAuxiliaryExecutable: "chroma-v0.7.0")

	override func getStylesheets() -> [Stylesheet] {
		var stylesheets = super.getStylesheets()
		if let cssUrl = chromaCssUrl {
			stylesheets.append(Stylesheet(url: cssUrl))
		} else {
			os_log("Could not find Chroma stylesheet", type: .error)
		}
		return stylesheets
	}

	override func getHtml() -> String {
		guard let binaryUrlResolved = chromaBinUrl else {
			os_log("Could not find Chroma binary", type: .error)
			return errorHtml
		}

		let (status, stdout, stderr) = Shell.run(
			url: binaryUrlResolved,
			arguments: [fileUrl.path, "--html", "--html-only"]
		)

		guard status == 0 else {
			os_log("Chroma returned exit code %s: %s", type: .error, status, stderr ?? "")
			return errorHtml
		}

		return stdout ?? ""
	}
}
