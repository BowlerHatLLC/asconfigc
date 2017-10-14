# asconfigc

A command line utility that compiles an ActionScript project configured with an [`asconfig.json`](https://github.com/BowlerHatLLC/vscode-nextgenas/wiki/asconfig.json) file. This utility parses the configuration file and runs the compiler with the appropriate options. Supports a variety of ActionScript SDKs, including the Apache Royale SDK and the Adobe AIR SDK & Compiler.

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

* `--royaleHome DIRECTORY`

	Specify the directory where Apache Royale, or another supported SDK, is located. If omitted, defaults to checking `FLEX_HOME` and `PATH` environment variables for a supported SDK.

* `--debug=true` or `--debug=false`

	Overrides the `debug` compiler option specified in `asconfig.json`.

* `-h` or `--help`

	Print help message.

* `-v` or `--version`

	Print the version of `asconfigc`.

## Made with Apache Royale

The source code for the `asconfigc` utility is written in ActionScript. That's right, a utility that runs on Node.js — written in ActionScript and compiled with Apache Royale. Pretty cool, right?

## Support this project

The [ActionScript and MXML extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=bowlerhatllc.vscode-nextgenas) and [`asconfigc`](https://www.npmjs.com/package/asconfigc) are developed by Josh Tynjala with the support of community members like you.

[Support Josh Tynjala on Patreon](http://patreon.com/josht)

Special thanks to the following sponsors for their generous support:

* [YETi CGI](http://yeticgi.com/)

* [Moonshine IDE](http://moonshine-ide.com/)