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
package com.as3mxml.asconfigc
{
	import com.as3mxml.asconfigc.utils.OptionsFormatter;
	import com.as3mxml.asconfigc.utils.escapePath;

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
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.ADVANCED_TELEMETRY:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.BENCHMARK:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.DEBUG:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.DEBUG_PASSWORD:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.DEFAULT_BACKGROUND_COLOR:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.DEFAULT_FRAME_RATE:
					{
						OptionsFormatter.setValue(key, options[key], result);
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
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.EXTERNAL_LIBRARY_PATH:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.HTML_OUTPUT_FILENAME:
					{
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.HTML_TEMPLATE:
					{
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.INCLUDE_CLASSES:
					{
						OptionsFormatter.appendValues(key, options[key], result);
						break;
					}
					case CompilerOptions.INCLUDE_NAMESPACES:
					{
						OptionsFormatter.appendValues(key, options[key], result);
						break;
					}
					case CompilerOptions.INCLUDE_SOURCES:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_COMPILER_OPTION:
					{
						appendJSCompilerOptions(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_DEFAULT_INITIALIZERS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_EXTERNAL_LIBRARY_PATH:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_LIBRARY_PATH:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_OUTPUT:
					{
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_OUTPUT_TYPE:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.KEEP_AS3_METADATA:
					{
						OptionsFormatter.appendValues(key, options[key], result);
						break;
					}
					case CompilerOptions.KEEP_GENERATED_ACTIONSCRIPT:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.LIBRARY_PATH:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.LINK_REPORT:
					{
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.LOAD_CONFIG:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.LOCALE:
					{
						OptionsFormatter.setValues(key, options[key], result);
						break;
					}
					case CompilerOptions.NAMESPACE:
					{
						setNamespace(options[key], result);
						break;
					}
					case CompilerOptions.OPTIMIZE:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.OMIT_TRACE_STATEMENTS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.OUTPUT:
					{
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.PRELOADER:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.REMOVE_CIRCULARS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.SIZE_REPORT:
					{
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.SOURCE_MAP:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.SOURCE_PATH:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.STRICT:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.SWF_LIBRARY_PATH:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.SWF_VERSION:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.TARGET_PLAYER:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.TARGETS:
					{
						OptionsFormatter.setCommaArray(key, options[key], result);
						break;
					}
					case CompilerOptions.THEME:
					{
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.TOOLS_LOCALE:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.USE_DIRECT_BLIT:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.USE_GPU:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.USE_NETWORK:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.USE_RESOURCE_BUNDLE_METADATA:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.VERBOSE_STACKTRACES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.WARNINGS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.WARN_PUBLIC_VARS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
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

				var manifest:String = escapePath(currentValue.manifest.toString(), false);
				result.push("--" + CompilerOptions.NAMESPACE);
				result.push(currentValue.uri.toString());
				result.push(manifest);
			}
		}

		private static function appendJSCompilerOptions(optionName:String, values:Array, result:Array):void
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
				result.push("--" + optionName + "+=\"" + currentValue.toString() + "\"");
			}
		}

		private static function setDefaultSize(sizePair:Object, result:Array):void
		{
			result.push("--" + CompilerOptions.DEFAULT_SIZE);
			result.push(sizePair[CompilerOptions.DEFAULT_SIZE__WIDTH].toString());
			result.push(sizePair[CompilerOptions.DEFAULT_SIZE__HEIGHT].toString());
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