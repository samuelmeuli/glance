import XCTest

/// Helper function for asserting that the provided parent node has a child with the specified
/// file/directory properties.
func assertNode(
	parent: FileTreeNode,
	name: String,
	size: Int,
	isDirectory: Bool,
	dateModified: Date?
) -> FileTreeNode {
	guard let node = parent.childrenList.first(where: { $0.name == name }) else {
		XCTFail("Node \"\(parent.name)\" doesn't have child node \"\(name)\"")
		exit(1)
	}
	XCTAssertNotNil(node)
	XCTAssertEqual(node.name, name)
	XCTAssertEqual(node.size, size)
	XCTAssertEqual(node.isDirectory, isDirectory)
	XCTAssertEqual(node.dateModified, dateModified)
	return node
}

class FileTreeTests: XCTestCase {
	var fileTree: FileTree?
	let now = Date()

	override func setUp() {
		super.setUp()
		fileTree = FileTree()
	}

	// No files

	func testInit() {
		XCTAssert(fileTree!.root.children.isEmpty)
	}

	// Tree:
	//
	// └── file

	func testAddSingleFile() throws {
		try fileTree?.addNode(
			path: "file",
			isDirectory: false,
			size: 123,
			dateModified: now
		)

		_ = assertNode(
			parent: fileTree!.root,
			name: "file",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
	}

	// Tree:
	//
	// └── empty-directory/

	func testAddEmptyDirectory() throws {
		try fileTree?.addNode(
			path: "empty-directory",
			isDirectory: true,
			size: 0,
			dateModified: now
		)

		_ = assertNode(
			parent: fileTree!.root,
			name: "empty-directory",
			size: 0,
			isDirectory: true,
			dateModified: now
		)
	}

	// Tree:
	//
	// └── non-empty-directory/
	//     ├── file-1
	//     └── file-2

	func testAddNonEmptyDirectory1() throws {
		// Provide directory first
		try fileTree?.addNode(
			path: "non-empty-directory",
			isDirectory: true,
			size: 0,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory/file-1",
			isDirectory: false,
			size: 123,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory/file-2",
			isDirectory: false,
			size: 123,
			dateModified: now
		)

		let nonEmptyDirectory = assertNode(
			parent: fileTree!.root,
			name: "non-empty-directory",
			size: 0,
			isDirectory: true,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-1",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-2",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
	}

	func testAddNonEmptyDirectory2() throws {
		// Provide directory between files
		try fileTree?.addNode(
			path: "non-empty-directory/file-1",
			isDirectory: false,
			size: 123,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory",
			isDirectory: true,
			size: 0,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory/file-2",
			isDirectory: false,
			size: 123,
			dateModified: now
		)

		let nonEmptyDirectory = assertNode(
			parent: fileTree!.root,
			name: "non-empty-directory",
			size: 0,
			isDirectory: true,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-1",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-2",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
	}

	func testAddNonEmptyDirectory3() throws {
		// Provide directory last
		try fileTree?.addNode(
			path: "non-empty-directory/file-1",
			isDirectory: false,
			size: 123,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory/file-2",
			isDirectory: false,
			size: 123,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory",
			isDirectory: true,
			size: 0,
			dateModified: now
		)

		let nonEmptyDirectory = assertNode(
			parent: fileTree!.root,
			name: "non-empty-directory",
			size: 0,
			isDirectory: true,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-1",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-2",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
	}

	func testAddNonEmptyDirectory4() throws {
		// Create directory implicitly
		try fileTree?.addNode(
			path: "non-empty-directory/file-1",
			isDirectory: false,
			size: 123,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory/file-2",
			isDirectory: false,
			size: 123,
			dateModified: now
		)

		let nonEmptyDirectory = assertNode(
			parent: fileTree!.root,
			name: "non-empty-directory",
			size: 0,
			isDirectory: true,
			dateModified: nil // Date is not know because directory was created implicitly
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-1",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-2",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
	}

	// Tree:
	//
	// ├── non-empty-directory/
	// │   ├── file-1
	// │   └── file-2
	// ├── empty-directory/
	// └── file-1

	func testAddComplexFileStructure() throws {
		try fileTree?.addNode(
			path: "empty-directory",
			isDirectory: true,
			size: 0,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory/file-2",
			isDirectory: false,
			size: 123,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "file-1",
			isDirectory: false,
			size: 123,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory",
			isDirectory: true,
			size: 0,
			dateModified: now
		)
		try fileTree?.addNode(
			path: "non-empty-directory/file-3",
			isDirectory: false,
			size: 123,
			dateModified: now
		)

		_ = assertNode(
			parent: fileTree!.root,
			name: "empty-directory",
			size: 0,
			isDirectory: true,
			dateModified: now
		)
		_ = assertNode(
			parent: fileTree!.root,
			name: "file-1",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
		let nonEmptyDirectory = assertNode(
			parent: fileTree!.root,
			name: "non-empty-directory",
			size: 0,
			isDirectory: true,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-2",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
		_ = assertNode(
			parent: nonEmptyDirectory,
			name: "file-3",
			size: 123,
			isDirectory: false,
			dateModified: now
		)
	}
}
