import Foundation

enum FileTreeError {
	case missingParentDirectoryError(pathParts: [String.SubSequence], pathPartIndex: Int)
	case notADirectoryError(pathParts: [String.SubSequence], pathPartIndex: Int)
}

extension FileTreeError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case let .missingParentDirectoryError(pathParts, pathPartIndex):
				return NSLocalizedString(
					"Cannot create file tree node with path \"\(pathParts.joined())\": Directory \"\(pathParts[pathPartIndex])\" does not exist",
					comment: ""
				)
			case let .notADirectoryError(pathParts, pathPartIndex):
				return NSLocalizedString(
					"Cannot create file tree node with path \"\(pathParts.joined())\": \"\(pathParts[pathPartIndex])\" is not a directory",
					comment: ""
				)
		}
	}
}

/// Data structure for representing a single file/directory in a tree. The class is designed to be
/// used in an `NSOutlineView`, which is why the `@objc` attributes are required.
class FileTreeNode: NSObject {
	/// Name of the file (without path information), e.g. `"myfile.txt"`
	@objc let name: String
	/// File size in bytes
	@objc let size: Int
	@objc let dateModified: Date
	@objc let isDirectory: Bool
	/// Child nodes of a directory
	@objc var children = [String: FileTreeNode]()

	/// Number of child nodes (required for rendering the tree in an `NSOutlineView`)
	@objc var childrenCount: Int { children.values.count }
	/// List of child nodes (required for rendering the tree in an `NSOutlineView`)
	@objc var childrenList: [FileTreeNode] { Array(children.values) }
	/// Whether the node has any children (required for rendering the tree in an `NSOutlineView`)
	@objc var hasChildren: Bool { children.isEmpty }

	init(name: String, size: Int, dateModified: Date, isDirectory: Bool) {
		self.name = name
		self.size = size
		self.dateModified = dateModified
		self.isDirectory = isDirectory
	}
}

/// Data structure for representing a tree of files and directories. This class stores the root node
/// and provides functionality to insert new nodes.
class FileTree {
	var root = FileTreeNode(name: "Root", size: 0, dateModified: Date(), isDirectory: true)

	/// Parses the provided file/directory's path and creates a new `FileTreeNode` at the correct
	/// position in the tree.
	func addNode(path: String, isDirectory: Bool, size: Int, dateModified: Date) throws {
		try addNode(
			node: root,
			pathParts: path.split(separator: "/", omittingEmptySubsequences: true),
			pathPartIndex: 0,
			isDirectory: isDirectory,
			size: size,
			dateModified: dateModified
		)
	}

	/// Parses the provided file/directory's path and creates a new `FileTreeNode` at the correct
	/// position in the tree. This is a helper function for the `addNode` function. It performs a
	/// recursive tree traversal to find the node's location.
	private func addNode(
		node: FileTreeNode,
		pathParts: [String.SubSequence],
		pathPartIndex: Int,
		isDirectory: Bool,
		size: Int,
		dateModified: Date
	) throws {
		let isLastPathPart = pathPartIndex == pathParts.count - 1
		let name = String(pathParts[pathPartIndex])

		if isLastPathPart {
			// Reached end of path: Add to tree
			node.children[name] = FileTreeNode(
				name: name,
				size: size,
				dateModified: dateModified,
				isDirectory: isDirectory
			)
		} else {
			// Not at end of path: Recurse into subdirectory
			if let nextNode = node.children[name] {
				if !nextNode.isDirectory {
					throw FileTreeError.notADirectoryError(
						pathParts: pathParts,
						pathPartIndex: pathPartIndex
					)
				}
				try addNode(
					node: nextNode,
					pathParts: pathParts,
					pathPartIndex: pathPartIndex + 1,
					isDirectory: isDirectory,
					size: size,
					dateModified: dateModified
				)
			} else {
				throw FileTreeError.missingParentDirectoryError(
					pathParts: pathParts,
					pathPartIndex: pathPartIndex
				)
			}
		}
	}
}
