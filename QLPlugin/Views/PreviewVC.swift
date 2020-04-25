import Cocoa
import Foundation
import os.log

/// View controller for rendering previews of a specific file type.
protocol PreviewVC: NSViewController {}

/// Class that can be used to create an instance of a `PreviewVC` for the corresponding file type.
protocol Preview {
	init()
	func createPreviewVC(file: File) throws -> PreviewVC
}
