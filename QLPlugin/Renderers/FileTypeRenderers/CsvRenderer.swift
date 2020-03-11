import Foundation
import os.log

class CsvRenderer: Renderer {
	private let cssUrl = Bundle.main.url(forResource: "csv-main", withExtension: "css")
	private let papaParsejsUrl = Bundle.main.url(
		forResource: "csv-papaparse.min",
		withExtension: "js"
	)
	private let renderjsUrl = Bundle.main.url(forResource: "csv-main", withExtension: "js")

	override func getStylesheets() -> [Stylesheet] {
		var stylesheets = super.getStylesheets()
		if let cssUrl = cssUrl {
			stylesheets.append(Stylesheet(url: cssUrl))
		} else {
			os_log("Could not find main CSV stylesheet", type: .error)
		}
		return stylesheets
	}

	override func getHtml() -> String {
		"<div id=\"csv-preview\"></div>"
	}

	override func getScripts() -> [Script] {
		var scripts = super.getScripts()

		// Papa Parse library (parses CSV files)
		if let papaParsejsUrl = papaParsejsUrl {
			scripts.append(Script(url: papaParsejsUrl))
		} else {
			os_log("Could not find Papa Parse script", type: .error)
		}

		// Render script (generates HTML table from parsed CSV)
		if let renderjsUrl = renderjsUrl {
			scripts.append(Script(url: renderjsUrl))
		} else {
			os_log("Could not find CSV render script", type: .error)
		}

		// Main script (calls render function with file content)
		scripts.append(Script(content: """
			const fileContent = `\(fileContent.replacingOccurrences(of: "`", with: "\\`"))`;
			render(fileContent);
		"""))

		return scripts
	}
}
