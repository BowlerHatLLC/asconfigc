/*
Copyright 2016 Bowler Hat LLC

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
					this.printUsage();
					process.exit(0);
				}
			}
			process.chdir(path.dirname(this._configFilePath));

			this.parseConfig();
			//validate the SDK after knowing if we're building SWF or JS
			//because JS has stricter SDK requirements
			this.validateSDK();
			this.compileProject();
			process.exit(0);
		}

		private var _flexHome:String;
		private var _javaExecutable:String;
		private var _configFilePath:String;
		private var _projectType:String;
		private var _jsOutputType:String;
		private var _isSWF:Boolean;
		private var _args:Array;

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
		}

		private function parseArguments():void
		{
			var args:Object = minimist(process.argv.slice(2),
			{
				alias:
				{
					h: ["help"],
					p: ["project"],
					v: ["version"]
				}
			});
			for(var key:String in args)
			{
				switch(key)
				{
					case "h":
					case "p":
					case "v":
					{
						//ignore aliases
						break;
					}
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
				this.readCompilerOptions(compilerOptions);
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
				}
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
			if(CompilerOptions.JS_OUTPUT_TYPE in options)
			{
				//if it is set explicitly, then clear the default
				this._jsOutputType = null;
			}
			else if(this._jsOutputType)
			{
				this._args.push("--" + CompilerOptions.JS_OUTPUT_TYPE + "=" + this._jsOutputType);
			}
		}

		private function detectJavaScript(configName:String):void
		{
			switch(configName)
			{
				case ConfigName.JS:
				{
					this._jsOutputType = JSOutputType.JSC;
					this._isSWF = false;
					break;
				}
				case ConfigName.NODE:
				{
					this._jsOutputType = JSOutputType.NODE;
					this._isSWF = false;
					break;
				}
				case ConfigName.FLEX:
				case ConfigName.AIR:
				case ConfigName.AIRMOBILE:
				{
					this._jsOutputType = null;
					this._isSWF = true;
					break;
				}
				default:
				{
					this._jsOutputType = null;
				}
			}
		}

		private function validateSDK():void
		{
			if(this._flexHome)
			{
				//the --flexHome argument was used, so check if it's valid
				if(!ApacheFlexJSUtils.isValidSDK(this._flexHome))
				{
					if(!this._isSWF)
					{
						console.error("Path to Apache FlexJS SDK is not valid: " + this._flexHome);
						process.exit(1);
					}
					else if(!ActionScriptSDKUtils.isValidSDK(this._flexHome))
					{
						console.error("Path to SDK is not valid: " + this._flexHome);
						process.exit(1);
					}
				}
			}
			else
			{
				//the --flexHome argument wasn't passed in, so try to find an SDK
				this._flexHome = ApacheFlexJSUtils.findSDK();
				if(!this._flexHome && this._isSWF)
				{
					//if we're building a SWF, we don't necessarily need
					//FlexJS, so try to find another compatible SDK
					this._flexHome = ActionScriptSDKUtils.findSDK();
				}
				if(!this._flexHome)
				{
					console.error("SDK not found. Set FLEX_HOME, add to PATH, or use --flexHome option.");
					process.exit(1);
				}
			}
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
				if(this._isSWF)
				{
					jarPath = path.join(this._flexHome, "lib", jarName);
				}
				else
				{
					jarPath = path.join(this._flexHome, "js", "lib", jarName);
				}
				if(fs.existsSync(jarPath))
				{
					break;
				}
				jarPath = null;
			}
			return jarPath;
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
			this._args.unshift("+flexlib=" + frameworkPath);
			this._args.unshift(jarPath);
			this._args.unshift("-jar");
			this._args.unshift("-Dflexlib=" + frameworkPath);
			this._args.unshift("-Dflexcompiler=" + this._flexHome);
			try
			{
				var result:Object = child_process.execFileSync(this._javaExecutable, this._args,
				{
					stdio: "inherit",
					encoding: "utf8"
				});
			}
			catch(error:Error)
			{
				console.error("Failed to execute compiler. " + error);
				process.exit(1);
			}
		}
	}
}