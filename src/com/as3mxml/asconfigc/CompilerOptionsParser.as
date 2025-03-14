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
					case CompilerOptions.ALLOW_ABSTRACT_CLASSES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.ALLOW_IMPORT_ALIASES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.ALLOW_PRIVATE_CONSTRUCTORS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.BENCHMARK:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.CONTEXT_ROOT:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.CONTRIBUTOR:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.CREATOR:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.DATE:
					{
						OptionsFormatter.setValue(key, options[key], result);
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
					case CompilerOptions.DEFAULTS_CSS_FILES:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.DEFINE:
					{
						setDefine(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_DEFINE:
					{
						setDefine(key, options[key], result);
						break;
					}
					case CompilerOptions.DESCRIPTION:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.DIRECTORY:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.DUMP_CONFIG:
					{
						OptionsFormatter.setPathValue(key, options[key], result);
						break;
					}
					case CompilerOptions.EXCLUDE_DEFAULTS_CSS_FILES:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.EXPORT_PUBLIC_SYMBOLS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.EXPORT_PROTECTED_SYMBOLS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.EXPORT_INTERNAL_SYMBOLS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
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
						OptionsFormatter.setCommaArray(key, options[key], result);
						break;
					}
					case CompilerOptions.INCLUDE_FILE:
					{
						parseIncludeFile(options[key], result);
						break;
					}
					case CompilerOptions.INCLUDES:
					{
						OptionsFormatter.appendValues(key, options[key], result);
						break;
					}
					case CompilerOptions.INCLUDE_LIBRARIES:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
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
					case CompilerOptions.INLINE_CONSTANTS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_COMPILER_OPTION:
					{
						appendJSCompilerOptions(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_COMPLEX_IMPLICIT_COERCIONS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_OUTPUT_OPTIMIZATION:
					{
						OptionsFormatter.setValues(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_DEFAULT_INITIALIZERS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_DYNAMIC_ACCESS_UNKNOWN_MEMBERS:
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
					case CompilerOptions.JS_VECTOR_EMULATION_CLASS:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_VECTOR_INDEX_CHECKS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.KEEP_ALL_TYPE_SELECTORS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
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
					case CompilerOptions.LANGUAGE:
					{
						OptionsFormatter.setValue(key, options[key], result);
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
					case CompilerOptions.LOAD_EXTERNS:
					{
						OptionsFormatter.appendPaths(key, options[key], result);
						break;
					}
					case CompilerOptions.JS_LOAD_CONFIG:
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
						appendNamespace(options[key], result);
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
					case CompilerOptions.PREVENT_RENAME_PUBLIC_SYMBOLS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PUBLIC_STATIC_METHODS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PUBLIC_INSTANCE_METHODS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PUBLIC_STATIC_VARIABLES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PUBLIC_INSTANCE_VARIABLES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PUBLIC_STATIC_ACCESSORS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PUBLIC_INSTANCE_ACCESSORS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PROTECTED_SYMBOLS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PROTECTED_STATIC_METHODS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PROTECTED_INSTANCE_METHODS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PROTECTED_STATIC_VARIABLES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PROTECTED_INSTANCE_VARIABLES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PROTECTED_STATIC_ACCESSORS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_PROTECTED_INSTANCE_ACCESSORS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_INTERNAL_SYMBOLS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_INTERNAL_STATIC_METHODS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_INTERNAL_INSTANCE_METHODS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_INTERNAL_STATIC_VARIABLES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_INTERNAL_INSTANCE_VARIABLES:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_INTERNAL_STATIC_ACCESSORS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PREVENT_RENAME_INTERNAL_INSTANCE_ACCESSORS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.PUBLISHER:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.REMOVE_CIRCULARS:
					{
						OptionsFormatter.setBoolean(key, options[key], result);
						break;
					}
					case CompilerOptions.SERVICES:
					{
						OptionsFormatter.setValue(key, options[key], result);
						break;
					}
					case CompilerOptions.SHOW_UNUSED_TYPE_SELECTOR_WARNINGS:
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
					case CompilerOptions.SOURCE_MAP_SOURCE_ROOT:
					{
						OptionsFormatter.setValue(key, options[key], result);
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
					case CompilerOptions.STRICT_IDENTIFIER_NAMES:
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
						var themeValue:Object = options[key];
						if(Array.isArray(themeValue))
						{
							OptionsFormatter.setThenAppendPaths(key, themeValue as Array, result);
						}
						else
						{
							OptionsFormatter.setPathValue(key, themeValue, result);
						}
						break;
					}
					case CompilerOptions.TITLE:
					{
						OptionsFormatter.setValue(key, options[key], result);
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

		private static function appendNamespace(values:Array, result:Array):void
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
					throw new Error("Value for option \"" + CompilerOptions.NAMESPACE + "\" not valid: " + currentValue);
				}

				var uri:String = currentValue[CompilerOptions.NAMESPACE__URI].toString();
				var manifest:String = escapePath(currentValue[CompilerOptions.NAMESPACE__MANIFEST].toString(), false);
				result.push("--" + CompilerOptions.NAMESPACE + "+=" + uri + "," + manifest);
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
					throw new Error("Value for option \"" + optionName + "\" not valid: " + currentValue);
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

		private static function setDefine(optionName:String, values:Array, result:Array):void
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
					throw new Error("Value for option \"" + CompilerOptions.DEFINE + "\" not valid: " + currentValue);
				}
				var defineName:String = currentValue[CompilerOptions.DEFINE__NAME].toString();
				var defineValue:Object = currentValue[CompilerOptions.DEFINE__VALUE];
				if(defineValue is String)
				{
					defineValue = defineValue.replace(/\"/g, "\\\"");
					defineValue = "\"" + defineValue + "\"";
				}
				result.push("--" + optionName + "+=" +
					defineName + "," + defineValue.toString());
			}
		}

		private static function parseIncludeFile(files:Array, result:Array):void
		{
			var count:int = files.length;
			for(var i:int = 0; i < count; i++)
			{
				var file:Object = files[i];
				var src:String = null;
				var dest:String = null;
				if(typeof file === "string")
				{
					src = file as String;
					dest = file as String;
				}
				else
				{
					src = file[CompilerOptions.INCLUDE_FILE__FILE];
					dest = file[CompilerOptions.INCLUDE_FILE__PATH];
				}
				src = escapePath(src, false);
				dest = escapePath(dest, false);
				result.push("--" + CompilerOptions.INCLUDE_FILE + "+=" + dest + "," + src);
			}
		}
	}
}