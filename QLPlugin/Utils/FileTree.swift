import Foundation

enum FileTreeError {
	case notADirectoryError(pathParts: [String.SubSequence], pathPartIndex: Int)
}

extension FileTreeError: LocalizedError {
	public var errorDescription: String? {
		switch self {
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
	@objc let isDirectory: Bool
	@objc var dateModified: Date?
	/// Child nodes of a directory
	@objc var children = [String: FileTreeNode]()

	/// Number of child nodes (required for rendering the tree in an `NSOutlineView`)
	@objc var childrenCount: Int { children.values.count }
	/// List of child nodes (required for rendering the tree in an `NSOutlineView`)
	@objc var childrenList: [FileTreeNode] { Array(children.values) }
	/// Whether the node has any children (required for rendering the tree in an `NSOutlineView`)
	@objc var hasChildren: Bool { children.isEmpty }

	convenience init(name: String, size: Int, isDirectory: Bool) {
		self.init(name: name, size: size, isDirectory: isDirectory, dateModified: nil)
	}

	init(name: String, size: Int, isDirectory: Bool, dateModified: Date?) {
		self.name = name
		self.size = size
		self.isDirectory = isDirectory
		self.dateModified = dateModified
	}
}

/// Data structure for representing a tree of files and directories. This class stores the root node
/// and provides functionality to insert new nodes.
class FileTree {
	var root = FileTreeNode(name: "Root", size: 0, isDirectory: true, dateModified: Date())

	/// Parses the provided file/directory's path and creates a new `FileTreeNode` at the correct
	/// position in the tree. If a file/directory's parent directory doesn't exist yet, it will
	/// be created (with `dateModified` set to `nil`).
	func addNode(path: String, isDirectory: Bool, size: Int, dateModified: Date?) throws {
		try addNode(
			parentNode: root,
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
		parentNode: FileTreeNode,
		pathParts: [String.SubSequence],
		pathPartIndex: Int,
		isDirectory: Bool,
		size: Int,
		dateModified: Date?
	) throws {
		let isLastPathPart = pathPartIndex == pathParts.count - 1
		let name = String(pathParts[pathPartIndex])
		var currentNode = parentNode.children[name]

		if isLastPathPart {
			// Reached end of path: Add to tree
			if currentNode == nil {
				// Node doesn't exist yet: Create it
				parentNode.children[name] = FileTreeNode(
					name: name,
					size: size,
					isDirectory: isDirectory,
					dateModified: dateModified
				)
			} else {
				// Node already exists (i.e. directory has been created implicitly in a previous
				// function call): Update the directory node with the missing `dateModified` info
				currentNode!.dateModified = dateModified
			}
		} else {
			// Not yet at end of path: Recurse into subdirectory
			if currentNode == nil {
				// Directory that doesn't exist yet: Create it
				currentNode = FileTreeNode(
					name: name,
					size: 0,
					isDirectory: true
				)
				parentNode.children[name] = currentNode
			} else {
				// Directory exists: Make sure it's not a file
				if !currentNode!.isDirectory {
					throw FileTreeError.notADirectoryError(
						pathParts: pathParts,
						pathPartIndex: pathPartIndex
					)
				}
			}
			// Recurse: Execute function again for next path part
			try addNode(
				parentNode: currentNode!,
				pathParts: pathParts,
				pathPartIndex: pathPartIndex + 1,
				isDirectory: isDirectory,
				size: size,
				dateModified: dateModified
			)
		}
	}
}
