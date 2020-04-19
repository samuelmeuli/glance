import Cocoa

/// Node used for representing a file in an `NSOutlineView`
class FileNode: NSObject {
	@objc let name: String
	@objc let size: Int
	@objc let dateModified: Date
	@objc let isDirectory: Bool
	@objc let children: [FileNode]

	/// Number of children (required by `NSOutlineView`)
	@objc var count: Int { children.count }

	/// Whether the current node has any children (required by `NSOutlineView`)
	@objc var isLeaf: Bool { children.isEmpty }

	init(
		name: String,
		size: Int,
		dateModified: Date,
		isDirectory: Bool,
		children: [FileNode]
	) {
		self.name = name
		self.size = size
		self.dateModified = dateModified
		self.isDirectory = isDirectory
		self.children = children
	}
}

/// Implementation of a `NSOutlineView` for file hiearchies
class OutlinePreviewView: NSView, LoadableNib {
	// swiftlint:disable:next private_outlet
	@IBOutlet internal var contentView: NSView!
	@IBOutlet private var label: NSTextField!
	@IBOutlet private var outlineView: NSOutlineView!
	@objc dynamic var outlineData = [FileNode]()
	private let treeController = NSTreeController()

	required init(frame: CGRect, outlineData: [FileNode]) {
		self.outlineData = outlineData
		super.init(frame: frame)
		loadViewFromNib(nibName: "OutlinePreviewView")
		setUpView()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setUpView() {
		outlineView.delegate = self

		treeController.objectClass = FileNode.self
		treeController.childrenKeyPath = "children"
		treeController.countKeyPath = "count"
		treeController.leafKeyPath = "isLeaf"

		treeController.bind(
			NSBindingName(rawValue: "contentArray"),
			to: self,
			withKeyPath: "outlineData",
			options: nil
		)
		outlineView.bind(
			NSBindingName(rawValue: "content"),
			to: treeController,
			withKeyPath: "arrangedObjects",
			options: nil
		)
	}
}

extension OutlinePreviewView: NSOutlineViewDelegate {
	public func outlineView(
		_ outlineView: NSOutlineView,
		viewFor tableColumn: NSTableColumn?,
		item _: Any
	) -> NSView? {
		var cellView: NSTableCellView?

		guard let columnID = tableColumn?.identifier else {
			return cellView
		}

		switch columnID {
			case .init("name"):
				if let view = outlineView.makeView(
					withIdentifier: columnID,
					owner: outlineView.delegate
				) as? NSTableCellView {
					view.textField?.bind(
						.value,
						to: view,
						withKeyPath: "objectValue.name",
						options: nil
					)
					cellView = view
				}
			case .init("size"):
				if let view = outlineView.makeView(
					withIdentifier: columnID,
					owner: outlineView.delegate
				) as? NSTableCellView {
					view.textField?.bind(
						.value,
						to: view,
						withKeyPath: "objectValue.size",
						options: nil
					)
					cellView = view
				}
			case .init("dateModified"):
				if let view = outlineView.makeView(
					withIdentifier: columnID,
					owner: outlineView.delegate
				) as? NSTableCellView {
					view.textField?.bind(
						.value,
						to: view,
						withKeyPath: "objectValue.dateModified",
						options: nil
					)
					cellView = view
				}
			default:
				return cellView
		}
		return cellView
	}
}
