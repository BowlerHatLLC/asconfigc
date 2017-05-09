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
	public class CompilerOptionsParser
	{
		public static function parse(options:Object, result:Array = null):Array
		{
			if(result === null)
			{
				result = [];
			}
			for(var key:String in options)
			{
				switch(key)
				{
					case CompilerOptions.ACCESSIBLE:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.DEBUG:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.DEBUG_PASSWORD:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.DEFAULT_FRAME_RATE:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.DEFAULT_SIZE:
					{
						setDefaultSize(options[key], result);
						break;
					}
					case CompilerOptions.DEFINE:
					{
						setDefine(options[key], result);
						break;
					}
					case CompilerOptions.DUMP_CONFIG:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.EXTERNAL_LIBRARY_PATH:
					{
						appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.INCLUDE_CLASSES:
					{
						appendValues(key, options[key], result);
						break;
					}
					case CompilerOptions.INCLUDE_NAMESPACES:
					{
						appendValues(key, options[key], result);
						break;
					}
					case CompilerOptions.INCLUDE_SOURCES:
					{
						appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_OUTPUT_TYPE:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.KEEP_AS3_METADATA:
					{
						appendValues(key, options[key], result);
						break;
					}
					case CompilerOptions.LIBRARY_PATH:
					{
						appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.LINK_REPORT:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.LOAD_CONFIG:
					{
						appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.LOCALE:
					{
						setValues(key, options[key], result);
						break;
					}
					case CompilerOptions.NAMESPACE:
					{
						setNamespace(options[key], result);
						break;
					}
					case CompilerOptions.OPTIMIZE:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.OMIT_TRACE_STATEMENTS:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.OUTPUT:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.SOURCE_MAP:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.SOURCE_PATH:
					{
						appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.STRICT:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.SWF_VERSION:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.TARGET_PLAYER:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.TARGETS:
					{
						setCommaArray(key, options[key], result);
						break;
					}
					case CompilerOptions.TOOLS_LOCALE:
					{
						setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.USE_DIRECT_BLIT:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.USE_GPU:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.USE_NETWORK:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.USE_RESOURCE_BUNDLE_METADATA:
					{
						setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.VERBOSE_STACKTRACES:
					{
						setBoolean(key, options[key], result);
						break;
					}
					default:
					{
						throw new Error("Unknown compiler option: " + key);
					}
				}
			}
			return result;
		}

		private static function setValue(optionName:String, value:Object, result:Array):void
		{
			result.push("--" + optionName + "=" + value.toString());
		}

		private static function setBoolean(optionName:String, value:Boolean, result:Array):void
		{
			var boolString:String = value ? "true" : "false";
			result.push("--" + optionName + "=" + boolString);
		}

		private static function setValues(optionName:String, values:Array, result:Array):void
		{
			if(values.length === 0)
			{
				return;
			}
			var firstValue:Object = values[0];
			if(firstValue === null)
			{
				console.error("Value for option \"" + optionName + "\" not valid: " + firstValue);
				process.exit(1);
			}
			result.push("--" + optionName + "=" + firstValue.toString());
			appendValues(optionName, values.slice(1), result);
		}

		private static function setCommaArray(optionName:String, values:Array, result:Array):void
		{
			result.push("--" + optionName + "=" + values.join(","));
		}

		private static function setNamespace(values:Array, result:Array):void
		{
			if(values.length === 0)
			{
				return;
			}
			var valuesCount:int = values.length;
			for(var i:int = 0; i < valuesCount; i++)
			{
				var currentValue:Object = values[i];
				if(currentValue === null)
				{
					console.error("Value for option \"" + CompilerOptions.NAMESPACE + "\" not valid: " + currentValue);
					process.exit(1);
				}
				result.push("--" + CompilerOptions.NAMESPACE);
				result.push(currentValue.uri.toString());
				result.push(currentValue.manifest.toString());
			}
		}

		private static function appendValues(optionName:String, values:Array, result:Array):void
		{
			if(values.length === 0)
			{
				return;
			}
			var valuesCount:int = values.length;
			for(var i:int = 0; i < valuesCount; i++)
			{
				var currentValue:Object = values[i];
				if(currentValue === null)
				{
					console.error("Value for option \"" + optionName + "\" not valid: " + currentValue);
					process.exit(1);
				}
				result.push("--" + optionName + "+=" + currentValue.toString());
			}
		}

		private static function appendPaths(optionName:String, paths:Array, result:Array):void
		{
			var pathsCount:int = paths.length;
			for(var i:int = 0; i < pathsCount; i++)
			{
				var currentPath:String = paths[i];
				if(!fs.existsSync(currentPath))
				{
					console.error("Path for option \"" + optionName + "\" not found: " + currentPath);
					process.exit(1);
				}
				if(currentPath.indexOf(" ") !== -1)
				{
					result.push("--" + optionName + "+=\"" + currentPath + "\"");
				}
				else
				{
					result.push("--" + optionName + "+=" + currentPath);
				}
			}
		}

		private static function setDefaultSize(sizePair:Object, result:Array):void
		{
			result.push("--" + CompilerOptions.DEFAULT_SIZE);
			result.push(sizePair.width.toString());
			result.push(sizePair.height.toString());
		}

		private static function setDefine(values:Array, result:Array):void
		{
			if(values.length === 0)
			{
				return;
			}
			var valuesCount:int = values.length;
			for(var i:int = 0; i < valuesCount; i++)
			{
				var currentValue:Object = values[i];
				if(currentValue === null)
				{
					console.error("Value for option \"" + CompilerOptions.DEFINE + "\" not valid: " + currentValue);
					process.exit(1);
				}
				var defineName:String = currentValue.name.toString();
				var defineValue:Object = currentValue.value;
				if(defineValue is String)
				{
					defineValue = defineValue.replace(/\"/g, "\\\"");
					defineValue = "\"" + defineValue + "\"";
				}
				result.push("--" + CompilerOptions.DEFINE + "+=" +
					defineName + "," + defineValue.toString());
			}
		}
	}
}