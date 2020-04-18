import Foundation

class Stylesheet: WebAsset {
	private var content: String?
	private var url: URL?

	required init(content: String) {
		self.content = content
	}

	required init(url: URL) {
		self.url = url
	}

	func getHTML() -> String {
		if let url = url {
			return "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(url.path)\" />"
		} else {
			return "<style>\(content ?? "")</style>"
		}
	}
}
