import Foundation
import os.log

class CsvRenderer: Renderer {
	private let mainJsUrl = Bundle.main.url(forResource: "csv-main", withExtension: "js")
	private let papaParseJsUrl = Bundle.main.url(
		forResource: "csv-papaparse.min",
		withExtension: "js"
	)

	override func getHtml() throws -> String {
		"<div id=\"csv-preview\"></div>"
	}

	override func getScripts() throws -> [Script] {
		var fileContent: String
		do {
			fileContent = try file.read()
		} catch {
			os_log("Could not read CSV file: %s", type: .error, error.localizedDescription)
			throw error
		}

		var scripts = try! super.getScripts()

		// Papa Parse library (for parsing CSV files)
		if let papaParsejsUrl = papaParseJsUrl {
			scripts.append(Script(url: papaParsejsUrl))
		} else {
			os_log("Could not find Papa Parse script", type: .error)
		}

		// Render script (for generating an HTML table from parsed CSV)
		if let renderjsUrl = mainJsUrl {
			scripts.append(Script(url: renderjsUrl))
		} else {
			os_log("Could not find main CSV script", type: .error)
		}

		// Main script (for calling the render function with the previewed file's content)
		scripts.append(Script(content: """
			const fileContent = `\(fileContent.replacingOccurrences(of: "`", with: "\\`"))`;
			render(fileContent);
		"""))

		return scripts
	}
}
