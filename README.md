# asconfigc

A command line utility that compiles an ActionScript project configured with an [*asconfig.json*](https://github.com/BowlerHatLLC/vscode-as3mxml/wiki/asconfig.json) file. This utility parses the configuration file and runs the compiler with the appropriate options. It can also package an Adobe AIR application. Supports a variety of ActionScript SDKs, including [Adobe AIR SDK & Compiler](https://www.adobe.com/devnet/air/air-sdk-download.html), [Apache Flex](https://flex.apache.org), the [Feathers SDK](https://feathersui.com/sdk/), and [Apache Royale](https://royale.apache.org/).

## Installation

Requires [Node.js](https://nodejs.org/).

```
npm install -g asconfigc
```

## Usage

Run *asconfigc* in a directory containing an [*asconfig.json*](https://github.com/BowlerHatLLC/vscode-as3mxml/wiki/asconfig.json) file.

The following options are available:

* `-p FILE OR DIRECTORY` or `--project FILE OR DIRECTORY`

	Compile a project with the path to its configuration file or a directory containing *asconfig.json*. If omitted, will look for *asconfig.json* in current working directory.

* `--sdk DIRECTORY`

	Specify the directory where the ActionScript SDK is located. If omitted, defaults to checking `ROYALE_HOME`, `FLEX_HOME`, and `PATH` environment variables for a supported SDK.

* `--debug=true` or `--debug=false`

	Specify debug or release mode. Overrides the `debug` compiler option, if specified in *asconfig.json*.

* `--air PLATFORM`

	Package the project as an Adobe AIR application. The allowed platforms include `android`, `ios`, `windows`, `mac`, and `air`.

* `--storepass PASSWORD`

	The password used when signing and packaging an Adobe AIR application. If not specified, prompts for the password.

* `--clean`

	Clean the output directory. Will not build the project.

* `--unpackage-anes`

	(Advanced) Unpackage native extensions to the output directory when creating a debug build for the Adobe AIR simulator.

* `--verbose`

	(Advanced) Displays more detailed output, including the full set of options passed to all programs.

* `--jvmargs`

	(Advanced) Pass additional options to the Java Virtual Machine when running the compiler.

* `-h` or `--help`

	Print help message.

* `-v` or `--version`

	Print the version of `asconfigc`.

## Made with Apache Royale

The source code for the `asconfigc` utility is written in ActionScript. That's right, a utility that runs on Node.js — written in ActionScript and compiled with [Apache Royale](https://royale.apache.org/). Pretty cool, right?

## Support this project

The [ActionScript & MXML extension for Visual Studio Code](https://as3mxml.com/) and [*asconfigc*](https://www.npmjs.com/package/asconfigc) are developed by [Josh Tynjala](https://patreon.com/josht) with the support of community members like you.

[Support Josh Tynjala on Patreon](https://patreon.com/josht)

Special thanks to the following sponsors for their generous support:

* [Moonshine IDE](https://moonshine-ide.com/)

* [Dedoose](https://www.dedoose.com/)