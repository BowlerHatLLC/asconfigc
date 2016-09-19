# asconfigc

A command line utility that compiles an ActionScript project configured with an [`asconfig.json`](https://github.com/BowlerHatLLC/vscode-nextgenas/wiki/asconfig.json) file. This utility parses the configuration file and runs the compiler with the appropriate options. Supports a variety of ActionScript SDKs, including the Apache FlexJS SDK and the Adobe AIR SDK & Compiler.

## Installation

Requires [Node.js](https://nodejs.org/).

```
npm install -g asconfigc
```

## Usage

Run `asconfigc` in a directory containing an [`asconfig.json`](https://github.com/BowlerHatLLC/vscode-nextgenas/wiki/asconfig.json) file.

The following options are available:

* `-p DIRECTORY` or `--project DIRECTORY`

	Compile the `asconfig.json` project in the given directory. If omitted, will look for `asconfig.json` in current directory.

* `--flexHome DIRECTORY`

	Specify the directory where Apache FlexJS, or another supported SDK, is located. If omitted, defaults to checking `FLEX_HOME` and `PATH` environment variables for a supported SDK.

* `-h` or `--help`

	Print help message.

* `-v` or `--version`

	Print the version of `asconfigc`.

## Support this project

Want to see more ActionScript transpiler tools and utilities like `asconfigc`? How about in-depth articles and step-by-step video tutorials that teach you how to use ActionScript with libraries like jQuery, CreateJS, and Pixi.js? Please [become a patron](http://patreon.com/josht) and support the next generation of ActionScript development on the web -- without a plugin!

[NextGen ActionScript by Josh Tynjala on Patreon](http://patreon.com/josht)

Special thanks to the following sponsors for their generous support:

* [YETi CGI](http://yeticgi.com/)

* [Moonshine IDE](http://moonshine-ide.com/)