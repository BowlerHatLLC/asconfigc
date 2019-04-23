/*
Copyright 2016-2019 Bowler Hat LLC

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
	import com.as3mxml.asconfigc.AIROptions;
	import com.as3mxml.asconfigc.AIROptionsParser;
	import com.as3mxml.asconfigc.AIRPlatformType;
	import com.as3mxml.asconfigc.ASConfigFields;
	import com.as3mxml.asconfigc.CompilerOptions;
	import com.as3mxml.asconfigc.CompilerOptionsParser;
	import com.as3mxml.asconfigc.ConfigName;
	import com.as3mxml.asconfigc.HTMLTemplateOptionsParser;
	import com.as3mxml.asconfigc.JSOutputType;
	import com.as3mxml.asconfigc.ProjectType;
	import com.as3mxml.asconfigc.SigningOptions;
	import com.as3mxml.asconfigc.Targets;
	import com.as3mxml.asconfigc.utils.assetPathToOutputPath;
	import com.as3mxml.asconfigc.utils.escapePath;
	import com.as3mxml.asconfigc.utils.findAIRDescriptorOutputPath;
	import com.as3mxml.asconfigc.utils.findApplicationContent;
	import com.as3mxml.asconfigc.utils.findApplicationContentOutputPath;
	import com.as3mxml.asconfigc.utils.findOutputDirectory;
	import com.as3mxml.asconfigc.utils.findSourcePathAssets;
	import com.as3mxml.asconfigc.utils.folderContains;
	import com.as3mxml.asconfigc.utils.populateHTMLTemplateFile;
	import com.as3mxml.royale.utils.ApacheFlexJSUtils;
	import com.as3mxml.royale.utils.ApacheRoyaleUtils;
	import com.as3mxml.utils.ActionScriptSDKUtils;
	import com.as3mxml.utils.findJava;

	/**
	 * A command line utility to build a project defined with an asconfig.json
	 * file using any supported ActionScript SDK, including Apache Royale, the
	 * Feathers SDK, and the Adobe AIR SDK & Compiler.
	 */
	public class ASConfigC
	{
		private static const ASCONFIG_JSON:String = "asconfig.json";
		private static const FILE_EXTENSION_ANE:String = ".ane";
		private static const FILE_NAME_UNPACKAGED_ANES:String = ".as3mxml-unpackaged-anes";

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

		private static const ADT_JAR:String = "adt.jar";

		public function ASConfigC()
		{
			this.parseArguments();
			if(!this._javaExecutable)
			{
				this._javaExecutable = findJava();
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
			this.cleanProject();
			this.compileProject();
			this.copySourcePathAssets();
			this.copyHTMLTemplate();
			this.processDescriptor();
			this.copyAIRFiles();
			this.prepareNativeExtensions();
			if(this._airPlatform !== null)
			{
				this.packageAIR();
			}
			process.exit(0);
		}

		private var _sdkHome:String;
		private var _javaExecutable:String;
		private var _configFilePath:String;
		private var _projectType:String;
		private var _sdkIsRoyale:Boolean;
		private var _configRequiresRoyale:Boolean;
		private var _configRequiresFlexJS:Boolean;
		private var _configRequiresRoyaleOrFlexJS:Boolean;
		private var _isSWFTargetOnly:Boolean;
		private var _outputIsJS:Boolean;
		private var _jsOutputType:String;
		private var _compilerArgs:Array;
		private var _additionalOptions:String;
		private var _airDescriptor:String = null;
		private var _outputPath:String = null;
		private var _files:Array = null;
		private var _mainFile:String = null;
		private var _forceDebug:* = undefined;
		private var _clean:Boolean = false;
		private var _unpackageANEs:Boolean = false;
		private var _debugBuild:Boolean = false;
		private var _sourcePaths:Vector.<String> = null;
		private var _copySourcePathAssets:Boolean = false;
		private var _airPlatform:String = null;
		private var _storepass:String = null;
		private var _airArgs:Array;
		private var _compilerOptionsJSON:Object = null;
		private var _airOptionsJSON:Object = null;
		private var _htmlTemplate:String = null;
		private var _htmlTemplateOptions:Object = null;

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
			console.info("Examples: asconfigc");
			console.info("          asconfigc -p .");
			console.info("          asconfigc -p path/to/custom.json");
			console.info();
			console.info("Options:");
			console.info(" -h, --help                                          Print this help message.");
			console.info(" -v, --version                                       Print the version.");
			console.info(" -p FILE OR DIRECTORY, --project FILE OR DIRECTORY   Compile a project with the path to its configuration file or a directory containing asconfig.json. If omitted, will look for asconfig.json in current directory.");
			console.info(" --sdk DIRECTORY                                     Specify the directory where the ActionScript SDK is located. If omitted, defaults to checking ROYALE_HOME, FLEX_HOME and PATH environment variables.");
			console.info(" --debug=true, --debug=false                         Specify debug or release mode. Overrides the debug compiler option, if specified in asconfig.json.");
			console.info(" --air PLATFORM                                      Package the project as an Adobe AIR application. The allowed platforms include `android`, `ios`, `windows`, `mac`, and `air`.");
			console.info(" --storepass PASSWORD                                The password used when signing and packaging an Adobe AIR application. If not specified, prompts for the password.");
			console.info(" --unpackage-anes                                    Unpackage native extensions to the output directory when creating a debug build for the Adobe AIR simulator.");
			console.info(" --clean                                             Clean the output directory. Will not build the project.")
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
						var value:String = String(args[key]);
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
					case "sdk":
					case "flexHome":
					{
						this._sdkHome = String(args[key]);
						//on windows, don't let the path end with a backslash
						//because resolving sub-directories may fail
						if(this._sdkHome.endsWith("\\"))
						{
							this._sdkHome = this._sdkHome.substr(0, this._sdkHome.length - 1);
						}
						break;
					}
					case "p":
					case "project":
					{
						var projectPath:String = String(args[key]);
						projectPath = path.resolve(process.cwd(), projectPath);
						if(!fs.existsSync(projectPath))
						{
							console.error("Project directory or JSON file not found: " + projectPath);
							process.exit(1);
						}
						if(fs.statSync(projectPath).isDirectory())
						{
							var configFilePath:String = path.resolve(projectPath, ASCONFIG_JSON);
							if(!fs.existsSync(configFilePath))
							{
								console.error("asconfig.json not found in directory: " + projectPath);
								process.exit(1);
							}
							this._configFilePath = configFilePath;
						}
						else
						{
							this._configFilePath = projectPath;
						}
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
					case "clean":
					{
						//support both --clean=true or simply --clean
						var cleanValue:Object = args[key];
						if(typeof cleanValue === "string")
						{
							this._clean = cleanValue === "true";
						}
						else
						{
							this._clean = cleanValue as Boolean;
						}
						break;
					}
					case "air":
					{
						var airPlatformValue:Object = args[key];
						if(typeof airPlatformValue === "string")
						{
							this._airPlatform = airPlatformValue as String;
							if(this._airPlatform === AIRPlatformType.MAC &&
								process.platform !== "darwin")
							{
								console.error("Error: Adobe AIR applications for macOS cannot be packaged on this platorm.");
								process.exit(1);
							}
							else if(this._airPlatform === AIRPlatformType.WINDOWS &&
								process.platform !== "win32")
							{
								console.error("Error: Adobe AIR applications for Windows cannot be packaged on this platform.");
								process.exit(1);
							}
						}
						else
						{
							this._airPlatform = AIRPlatformType.AIR;
						}
						break;
					}
					case "storepass":
					{
						if(!args["air"])
						{
							console.error("Error: The storepass option requires the air option to be set too.");
							process.exit(1);
						}
						this._storepass = String(args[key]);
						break;
					}
					case "unpackage-anes":
					{
						if(args["air"])
						{
							console.error("Error: The unpackage-anes option cannot be set when the air option is set.");
							process.exit(1);
						}
						//support both --unpackage-anes=true or simply --unpackage-anes
						var unpackageANEsValue:Object = args[key];
						if(typeof unpackageANEsValue === "string")
						{
							this._unpackageANEs = unpackageANEsValue === "true";
						}
						else
						{
							this._unpackageANEs = unpackageANEsValue as Boolean;
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
				var configData:Object = json5.parse(configText);
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
			this._compilerArgs = [];
			this._airArgs = [];
			this._compilerOptionsJSON = null;
			this._airOptionsJSON = null;
			var configData:Object = this.loadConfig();
			this._projectType = this.readProjectType(configData);
			if(ASConfigFields.CONFIG in configData)
			{
				var configName:String = configData[ASConfigFields.CONFIG] as String;
				this.detectJavaScript(configName);
				this._compilerArgs.push("+configname=" + configName);
			}
			if(ASConfigFields.COMPILER_OPTIONS in configData)
			{
				this._compilerOptionsJSON = configData[ASConfigFields.COMPILER_OPTIONS];
				if(this._forceDebug === true || this._forceDebug === false)
				{
					//ignore the debug option when it is specified on the
					//command line
					delete this._compilerOptionsJSON["debug"];
					this._compilerArgs.push("--debug=" + this._forceDebug);
				}
				this.readCompilerOptions(this._compilerOptionsJSON);
				if(this._forceDebug === true || this._compilerOptionsJSON.debug)
				{
					this._debugBuild = true;
				}
				if(CompilerOptions.SOURCE_PATH in this._compilerOptionsJSON)
				{
					this._sourcePaths = this._compilerOptionsJSON[CompilerOptions.SOURCE_PATH];
				}
				if(CompilerOptions.OUTPUT in this._compilerOptionsJSON)
				{
					this._outputPath = this._compilerOptionsJSON[CompilerOptions.OUTPUT];
				}
			}
			if(ASConfigFields.ADDITIONAL_OPTIONS in configData)
			{
				this._additionalOptions = configData[ASConfigFields.ADDITIONAL_OPTIONS];
			}
			//if js-output-type was not specified, use the default
			//swf projects won't have a js-output-type
			if(this._jsOutputType)
			{
				this._compilerArgs.push("--" + CompilerOptions.JS_OUTPUT_TYPE + "=" + this._jsOutputType);
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
			//parse files before airOptions because the mainFile may be
			//needed to generate some file paths
			if(ASConfigFields.FILES in configData)
			{
				this._files = configData[ASConfigFields.FILES] as Array;
				if(this._projectType === ProjectType.LIB)
				{
					CompilerOptionsParser.parse(
					{
						"include-sources": this._files
					}, this._compilerArgs);
				}
				else //app
				{
					if(this._files.length > 0)
					{
						this._mainFile = this._files[this._files.length - 1];
					}
				}
			}
			if(ASConfigFields.AIR_OPTIONS in configData)
			{
				if(this._airDescriptor === null)
				{
					console.error("Adobe AIR packaging options found, but the \"application\" field is empty.");
					process.exit(1);
				}
				this._airOptionsJSON = configData[ASConfigFields.AIR_OPTIONS];
				this.readAIROptions(this._airOptionsJSON);
			}
			if(ASConfigFields.COPY_SOURCE_PATH_ASSETS in configData)
			{
				this._copySourcePathAssets = configData[ASConfigFields.COPY_SOURCE_PATH_ASSETS];
			}
			if(ASConfigFields.HTML_TEMPLATE in configData)
			{
				this._htmlTemplate = configData[ASConfigFields.HTML_TEMPLATE];

				//the HTML template needs to be parsed after files and outputPath have
				//both been parsed
				var compilerOptionsJSON:Object = null;
				if(ASConfigFields.COMPILER_OPTIONS in configData)
				{
					compilerOptionsJSON = configData[ASConfigFields.COMPILER_OPTIONS];
				}
				readHTMLTemplateOptions(compilerOptionsJSON);
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
				CompilerOptionsParser.parse(options, this._compilerArgs);
			}
			catch(error:Error)
			{
				console.error("Error: Failed to parse compiler options.");
				console.error(error.stack);
				process.exit(1);
			}
			//make sure that we require Royale (or FlexJS) depending on which options are specified
			if(CompilerOptions.JS_OUTPUT_TYPE in options)
			{
				//this option was used in FlexJS 0.7, but it was replaced with
				//targets in FlexJS 0.8.
				this._configRequiresFlexJS = true;
				//if it is set explicitly, then clear the default
				this._jsOutputType = null;
			}
			if(CompilerOptions.TARGETS in options)
			{
				var targets:Array = options[CompilerOptions.TARGETS];
				if(targets.indexOf(Targets.JS_ROYALE) !== -1 ||
					targets.indexOf(Targets.JS_ROYALE_CORDOVA) !== -1)
				{
					//these targets definitely don't work with FlexJS
					this._configRequiresRoyale = true;
				}
				else
				{
					//remaining targets are supported by both Royale and FlexJS
					this._configRequiresRoyaleOrFlexJS = true;
				}
				this._isSWFTargetOnly = targets.length === 1 && targets.indexOf(Targets.SWF) !== -1;
				//if targets is set explicitly, then we're using a newer SDK
				//that doesn't need js-output-type
				this._jsOutputType = null;
			}
			if(this._sdkIsRoyale)
			{
				//this was only needed for Apache FlexJS
				this._jsOutputType = null;
			}
			if(CompilerOptions.SOURCE_MAP in options)
			{
				//source-map compiler option is supported by both Royale and FlexJS
				this._configRequiresRoyaleOrFlexJS = true;
			}
		}

		private function readAIROptions(options:Object):void
		{
			try
			{
				AIROptionsParser.parse(
					this._airPlatform,
					this._debugBuild,
					findAIRDescriptorOutputPath(this._mainFile, this._airDescriptor, this._outputPath, !this._outputIsJS),
					findApplicationContentOutputPath(this._mainFile, this._outputPath, !this._outputIsJS),
					options,
					this._airArgs);
			}
			catch(error:Error)
			{
				console.error("Error: Failed to parse Adobe AIR options.");
				console.error(error.stack);
				process.exit(1);
			}
		}

		private function readHTMLTemplateOptions(compilerOptionsJSON:Object):void
		{
			try
			{
				this._htmlTemplateOptions = HTMLTemplateOptionsParser.parse(
					compilerOptionsJSON,
					this._mainFile,
					this._outputPath);
			}
			catch(error:Error)
			{
				console.error("Error: Failed to parse HTML template options.");
				console.error(error.stack);
				process.exit(1);
			}
		}

		private function detectJavaScript(configName:String):void
		{
			switch(configName)
			{
				case ConfigName.JS:
				{
					this._jsOutputType = JSOutputType.JSC;
					this._configRequiresRoyaleOrFlexJS = true;
					break;
				}
				case ConfigName.NODE:
				{
					this._jsOutputType = JSOutputType.NODE;
					this._configRequiresRoyaleOrFlexJS = true;
					break;
				}
				case ConfigName.ROYALE:
				{
					//this option is not supported by FlexJS
					this._configRequiresRoyale = true;
					break;
				}
			}
		}

		private function validateSDK():void
		{
			//the --sdk argument wasn't passed in, try to find an SDK
			if(!this._sdkHome)
			{
				this._sdkHome = ApacheRoyaleUtils.findSDK();
			}
			if(!this._sdkHome && !this._configRequiresRoyale)
			{
				this._sdkHome = ApacheFlexJSUtils.findSDK();
			}
			if(!this._sdkHome &&
				!this._configRequiresRoyale &&
				!this._configRequiresRoyaleOrFlexJS &&
				!this._configRequiresFlexJS)
			{
				//asconfigc prefers to use Royale, but if the specified
				//configuration options don't require Royale, it will use any
				//valid SDK
				this._sdkHome = ActionScriptSDKUtils.findSDK();
			}
			if(!this._sdkHome)
			{
				var envHome:String = "FLEX_HOME";
				if(this._configRequiresRoyale)
				{
					envHome = "ROYALE_HOME";
				}
				else if(this._configRequiresRoyaleOrFlexJS)
				{
					envHome = "ROYALE_HOME for Apache Royale, FLEX_HOME for Apache FlexJS";
				}
				console.error("SDK not found. Set " + envHome + ", add to PATH, or use --sdk option.");
				process.exit(1);
			}
			var royaleHome:String = ApacheRoyaleUtils.isValidSDK(this._sdkHome);
			if(royaleHome !== null)
			{
				this._sdkHome = royaleHome;
				this._sdkIsRoyale = true;
			}
			if(this._configRequiresRoyale)
			{
				if(!this._sdkIsRoyale)
				{
					console.error("Configuration options in asconfig.json require Apache Royale. Path to SDK is not valid: " + this._sdkHome);
					process.exit(1);
				}
			}
			var sdkIsFlexJS:Boolean = ApacheFlexJSUtils.isValidSDK(this._sdkHome);
			if(this._configRequiresRoyaleOrFlexJS)
			{
				if(!this._sdkIsRoyale && !sdkIsFlexJS)
				{
					console.error("Configuration options in asconfig.json require Apache Royale or FlexJS. Path to SDK is not valid: " + this._sdkHome);
					process.exit(1);
				}
			}
			if(this._configRequiresFlexJS)
			{
				if(!sdkIsFlexJS)
				{
					console.error("Configuration options in asconfig.json require Apache FlexJS. Path to SDK is not valid: " + this._sdkHome);
					process.exit(1);
				}
			}

			this._outputIsJS = (this._sdkIsRoyale || sdkIsFlexJS) && !this._isSWFTargetOnly;
		}

		private function findCompilerJarPath():String
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
					jarPath = path.join(this._sdkHome, "js", "lib", jarName);
				}
				else
				{
					jarPath = path.join(this._sdkHome, "lib", jarName);
				}
				if(fs.existsSync(jarPath))
				{
					break;
				}
				jarPath = null;
			}
			return jarPath;
		}

		private function findAIRPackagerJarPath():String
		{
			var jarPath:String = path.join(this._sdkHome, "lib", ADT_JAR);
			if(fs.existsSync(jarPath))
			{
				return jarPath;
			}
			return null;
		}

		private function cleanProject():void
		{
			if(!this._clean)
			{
				return;
			}

			var outputDirectory:String = findOutputDirectory(this._mainFile, this._outputPath, !this._outputIsJS);
			if(this._outputIsJS)
			{
				var debugOutputDir:String = path.join(outputDirectory, "bin", "js-debug");
				this.cleanOutputDirectory(debugOutputDir);
				var releaseOutputDir:String = path.join(outputDirectory, "bin", "js-release");
				this.cleanOutputDirectory(releaseOutputDir);
			}
			else //swf
			{
				this.cleanOutputDirectory(outputDirectory);
			}

			//immediately exits after cleaning
			process.exit(0);
		}

		private function cleanOutputDirectory(outputDirectory:String):void
		{
			var cwd:String = process.cwd();
			if(folderContains(outputDirectory, cwd))
			{
				console.error("Failed to clean project because the output path overlaps with the current working directory.");
				process.exit(1);
			}

			var sourcePathsCopy:Vector.<String> = new <String>[];
			if(this._sourcePaths !== null)
			{
				//we don't want to modify the original list, so copy the items over
				sourcePathsCopy = this._sourcePaths.slice();
			}
			if(this._mainFile !== null)
			{
				//the parent directory of the main file is automatically added as a
				//source path by the compiler
				var mainPath:String = path.dirname(this._mainFile);
				sourcePathsCopy.push(mainPath);
			}
			var sourcePathCount:int = sourcePathsCopy.length;
			for(var i:int = 0; i < sourcePathCount; i++)
			{
				var sourcePath:String = sourcePathsCopy[i];
				//get the absolute path for each of the source paths
				sourcePath = path.resolve(sourcePath);
				if(folderContains(outputDirectory, sourcePath) ||
					folderContains(sourcePath, outputDirectory))
				{
					console.error("Failed to clean project because the output path overlaps with a source path.");
					process.exit(1);
				}
			}

			if(fs.existsSync(outputDirectory))
			{
				try
				{
					del.sync([outputDirectory]);
				}
				catch(e:Error)
				{
					console.error("Failed to clean project because an I/O exception occurred.");
					process.exit(1);
				}
			}
		}

		private function compileProject():void
		{
			var jarPath:String = this.findCompilerJarPath();
			if(!jarPath)
			{
				console.error("Compiler not found in SDK. Expected: " + jarPath);
				process.exit(1);
			}
			var frameworkPath:String = path.join(this._sdkHome, "frameworks");
			if(this._sdkIsRoyale)
			{
				//royale is a special case that has renamed many of the common
				//configuration options for the compiler
				this._compilerArgs.unshift("+royalelib=" + escapePath(frameworkPath));
				this._compilerArgs.unshift(escapePath(jarPath));
				this._compilerArgs.unshift("-jar");
				this._compilerArgs.unshift("-Droyalelib=" + escapePath(frameworkPath));
				this._compilerArgs.unshift("-Droyalecompiler=" + escapePath(this._sdkHome));
				//Royale requires this so that it doesn't changing the encoding of
				//UTF-8 characters and display ???? instead
				this._compilerArgs.unshift("-Dfile.encoding=UTF8");
			}
			else
			{
				//other SDKs all use the same options
				this._compilerArgs.unshift("+flexlib=" + escapePath(frameworkPath));
				this._compilerArgs.unshift(escapePath(jarPath));
				this._compilerArgs.unshift("-jar");
				this._compilerArgs.unshift("-Dflexlib=" + escapePath(frameworkPath));
				this._compilerArgs.unshift("-Dflexcompiler=" + escapePath(this._sdkHome));
			}
			this._compilerArgs.unshift("-Xmx512m");
			try
			{
				var command:String = escapePath(this._javaExecutable) + " " + this._compilerArgs.join(" ");
				if(process.platform !== "win32")
				{
					command = command.replace(/\$\{/g, "\\${");
				}
				if(this._additionalOptions)
				{
					command += " " + this._additionalOptions;
				}
				if(this._files && this._projectType !== ProjectType.LIB)
				{
					var filesCount:int = this._files.length;
					for(var i:int = 0; i < filesCount; i++)
					{
						if(i === 0)
						{
							command += " -- ";
						}
						else
						{
							command += " ";
						}
						var file:String = this._files[i];
						command += escapePath(file, false);
					}
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

		private function copySourcePathAssetToOutputDirectory(assetPath:String, mainFile:String, sourcePaths:Vector.<String>, outputDirectory:String):void
		{
			var content:Object = fs.readFileSync(assetPath);
			var targetPath:String = assetPathToOutputPath(assetPath, mainFile, sourcePaths, outputDirectory);
			mkdirp["sync"](path.dirname(targetPath));
			fs.writeFileSync(targetPath, content);
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
			var assetPaths:Array = findSourcePathAssets(this._mainFile, sourcePaths, outputDirectory, excludes);
			var assetCount:int = assetPaths.length;
			for(var i:int = 0; i < assetCount; i++)
			{
				var assetPath:String = assetPaths[i];
				if(this._outputIsJS)
				{
					var debugOutputDir:String = path.join(outputDirectory, "bin", "js-debug");
					copySourcePathAssetToOutputDirectory(assetPath, this._mainFile, sourcePaths, debugOutputDir);
					if(!this._debugBuild)
					{
						var releaseOutputDir:String = path.join(outputDirectory, "bin", "js-release");
						copySourcePathAssetToOutputDirectory(assetPath, this._mainFile, sourcePaths, releaseOutputDir);
					}
				}
				else
				{
					copySourcePathAssetToOutputDirectory(assetPath, this._mainFile, sourcePaths, outputDirectory);
				}
			}
		}

		private function copyHTMLTemplate():void
		{
			if(!this._htmlTemplate)
			{
				return;
			}
			if(!fs.existsSync(this._htmlTemplate))
			{
				console.error("htmlTemplate directory does not exist: " + this._htmlTemplate);
				process.exit(1);
			}
			if(!fs.statSync(this._htmlTemplate).isDirectory())
			{
				console.error("htmlTemplate path must be a directory. Invalid path: " + this._htmlTemplate);
				process.exit(1);
			}
			var outputDir:String = findOutputDirectory(this._mainFile, this._outputPath, !this._outputIsJS);
			copyHTMLTemplateDirectory(this._htmlTemplate, outputDir);
		}

		private function copyHTMLTemplateDirectory(inputDir:String, outputDir:String):void
		{
			mkdirp["sync"](outputDir);
			if(!fs.existsSync(outputDir))
			{
				console.error("Failed to create output directory for HTML template: " + outputDir);
				process.exit(1);
			}
			var files:Array = fs.readdirSync(inputDir);
			var fileCount:int = files.length;
			for(var i:int = 0; i < fileCount; i++)
			{
				var fileName:String = files[i];
				var inputFilePath:String = path.resolve(inputDir, fileName);
				var outputFilePath:String = path.resolve(outputDir, fileName);
				if(fs.statSync(inputFilePath).isDirectory())
				{
					copyHTMLTemplateDirectory(inputFilePath, outputFilePath);
					continue;
				}
				var extension:String = path.extname(fileName);
				if(extension)
				{
					var templateExtension:String = ".template" + extension;
					if(fileName.endsWith(templateExtension))
					{
						var fileNameWithoutExtension:String = fileName.substr(0, fileName.length - templateExtension.length);
						if(fileNameWithoutExtension === "index")
						{
							if(this._mainFile !== null)
							{
								var mainFileName:String = path.basename(this._mainFile);
								var mainFileExtensionIndex:int = mainFileName.indexOf(".");
								if(mainFileExtensionIndex !== -1)
								{
									fileNameWithoutExtension = mainFileName.substr(0, mainFileExtensionIndex);
								}
							}
						}
						try
						{
							var content:String = fs.readFileSync(inputFilePath, "utf8") as String;
						}
						catch(error)
						{
							console.error("Failed to copy file: " + inputFilePath);
							process.exit(1);
						}
						content = populateHTMLTemplateFile(content, this._htmlTemplateOptions);
						var outputFileName:String = fileNameWithoutExtension + extension;
						outputFilePath = path.resolve(outputDir, outputFileName);
						fs.writeFileSync(outputFilePath, content);
						continue;
					}
				}
				try
				{
					var rawContent:Object = fs.readFileSync(inputFilePath);
				}
				catch(error)
				{
					console.error("Failed to copy file: " + inputFilePath);
					process.exit(1);
				}
				fs.writeFileSync(outputFilePath, rawContent);

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
			descriptor = descriptor.replace(/<content>.*<\/content>/, "<content>" + contentValue + "</content>");
			if(this._outputIsJS)
			{
				var debugOutputDir:String = path.join(outputDir, "bin", "js-debug");
				var debugDescriptorOutputPath:String = path.resolve(debugOutputDir, path.basename(this._airDescriptor));
				mkdirp["sync"](path.dirname(debugDescriptorOutputPath));
				fs.writeFileSync(debugDescriptorOutputPath, descriptor, "utf8");
				if(!this._debugBuild)
				{
					var releaseOutputDir:String = path.join(outputDir, "bin", "js-release");
					var releaseDescriptorOutputPath:String = path.resolve(releaseOutputDir, path.basename(this._airDescriptor));
					mkdirp["sync"](path.dirname(releaseDescriptorOutputPath));
					fs.writeFileSync(releaseDescriptorOutputPath, descriptor, "utf8");
				}
			}
			else //swf
			{
				var descriptorOutputPath:String = findAIRDescriptorOutputPath(this._mainFile, this._airDescriptor, this._outputPath, true);
				mkdirp["sync"](path.dirname(descriptorOutputPath));
				fs.writeFileSync(descriptorOutputPath, descriptor, "utf8");
			}
		}

		private function prepareNativeExtensions():void
		{
			if(this._airPlatform !== null)
			{
				//don't copy anything when packaging an app. these files are
				//used for debug builds only.
				return;
			}
			if(!this._unpackageANEs)
			{
				//don't copy anything if it's not requested.
				return;
			}
			if(!this._debugBuild)
			{
				//don't copy anything when it's a release build.
				return;
			}
			if(this._compilerOptionsJSON === null)
			{
				//the compilerOptions field is not defined, so there's nothing to copy
				return;
			}

			if(CompilerOptions.LIBRARY_PATH in this._compilerOptionsJSON)
			{
				var libraryPathJSON:Array = this._compilerOptionsJSON[CompilerOptions.LIBRARY_PATH] as Array;
				this.unpackANEs(libraryPathJSON);
			}
			if(CompilerOptions.EXTERNAL_LIBRARY_PATH in this._compilerOptionsJSON)
			{
				var externalLibraryPathJSON:Array = this._compilerOptionsJSON[CompilerOptions.EXTERNAL_LIBRARY_PATH] as Array;
				this.unpackANEs(externalLibraryPathJSON);
			}
		}

		private function unpackANEs(libraryPathJSON:Array):void
		{
			var pathCount:int = libraryPathJSON.length;
			for(var i:int = 0; i < pathCount; i++)
			{
				var libraryPath:String = libraryPathJSON[i] as String;
				libraryPath = path.resolve(libraryPath);
				if(libraryPath.endsWith(FILE_EXTENSION_ANE))
				{
					this.unpackANE(libraryPath);
				}
				else if(fs.statSync(libraryPath).isDirectory())
				{
					var files:Array = fs.readdirSync(libraryPath);
					var fileCount:int = files.length;
					for(var j:int = 0; j < fileCount; j++)
					{
						var file:String = files[j];
						var fullPath:String = path.resolve(libraryPath, file);
						if(fullPath.endsWith(FILE_EXTENSION_ANE))
						{
							this.unpackANE(fullPath);
						}
					}
				}
			}
		}

		private function unpackANE(aneFilePath:String):void
		{
			if(fs.statSync(aneFilePath).isDirectory())
			{
				//this is either an ANE that's already unpacked
				//...or something else entirely
				return;
			}

			var outputDir:String = findOutputDirectory(this._mainFile, this._outputPath, !this._outputIsJS);
			var unpackedAneDir:String = path.resolve(outputDir, FILE_NAME_UNPACKAGED_ANES);
			var currentAneDir:String = path.resolve(unpackedAneDir, path.basename(aneFilePath));		
			mkdirp["sync"](currentAneDir);

			try
			{
				var zipFile:admZip = new admZip(aneFilePath);
				zipFile.extractAllTo(currentAneDir, true);
			}
			catch(error:Error)
			{
				console.error("Failed to copy Adobe AIR native extension from path: " + aneFilePath + ".");
				process.exit(1);
			}
		}

		private function copyAIRFiles():void
		{
			if(this._airPlatform !== null)
			{
				//don't copy anything when packaging an app. these files are
				//used for debug builds only.
				return;
			}
			if(this._airOptionsJSON === null)
			{
				//the airOptions field is not defined, so there's nothing to copy
				return;
			}
			if(!this._airOptionsJSON.files)
			{
				//the files field is not defined, so there's nothing to copy
				return;
			}

			var outputDir:String = findOutputDirectory(this._mainFile, this._outputPath, !this._outputIsJS);
			var filesJSON:Array = this._airOptionsJSON.files as Array;
			var fileCount:int = filesJSON.length;
			for(var i:int = 0; i < fileCount; i++)
			{
				var fileJSON:Object = filesJSON[i];
				if(fileJSON is String)
				{
					var srcFilePath:String = fileJSON as String;
					srcFilePath = path.resolve(srcFilePath);

					//copy directly to output directory
					var destFilePath:String = path.basename(srcFilePath);
				}
				else //object with src and dest
				{
					srcFilePath = fileJSON[AIROptions.FILES_FILE];
					srcFilePath = path.resolve(srcFilePath);
					destFilePath = fileJSON[AIROptions.FILES_PATH];
				}

				if(fs.statSync(srcFilePath).isDirectory())
				{
					var assetDirList:Vector.<String> = new <String>[srcFilePath];
					var assetPaths:Array = findSourcePathAssets(null, assetDirList, outputDir, null);
					assetDirList = new <String>[path.dirname(srcFilePath)];
					var assetCount:int = assetPaths.length;
					for(var j:int = 0; j < assetCount; j++)
					{
						var assetPath:String = assetPaths[j];
						if(this._outputIsJS)
						{
							var debugOutputDir:String = path.join(outputDir, "bin", "js-debug");
							copySourcePathAssetToOutputDirectory(assetPath, null, assetDirList, debugOutputDir);
							if(!this._debugBuild)
							{
								var releaseOutputDir:String = path.join(outputDir, "bin", "js-release");
								copySourcePathAssetToOutputDirectory(assetPath, null, assetDirList, releaseOutputDir);
							}
						}
						else //swf
						{
							copySourcePathAssetToOutputDirectory(assetPath, null, assetDirList, outputDir);
						}
					}
				}
				else //src not a directory
				{
					try
					{
						var content:Object = fs.readFileSync(srcFilePath);
					}
					catch(error)
					{
						console.error("Failed to copy file: " + srcFilePath);
						process.exit(1);
					}
					if(this._outputIsJS)
					{
						var targetPath:String = path.resolve(path.join(outputDir, "bin", "js-debug"), destFilePath);
						mkdirp["sync"](path.dirname(targetPath));
						fs.writeFileSync(targetPath, content);
						if(!this._debugBuild)
						{
							targetPath = path.resolve(path.join(outputDir, "bin", "js-release"), destFilePath);
							mkdirp["sync"](path.dirname(targetPath));
							fs.writeFileSync(targetPath, content);
						}
					}
					else //swf
					{
						targetPath = path.resolve(outputDir, destFilePath);
						mkdirp["sync"](path.dirname(targetPath));
						fs.writeFileSync(targetPath, content);
					}
				}
			}
		}

		private function packageAIR():void
		{
			if(this._storepass !== null)
			{
				var storepassIndex:int = this._airArgs.indexOf("-" + SigningOptions.STOREPASS);
				if(storepassIndex == -1)
				{
					var keystoreIndex:int = this._airArgs.indexOf("-" + SigningOptions.KEYSTORE);
					if(keystoreIndex != -1)
					{
						this._airArgs.splice(keystoreIndex + 2, 0, "-" + SigningOptions.STOREPASS);
						this._airArgs.splice(keystoreIndex + 3, 0, this._storepass);
					}
				}
			}
			var jarPath:String = this.findAIRPackagerJarPath();
			if(!jarPath)
			{
				console.error("AIR ADT not found in SDK. Expected: " + jarPath);
				process.exit(1);
			}
			this._airArgs.unshift(escapePath(jarPath));
			this._airArgs.unshift("-jar");
			try
			{
				var command:String = escapePath(this._javaExecutable) + " " + this._airArgs.join(" ");
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
					console.error("Failed to execute AIR packager: " + error.code);
					process.exit(1);
				}
				//while this means there was an error code from the executable,
				//probably from compilation errors
				process.exit(error.status);
			}
		}
	}
}