import Foundation

/// Returns an instance of the `PreviewVC` subclass that should be used for generating previews of
/// files with the provided extension
class PreviewVCFactory {
	static func getView(fileURL: URL) -> PreviewVC.Type? {
		switch fileURL.pathExtension {
			case "gz":
				// `gzip` is only supported for tarballs
				return fileURL.path.hasSuffix(".tar.gz") ? TARPreviewVC.self : nil
			case "md", "markdown", "mdown", "mkdn", "mkd":
				return MarkdownPreviewVC.self
			case "ipynb":
				return JupyterPreviewVC.self
			case "tar":
				return TARPreviewVC.self
			case "tab", "tsv":
				return TSVPreviewVC.self
			case "zip":
				return ZIPPreviewVC.self
			default:
				return CodePreviewVC.self
		}
	}
}
