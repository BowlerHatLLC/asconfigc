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
package com.as3mxml.utils
{
	import com.as3mxml.asconfigc.AIROptions;
	import com.as3mxml.asconfigc.AIRPlatformType;
	import com.as3mxml.asconfigc.ASConfigFields;
	import com.as3mxml.asconfigc.CompilerOptions;

	/**
	 * Utilities for parsing asconfig.json files.
	 */
	public class ConfigUtils
	{
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
				if(key === ASConfigFields.EXTENDS)
				{
					//safe to skip
					return;
				}
				var hasConfig:Boolean = configData.hasOwnProperty(key);
				var hasBase:Boolean = baseConfigData.hasOwnProperty(key);
				if(hasConfig && hasBase)
				{
					if(key === ASConfigFields.APPLICATION)
					{
						result[key] = mergeApplication(configData[key], baseConfigData[key]);
					}
					else if(key === ASConfigFields.COMPILER_OPTIONS)
					{
						result[key] = mergeCompilerOptions(configData[key], baseConfigData[key]);
					}
					else if(key === ASConfigFields.AIR_OPTIONS)
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
				for(var key:String in AIRPlatformType)
				{
					if(AIRPlatformType.hasOwnProperty(key))
					{
						result[key] = baseApplication;
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
			keys.forEach(function(value:String, key:Object, set:Set):void
			{
				var hasConfig:Boolean = airOptions.hasOwnProperty(key);
				var hasBase:Boolean = baseAIROptions.hasOwnProperty(key);
				if(hasConfig && hasBase)
				{
					if(handlePlatforms && AIRPlatformType.hasOwnProperty(key))
					{
						result[key] = mergeAIROptions(airOptions[key], baseAIROptions[key], false);
					}
					else if(key === AIROptions.FILES)
					{
						result[key] = mergeArrays(airOptions[key] as Array, baseAIROptions[key] as Array);
					}
					else if(key === AIROptions.EXTDIR)
					{
						result[key] = mergeArrays(airOptions[key] as Array, baseAIROptions[key] as Array);
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
	}
}