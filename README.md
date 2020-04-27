# Glance

**All-in-one Quick Look plugin**

Glance provides QuickLook previews for various file types that macOS doesn't support out of the box.

## Install

**Glance is available on the Mac App Store:** (TODO: Add link)

![App Store download link](./.github/download-badge.svg)

After opening the app for the first time, macOS will use Glance to generate previews for the supported file types.

TODO: Main app screenshot

## Supported file types

- **Source code** (with [Chroma](https://github.com/alecthomas/chroma) syntax highlighting): `.cpp`, `.js`, `.json`, `.py`, `.swift`, `.yml` and many more

  TODO: Add screenshot

- **Markdown** (rendered using [Blackfriday](https://github.com/russross/blackfriday)): `.md`, `.markdown`, `.mdown`, `.mkdn`, `.mkd`

  TODO: Add screenshot

- **Archives**: `.tar`, `.tar.gz`, `.zip`

  TODO: Add screenshot

- **Jupyter Notebook** (rendered using [`nbtohtml`](https://github.com/samuelmeuli/nbtohtml)): `.ipynb`

  TODO: Add screenshot

- **TSV** (parsed using [SwiftCSV](https://github.com/swiftcsv/SwiftCSV)): `.tab`, `.tsv`

  TODO: Add screenshot

## FAQ

**There are existing QuickLook apps for some of the supported file types. Why create another one?**

- Glance combines the features of many plugins into one and provides consistent and beautiful previews
- Glance is fully compatible with Dark Mode
- Some plugins still use the deprecated Quick Look generator API and might stop working in the future
- Glance can easily be extended to support other file types

**Why does Glance require network permissions?**

Glance renders some file previews in a `WKWebView`. All assets are stored locally and [network access is disabled](./QLPlugin/Views/General/OfflineWebView.swift), but web views still need the `com.apple.security.network.client` entitlement to function.

**Why are images in my Markdown files not loading?**

Glance only has access to the file that’s being previewed (`com.apple.security.files.user-selected.read-only` entitlement). Any image files referenced from Markdown are therefore not loaded.

**Why isn't [file type] supported?**

Please feel free to [open an issue](https://github.com/samuelmeuli/glance/issues/new) or [contribute](#contributing)!

**You claim to support [file type], but previews aren't showing up.**

Please note that Glance skips previews for large files.

It's possible that your file's extension or [UTI](https://en.wikipedia.org/wiki/Uniform_Type_Identifier) isn't associated with Glance. You can easily verify this:

1. Check whether the file extension is matched to the correct class in [`PreviewVCFactory.swift`](./QLPlugin/Views/PreviewVCFactory.swift).
2. Find your file's UTI by running `mdls -name kMDItemContentType -name kMDItemContentTypeTree /path/to/your/file`. Check whether the UTI is listed under `QLSupportedContentTypes` in [`Info.plist`](./QLPlugin/Info.plist).
3. If an association is missing, please feel free to add it and submit a PR.

## Contributing

Suggestions and contributions are always welcome! Please discuss larger changes (e.g. adding support for a new file type) via issue before submitting a pull request.

To add previews for a new file extension, please follow these steps:

1. Create a new class for your file type in [this directory](./QLPlugin/Views/Previews/). It should implement the `Preview` protocol. See the other files in the directory for examples.
2. Match the file extension to your class in [`PreviewVCFactory.swift`](./QLPlugin/Views/PreviewVCFactory.swift).
3. Find your file's UTI by running `mdls -name kMDItemContentType -name kMDItemContentTypeTree /path/to/your/file`. Add it to `QLSupportedContentTypes` in [`Info.plist`](./QLPlugin/Info.plist).
4. Update [`README.md`](./README.md) and [`Credits.rtf`](./Glance/Credits.rtf).
