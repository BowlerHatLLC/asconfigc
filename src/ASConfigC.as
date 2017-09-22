/*
Copyright 2016-2017 Bowler Hat LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package
{
	import com.nextgenactionscript.asconfigc.ASConfigFields;
	import com.nextgenactionscript.asconfigc.CompilerOptions;
	import com.nextgenactionscript.asconfigc.CompilerOptionsParser;
	import com.nextgenactionscript.asconfigc.ConfigName;
	import com.nextgenactionscript.asconfigc.JSOutputType;
	import com.nextgenactionscript.asconfigc.ProjectType;
	import com.nextgenactionscript.asconfigc.Targets;
	import com.nextgenactionscript.asconfigc.utils.assetPathToOutputPath;
	import com.nextgenactionscript.asconfigc.utils.findApplicationContent;
	import com.nextgenactionscript.asconfigc.utils.findOutputDirectory;
	import com.nextgenactionscript.asconfigc.utils.findSourcePathAssets;
	import com.nextgenactionscript.flexjs.utils.ApacheFlexJSUtils;
	import com.nextgenactionscript.utils.ActionScriptSDKUtils;

	/**
	 * A command line utility to build a project defined with an asconfig.json
	 * file using the Apache FlexJS SDK.
	 */
	public class ASConfigC
	{
		private static const ASCONFIG_JSON:String = "asconfig.json";

		private static const MXMLC_JARS:Vector.<String> = new <String>
		[
			"falcon-mxmlc.jar",
			"mxmlc-cli.jar",
			"mxmlc.jar",
		];

		private static const COMPC_JARS:Vector.<String> = new <String>
		[
			"falcon-compc.jar",
			"compc-cli.jar",
			"compc.jar",
		];

		public function ASConfigC()
		{
			this.parseArguments();
			if(!this._javaExecutable)
			{
				this._javaExecutable = ApacheFlexJSUtils.findJava();
				if(!this._javaExecutable)
				{
					console.error("Java not found. Cannot run compiler without Java.");
					process.exit(1);
				}
			}
			if(!this._configFilePath)
			{
				//try to find asconfig.json in the current working directory
				var cwdConfigPath:String = path.resolve(process.cwd(), ASCONFIG_JSON);
				if(fs.existsSync(cwdConfigPath))
				{
					this._configFilePath = cwdConfigPath;
				}
				else
				{
					//asconfig.json not found
					console.error("asconfig.json not found in directory: " + process.cwd());
					this.printUsage();
					process.exit(1);
				}
			}
			process.chdir(path.dirname(this._configFilePath));

			this.parseConfig();
			//validate the SDK after knowing if we're building SWF or JS
			//because JS has stricter SDK requirements
			this.validateSDK();
			this.compileProject();
			this.copySourcePathAssets();
			this.processDescriptor();
			process.exit(0);
		}

		private var _flexHome:String;
		private var _javaExecutable:String;
		private var _configFilePath:String;
		private var _projectType:String;
		private var _configRequiresFlexJS:Boolean;
		private var _isSWFTargetOnly:Boolean;
		private var _outputIsJS:Boolean;
		private var _jsOutputType:String;
		private var _args:Array;
		private var _additionalOptions:String;
		private var _airDescriptor:String = null;
		private var _outputPath:String = null;
		private var _mainFile:String = null;
		private var _forceDebug:* = undefined;
		private var _debugBuild:Boolean = false;
		private var _sourcePaths:Vector.<String> = null;
		private var _copySourcePathAssets:Boolean = false;

		private function printVersion():void
		{
			var packageJSONString:String = fs.readFileSync(path.join(__dirname, "..", "..", "package.json"), "utf8") as String;
			var packageJSON:Object = JSON.parse(packageJSONString);
			console.info("Version: " + packageJSON.version);
		}

		private function printUsage():void
		{
			this.printVersion();
			console.info("Syntax:   asconfigc [options]");
			console.info();
			console.info("Examples: asconfigc -p .");
			console.info("          asconfigc -p path/to/project");
			console.info();
			console.info("Options:");
			console.info(" -h, --help                          Print this help message.");
			console.info(" -v, --version                       Print the version.");
			console.info(" -p DIRECTORY, --project DIRECTORY   Compile the asconfig.json project in the given directory. If omitted, will look for asconfig.json in current directory.");
			console.info(" --flexHome DIRECTORY                Specify the directory where Apache FlexJS, or another supported SDK, is located. If omitted, defaults to checking FLEX_HOME and PATH environment variables.");
			console.info(" --debug=true, --debug=false         Overrides the debug compiler option specified in asconfig.json.");
		}

		private function parseArguments():void
		{
			var args:Object = minimist(process.argv.slice(2));
			for(var key:String in args)
			{
				switch(key)
				{
					case "_":
					{
						var value:String = args[key] as String;
						if(value)
						{
							console.error("Unknown argument: " + value);
							process.exit(1);
						}
						break;
					}
					case "h":
					case "help":
					{
						this.printUsage();
						process.exit(0);
						break;
					}
					case "flexHome":
					{
						this._flexHome = args[key] as String;
						break;
					}
					case "p":
					case "project":
					{
						var projectDirectoryPath:String = args[key] as String;
						projectDirectoryPath = path.resolve(process.cwd(), projectDirectoryPath);
						if(!fs.existsSync(projectDirectoryPath))
						{
							console.error("Project directory not found: " + projectDirectoryPath);
							process.exit(1);
						}
						if(!fs.statSync(projectDirectoryPath).isDirectory())
						{
							console.error("Project must be a directory: " + projectDirectoryPath);
							process.exit(1);
						}
						var configFilePath:String = path.resolve(projectDirectoryPath, ASCONFIG_JSON);
						if(!fs.existsSync(configFilePath))
						{
							console.error("asconfig.json not found in directory: " + projectDirectoryPath);
							process.exit(1);
						}
						this._configFilePath = configFilePath;
						break;
					}
					case "debug":
					{
						//support both --debug=true or simply --debug
						var debugValue:Object = args[key];
						if(typeof debugValue === "string")
						{
							this._forceDebug = debugValue === "true";
						}
						else
						{
							this._forceDebug = debugValue as Boolean;
						}
						break;
					}
					case "v":
					case "version":
					{
						this.printVersion();
						process.exit(0);
					}
					default:
					{
						console.error("Unknown argument: " + key);
						process.exit(1);
					}
				}
			}
		}

		private function loadConfig():Object
		{
			var schemaFilePath:String = path.join(__dirname, "..", "..", "schemas", "asconfig.schema.json");
			try
			{
				var schemaText:String = fs.readFileSync(schemaFilePath, "utf8") as String;
			}
			catch(error:Error)
			{
				console.error("Error: Cannot read schema file. " + schemaFilePath);
				process.exit(1);
			}
			try
			{
				var schemaData:Object = JSON.parse(schemaText);
			}
			catch(error:Error)
			{
				console.error("Error: Invalid JSON in schema file. " + schemaFilePath);
				console.error(error);
				process.exit(1);
			}
			try
			{
				var validate:Function = jsen(schemaData);
			}
			catch(error:Error)
			{
				console.error("Error: Invalid schema. " + schemaFilePath);
				console.error(error);
				process.exit(1);
			}
			try
			{
				var configText:String = fs.readFileSync(this._configFilePath, "utf8") as String;
			}
			catch(error:Error)
			{
				console.error("Error: Cannot read file. " + this._configFilePath);
				process.exit(1);
			}
			try
			{
				var configData:Object = JSON.parse(configText);
			}
			catch(error:Error)
			{
				console.error("Error: Invalid JSON in file. " + this._configFilePath);
				console.error(error);
				process.exit(1);
			}
			if(!validate(configData))
			{
				console.error("Error: Invalid asconfig.json file. " + this._configFilePath);
				console.error(validate["errors"]);
				process.exit(1);
			}
			return configData;
		}

		private function parseConfig():void
		{
			this._args = [];
			var configData:Object = this.loadConfig();
			this._projectType = this.readProjectType(configData);
			if(ASConfigFields.CONFIG in configData)
			{
				var configName:String = configData[ASConfigFields.CONFIG] as String;
				this.detectJavaScript(configName);
				this._args.push("+configname=" + configName);
			}
			if(ASConfigFields.COMPILER_OPTIONS in configData)
			{
				var compilerOptions:Object = configData[ASConfigFields.COMPILER_OPTIONS];
				if(this._forceDebug === true || this._forceDebug === false)
				{
					//ignore the debug option when it is specified on the
					//command line
					delete compilerOptions["debug"];
					this._args.push("--debug=" + this._forceDebug);
				}
				this.readCompilerOptions(compilerOptions);
				if(this._forceDebug === true || compilerOptions.debug)
				{
					this._debugBuild = true;
				}
				if(CompilerOptions.SOURCE_PATH in compilerOptions)
				{
					this._sourcePaths = compilerOptions[CompilerOptions.SOURCE_PATH];
				}
				if(CompilerOptions.OUTPUT in compilerOptions)
				{
					this._outputPath = compilerOptions[CompilerOptions.OUTPUT];
				}
			}
			if(ASConfigFields.ADDITIONAL_OPTIONS in configData)
			{
				this._additionalOptions = configData[ASConfigFields.ADDITIONAL_OPTIONS];
			}
			if(ASConfigFields.APPLICATION in configData)
			{
				//if the path is relative, path.resolve() will give us the
				//absolute path
				this._airDescriptor = path.resolve(configData[ASConfigFields.APPLICATION]);
				if(this._airDescriptor &&
					(!fs.existsSync(this._airDescriptor) || fs.statSync(this._airDescriptor).isDirectory()))
				{
					console.error("Adobe AIR application descriptor not found: " + this._airDescriptor);
					process.exit(1);
				}
			}
			if(ASConfigFields.COPY_SOURCE_PATH_ASSETS in configData)
			{
				this._copySourcePathAssets = configData[ASConfigFields.COPY_SOURCE_PATH_ASSETS];
			}
			if(ASConfigFields.FILES in configData)
			{
				var files:Array = configData[ASConfigFields.FILES] as Array;
				if(this._projectType === ProjectType.LIB)
				{
					CompilerOptionsParser.parse(
					{
						"include-sources": files
					}, this._args);
				}
				else
				{
					var filesCount:int = files.length;
					for(var i:int = 0; i < filesCount; i++)
					{
						var file:String = files[i];
						this._args.push(file);
					}
					if(filesCount > 0)
					{
						this._mainFile = files[filesCount - 1];
					}
				}
			}
			//if js-output-type was not specified, use the default
			//swf projects won't have a js-output-type
			if(this._jsOutputType)
			{
				this._args.push("--" + CompilerOptions.JS_OUTPUT_TYPE + "=" + this._jsOutputType);
			}
		}

		private function readProjectType(configData:Object):String
		{
			if(ASConfigFields.TYPE in configData)
			{
				//this was already validated
				return configData[ASConfigFields.TYPE] as String;
			}
			//this field is optional, and this is the default
			return ProjectType.APP;
		}

		private function readCompilerOptions(options:Object):void
		{
			try
			{
				CompilerOptionsParser.parse(options, this._args);
			}
			catch(error:Error)
			{
				console.error(error.message);
				process.exit(1);
			}
			//make sure that we require FlexJS when these options are specified
			if(CompilerOptions.JS_OUTPUT_TYPE in options)
			{
				this._configRequiresFlexJS = true;
				//if it is set explicitly, then clear the default
				this._jsOutputType = null;
			}
			if(CompilerOptions.TARGETS in options)
			{
				this._configRequiresFlexJS = true;
				var targets:Array = options[CompilerOptions.TARGETS];
				this._isSWFTargetOnly = targets.length === 1 && targets.indexOf(Targets.SWF) !== -1;
				//if targets is set explicitly, then we're using a newer SDK
				//that doesn't need js-output-type
				this._jsOutputType = null;
			}
			if(CompilerOptions.SOURCE_MAP in options)
			{
				this._configRequiresFlexJS = true;
			}
		}

		private function detectJavaScript(configName:String):void
		{
			switch(configName)
			{
				case ConfigName.JS:
				{
					this._jsOutputType = JSOutputType.JSC;
					this._configRequiresFlexJS = true;
					break;
				}
				case ConfigName.NODE:
				{
					this._jsOutputType = JSOutputType.NODE;
					this._configRequiresFlexJS = true;
					break;
				}
			}
		}

		private function validateSDK():void
		{
			//the --flexHome argument wasn't passed in, try to find an SDK
			if(!this._flexHome)
			{
				this._flexHome = ApacheFlexJSUtils.findSDK();
			}
			if(!this._flexHome && !this._configRequiresFlexJS)
			{
				//asconfigc prefers to use FlexJS, but if the specified
				//configuration options don't require FlexJS, it will use any
				//valid SDK
				this._flexHome = ActionScriptSDKUtils.findSDK();
			}
			if(!this._flexHome)
			{
				console.error("SDK not found. Set FLEX_HOME, add to PATH, or use --flexHome option.");
				process.exit(1);
			}
			var sdkIsFlexJS:Boolean = ApacheFlexJSUtils.isValidSDK(this._flexHome);
			if(this._configRequiresFlexJS)
			{
				if(!sdkIsFlexJS)
				{
					console.error("Configuration options in asconfig.json require Apache FlexJS. Path to SDK is not valid: " + this._flexHome);
					process.exit(1);
				}
			}
			this._outputIsJS = sdkIsFlexJS && !this._isSWFTargetOnly;
		}

		private function findJarPath():String
		{
			var jarPath:String = null;
			var jarNames:Vector.<String> = MXMLC_JARS;
			if(this._projectType === ProjectType.LIB)
			{
				jarNames = COMPC_JARS;
			}
			var jarNamesCount:int = jarNames.length;
			for(var i:int = 0; i < jarNamesCount; i++)
			{
				var jarName:String = jarNames[i];
				if(this._outputIsJS)
				{
					jarPath = path.join(this._flexHome, "js", "lib", jarName);
				}
				else
				{
					jarPath = path.join(this._flexHome, "lib", jarName);
				}
				if(fs.existsSync(jarPath))
				{
					break;
				}
				jarPath = null;
			}
			return jarPath;
		}

		private function escapePath(path:String):String
		{
			//we don't want spaces in paths or they will be interpreted as new
			//command line options
			if(process.platform === "win32")
			{
				//on windows, paths may be wrapped in quotes to include spaces
				path = "\"" + path + "\"";
			}
			else
			{
				//on other platforms, a backslash preceding a string will
				//include the space in the path
				path = path.replace(/\ /g, "\\ ");
			}
			return path;
		}

		private function compileProject():void
		{
			var jarPath:String = this.findJarPath();
			if(!jarPath)
			{
				console.error("Compiler not found in SDK. Expected: " + jarPath);
				process.exit(1);
			}
			var frameworkPath:String = path.join(this._flexHome, "frameworks");
			this._args.unshift("+flexlib=" + escapePath(frameworkPath));
			this._args.unshift(escapePath(jarPath));
			this._args.unshift("-jar");
			this._args.unshift("-Dflexlib=" + escapePath(frameworkPath));
			this._args.unshift("-Dflexcompiler=" + escapePath(this._flexHome));
			try
			{
				var command:String = escapePath(this._javaExecutable) + " " + this._args.join(" ");
				if(this._additionalOptions)
				{
					command += " " + this._additionalOptions;
				}
				var result:Object = child_process.execSync(command,
				{
					stdio: "inherit",
					encoding: "utf8"
				});
			}
			catch(error:Object)
			{
				if(error.status === null)
				{
					//this means something went wrong running the executable
					console.error("Failed to execute compiler: " + error.code);
					process.exit(1);
				}
				//while this means there was an error code from the executable,
				//probably from compilation errors
				process.exit(error.status);
			}
		}

		private function copySourcePathAssets():void
		{
			if(!this._copySourcePathAssets)
			{
				return;
			}
			var sourcePaths:Vector.<String> = null;
			if(this._sourcePaths)
			{
				sourcePaths = this._sourcePaths.slice();
			}
			else
			{
				sourcePaths = new <String>[];
			}
			var outputDirectory:String = findOutputDirectory(this._mainFile, this._outputPath, !this._outputIsJS);
			var excludes:Vector.<String> = new <String>[];
			if(this._airDescriptor)
			{
				excludes.push(this._airDescriptor);
			}
			var assetPaths:Vector.<String> = findSourcePathAssets(this._mainFile, sourcePaths, outputDirectory, excludes);
			var assetCount:int = assetPaths.length;
			for(var i:int = 0; i < assetCount; i++)
			{
				var assetPath:String = assetPaths[i];
				var content:Object = fs.readFileSync(assetPath);
				if(this._outputIsJS)
				{
					var debugOutputDir:String = path.join(outputDirectory, "bin", "js-debug");
					var targetPath:String = assetPathToOutputPath(assetPath, this._mainFile, sourcePaths, debugOutputDir);
					mkdirp["sync"](path.dirname(targetPath));
					fs.writeFileSync(targetPath, content);
					if(!this._debugBuild)
					{
						var releaseOutputDir:String = path.join(outputDirectory, "bin", "js-release");
						targetPath = assetPathToOutputPath(assetPath, this._mainFile, sourcePaths, releaseOutputDir);
						mkdirp["sync"](path.dirname(targetPath));
						fs.writeFileSync(targetPath, content);
					}
				}
				else
				{
					targetPath = assetPathToOutputPath(assetPath, this._mainFile, sourcePaths, outputDirectory);
					mkdirp["sync"](path.dirname(targetPath));
					fs.writeFileSync(targetPath, content);
				}
			}
		}

		private function processDescriptor():void
		{
			if(!this._airDescriptor)
			{
				return;
			}
			var outputDir:String = findOutputDirectory(this._mainFile, this._outputPath, !this._outputIsJS);
			var contentValue:String = findApplicationContent(this._mainFile, this._outputPath, !this._outputIsJS);
			if(contentValue === null)
			{
				console.error("Failed to find content for application descriptor.");
				process.exit(1);
			}
			var descriptor:String = fs.readFileSync(this._airDescriptor, "utf8") as String;
			descriptor = descriptor.replace(/<content>.+<\/content>/, "<content>" + contentValue + "</content>");
			if(this._outputIsJS)
			{
				var debugOutputDir:String = path.join(outputDir, "bin", "js-debug");
				var debugDescriptorOutputPath:String = path.resolve(debugOutputDir, path.basename(this._airDescriptor));
				fs.writeFileSync(debugDescriptorOutputPath, descriptor, "utf8");
				if(!this._debugBuild)
				{
					var releaseOutputDir:String = path.join(outputDir, "bin", "js-release");
					var releaseDescriptorOutputPath:String = path.resolve(releaseOutputDir, path.basename(this._airDescriptor));
					fs.writeFileSync(releaseDescriptorOutputPath, descriptor, "utf8");
				}
			}
			else //swf
			{
				var descriptorOutputPath:String = path.resolve(outputDir, path.basename(this._airDescriptor));
				fs.writeFileSync(descriptorOutputPath, descriptor, "utf8");
			}
		}
	}
}