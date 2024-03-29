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
package com.as3mxml.asconfigc.utils
{
	import com.as3mxml.asconfigc.AIROptions;
	import com.as3mxml.asconfigc.AIRPlatformType;
	import com.as3mxml.asconfigc.CompilerOptions;
	import com.as3mxml.asconfigc.SigningOptions;
	import com.as3mxml.asconfigc.TopLevelFields;

	/**
	 * Utilities for parsing asconfig.json files.
	 */
	public class ConfigUtils
	{
		private static const FILE_EXTENSION_AS:String = ".as";
		private static const FILE_EXTENSION_MXML:String = ".mxml";

		public static function resolveMainClass(mainClass:String, sourcePaths:Vector.<String>):String
		{
			var mainClassBasePath:String = mainClass.replace(/\./g, path.sep);
			if(sourcePaths != null)
			{
				var sourcePathCount:int = sourcePaths.length;
				for(var i:int = 0; i < sourcePathCount; i++)
				{
					var sourcePath:String = path.resolve(process.cwd(), sourcePaths[i]);
					var mainClassPath:String = path.resolve(sourcePath, mainClassBasePath + FILE_EXTENSION_AS);
					if(fs.existsSync(mainClassPath))
					{
						return mainClassPath;
					}
					mainClassPath = path.resolve(sourcePath, mainClassBasePath + FILE_EXTENSION_MXML);
					if(fs.existsSync(mainClassPath))
					{
						return mainClassPath;
					}
				}
			}
			//as a final fallback, try in the current working directory
			mainClassPath = path.resolve(process.cwd(), mainClassBasePath + FILE_EXTENSION_AS);
			if(fs.existsSync(mainClassPath))
			{
				return mainClassPath;
			}
			mainClassPath = path.resolve(process.cwd(), mainClassBasePath + FILE_EXTENSION_MXML);
			if(fs.existsSync(mainClassPath))
			{
				return mainClassPath;
			}
			return null;
		}

		public static function mergeConfigs(configData:Object, baseConfigData:Object):Object
		{
			var result:Object = {};
			var keys:Set = new Set();
			for(var key:String in baseConfigData)
			{
				if(baseConfigData.hasOwnProperty(key))
				{
					keys.add(key);
				}
			}
			for(key in configData)
			{
				if(configData.hasOwnProperty(key))
				{
					keys.add(key);
				}
			}
			keys.forEach(function(value:String, key:Object, set:Set):void
			{
				if(key === TopLevelFields.EXTENDS)
				{
					//safe to skip
					return;
				}
				var hasConfig:Boolean = configData.hasOwnProperty(key);
				var hasBase:Boolean = baseConfigData.hasOwnProperty(key);
				if(hasConfig && hasBase)
				{
					if(key === TopLevelFields.APPLICATION)
					{
						result[key] = mergeApplication(configData[key], baseConfigData[key]);
					}
					else if(key === TopLevelFields.COMPILER_OPTIONS)
					{
						result[key] = mergeCompilerOptions(configData[key], baseConfigData[key]);
					}
					else if(key === TopLevelFields.AIR_OPTIONS)
					{
						result[key] = mergeAIROptions(configData[key], baseConfigData[key], true);
					}
					else
					{
						result[key] = mergeObjectsSimple(configData[key], baseConfigData[key]);
					}
				}
				else if(hasConfig)
				{
					result[key] = configData[key];
				}
				else if(hasBase)
				{
					result[key] = baseConfigData[key];
				}
			});
			return result;
		}

		private static function mergeObjectsSimple(object:Object, baseObject:Object):Object
		{
			if(typeof object !== "object" || Array.isArray(object))
			{
				return object;
			}
			var result:Object = {};
			for(var key:String in baseObject)
			{
				if(baseObject.hasOwnProperty(key))
				{
					result[key] = baseObject[key];
				}
			}
			for(key in object)
			{
				if(object.hasOwnProperty(key))
				{
					result[key] = object[key];
				}
			}
			return result;
		}

		private static function mergeArrays(array:Array, baseArray:Array):Array
		{
			var result:Array = baseArray.slice();
			for each(var item:Object in array)
			{
				var isObject:Boolean = typeof item === "object";
				if(!result.find(function(existingItem:Object):Boolean
				{
					if(isObject)
					{
						for(var key:String in existingItem)
						{
							if(!(key in item) || item[key] !== existingItem[key])
							{
								return false;
							}
						}
						for(key in item)
						{
							if(!(key in existingItem) || item[key] !== existingItem[key])
							{
								return false;
							}
						}
						return true;
					}
					return item === existingItem;
				}))
				{
					result.push(item);
				}
			}
			return result;
		}

		private static function mergeArrayWithComparisonKey(array:Array, baseArray:Array, comparisonKey:String):Array
		{
			var result:Array = array.slice();
			var values:Set = new Set();
			for each(var pair:Object in array)
			{
				values.add(pair[comparisonKey]);
			}
			for each(pair in baseArray)
			{
				var valueToCompare:Object = pair[comparisonKey];
				if(values.has(valueToCompare))
				{
					//if we already added this value, skip it because its been
					//overridden in the main config
					continue;
				}
				result.push(pair);
			}
			return result;
		}

		private static function mergeCompilerOptions(compilerOptions:Object, baseCompilerOptions:Object):Object
		{
			var result:Object = {};
			for(var key:String in baseCompilerOptions)
			{
				if(baseCompilerOptions.hasOwnProperty(key))
				{
					result[key] = baseCompilerOptions[key];
				}
			}
			for(key in compilerOptions)
			{
				if(compilerOptions.hasOwnProperty(key))
				{
					var newValue:Object = compilerOptions[key];
					if(key === CompilerOptions.DEFINE)
					{
						if(result.hasOwnProperty(key))
						{
							var oldDefine:Object = result[key];
							result[key] = mergeArrayWithComparisonKey(newValue as Array, oldDefine as Array, CompilerOptions.DEFINE__NAME);
						}
						else
						{
							result[key] = newValue;
						}
					}
					else if(Array.isArray(newValue))
					{
						if(result.hasOwnProperty(key))
						{
							var oldArray:Object = result[key];
							if(Array.isArray(oldArray))
							{
								result[key] = mergeArrays(newValue as Array, oldArray as Array);
							}
							else
							{
								result[key] = newValue;
							}
						}
						else
						{
							result[key] = newValue;
						}
					}
					else
					{
						result[key] = newValue;
					}
				}
			}
			return result;
		}

		private static function mergeApplication(application:Object, baseApplication:Object):Object
		{
			if(typeof application === "string")
			{
				//overrides all fields
				return application;
			}
			var result:Object = {};
			if(typeof baseApplication === "string")
			{
				//royale 0.9.6 has a bug that misses fully-qualified package in
				//the hasOwnProperty() part. fixed in 0.9.7.
				var platformTypes:Object = AIRPlatformType;
				for(var key:String in platformTypes)
				{
					if(platformTypes.hasOwnProperty(key))
					{
						var keyValue:String = platformTypes[key] as String;
						result[keyValue] = baseApplication;
					}
				}
			}
			else
			{
				result = baseApplication;
			}
			return mergeObjectsSimple(application, result);
		}

		private static function mergeAIROptions(airOptions:Object, baseAIROptions:Object, handlePlatforms:Boolean):Object
		{
			var result:Object = {};
			var keys:Set = new Set();
			for(var key:String in baseAIROptions)
			{
				if(baseAIROptions.hasOwnProperty(key))
				{
					keys.add(key);
				}
			}
			for(key in airOptions)
			{
				if(airOptions.hasOwnProperty(key))
				{
					keys.add(key);
				}
			}
			var platforms:Set = new Set();
			//royale 0.9.6 has a bug that misses fully-qualified package in
			//the hasOwnProperty() part. fixed in 0.9.7.
			var platformTypes:Object = AIRPlatformType;
			for(key in platformTypes)
			{
				if(platformTypes.hasOwnProperty(key))
				{
					var keyValue:String = platformTypes[key] as String;
					platforms.add(keyValue);
				}
			}
			keys.forEach(function(value:String, key:Object, set:Set):void
			{
				var hasConfig:Boolean = airOptions.hasOwnProperty(key);
				var hasBase:Boolean = baseAIROptions.hasOwnProperty(key);
				if(hasConfig && hasBase)
				{
					var newValue:* = airOptions[key];
					var baseValue:* = baseAIROptions[key];
					if(handlePlatforms && platforms.has(key))
					{
						result[key] = mergeAIROptions(newValue, baseValue, false);
					}
					else if(key === AIROptions.FILES)
					{
						result[key] = mergeArrayWithComparisonKey(newValue as Array, baseValue as Array, AIROptions.FILES__PATH);
					}
					else if(key === AIROptions.SIGNING_OPTIONS)
					{
						result[key] = mergeSigningOptions(newValue, baseValue);
					}
					else if(Array.isArray(newValue) && Array.isArray(baseValue))
					{
						result[key] = mergeArrays(newValue as Array, baseValue as Array);
					}
					else
					{
						result[key] = mergeObjectsSimple(airOptions[key], baseAIROptions[key]);
					}
				}
				else if(hasConfig)
				{
					result[key] = airOptions[key];
				}
				else if(hasBase)
				{
					result[key] = baseAIROptions[key];
				}
			});
			return result;
		}

		private static function mergeSigningOptions(signingOptions:Object, baseSigningOptions:Object):Object
		{
			var hasDebug:Boolean = signingOptions.hasOwnProperty(SigningOptions.DEBUG);
			var hasRelease:Boolean = signingOptions.hasOwnProperty(SigningOptions.RELEASE);
			if(!hasDebug && !hasRelease)
			{
				//nothing to merge. fully overrides the base
				return signingOptions;
			}
			if(hasDebug && hasRelease)
			{
				//also fully overrides the base
				return signingOptions;
			}
			var hasBaseDebug:Boolean = baseSigningOptions.hasOwnProperty(SigningOptions.DEBUG);
			var hasBaseRelease:Boolean = baseSigningOptions.hasOwnProperty(SigningOptions.RELEASE);
			var result:Object = {};
			if(hasDebug)
			{
				result[SigningOptions.DEBUG] = signingOptions[SigningOptions.DEBUG];
			}
			else if(hasBaseDebug)
			{
				result[SigningOptions.DEBUG] = baseSigningOptions[SigningOptions.DEBUG];
			}
			else if(!hasBaseRelease)
			{
				result[SigningOptions.DEBUG] = baseSigningOptions;
			}
			if(hasRelease)
			{
				result[SigningOptions.RELEASE] = signingOptions[SigningOptions.RELEASE];
			}
			else if(hasBaseRelease)
			{
				result[SigningOptions.RELEASE] = baseSigningOptions[SigningOptions.RELEASE];
			}
			else if(!hasBaseDebug)
			{
				result[SigningOptions.RELEASE] = baseSigningOptions;
			}
			return result;
		}
	}
}