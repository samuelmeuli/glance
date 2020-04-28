# HTMLConverter

**Go library which is called from Glance's Quick Look plugin**

Using this helper library, the code, Markdown and Jupyter Notebook renderers can share their common dependencies (e.g. Chroma) in a single binary, which reduces the app size significantly.

To build the C archive, run the following command:

```sh
go build --buildmode=c-archive -o htmlconverter.a
```
