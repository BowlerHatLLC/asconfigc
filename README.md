# asconfigc

A command line utility that compiles an ActionScript project configured with asconfig.json.

## Installation

This utility is still in development. A preview build will be available soon.

## Usage

```
asconfigc -p .
asconfigc -p path/to/project
```

The following arguments are available:

* `-p DIRECTORY` or `--project DIRECTORY`

	Compile the asconfig.json project in the given directory. If omitted, will look for asconfig.json in current directory.

* `--flexHome DIRECTORY`

	Specify the directory where Apache FlexJS is located. Defaults to checking FLEX_HOME and PATH environment variables.

* `-h` or `--help`

	Print help message.

* `-v` or `--version`

	Print the version of `asconfigc`.

## Support this project

Want to see more ActionScript transpiler tools and utilities like `asconfigc`? How about in-depth articles and step-by-step video tutorials that teach you how to use ActionScript with libraries like jQuery, CreateJS, and Pixi.js? Please [become a patron](http://patreon.com/josht) and support the next generation of ActionScript development on the web -- without a plugin!

[NextGen ActionScript by Josh Tynjala on Patreon](http://patreon.com/josht)

Special thanks to the following sponsors for their generous support:

* [YETi CGI](http://yeticgi.com/)