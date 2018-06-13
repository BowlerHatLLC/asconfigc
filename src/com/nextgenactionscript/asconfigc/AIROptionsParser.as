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
package com.nextgenactionscript.asconfigc
{
	import com.nextgenactionscript.asconfigc.utils.escapePath;

	public class AIROptionsParser
	{
		public static function parse(platform:String, debug:Boolean, applicationDescriptorPath:String, applicationContentPath:String, options:Object, result:Array = null):Array
		{
			if(result === null)
			{
				result = [];
			}
			result.push("-" + AIROptions.PACKAGE);

			//AIR_SIGNING_OPTIONS begin
			//these are *desktop* signing options only
			//mobile signing options must be specified later!
			if(platform === AIRPlatformType.AIR ||
				platform === AIRPlatformType.WINDOWS ||
				platform === AIRPlatformType.MAC)
			{
				if(AIROptions.SIGNING_OPTIONS in options &&
					!overridesOptionForPlatform(options, AIROptions.SIGNING_OPTIONS, platform))
				{
					parseSigningOptions(options[AIROptions.SIGNING_OPTIONS], debug, result);
				}
				else if(overridesOptionForPlatform(options, AIROptions.SIGNING_OPTIONS, platform))
				{
					//desktop captive runtime
					parseSigningOptions(options[platform][AIROptions.SIGNING_OPTIONS], debug, result);
				}
				else if(!(AIROptions.SIGNING_OPTIONS in options))
				{
					//desktop shared runtime, but signing options overridden for windows or mac
					if(process.platform === "darwin" &&
						overridesOptionForPlatform(options, AIROptions.SIGNING_OPTIONS, AIRPlatformType.MAC))
					{
						parseSigningOptions(options[AIRPlatformType.MAC][AIROptions.SIGNING_OPTIONS], debug, result);
					}
					else if(process.platform === "win32" &&
						overridesOptionForPlatform(options, AIROptions.SIGNING_OPTIONS, AIRPlatformType.WINDOWS))
					{
						parseSigningOptions(options[AIRPlatformType.WINDOWS][AIROptions.SIGNING_OPTIONS], debug, result);
					}
				}
			}
			//AIR_SIGNING_OPTIONS end

			if(overridesOptionForPlatform(options, AIROptions.TARGET, platform))
			{
				setValueWithoutAssignment(AIROptions.TARGET, options[platform][AIROptions.TARGET], result);
			}
			else if(AIROptions.TARGET in options)
			{
				setValueWithoutAssignment(AIROptions.TARGET, options[AIROptions.TARGET], result);
			}
			else
			{
				switch(platform)
				{
					case AIRPlatformType.ANDROID:
					{
						if(debug)
						{
							setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.APK_DEBUG, result);
						}
						else
						{
							setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.APK_CAPTIVE_RUNTIME, result);
						}
						break;
					}
					case AIRPlatformType.IOS:
					{
						if(debug)
						{
							setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.IPA_DEBUG, result);
						}
						else
						{
							setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.IPA_APP_STORE, result);
						}
						break;
					}
					case AIRPlatformType.IOS_SIMULATOR:
					{
						if(debug)
						{
							setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.IPA_DEBUG_INTERPRETER_SIMULATOR, result);
						}
						else
						{
							setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.IPA_TEST_INTERPRETER_SIMULATOR, result);
						}
						break;
					}
					case AIRPlatformType.WINDOWS:
					{
						//captive runtime
						setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.BUNDLE, result);
						break;
					}
					case AIRPlatformType.MAC:
					{
						//captive runtime
						setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.BUNDLE, result);
						break;
					}
					default:
					{
						//shared runtime
						setValueWithoutAssignment(AIROptions.TARGET, AIRTarget.AIR, result);
						break;
					}
				}
			}
			if(overridesOptionForPlatform(options, AIROptions.SAMPLER, platform))
			{
				setValueWithoutAssignment(AIROptions.SAMPLER, options[platform][AIROptions.SAMPLER], result);
			}
			if(overridesOptionForPlatform(options, AIROptions.HIDE_ANE_LIB_SYMBOLS, platform))
			{
				setValueWithoutAssignment(AIROptions.HIDE_ANE_LIB_SYMBOLS, options[platform][AIROptions.HIDE_ANE_LIB_SYMBOLS], result);
			}
			if(overridesOptionForPlatform(options, AIROptions.EMBED_BITCODE, platform))
			{
				setValueWithoutAssignment(AIROptions.EMBED_BITCODE, options[platform][AIROptions.EMBED_BITCODE], result);
			}

			//DEBUGGER_CONNECTION_OPTIONS begin
			if(debug && (platform === AIRPlatformType.ANDROID || platform === AIRPlatformType.IOS || platform === AIRPlatformType.IOS_SIMULATOR))
			{
				parseDebugOptions(options, platform, result);
			}
			//DEBUGGER_CONNECTION_OPTIONS end

			if(overridesOptionForPlatform(options, AIROptions.AIR_DOWNLOAD_URL, platform))
			{
				setValueWithoutAssignment(AIROptions.AIR_DOWNLOAD_URL, options[platform][AIROptions.AIR_DOWNLOAD_URL], result);
			}

			//NATIVE_SIGNING_OPTIONS begin
			//these are *mobile* signing options only
			//desktop signing options were already handled earlier
			if(platform === AIRPlatformType.ANDROID || platform === AIRPlatformType.IOS || platform === AIRPlatformType.IOS_SIMULATOR)
			{
				if(overridesOptionForPlatform(options, AIROptions.SIGNING_OPTIONS, platform))
				{
					parseSigningOptions(options[platform][AIROptions.SIGNING_OPTIONS], debug, result);
				}
				else if(AIROptions.SIGNING_OPTIONS in options)
				{
					parseSigningOptions(options[AIROptions.SIGNING_OPTIONS], debug, result);
				}
			}
			//NATIVE_SIGNING_OPTIONS end

			if(overridesOptionForPlatform(options, AIROptions.OUTPUT, platform))
			{
				var outputPath:String = options[platform][AIROptions.OUTPUT];
				outputPath = escapePath(outputPath, false);
				result.push(outputPath);
			}
			else if(AIROptions.OUTPUT in options)
			{
				outputPath = options[AIROptions.OUTPUT];
				outputPath = escapePath(outputPath, false);
				result.push(outputPath);
			}
			else
			{
				//output is not defined, so generate an appropriate file name based
				//on the content's file name
				outputPath = applicationContentPath;
				var dotIndex:int = outputPath.lastIndexOf(".");
				if(dotIndex != -1)
				{
					//remove the file extension, if it exists
				//adt will automatically add an extension, if necessary
					outputPath = outputPath.substring(0, dotIndex);
				}
				else
				{
					throw new Error("Cannot find Adobe AIR application output path.");
				}
				outputPath = escapePath(outputPath, false);
				result.push(outputPath);
			}
			
			result.push(escapePath(applicationDescriptorPath, false));

			if(overridesOptionForPlatform(options, AIROptions.PLATFORMSDK, platform))
			{
				setPathValueWithoutAssignment(AIROptions.PLATFORMSDK, options[platform][AIROptions.PLATFORMSDK], result);
			}
			if(overridesOptionForPlatform(options, AIROptions.ARCH, platform))
			{
				setValueWithoutAssignment(AIROptions.ARCH, options[platform][AIROptions.ARCH], result);
			}

			//FILE_OPTIONS begin
			if(overridesOptionForPlatform(options, AIROptions.FILES, platform))
			{
				parseFiles(options[platform][AIROptions.FILES], result);
			}
			else if(AIROptions.FILES in options)
			{
				parseFiles(options[AIROptions.FILES], result);
			}
			if(applicationContentPath !== path.basename(applicationContentPath))
			{
				result.push("-C");
				var dirname:String = path.dirname(applicationContentPath);
				dirname = escapePath(dirname, false);
				result.push(dirname);
				var basename:String = path.basename(applicationContentPath);
				basename = escapePath(basename, false);
				result.push(basename);
			}
			else
			{
				result.push(escapePath(applicationContentPath, false));
			}

			if(overridesOptionForPlatform(options, AIROptions.EXTDIR, platform))
			{
				parseExtdir(options[platform][AIROptions.EXTDIR], result);
			}
			else if(AIROptions.EXTDIR in options)
			{
				parseExtdir(options[AIROptions.EXTDIR], result);
			}
			//FILE_OPTIONS end
			
			//ANE_OPTIONS begin
			//ANE_OPTIONS end

			for(var key:String in options)
			{
				switch(key)
				{
					case AIRPlatformType.AIR:
					case AIRPlatformType.ANDROID:
					case AIRPlatformType.IOS:
					case AIRPlatformType.IOS_SIMULATOR:
					case AIRPlatformType.MAC:
					case AIRPlatformType.WINDOWS:

					case AIROptions.AIR_DOWNLOAD_URL:
					case AIROptions.ARCH:
					case AIROptions.EMBED_BITCODE:
					case AIROptions.EXTDIR:
					case AIROptions.FILES:
					case AIROptions.HIDE_ANE_LIB_SYMBOLS:
					case AIROptions.OUTPUT:
					case AIROptions.PLATFORMSDK:
					case AIROptions.SAMPLER:
					case AIROptions.SIGNING_OPTIONS:
					case AIROptions.TARGET:
					{
						break;
					}
					default:
					{
						throw new Error("Unknown AIR option: " + key);
					}
				}
			}
			return result;
		}

		/**
		 * @private
		 * Determines if an option is also specified for a specific platform.
		 */
		protected static function overridesOptionForPlatform(globalOptions:Object, optionName:String, platform:String):Boolean
		{
			return platform in globalOptions && optionName in globalOptions[platform];
		}
		
		public static function setValueWithoutAssignment(optionName:String, value:Object, result:Array):void
		{
			result.push("-" + optionName);
			result.push(value.toString());
		}
		
		public static function setPathValueWithoutAssignment(optionName:String, value:Object, result:Array):void
		{
			var pathValue:String = escapePath(value.toString(), false);
			result.push("-" + optionName);
			result.push(pathValue);
		}

		protected static function parseDebugOptions(airOptions:Object, platform:String, result:Array):void
		{
			var useDefault:Boolean = true;
			if(platform in airOptions)
			{
				var platformOptions:Object = airOptions[platform];
				if(AIROptions.CONNECT in platformOptions)
				{
					useDefault = false;
					var connectValue:Object = platformOptions[AIROptions.CONNECT];
					if(connectValue === true)
					{
						result.push("-" + AIROptions.CONNECT);
					}
					else if(connectValue !== false)
					{
						result.push("-" + AIROptions.CONNECT);
						result.push(connectValue);
					}
				}
				if(AIROptions.LISTEN in platformOptions)
				{
					useDefault = false
					var listenValue:Object = platformOptions[AIROptions.LISTEN];
					if(listenValue === true)
					{
						result.push("-" + AIROptions.LISTEN);
					}
					else if(listenValue !== false)
					{
						result.push("-" + AIROptions.LISTEN);
						result.push(listenValue);
					}
				}
			}
			if(useDefault)
			{
				//if both connect and listen options are omitted, use the
				//connect as the default with no host name.
				result.push("-" + AIROptions.CONNECT);
			}
		}

		protected static function parseExtdir(extdir:Array, result:Array):void
		{
			var count:int = extdir.length;
			for(var i:int = 0; i < count; i++)
			{
				var current:String = extdir[i];
				setPathValueWithoutAssignment(AIROptions.EXTDIR, current, result);
			}
		}

		protected static function parseFiles(files:Array, result:Array):void
		{
			var count:int = files.length;
			for(var i:int = 0; i < count; i++)
			{
				var file:Object = files[i];
				if(typeof file === "string")
				{
					result.push(file);
				}
				else
				{
					var srcFile:String = file[AIROptions.FILES_FILE];
					var destPath:String = file[AIROptions.FILES_PATH];
					addFile(srcFile, destPath, result);
				}
			}
		}

		protected static function addFile(srcFile:String, destPath:String, result:Array):void
		{
			if(fs.statSync(srcFile).isDirectory())
			{
				//Adobe's documentation for adt says that the -e option can
				//accept a directory, but it only seems to work with files, so
				//we read the directory contents to add the files individually
				destPath = path.join(destPath, path.basename(srcFile));
				var files:Array = fs.readdirSync(srcFile);
				var fileCount:int = files.length;
				for(var i:int = 0; i < fileCount; i++)
				{
					var file:String = path.join(srcFile, files[i]);
					addFile(file, destPath, result);
				}
				return;
			}
			result.push("-e");
			result.push(escapePath(srcFile, false));
			result.push(escapePath(destPath, false));
		}

		protected static function parseSigningOptions(signingOptions:Object, debug:Boolean, result:Array):void
		{
			if(SigningOptions.DEBUG in signingOptions && debug)
			{
				parseSigningOptions(signingOptions[SigningOptions.DEBUG], debug, result);
				return;
			}
			if(SigningOptions.RELEASE in signingOptions && !debug)
			{
				parseSigningOptions(signingOptions[SigningOptions.RELEASE], debug, result);
				return;
			}

			if(SigningOptions.PROVISIONING_PROFILE in signingOptions)
			{
				setPathValueWithoutAssignment(SigningOptions.PROVISIONING_PROFILE, signingOptions[SigningOptions.PROVISIONING_PROFILE], result);
			}
			if(SigningOptions.ALIAS in signingOptions)
			{
				setValueWithoutAssignment(SigningOptions.ALIAS, signingOptions[SigningOptions.ALIAS], result);
			}
			if(SigningOptions.STORETYPE in signingOptions)
			{
				setValueWithoutAssignment(SigningOptions.STORETYPE, signingOptions[SigningOptions.STORETYPE], result);
			}
			if(SigningOptions.KEYSTORE in signingOptions)
			{
				setPathValueWithoutAssignment(SigningOptions.KEYSTORE, signingOptions[SigningOptions.KEYSTORE], result);
			}
			if(SigningOptions.PROVIDER_NAME in signingOptions)
			{
				setValueWithoutAssignment(SigningOptions.PROVIDER_NAME, signingOptions[SigningOptions.PROVIDER_NAME], result);
			}
			if(SigningOptions.TSA in signingOptions)
			{
				setValueWithoutAssignment(SigningOptions.TSA, signingOptions[SigningOptions.TSA], result);
			}
			for(var key:String in signingOptions)
			{
				switch(key)
				{
					case SigningOptions.ALIAS:
					case SigningOptions.STORETYPE:
					case SigningOptions.KEYSTORE:
					case SigningOptions.PROVIDER_NAME:
					case SigningOptions.TSA:
					case SigningOptions.PROVISIONING_PROFILE:
					{
						break;
					}
					default:
					{
						throw new Error("Unknown signing option: " + key);
					}
				}
			}
		}
	}
}