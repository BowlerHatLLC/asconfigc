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
	import com.as3mxml.asconfigc.utils.ConfigUtils;
	import com.as3mxml.asconfigc.utils.assetPathToOutputPath;
	import com.as3mxml.asconfigc.utils.escapePath;
	import com.as3mxml.asconfigc.utils.findAIRDescriptorOutputPath;
	import com.as3mxml.asconfigc.utils.findApplicationContent;
	import com.as3mxml.asconfigc.utils.findApplicationContentOutputPath;
	import com.as3mxml.asconfigc.utils.findOutputDirectory;
	import com.as3mxml.asconfigc.utils.findSourcePathAssets;
	import com.as3mxml.asconfigc.utils.folderContains;
	import com.as3mxml.asconfigc.utils.generateApplicationID;
	import com.as3mxml.asconfigc.utils.populateAdobeAIRDescriptorTemplateFile;
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

			this.findConfig();
			process.chdir(path.dirname(this._configFilePath));

			var configData:Object = this.loadConfig();
			if(this._printConfig)
			{
				console.info(JSON.stringify(configData, null, 2));
				process.exit(0);
			}
			this.parseConfig(configData);

			this.cleanProject();
			
			//java is required to run the compiler
			this.validateJava();
			//validate the SDK after parsing the config because we need to know
			//if we're building SWF or JS. JS has stricter SDK requirements.
			this.validateSDK();

			this.compileProject();
			this.copySourcePathAssets();
			this.copyHTMLTemplate();
			this.processAIRDescriptors();
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
		private var _configRequiresAIR:Boolean;
		private var _isSWFTargetOnly:Boolean;
		private var _outputIsJS:Boolean;
		private var _jsOutputType:String;
		private var _compilerArgs:Array;
		private var _additionalOptions:String;
		private var _airDescriptors:Vector.<String> = null;
		private var _outputPath:String = null;
		private var _files:Array = null;
		private var _mainFile:String = null;
		private var _forceDebug:* = undefined;
		private var _clean:Boolean = false;
		private var _printConfig:Boolean = false;
		private var _unpackageANEs:Boolean = false;
		private var _debugBuild:Boolean = false;
		private var _verbose:Boolean = false;
		private var _sourcePaths:Vector.<String> = null;
		private var _copySourcePathAssets:Boolean = false;
		private var _airPlatform:String = null;
		private var _storepass:String = null;
		private var _airArgs:Array;
		private var _compilerOptionsJSON:Object = null;
		private var _airOptionsJSON:Object = null;
		private var _htmlTemplate:String = null;
		private var _htmlTemplateOptions:Object = null;
		private var _jvmArgs:Array = null;

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
			console.info(" --clean                                             Clean the output directory. Will not build the project.");
			console.info(" --verbose                                           Displays more detailed output, including the full set of options passed to all programs.");
			console.info(" --jvmargs ARGS                                      (Advanced) Pass custom arguments to the Java virtual machine.");
			console.info(" --print-config                                      (Advanced) Prints the contents of the asconfig.json file used to build, including any extensions.");
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
					case "verbose":
					{
						//support both --verbose=true or simply --verbose
						var verboseValue:Object = args[key];
						if(typeof verboseValue === "string")
						{
							this._verbose = verboseValue === "true";
						}
						else
						{
							this._verbose = verboseValue as Boolean;
						}
						break;
					}
					case "jvmargs":
					{
						var jvmArgsValue:Object = args[key];
						if(typeof jvmArgsValue === "string")
						{
							var jvmArgs:String = jvmArgsValue as String;
							if(jvmArgs.startsWith("\"") && jvmArgs.endsWith("\""))
							{
								jvmArgs = jvmArgs.substr(1, jvmArgs.length - 2);
							}
							this._jvmArgs = jvmArgs.split(" ");
						}
						else
						{
							this._jvmArgs = null;
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
					case "print-config":
					{
						this._printConfig = true;
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
			return this.loadConfigFromPath(this._configFilePath, validate);
		}

		private function loadConfigFromPath(configPath:String, validate:Function):Object
		{
			if(this._verbose)
			{
				console.info("Configuration file: " + this._configFilePath);
			}
			if(this._verbose)
			{
				console.info("Reading configuration file...");
			}
			try
			{
				var configText:String = fs.readFileSync(configPath, "utf8") as String;
			}
			catch(error:Error)
			{
				console.error("Error: Cannot read file. " + configPath);
				process.exit(1);
			}
			if(this._verbose)
			{
				console.info("Parsing configuration file...");
			}
			try
			{
				var configData:Object = json5.parse(configText);
			}
			catch(error:Error)
			{
				console.error("Error: Invalid JSON in file. " + configPath);
				console.error(error);
				process.exit(1);
			}
			if(this._verbose)
			{
				console.info("Validating configuration file...");
			}
			if(!validate(configData))
			{
				console.error("Error: Invalid asconfig.json file. " + configPath);
				console.error(validate["errors"]);
				process.exit(1);
			}
			if(ASConfigFields.EXTENDS in configData)
			{
				var otherConfigPath:String = configData[ASConfigFields.EXTENDS];
				var otherConfigData:Object = this.loadConfigFromPath(otherConfigPath, validate);
				if(this._verbose)
				{
					console.info("Merging configuration files...");
				}
				configData = ConfigUtils.mergeConfigs(configData, otherConfigData);
			}
			return configData;
		}

		private function findConfig():void
		{
			if(this._configFilePath)
			{
				//already found from arguments
				return;
			}

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
		
		private function parseConfig(configData:Object):void
		{
			this._compilerArgs = [];
			this._airArgs = [];
			this._compilerOptionsJSON = null;
			this._airOptionsJSON = null;
			if(this._verbose)
			{
				console.info("Parsing configuration file...");
			}
			this._projectType = this.readProjectType(configData);
			if(ASConfigFields.CONFIG in configData)
			{
				var configName:String = configData[ASConfigFields.CONFIG] as String;
				this.detectConfigRequirements(configName);
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
				this._configRequiresAIR = true;
				this._airDescriptors = new <String>[];
				var application:Object = configData[ASConfigFields.APPLICATION]
				if(typeof application === "string")
				{
					//if it's a string, just use it as is for all platforms
					this._airDescriptors[0] = configData[ASConfigFields.APPLICATION];
				}
				else if(this._airPlatform)
				{
					//if it's an object, and we're packaging an AIR app, we need to
					//grab the descriptor for the platform we're targeting
					//we can ignore the rest
					if(application.hasOwnProperty(this._airPlatform))
					{
						this._airDescriptors[0] = application[this._airPlatform];
					}
				}
				else
				{
					//if it's an object, and we're compiling and not packaging an
					//AIR app, we need to use all of the descriptors
					var index:int = 0;
					for(var platformID:String in application)
					{
						this._airDescriptors[index] = application[platformID];
						index++;
					}
				}
				var descriptorCount:int = this._airDescriptors.length;
				for(var i:int = 0; i < descriptorCount; i++)
				{
					//if the path is relative, path.resolve() will give us the
					//absolute path
					var airDescriptor:String = path.resolve(this._airDescriptors[i]);
					this._airDescriptors[i] = airDescriptor;

					if(!fs.existsSync(airDescriptor) || fs.statSync(airDescriptor).isDirectory())
					{
						console.error("Adobe AIR application descriptor not found: " + airDescriptor);
						process.exit(1);
					}
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
			//mainClass must be parsed after files
			if(this._projectType === ProjectType.APP && ASConfigFields.MAIN_CLASS in configData)
			{
				var mainClass:String = configData[ASConfigFields.MAIN_CLASS];
				this._mainFile = ConfigUtils.resolveMainClass(mainClass, this._sourcePaths);
				if(this._mainFile === null)
				{
					console.error("Main class not found in source paths: " + mainClass);
					process.exit(1);
				}
				if(!this._files)
				{
					this._files = [];
				}
				this._files.push(this._mainFile);
			}
			if(ASConfigFields.AIR_OPTIONS in configData)
			{
				this._configRequiresAIR = true;
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
			if(ASConfigFields.ANIMATE_OPTIONS in configData)
			{
				console.error("The animateOptions field is not supported.");
				process.exit(1);
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
			var airDescriptor:String = null;
			if(this._airDescriptors && this._airDescriptors.length > 0)
			{
				airDescriptor = this._airDescriptors[0];
			}
			try
			{
				AIROptionsParser.parse(
					this._airPlatform,
					this._debugBuild,
					findAIRDescriptorOutputPath(this._mainFile, airDescriptor, this._outputPath, !this._outputIsJS),
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

		private function detectConfigRequirements(configName:String):void
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
				case ConfigName.AIR:
				{
					this._configRequiresAIR = true;
					break;
				}
				case ConfigName.AIRMOBILE:
				{
					this._configRequiresAIR = true;
					break;
				}
			}
		}

		private function validateJava():void
		{
			if(!this._javaExecutable)
			{
				this._javaExecutable = findJava();
				if(!this._javaExecutable)
				{
					console.error("Java not found. Cannot run compiler without Java.");
					process.exit(1);
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
			if(this._verbose)
			{
				console.info("SDK: " + this._sdkHome);
			}
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

			if(this._verbose)
			{
				console.info("Cleaning project...");
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
				if(this._verbose)
				{
					console.info("Deleting: " + outputDirectory);
				}
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
			if(this._verbose)
			{
				if(this._projectType == ProjectType.LIB)
				{
					console.info("Compiling library...");
				}
				else //app
				{
					console.info("Compiling application...");
				}
			}
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
			if(this._jvmArgs)
			{
				var jvmArgCount:int = this._jvmArgs.length;
				for(var i:int = jvmArgCount - 1; i >= 0; i--)
				{
					var jvmArg:String = this._jvmArgs[i] as String;
					this._compilerArgs.unshift(jvmArg);
				}
			}
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
					for(i = 0; i < filesCount; i++)
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
				if(this._verbose)
				{
					console.info(command);
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

		private function copyAsset(srcPath:String, targetPath:String):void
		{
			if(this._verbose)
			{
				console.info("Copying asset: " + srcPath);
			}
			var content:Object = fs.readFileSync(srcPath);
			mkdirp["sync"](path.dirname(targetPath));
			if(fs.existsSync(targetPath) && !fs["accessSync"](targetPath, fs["constants"].W_OK))
			{
				//is this the best way to do it? seems to be no way to make
				//writable without also modifying the others
				fs.chmodSync(targetPath, parseInt("766", 8));
			}
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
			if(this._airDescriptors)
			{
				var descriptorCount:int = this._airDescriptors.length;
				for(var i:int = 0; i < descriptorCount; i++)
				{
					excludes.push(this._airDescriptors[i]);
				}
			}
			var assetPaths:Array = findSourcePathAssets(this._mainFile, sourcePaths, outputDirectory, excludes);
			var assetCount:int = assetPaths.length;
			if(assetCount === 0)
			{
				return;
			}
			if(this._verbose)
			{
				console.info("Copying source path assets...");
			}
			for(i = 0; i < assetCount; i++)
			{
				var assetPath:String = assetPaths[i];
				if(this._outputIsJS)
				{
					var debugOutputDir:String = path.join(outputDirectory, "bin", "js-debug");
					var debugTargetPath:String = assetPathToOutputPath(assetPath, this._mainFile, sourcePaths, debugOutputDir);
					copyAsset(assetPath, debugTargetPath);
					if(!this._debugBuild)
					{
						var releaseOutputDir:String = path.join(outputDirectory, "bin", "js-release");
						var releaseTargetPath:String = assetPathToOutputPath(assetPath, this._mainFile, sourcePaths, releaseOutputDir);
						copyAsset(assetPath, releaseTargetPath);
					}
				}
				else //swf
				{
					var swfTargetPath:String = assetPathToOutputPath(assetPath, this._mainFile, sourcePaths, outputDirectory);
					copyAsset(assetPath, swfTargetPath);
				}
			}
		}

		private function copyHTMLTemplate():void
		{
			if(!this._htmlTemplate)
			{
				return;
			}
			if(this._verbose)
			{
				console.info("Copying HTML template...");
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

		private function processAIRDescriptors():void
		{
			if(!this._configRequiresAIR)
			{
				return;
			}

			if(this._verbose)
			{
				console.info("Processing Adobe AIR application descriptor(s)...");
			}
			
			var populateTemplate:Boolean = false;
			if(this._airDescriptors == null || this._airDescriptors.length == 0)
			{
				this._airDescriptors = new <String>[];
				var templatePath:String = path.resolve(this._sdkHome, "templates/air/descriptor-template.xml");
				this._airDescriptors.push(templatePath);
				populateTemplate = true;
				if(this._verbose)
				{
					console.info("Using template fallback: " + templatePath);
				}
			}
			var outputDir:String = findOutputDirectory(this._mainFile, this._outputPath, !this._outputIsJS);
			var contentValue:String = findApplicationContent(this._mainFile, this._outputPath, !this._outputIsJS);
			if(contentValue === null)
			{
				console.error("Failed to find content for application descriptor.");
				process.exit(1);
			}
			if(this._verbose)
			{
				console.info("Initial window content: " + contentValue);
			}
			var descriptorCount:int = this._airDescriptors.length;
			for(var i:int = 0; i < descriptorCount; i++)
			{
				var airDescriptor:String = this._airDescriptors[i];
				if(this._verbose)
				{
					console.info("Descriptor: " + airDescriptor);
				}
				var descriptor:String = fs.readFileSync(airDescriptor, "utf8") as String;
				if(populateTemplate)
				{
					var appID:String = generateApplicationID(this._mainFile, this._outputPath);
					if (appID == null)
					{
						console.error("Failed to generate application ID for Adobe AIR.");
						process.exit(1);
					}
					if(this._verbose)
					{
						console.info("Generated application ID: " + appID);
					}
					descriptor = populateAdobeAIRDescriptorTemplateFile(descriptor, appID);

					//clear this so that the name is based on the project name
					airDescriptor = null;
				}
				descriptor = descriptor.replace(/<content>.*<\/content>/, "<content>" + contentValue + "</content>");
				if(this._outputIsJS)
				{
					var debugOutputDir:String = path.join(outputDir, "bin", "js-debug");
					var debugDescriptorOutputPath:String = findAIRDescriptorOutputPath(this._mainFile, airDescriptor, debugOutputDir, false);
					mkdirp["sync"](path.dirname(debugDescriptorOutputPath));
					fs.writeFileSync(debugDescriptorOutputPath, descriptor, "utf8");
					if(!this._debugBuild)
					{
						var releaseOutputDir:String = path.join(outputDir, "bin", "js-release");
						var releaseDescriptorOutputPath:String = findAIRDescriptorOutputPath(this._mainFile, airDescriptor, releaseOutputDir, false);
						mkdirp["sync"](path.dirname(releaseDescriptorOutputPath));
						fs.writeFileSync(releaseDescriptorOutputPath, descriptor, "utf8");
					}
				}
				else //swf
				{
					var descriptorOutputPath:String = findAIRDescriptorOutputPath(this._mainFile, airDescriptor, this._outputPath, true);
					mkdirp["sync"](path.dirname(descriptorOutputPath));
					fs.writeFileSync(descriptorOutputPath, descriptor, "utf8");
				}
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

			var anes:Vector.<String> = new <String>[];
			if(CompilerOptions.LIBRARY_PATH in this._compilerOptionsJSON)
			{
				var libraryPathJSON:Array = this._compilerOptionsJSON[CompilerOptions.LIBRARY_PATH] as Array;
				this.findANEs(libraryPathJSON, anes);
			}
			if(CompilerOptions.EXTERNAL_LIBRARY_PATH in this._compilerOptionsJSON)
			{
				var externalLibraryPathJSON:Array = this._compilerOptionsJSON[CompilerOptions.EXTERNAL_LIBRARY_PATH] as Array;
				this.findANEs(externalLibraryPathJSON, anes);
			}

			var aneCount:int = anes.length;
			if(aneCount === 0)
			{
				return;
			}

			if(this._verbose)
			{
				console.info("Unpacking Adobe AIR native extensions...");
			}

			for(var i:int = 0; i < aneCount; i++)
			{
				var anePath:String = anes[i];
				this.unpackANE(anePath);
			}
		}

		private function findANEs(libraryPathJSON:Array, result:Vector.<String>):void
		{
			var pathCount:int = libraryPathJSON.length;
			for(var i:int = 0; i < pathCount; i++)
			{
				var libraryPath:String = libraryPathJSON[i] as String;
				libraryPath = path.resolve(libraryPath);
				if(libraryPath.endsWith(FILE_EXTENSION_ANE))
				{
					result.push(libraryPath);
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
							result.push(fullPath);
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

			if(this._verbose)
			{
				console.info("Unpacking: " + aneFilePath);
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
			if(fileCount === 0)
			{
				return;
			}

			if(this._verbose)
			{
				console.info("Copying Adobe AIR application files...")
			}

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
					srcFilePath = fileJSON[AIROptions.FILES__FILE];
					srcFilePath = path.resolve(srcFilePath);
					destFilePath = fileJSON[AIROptions.FILES__PATH];
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
							var debugTargetPath:String = assetPathToOutputPath(assetPath, null, assetDirList, debugOutputDir);
							copyAsset(assetPath, debugTargetPath);
							if(!this._debugBuild)
							{
								var releaseOutputDir:String = path.join(outputDir, "bin", "js-release");
								var releaseTargetPath:String = assetPathToOutputPath(assetPath, null, assetDirList, releaseOutputDir);
								copyAsset(assetPath, releaseTargetPath);
							}
						}
						else //swf
						{
							var swfTargetPath:String = assetPathToOutputPath(assetPath, null, assetDirList, outputDir);
							copyAsset(assetPath, swfTargetPath);
						}
					}
				}
				else //src not a directory
				{
					if(this._outputIsJS)
					{
						debugTargetPath = path.resolve(path.join(outputDir, "bin", "js-debug"), destFilePath);
						copyAsset(srcFilePath, debugTargetPath);
						if(!this._debugBuild)
						{
							releaseTargetPath = path.resolve(path.join(outputDir, "bin", "js-release"), destFilePath);
							copyAsset(srcFilePath, releaseTargetPath);
						}
					}
					else //swf
					{
						swfTargetPath = path.resolve(outputDir, destFilePath);
						copyAsset(srcFilePath, swfTargetPath);
					}
				}
			}
		}

		private function packageAIR():void
		{
			if(this._verbose)
			{
				console.info("Packaging Adobe AIR application...");
			}
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
				if(this._verbose)
				{
					console.info(command);
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