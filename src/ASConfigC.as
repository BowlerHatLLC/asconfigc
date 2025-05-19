/*
Copyright 2016-2021 Bowler Hat LLC

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
	import com.as3mxml.asconfigc.AnimateOptions;
	import com.as3mxml.asconfigc.CompilerOptions;
	import com.as3mxml.asconfigc.CompilerOptionsParser;
	import com.as3mxml.asconfigc.ConfigName;
	import com.as3mxml.asconfigc.HTMLTemplateOptionsParser;
	import com.as3mxml.asconfigc.JSOutputType;
	import com.as3mxml.asconfigc.ModuleFields;
	import com.as3mxml.asconfigc.ProjectType;
	import com.as3mxml.asconfigc.SigningOptions;
	import com.as3mxml.asconfigc.Targets;
	import com.as3mxml.asconfigc.TopLevelFields;
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
	import com.as3mxml.asconfigc.utils.parseAdditionalOptions;
	import com.as3mxml.asconfigc.utils.populateAdobeAIRDescriptorTemplateFile;
	import com.as3mxml.asconfigc.utils.populateHTMLTemplateFile;
	import com.as3mxml.royale.utils.ApacheRoyaleUtils;
	import com.as3mxml.utils.ActionScriptSDKUtils;
	import com.as3mxml.utils.findJava;
	import com.as3mxml.asconfigc.utils.findAIRDescriptorNamespace;

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
		private static const FILE_NAME_ANIMATE_PUBLISH_LOG:String = "AnimateDocument.log";
		private static const FILE_NAME_ANIMATE_ERROR_LOG:String = "AnimateErrors.log";

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

		public static function buildWithArgs(args:Array):Promise
		{
			return new Promise(function(resolve:Function, reject:Function):void
			{
				try
				{
					new ASConfigC(args, resolve, reject);
				}
				catch(e:Error)
				{
					reject(e);
				}
			});
		}

		public function ASConfigC(args:Array, resolve:Function, reject:Function)
		{
			this._resolvePromise = resolve;
			this._rejectPromise = reject;

			this.parseArguments(args);

			if(this._printHelp)
			{
				this.printUsage();
				this._resolvePromise();
				return;
			}

			if(this._printVersion)
			{
				this.printVersion();
				this._resolvePromise();
				return;
			}

			this.findConfig();
			process.chdir(path.dirname(this._configFilePath));

			var configData:Object = this.loadConfig();
			if(this._printConfig)
			{
				console.info(JSON.stringify(configData, null, 2));
				this._resolvePromise();
				return;
			}
			this.parseConfig(configData);

			if(this._animateFile)
			{
				this.compileAnimateFile();
				this.prepareNativeExtensions();
				//compiling an Animate project is asynchronous, so we must wait
				//to resolve/reject the promise until that completes
			}
			else
			{
				//java is required to run the compiler
				this.validateJava();

				if(this._clean) {
					this.cleanProject();
					this._resolvePromise();
					return;
				}

				this.copySourcePathAssets();
				this.copyHTMLTemplate();
				this.processAIRDescriptors();
				this.copyAIRFiles();
				this.prepareNativeExtensions();
				this.compileProject();
				if(this._airPlatform !== null)
				{
					this.packageAIR();
				}
				this._resolvePromise();
			}
		}

		private var _resolvePromise:Function;
		private var _rejectPromise:Function;
		private var _printHelp:Boolean = false;
		private var _printVersion:Boolean = false;
		private var _sdkHome:String;
		private var _javaExecutable:String;
		private var _configFilePath:String;
		private var _projectType:String;
		private var _sdkIsRoyale:Boolean;
		private var _configRequiresRoyale:Boolean;
		private var _configRequiresAIR:Boolean;
		private var _isSWFTargetOnly:Boolean;
		private var _outputIsJS:Boolean;
		private var _compilerArgs:Array;
		private var _allModuleCompilerArgs:Array;
		private var _allWorkerCompilerArgs:Array;
		private var _airDescriptors:Vector.<String> = null;
		private var _swfOutputPath:String = null;
		private var _jsOutputPath:String = ".";
		private var _outputPathForTarget:String = null;
		private var _moduleOutputPaths:Array;
		private var _workerOutputPaths:Array;
		private var _mainFile:String = null;
		private var _forceDebug:* = undefined;
		private var _clean:Boolean = false;
		private var _watch:Boolean = false;
		private var _printConfig:Boolean = false;
		private var _unpackageANEs:Boolean = false;
		private var _animateFile:String = null;
		private var _animatePath:String = null;
		private var _publishAnimate:Boolean = false;
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
			console.info(" --air PLATFORM                                      Package the project as an Adobe AIR application. The allowed platforms include `android`, `ios`, `windows`, `mac`, `bundle`, and `air`.");
			console.info(" --storepass PASSWORD                                The password used when signing and packaging an Adobe AIR application. If not specified, prompts for the password.");
			console.info(" --unpackage-anes                                    Unpackage native extensions to the output directory for the Adobe AIR simulator.");
			console.info(" --animate FILE                                      Specify the path to the Adobe Animate executable.");
			console.info(" --publish-animate                                   Publish Adobe Animate document, instead of only exporting the SWF.");
			console.info(" --clean                                             Clean the output directory. Will not build the project.");
			console.info(" --watch                                             Watch for file system changes and rebuild if detected (Royale only).");
			console.info(" --verbose                                           Displays more detailed output, including the full set of options passed to all programs.");
			console.info(" --jvmargs ARGS                                      (Advanced) Pass custom arguments to the Java virtual machine.");
			console.info(" --print-config                                      (Advanced) Prints the contents of the asconfig.json file used to build, including any extensions.");
		}

		private function parseArguments(rawArgs:Array):void
		{
			var args:Object = minimist(rawArgs);
			for(var key:String in args)
			{
				switch(key)
				{
					case "_":
					{
						var value:String = String(args[key]);
						if(value)
						{
							throw new Error("Unknown argument: " + value);
						}
						break;
					}
					case "h":
					case "help":
					{
						this._printHelp = true;
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
							throw new Error("Project directory or JSON file not found: " + projectPath);
						}
						if(fs.existsSync(projectPath) && fs.statSync(projectPath).isDirectory())
						{
							var configFilePath:String = path.resolve(projectPath, ASCONFIG_JSON);
							if(!fs.existsSync(configFilePath))
							{
								throw new Error("asconfig.json not found in directory: " + projectPath);
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
					case "watch":
					{
						//support both --watch=true or simply --watch
						var watchValue:Object = args[key];
						if(typeof watchValue === "string")
						{
							this._watch = watchValue === "true";
						}
						else
						{
							this._watch = watchValue as Boolean;
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
							if (this._airPlatform == "bundle")
							{
								if (process.platform === "darwin")
								{
									this._airPlatform = AIRPlatformType.MAC;
								}
								else if (process.platform === "win32")
								{
									this._airPlatform = AIRPlatformType.WINDOWS;
								}
								else if (process.platform === "linux")
								{
									this._airPlatform = AIRPlatformType.LINUX;
								}
							}
							if(this._airPlatform === AIRPlatformType.MAC &&
								process.platform !== "darwin")
							{
								throw new Error("Error: Adobe AIR applications for macOS cannot be packaged on this platorm.");
							}
							else if(this._airPlatform === AIRPlatformType.WINDOWS &&
								process.platform !== "win32")
							{
								throw new Error("Error: Adobe AIR applications for Windows cannot be packaged on this platform.");
							}
							else if(this._airPlatform === AIRPlatformType.LINUX &&
								process.platform !== "linux")
							{
								throw new Error("Error: Adobe AIR applications for Linux cannot be packaged on this platform.");
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
							throw new Error("Error: The storepass option requires the air option to be set too.");
						}
						this._storepass = String(args[key]);
						break;
					}
					case "unpackage-anes":
					{
						if(args["air"])
						{
							throw new Error("Error: The unpackage-anes option cannot be set when the air option is set.");
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
					case "animate":
					{
						this._animatePath = String(args[key]);
						break;
					}
					case "publish-animate":
					{
						//support both --publish-animate=true or simply --publish-animate
						var publishAnimateValue:Object = args[key];
						if(typeof publishAnimateValue === "string")
						{
							this._publishAnimate = publishAnimateValue === "true";
						}
						else
						{
							this._publishAnimate = publishAnimateValue as Boolean;
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
						this._printVersion = true;
						break;
					}
					default:
					{
						throw new Error("Unknown argument: " + key);
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
				throw new Error("Error: Cannot read schema file. " + schemaFilePath);
			}
			try
			{
				var schemaData:Object = JSON.parse(schemaText);
			}
			catch(error:Error)
			{
				throw new Error("Error: Invalid JSON in schema file. " + schemaFilePath + "\n" + String(error));
			}
			try
			{
				var ajv:Ajv = new Ajv({
					"allowUnionTypes": true
				});
				var validate:Function = ajv.compile(schemaData);
			}
			catch(error:Error)
			{
				throw new Error("Error: Invalid schema. " + schemaFilePath + "\n" + String(error));
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
				throw new Error("Error: Cannot read file. " + configPath);
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
				throw new Error("Error: Invalid JSON in file. " + configPath + "\n" + String(error));
			}
			if(this._verbose)
			{
				console.info("Validating configuration file...");
			}
			if(!validate(configData))
			{
				var errors:Array = validate["errors"];
				var errorsText:String = errors.reduce(function(accumulator:String, error:Object):String {
					return accumulator + "\n" + JSON.stringify(error);
				}, "");
				throw new Error("Error: Invalid asconfig.json file. " + configPath + errorsText);
			}
			if(TopLevelFields.EXTENDS in configData)
			{
				var otherConfigPath:String = configData[TopLevelFields.EXTENDS];
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
				throw new Error("asconfig.json not found in directory: " + process.cwd());
			}
		}
		
		private function parseConfig(configData:Object):void
		{
			this._compilerArgs = [];
			this._allModuleCompilerArgs = [];
			this._allWorkerCompilerArgs = [];
			this._airArgs = [];
			this._compilerOptionsJSON = null;
			this._airOptionsJSON = null;
			if(this._verbose)
			{
				console.info("Parsing configuration file...");
			}
			this._projectType = this.readProjectType(configData);
			if(TopLevelFields.CONFIG in configData)
			{
				var configName:String = configData[TopLevelFields.CONFIG] as String;
				this.detectConfigRequirements(configName);
				this._compilerArgs.push("+configname=" + configName);
			}
			if (this._watch)
			{
				this._debugBuild = true;
				this._configRequiresRoyale = true;
				if (this._forceDebug === false) {
					throw new Error("Watch requires debug to be true");
				}
				this._compilerArgs.push("--watch=true");
				this._compilerArgs.push("--debug=true");
			}
			else if (this._forceDebug === true || this._forceDebug === false)
			{
				this._debugBuild = this._forceDebug === true;
				this._compilerArgs.push("--" + CompilerOptions.DEBUG + "=" + this._debugBuild);
			}
			if(TopLevelFields.COMPILER_OPTIONS in configData)
			{
				this._compilerOptionsJSON = configData[TopLevelFields.COMPILER_OPTIONS];
				if(this._watch || this._forceDebug === true || this._forceDebug === false)
				{
					//ignore the debug option when it is specified on the
					//command line
					delete this._compilerOptionsJSON[CompilerOptions.DEBUG];
				}
				this.readCompilerOptions(this._compilerOptionsJSON);
				if(this._compilerOptionsJSON.debug)
				{
					this._debugBuild = true;
				}
				if(CompilerOptions.SOURCE_PATH in this._compilerOptionsJSON)
				{
					this._sourcePaths = this._compilerOptionsJSON[CompilerOptions.SOURCE_PATH];
				}
				if(CompilerOptions.OUTPUT in this._compilerOptionsJSON)
				{
					this._swfOutputPath = this._compilerOptionsJSON[CompilerOptions.OUTPUT];
				}
				if(CompilerOptions.JS_OUTPUT in this._compilerOptionsJSON)
				{
					this._jsOutputPath = this._compilerOptionsJSON[CompilerOptions.JS_OUTPUT];
				}
			}
			if(TopLevelFields.ADDITIONAL_OPTIONS in configData)
			{
				var additionalOptions:Object = configData[TopLevelFields.ADDITIONAL_OPTIONS];
				if(Array.isArray(additionalOptions))
				{
					this._compilerArgs = this._compilerArgs.concat(additionalOptions);
				}
				else
				{
					var additionalOptionsString:String = additionalOptions as String;
					if(additionalOptionsString != null)
					{
						var parsedOptions:Array = parseAdditionalOptions(additionalOptionsString);
						this._compilerArgs = this._compilerArgs.concat(parsedOptions);
					}
				}
			}
			if(TopLevelFields.APPLICATION in configData)
			{
				this._configRequiresAIR = true;
				this._airDescriptors = new <String>[];
				var application:Object = configData[TopLevelFields.APPLICATION]
				if(typeof application === "string")
				{
					//if it's a string, just use it as is for all platforms
					this._airDescriptors[0] = configData[TopLevelFields.APPLICATION];
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
						if (AIRPlatformType.WINDOWS === platformID
								&& process.platform !== "win32") {
							// AIR can't compile for Windows from macOS or
							// Linux, so we can skip this one
							continue;
						}
						if (AIRPlatformType.MAC === platformID
								&& process.platform !== "darwin") {
							// AIR can't compile for macOS from Windows or
							// Linux, so we can skip this one
							continue;
						}
						if (AIRPlatformType.LINUX === platformID
								&& process.platform !== "linux") {
							// AIR can't compile for Linux from Windows or
							// macOS, so we can skip this one
							continue;
						}
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
						throw new Error("Adobe AIR application descriptor not found: " + airDescriptor);
					}
				}
			}
			if(TopLevelFields.MODULES in configData)
			{
				this._moduleOutputPaths = [];
				var modules:Array = configData[TopLevelFields.MODULES];
				var templateModuleCompilerArgs:Array = this.duplicateCompilerOptionsForModuleOrWorker(this._compilerArgs);
				tmp.setGracefulCleanup();
				var linkReportPath:String = tmp.fileSync({"prefix": "asconfigc-link-report", "postfix": ".xml", "discardDescriptor": true}).name;
				var moduleCount:int = modules.length;
				for (i = 0; i < moduleCount; i++) {
					var module:Object = modules[i];
					var moduleCompilerArgs:Array = templateModuleCompilerArgs.slice();
					var output:String = "";
					if (ModuleFields.OUTPUT in module) {
						output = module[ModuleFields.OUTPUT];
						this._moduleOutputPaths.push(output);
					}
					if (output.length > 0) {
						moduleCompilerArgs.push("--" + CompilerOptions.OUTPUT + "=" + output);
					}
					var optimize:Boolean = false;
					if (ModuleFields.OPTIMIZE in module) {
						optimize = module[ModuleFields.OPTIMIZE] === true;
					}
					if (optimize) {
						moduleCompilerArgs
								.push("--" + CompilerOptions.LOAD_EXTERNS + "+=" + linkReportPath);
					}
					var file:String = module[ModuleFields.FILE];
					moduleCompilerArgs.push("--");
					moduleCompilerArgs.push(file);
					this._allModuleCompilerArgs.push(moduleCompilerArgs);
				}
				if (moduleCount > 0) {
					this._compilerArgs.push("--" + CompilerOptions.LINK_REPORT + "+=" + escapePath(linkReportPath));
				}
			}
			if(TopLevelFields.WORKERS in configData)
			{
				this._workerOutputPaths = [];
				var workers:Array = configData[TopLevelFields.WORKERS];
				var templateWorkerCompilerArgs:Array = this.duplicateCompilerOptionsForModuleOrWorker(this._compilerArgs);
				var workerCount:int = workers.length;
				for (i = 0; i < workerCount; i++) {
					var worker:Object = workers[i];
					var workerCompilerArgs:Array = templateWorkerCompilerArgs.slice();
					output = "";
					if (ModuleFields.OUTPUT in worker) {
						output = worker[ModuleFields.OUTPUT];
						this._workerOutputPaths.push(output);
					}
					if (output.length > 0) {
						workerCompilerArgs.push("--" + CompilerOptions.OUTPUT + "=" + output);
					}
					file = worker[ModuleFields.FILE];
					workerCompilerArgs.push("--");
					workerCompilerArgs.push(file);
					this._allWorkerCompilerArgs.push(workerCompilerArgs);
				}
			}
			//parse files before airOptions because the mainFile may be
			//needed to generate some file paths
			if(TopLevelFields.FILES in configData)
			{
				var files:Array = configData[TopLevelFields.FILES] as Array;
				if(this._projectType === ProjectType.LIB)
				{
					CompilerOptionsParser.parse(
					{
						"include-sources": files
					}, this._compilerArgs);
				}
				else //app
				{
					var fileCount:int = files.length;
					if(fileCount > 0)
					{
						//terminate previous options and start default options
						this._compilerArgs.push("--");
						//mainClass is preferred, but for backwards
						//compatibility, we need to support setting the entry
						//point with files too
						this._mainFile = files[fileCount - 1];
					}
					for (i = 0; i < fileCount; i++)
					{
						file = files[i];
						this._compilerArgs.push(escapePath(file));
					}
				}
			}
			//mainClass must be parsed after files
			if(this._projectType === ProjectType.APP && TopLevelFields.MAIN_CLASS in configData)
			{
				//if set already, clear it because we're going to replace it
				var hadMainFile:Boolean = this._mainFile !== null;
				var mainClass:String = configData[TopLevelFields.MAIN_CLASS];
				this._mainFile = ConfigUtils.resolveMainClass(mainClass, this._sourcePaths);
				if(this._mainFile === null)
				{
					throw new Error("Main class not found in source paths: " + mainClass);
				}
				if(!hadMainFile)
				{
					//terminate previous options and start default options
					this._compilerArgs.push("--");
				}
				this._compilerArgs.push(escapePath(this._mainFile));
			}
			if(TopLevelFields.ANIMATE_OPTIONS in configData)
			{
				var animateOptionsJSON:Object = configData[TopLevelFields.ANIMATE_OPTIONS];
				if(AnimateOptions.FILE in animateOptionsJSON)
				{
					this._animateFile = animateOptionsJSON[AnimateOptions.FILE];
					if(!path.isAbsolute(this._animateFile))
					{
						this._animateFile = path.resolve(process.cwd(), this._animateFile);
					}
				}
			}
			// before parsing AIR options, we need to figure out where the output
			// directory is, based on the SDK type and compiler options
			this.validateSDK();
			if(TopLevelFields.AIR_OPTIONS in configData)
			{
				this._configRequiresAIR = true;
				this._airOptionsJSON = configData[TopLevelFields.AIR_OPTIONS];
				this.readAIROptions(this._airOptionsJSON);
			}
			if(TopLevelFields.COPY_SOURCE_PATH_ASSETS in configData)
			{
				this._copySourcePathAssets = configData[TopLevelFields.COPY_SOURCE_PATH_ASSETS];
			}
			if(TopLevelFields.HTML_TEMPLATE in configData)
			{
				this._htmlTemplate = configData[TopLevelFields.HTML_TEMPLATE];

				//the HTML template needs to be parsed after files and outputPath have
				//both been parsed
				var compilerOptionsJSON:Object = null;
				if(TopLevelFields.COMPILER_OPTIONS in configData)
				{
					compilerOptionsJSON = configData[TopLevelFields.COMPILER_OPTIONS];
				}
				readHTMLTemplateOptions(compilerOptionsJSON);
			}
		}

		private function duplicateCompilerOptionsForModuleOrWorker(compilerArgs:Array):Array
		{
			return compilerArgs.filter(function(arg:String):Boolean
			{
				return !/^-{1,2}output\b/g.test(arg);
			});
		}

		private function readProjectType(configData:Object):String
		{
			if(TopLevelFields.TYPE in configData)
			{
				//this was already validated
				return configData[TopLevelFields.TYPE] as String;
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
				var errorText:String = "Error: Failed to parse compiler options.";
				if(this._verbose)
				{
					errorText += "\n" + String(error);
				}
				throw new Error(errorText);
			}
			//make sure that we require Royale, depending on which options are specified
			if(CompilerOptions.JS_OUTPUT_TYPE in options)
			{
				this._configRequiresRoyale = true;
			}
			if(CompilerOptions.TARGETS in options)
			{
				var targets:Array = options[CompilerOptions.TARGETS];
				this._configRequiresRoyale = true;
				this._isSWFTargetOnly = targets.length === 1 && targets.indexOf(Targets.SWF) !== -1;
			}
			if(CompilerOptions.SOURCE_MAP in options)
			{
				this._configRequiresRoyale = true;
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
					findAIRDescriptorOutputPath(this._mainFile, airDescriptor, this._outputPathForTarget, process.cwd(), !this._outputIsJS, this._debugBuild),
					findApplicationContentOutputPath(this._mainFile, this._outputPathForTarget, !this._outputIsJS),
					this._moduleOutputPaths,
					this._workerOutputPaths,
					options,
					this._airArgs);
			}
			catch(error:Error)
			{
				var errorText:String = "Error: Failed to parse Adobe AIR options.";
				if(this._verbose)
				{
					errorText += "\n" + String(error);
				}
				throw new Error(errorText);
			}
		}

		private function readHTMLTemplateOptions(compilerOptionsJSON:Object):void
		{
			try
			{
				this._htmlTemplateOptions = HTMLTemplateOptionsParser.parse(
					compilerOptionsJSON,
					this._mainFile,
					this._outputPathForTarget);
			}
			catch(error:Error)
			{
				var errorText:String = "Error: Failed to parse HTML template options.";
				if(this._verbose)
				{
					errorText += "\n" + String(error);
				}
				throw new Error(errorText);
			}
		}

		private function detectConfigRequirements(configName:String):void
		{
			switch(configName)
			{
				case ConfigName.JS:
				{
					this._configRequiresRoyale = true;
					break;
				}
				case ConfigName.NODE:
				{
					this._configRequiresRoyale = true;
					break;
				}
				case ConfigName.ROYALE:
				{
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

		private function compileAnimateFile():void
		{
			if(!this._animatePath)
			{
				throw new Error("Adobe Animate not found. Use --animate option.");
			}
			if(!fs.existsSync(this._animatePath))
			{
				throw new Error("Adobe Animate not found at path: " + this._animatePath);
			}

			var logPath:String = this.createAnimateLogFolder();

			var jsflPath:String = this.createJSFLScript();

			var command:String = escapePath(this._animatePath) + " " + escapePath(this._animateFile) + " " + escapePath(jsflPath);
			if(process.platform === "darwin")
			{
				command = "open -a " + command;
			}
			if(this._verbose)
			{
				console.info("Compiling Adobe Animate project...");
				console.info(command);
			}
			var result:Object = child_process.execSync(command,
			{
				stdio: "inherit",
				encoding: "utf8"
			});

			this.createAnimatePublishWatcher(logPath);
		}

		private function createAnimateLogFolder():String
		{			
			var logPath:String = null;
			if(process.platform === "win32")
			{
				logPath = path.resolve(process.env["LOCALAPPDATA"], path.join("Adobe", "vscode-as3mxml"));
			}
			else
			{
				logPath = path.resolve(os["homedir"](), path.join("Library", "Application Support", "Adobe", "vscode-as3mxml"));
			}
			if(logPath == null)
			{
				throw new Error("Failed to locate Adobe Animate logs at path: " + logPath);
			}
			//macOS seems to require these files to be manually deleted to detect
			//the appropriate create event
			if(fs.existsSync(logPath))
			{
				try
				{
					del.sync([logPath], {"force": true});
				}
				catch(e:Error)
				{
					var errorText:String = "Failed to delete Adobe Animate logs because an I/O exception occurred.";
					if(this._verbose)
					{
						errorText += "\n" + String(e);
					}
					throw new Error(errorText);
				}
			}
			mkdirp.sync(logPath);
			return logPath;
		}

		private function createJSFLScript():String
		{
			var jsflFileName:String = null;
			if(this._publishAnimate)
			{
				jsflFileName = this._debugBuild ? "publish-debug.jsfl" : "publish-release.jsfl";
			}
			else
			{
				jsflFileName = this._debugBuild ? "compile-debug.jsfl" : "compile-release.jsfl";
			}

			var jsflTemplatePath:String = path.resolve(path.dirname(__filename), path.join("..", "..", "jsfl", jsflFileName));

			tmp.setGracefulCleanup();
			var jsflPath:String = tmp.fileSync({"prefix": "vscode-as3mxml", "postfix": ".jsfl", "discardDescriptor": true}).name;

			var jsflContents:String = fs.readFileSync(jsflTemplatePath, "utf8") as String;

			var resolvedOutputPath:String = null;
			if(this._swfOutputPath == null)
			{
				var swfFileName:String = path.basename(this._animateFile);
				swfFileName = swfFileName.substr(0, swfFileName.length - path.extname(swfFileName).length);
				resolvedOutputPath = path.resolve(path.dirname(this._animateFile), swfFileName + ".swf");
			}
			else
			{
				resolvedOutputPath = path.resolve(this._swfOutputPath);
			}

			mkdirp.sync(path.dirname(resolvedOutputPath));

			var resolvedUri:String = url["pathToFileURL"](resolvedOutputPath);
			jsflContents = jsflContents.replace(/\$\{OUTPUT_URI\}/g, resolvedUri);
			fs.writeFileSync(jsflPath, jsflContents, "utf8");

			return jsflPath;
		}

		private function createAnimatePublishWatcher(pathToWatch:String):void
		{
			var errorLogPath:String = path.resolve(pathToWatch, FILE_NAME_ANIMATE_ERROR_LOG);
			var hasErrors:Boolean = false;
			var hasPublish:Boolean = false;
			chokidar.watch("*", {"cwd": pathToWatch, "awaitWriteFinish": true, "usePolling": true})
				.on("add", function(filePath:String):void
				{
					if(filePath == FILE_NAME_ANIMATE_ERROR_LOG)
					{
						hasErrors = true;
						if(hasPublish)
						{
							animateComplete(errorLogPath);
						}
					}
					else if(filePath === FILE_NAME_ANIMATE_PUBLISH_LOG)
					{
						hasPublish = true;
						if(hasErrors)
						{
							animateComplete(errorLogPath);
						}
					}
				});
		}

		private function animateComplete(errorLogPath:String):void
		{
			if(!fs.existsSync(errorLogPath))
			{
				this._resolvePromise();
				return;
			}
			try
			{
				var errorLogContents:String = fs.readFileSync(errorLogPath, "utf8") as String;
				//print the errors/warnings to the console
				if(errorLogContents.indexOf("**Error** ") !== -1)
				{
					this._rejectPromise(new Error(errorLogContents));
					return;
				}
				this._resolvePromise();
			}
			catch(e:Error)
			{
				this._rejectPromise("Failed to read Adobe Animate log at path: " + errorLogPath + "\n" + String(e));
			}
		}

		private function validateJava():void
		{
			if(!this._javaExecutable)
			{
				this._javaExecutable = findJava();
				if(!this._javaExecutable)
				{
					throw new Error("Java not found. Cannot run compiler without Java.");
				}
			}
		}

		private function validateSDK():void
		{
			if (this._animateFile)
			{
				return;
			}
			//the --sdk argument wasn't passed in, try to find an SDK
			if(!this._sdkHome)
			{
				this._sdkHome = ApacheRoyaleUtils.findSDK();
			}
			if(!this._sdkHome && !this._configRequiresRoyale)
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
				throw new Error("SDK not found. Set " + envHome + ", add to PATH, or use --sdk option.");
			}
			var royaleHome:String = ApacheRoyaleUtils.isValidSDK(this._sdkHome);
			if(royaleHome !== null)
			{
				this._sdkHome = royaleHome;
				this._sdkIsRoyale = true;
			}
			if(this._configRequiresRoyale && !this._sdkIsRoyale)
			{
				throw new Error("Configuration options in asconfig.json require Apache Royale. Path to SDK is not valid: " + this._sdkHome);
			}

			this._outputIsJS = this._sdkIsRoyale && !this._isSWFTargetOnly;
			this._outputPathForTarget = this._outputIsJS ? this._jsOutputPath : this._swfOutputPath;
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
				if(this._sdkIsRoyale)
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
			if(this._verbose)
			{
				console.info("Cleaning project...");
			}

			var outputDirectory:String = findOutputDirectory(this._mainFile, this._outputPathForTarget, !this._outputIsJS);
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

			if(this._moduleOutputPaths != null) {
				var moduleCount:int = this._moduleOutputPaths.length;
				for(var i:int = 0; i < moduleCount; i++)
				{
					var moduleOutputPath:String = this._moduleOutputPaths[i];
					if(fs.existsSync(moduleOutputPath))
					{
						try
						{
							fs.unlinkSync(moduleOutputPath);
						}
						catch(e:Error)
						{
							var errorText:String = "Failed to clean project because an I/O exception occurred while deleting file: " + moduleOutputPath;
							if(this._verbose)
							{
								errorText += "\n" + String(e);
							}
							throw new Error(errorText);
						}
					}
				}
			}

			if(this._workerOutputPaths != null) {
				var workerCount:int = this._workerOutputPaths.length;
				for(i = 0; i < workerCount; i++)
				{
					var workerOutputPath:String = this._workerOutputPaths[i];
					if(fs.existsSync(workerOutputPath))
					{
						try
						{
							fs.unlinkSync(workerOutputPath);
						}
						catch(e:Error)
						{
							errorText = "Failed to clean project because an I/O exception occurred while deleting file: " + workerOutputPath;
							if(this._verbose)
							{
								errorText += "\n" + String(e);
							}
							throw new Error(errorText);
						}
					}
				}
			}
		}

		private function cleanOutputDirectory(outputDirectory:String):void
		{
			var cwd:String = process.cwd();
			if(folderContains(outputDirectory, cwd))
			{
				throw new Error("Failed to clean project because the output path overlaps with the current working directory.");
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
					throw new Error("Failed to clean project because the output path overlaps with a source path.");
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
					del.sync([outputDirectory + "/*"], {"force": true});
				}
				catch(e:Error)
				{
					var errorText:String = "Failed to clean project because an I/O exception occurred.";
					if(this._verbose)
					{
						errorText += "\n" + String(e);
					}
					throw new Error(errorText);
				}
			}
		}

		private function compileProject():void
		{
			//compile workers first because they might be embedded in the app
			var workerCount:int = this._allWorkerCompilerArgs.length;
			for(var i:int = 0; i < workerCount; i++)
			{
				var workerCompilerArgs:Array = this._allWorkerCompilerArgs[i];
				compile(workerCompilerArgs);
			}
			compile(this._compilerArgs);
			//compile modules last because they might be optimized for the app
			var moduleCount:int = this._allModuleCompilerArgs.length;
			for(i = 0; i < moduleCount; i++)
			{
				var moduleCompilerArgs:Array = this._allModuleCompilerArgs[i];
				compile(moduleCompilerArgs);
			}
		}	

		private function compile(compilerArgs:Array):void
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
				throw new Error("Compiler not found in SDK. Expected: " + jarPath);
			}
			var frameworkPath:String = path.join(this._sdkHome, "frameworks");
			if(this._sdkIsRoyale)
			{
				//royale is a special case that has renamed many of the common
				//configuration options for the compiler
				compilerArgs.unshift("+royalelib=" + escapePath(frameworkPath));
				compilerArgs.unshift(escapePath(jarPath));
				compilerArgs.unshift("-jar");
				compilerArgs.unshift("-Droyalelib=" + escapePath(frameworkPath));
				compilerArgs.unshift("-Droyalecompiler=" + escapePath(this._sdkHome));
				//Royale requires this so that it doesn't changing the encoding of
				//UTF-8 characters and display ???? instead
				compilerArgs.unshift("-Dfile.encoding=UTF8");
			}
			else
			{
				//other SDKs all use the same options
				compilerArgs.unshift("+flexlib=" + escapePath(frameworkPath));
				compilerArgs.unshift(escapePath(jarPath));
				compilerArgs.unshift("-jar");
				compilerArgs.unshift("-Dflexlib=" + escapePath(frameworkPath));
				compilerArgs.unshift("-Dflexcompiler=" + escapePath(this._sdkHome));
			}
			if(process.platform === "darwin")
			{
				compilerArgs.unshift("-Dapple.awt.UIElement=true");
			}
			if(this._jvmArgs)
			{
				var jvmArgCount:int = this._jvmArgs.length;
				for(var i:int = jvmArgCount - 1; i >= 0; i--)
				{
					var jvmArg:String = this._jvmArgs[i] as String;
					compilerArgs.unshift(jvmArg);
				}
			}
			try
			{
				var command:String = escapePath(this._javaExecutable) + " " + compilerArgs.join(" ");
				if(process.platform !== "win32")
				{
					command = command.replace(/\$\{/g, "\\${");
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
					throw new Error("Failed to execute compiler. Exit code: " + error.code);
				}
				//while this means there was an error code from the executable,
				//probably from compilation errors
				throw new Error("Failed to execute compiler. Exit status: " + error.status);
			}
		}

		private function copyAsset(srcPath:String, targetPath:String):void
		{
			if(this._verbose)
			{
				console.info("Copying asset: " + srcPath);
			}
			var content:Object = fs.readFileSync(srcPath);
			mkdirp.sync(path.dirname(targetPath));
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
			var outputDirectory:String = findOutputDirectory(this._mainFile, this._outputPathForTarget, !this._outputIsJS);
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
				throw new Error("htmlTemplate directory does not exist: " + this._htmlTemplate);
			}
			if(!fs.statSync(this._htmlTemplate).isDirectory())
			{
				throw new Error("htmlTemplate path must be a directory. Invalid path: " + this._htmlTemplate);
			}
			var outputDir:String = findOutputDirectory(this._mainFile, this._outputPathForTarget, !this._outputIsJS);
			if (this._outputIsJS)
			{
				var debugOutputDir:String = path.join(outputDir, "bin", "js-debug");
				copyHTMLTemplateDirectory(this._htmlTemplate, debugOutputDir);
				if(!this._debugBuild)
				{
					var releaseOutputDir:String = path.join(outputDir, "bin", "js-release");
					copyHTMLTemplateDirectory(this._htmlTemplate, releaseOutputDir);
				}
			}
			else //swf
			{
				copyHTMLTemplateDirectory(this._htmlTemplate, outputDir);
			}
		}

		private function copyHTMLTemplateDirectory(inputDir:String, outputDir:String):void
		{
			mkdirp.sync(outputDir);
			if(!fs.existsSync(outputDir))
			{
				throw new Error("Failed to create output directory for HTML template: " + outputDir);
			}
			var files:Array = fs.readdirSync(inputDir);
			var fileCount:int = files.length;
			for(var i:int = 0; i < fileCount; i++)
			{
				var fileName:String = files[i];
				var inputFilePath:String = path.resolve(inputDir, fileName);
				var outputFilePath:String = path.resolve(outputDir, fileName);
				if(fs.existsSync(inputFilePath) && fs.statSync(inputFilePath).isDirectory())
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
						if (this._verbose)
						{
							console.info("Copying template asset: " + inputFilePath);
						}
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
							throw new Error("Failed to copy file: " + inputFilePath);
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
					throw new Error("Failed to copy file: " + inputFilePath);
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
			
			var templatePath:String = path.resolve(this._sdkHome, "templates/air/descriptor-template.xml");
			var templateNamespace:String = null;
			try
			{
				var templateContents:String = fs.readFileSync(templatePath, "utf8") as String;
				templateNamespace = findAIRDescriptorNamespace(templateContents);
			}
			catch(e:Object) {}
			var populateTemplate:Boolean = false;
			if(this._airDescriptors == null || this._airDescriptors.length == 0)
			{
				this._airDescriptors = new <String>[];
				this._airDescriptors.push(templatePath);
				populateTemplate = true;
				if(this._verbose)
				{
					console.info("Using template fallback: " + templatePath);
				}
			}
			var contentValue:String = findApplicationContent(this._mainFile, this._outputPathForTarget, !this._outputIsJS);
			if(contentValue === null)
			{
				throw new Error("Failed to find content for application descriptor.");
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
					var appID:String = generateApplicationID(this._mainFile, this._outputPathForTarget, process.cwd());
					if (appID == null)
					{
						throw new Error("Failed to generate application ID for Adobe AIR.");
					}
					if(this._verbose)
					{
						console.info("Generated application ID: " + appID);
					}
					descriptor = populateAdobeAIRDescriptorTemplateFile(descriptor, appID);

					//clear this so that the name is based on the project name
					airDescriptor = null;
				}
				// (?!\s*-->) ignores lines that are commented out
				descriptor = descriptor.replace(/<content>.*<\/content>(?!\s*-->)/, "<content>" + contentValue + "</content>");
				if (templateNamespace)
				{
					descriptor = descriptor.replace(/<application xmlns=".*?"/, "<application xmlns=\"" + templateNamespace + "\"");
				}
				if(this._outputIsJS)
				{
					var debugDescriptorOutputPath:String = findAIRDescriptorOutputPath(this._mainFile, airDescriptor, this._outputPathForTarget, process.cwd(), false, true);
					mkdirp.sync(path.dirname(debugDescriptorOutputPath));
					fs.writeFileSync(debugDescriptorOutputPath, descriptor, "utf8");
					if(!this._debugBuild)
					{
						var releaseDescriptorOutputPath:String = findAIRDescriptorOutputPath(this._mainFile, airDescriptor, this._outputPathForTarget, process.cwd(), false, false);
						mkdirp.sync(path.dirname(releaseDescriptorOutputPath));
						fs.writeFileSync(releaseDescriptorOutputPath, descriptor, "utf8");
					}
				}
				else //swf
				{
					var descriptorOutputPath:String = findAIRDescriptorOutputPath(this._mainFile, airDescriptor, this._outputPathForTarget, process.cwd(), true, this._debugBuild);
					mkdirp.sync(path.dirname(descriptorOutputPath));
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
				else if(fs.existsSync(libraryPath) && fs.statSync(libraryPath).isDirectory())
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
			if(fs.existsSync(aneFilePath) && fs.statSync(aneFilePath).isDirectory())
			{
				//this is either an ANE that's already unpacked
				//...or something else entirely
				return;
			}

			if(this._verbose)
			{
				console.info("Unpacking: " + aneFilePath);
			}

			var outputDir:String = findOutputDirectory(this._mainFile, this._outputPathForTarget, !this._outputIsJS);
			var unpackedAneDir:String = path.resolve(outputDir, FILE_NAME_UNPACKAGED_ANES);
			var currentAneDir:String = path.resolve(unpackedAneDir, path.basename(aneFilePath));		
			mkdirp.sync(currentAneDir);

			try
			{
				var zipFile:admZip = new admZip(aneFilePath);
				zipFile.extractAllTo(currentAneDir, true);
			}
			catch(error:Error)
			{
				throw new Error("Failed to copy Adobe AIR native extension from path: " + aneFilePath + ".");
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

			var outputDir:String = findOutputDirectory(this._mainFile, this._outputPathForTarget, !this._outputIsJS);
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
				if(!path.isAbsolute(srcFilePath))
				{
					srcFilePath = path.resolve(process.cwd(), srcFilePath);
				}
				var srcIsDir:Boolean = fs.existsSync(srcFilePath) && fs.statSync(srcFilePath).isDirectory();
				//ensures that path formatting is consistent
				destFilePath = path.relative(outputDir, path.resolve(outputDir, destFilePath));
				if(destFilePath.length === 0)
				{
					//if paths are equal, path.relative() returns an empty
					//string, but this is what we need to use later
					destFilePath = ".";
				}
				if(destFilePath.startsWith("..") || (!srcIsDir && destFilePath === "."))
				{
					throw new Error("Invalid destination path for file in Adobe AIR application. Source: " + srcFilePath + ", Destination: " + destFilePath);
				}

				if(srcIsDir)
				{
					var assetDirList:Vector.<String> = new <String>[srcFilePath];
					var assetPaths:Array = findSourcePathAssets(null, assetDirList, outputDir, null);
					var assetCount:int = assetPaths.length;
					for(var j:int = 0; j < assetCount; j++)
					{
						var assetPath:String = assetPaths[j];
						var relativeAssetPath:String = path.relative(srcFilePath, assetPath);
						if(this._outputIsJS)
						{
							var debugOutputDir:String = path.join(outputDir, "bin", "js-debug");
							debugOutputDir = path.resolve(debugOutputDir, destFilePath);
							var debugTargetPath:String = path.resolve(debugOutputDir, relativeAssetPath);
							copyAsset(assetPath, debugTargetPath);
							if(!this._debugBuild)
							{
								var releaseOutputDir:String = path.join(outputDir, "bin", "js-release");
								releaseOutputDir = path.resolve(releaseOutputDir, destFilePath);
								var releaseTargetPath:String = path.resolve(releaseOutputDir, relativeAssetPath);
								copyAsset(assetPath, releaseTargetPath);
							}
						}
						else //swf
						{
							var assetOutputDir:String = path.resolve(outputDir, destFilePath);
							var swfTargetPath:String = path.resolve(assetOutputDir, relativeAssetPath);
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
				throw new Error("AIR ADT not found in SDK. Expected: " + jarPath);
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
					throw new Error("Failed to execute AIR packager. Exit code: " + error.code);
				}
				//while this means there was an error code from the executable,
				//probably from compilation errors
				throw new Error("Failed to execute AIR packager. Exit status: " + error.status);
			}
		}
	}
}