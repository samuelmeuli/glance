module github.com/samuelmeuli/glance

go 1.14

require (
	github.com/Depado/bfchroma v1.1.1
	github.com/alecthomas/chroma v0.7.2
	github.com/microcosm-cc/bluemonday v1.0.2
	github.com/samuelmeuli/nbtohtml v0.4.0
	github.com/stretchr/testify v1.5.1
	github.com/tdewolff/minify/v2 v2.7.4
	golang.org/x/sys v0.0.0-20200323222414-85ca7c5b95cd // indirect
	gopkg.in/russross/blackfriday.v2 v2.0.1
)

replace gopkg.in/russross/blackfriday.v2 v2.0.1 => github.com/russross/blackfriday/v2 v2.0.1
