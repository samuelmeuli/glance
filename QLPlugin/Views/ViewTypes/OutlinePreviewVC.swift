import Cocoa

class OutlinePreviewVC: NSViewController {
	/// File to render
	let file: File

	required convenience init(file: File) {
		self.init(nibName: nil, bundle: nil, file: file)
	}

	init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?, file: File) {
		self.file = file
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		// Required because the view controller is not initialized using a Storyboard
		view = NSView()
	}

	func loadData(outlineData: [FileNode]) {
		let outlineView = OutlinePreviewView(frame: view.frame, outlineData: outlineData)
		outlineView.autoresizingMask = [.height, .width]
		view.addSubview(outlineView)
	}
}
