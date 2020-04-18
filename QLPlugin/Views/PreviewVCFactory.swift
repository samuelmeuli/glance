import Foundation

/// Returns an instance of the `PreviewVC` subclass that should be used for generating previews of
/// files with the provided extension
class PreviewVCFactory {
	static func getView(fileExtension: String) -> PreviewVC.Type {
		switch fileExtension {
		case "csv", "tab", "tsv":
			return CSVPreviewVC.self
		case "md", "markdown", "mdown", "mkdn", "mkd":
			return MarkdownPreviewVC.self
		case "ipynb":
			return JupyterPreviewVC.self
		default:
			return CodePreviewVC.self
		}
	}
}
