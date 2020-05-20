import Cocoa

class OutlinePreviewVC: NSViewController, PreviewVC {
	@objc dynamic var rootNodes: [FileTreeNode]
	private let labelText: String?

	@objc dynamic var customSortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

	@IBOutlet private var treeController: NSTreeController!
	@IBOutlet private var outlineView: NSOutlineView!
	@IBOutlet private var label: NSTextField!

	required convenience init(rootNodes: [FileTreeNode], labelText: String?) {
		self.init(nibName: nil, bundle: nil, rootNodes: rootNodes, labelText: labelText)
	}

	init(
		nibName nibNameOrNil: NSNib.Name?,
		bundle nibBundleOrNil: Bundle?,
		rootNodes: [FileTreeNode],
		labelText: String?
	) {
		self.rootNodes = rootNodes
		self.labelText = labelText
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		// Register required value transformers
		ValueTransformer.setValueTransformer(DateTransformer(), forName: .dateTransformerName)
		ValueTransformer.setValueTransformer(IconTransformer(), forName: .iconTransformerName)
		ValueTransformer.setValueTransformer(SizeTransformer(), forName: .sizeTransformerName)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpView()
		expandSingleRootItem()
	}

	private func setUpView() {
		// Add file tree to `treeController`
		for node in rootNodes {
			treeController.addObject(node)
		}

		// Add label
		label.stringValue = labelText ?? ""
	}

	/// If the root contains a single item, this function expands its children.
	private func expandSingleRootItem() {
		let root = treeController.arrangedObjects
		if root.children?.count == 1 {
			outlineView.expandItem(root.children?.first!)
		}
	}
}

/// `ValueTransformer` which formats the provided date.
class DateTransformer: ValueTransformer {
	let dateFormatter = DateFormatter()
	let fallbackValue = "--"

	override init() {
		// Use same date format as Finder
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short
		dateFormatter.doesRelativeDateFormatting = true
	}

	override class func transformedValueClass() -> AnyClass { NSString.self }

	override class func allowsReverseTransformation() -> Bool { false }

	override func transformedValue(_ value: Any?) -> Any? {
		guard let date = value as? Date else {
			return nil
		}

		// Dates which are `nil` are passed to this function as epoch dates (default value). If
		// this is the case, return "--" instead (same behavior as Finder)
		return date.timeIntervalSince1970 == 0 ? fallbackValue : dateFormatter.string(from: date)
	}
}

/// `ValueTransformer` which returns the correct icon depending on whether the current row
/// represents a file or directory.
class IconTransformer: ValueTransformer {
	let directoryIcon = NSImage(
		contentsOfFile: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericFolderIcon.icns"
	)
	let fileIcon = NSImage(
		contentsOfFile: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericDocumentIcon.icns"
	)

	override class func transformedValueClass() -> AnyClass { NSImage.self }

	override class func allowsReverseTransformation() -> Bool { false }

	override func transformedValue(_ value: Any?) -> Any? {
		guard let isDirectoryNumber = value as? NSNumber else {
			return nil
		}
		let isDirectory = Bool(truncating: isDirectoryNumber)
		return isDirectory ? directoryIcon : fileIcon
	}
}

/// `ValueTransformer` which formats the provided number of bytes as a human-readable string (e.g.
/// `12345` -> `"12.345 KB"` or `0` -> `"--"`).
class SizeTransformer: ValueTransformer {
	let byteCountFormatter = ByteCountFormatter()
	let fallbackValue = "--"

	override class func transformedValueClass() -> AnyClass { NSString.self }

	override class func allowsReverseTransformation() -> Bool { false }

	override func transformedValue(_ value: Any?) -> Any? {
		guard let size = value as? NSNumber else {
			return nil
		}

		// Format number of bytes in human-readable way. If the size is 0 bytes, return "--" instead
		// (same behavior as Finder)
		return size == 0 ? fallbackValue : (byteCountFormatter.string(for: size) ?? fallbackValue)
	}
}

extension NSValueTransformerName {
	static let dateTransformerName = NSValueTransformerName(rawValue: "DateTransformer")
	static let iconTransformerName = NSValueTransformerName(rawValue: "IconTransformer")
	static let sizeTransformerName = NSValueTransformerName(rawValue: "SizeTransformer")
}
