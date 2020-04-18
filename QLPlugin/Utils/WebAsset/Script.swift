import Foundation

class Script: WebAsset {
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
			return "<script src=\"\(url.path)\"></script>"
		} else {
			return "<script>\(content ?? "")</script>"
		}
	}
}
