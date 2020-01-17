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
package com.as3mxml.asconfigc.utils
{
	public class OptionsFormatter
	{
		public static function setValue(optionName:String, value:Object, result:Array):void
		{
			result.push("--" + optionName + "=" + value.toString());
		}

		public static function setBoolean(optionName:String, value:Boolean, result:Array):void
		{
			var boolString:String = value ? "true" : "false";
			result.push("--" + optionName + "=" + boolString);
		}

		public static function setPathValue(optionName:String, value:Object, result:Array):void
		{
			var pathValue:String = value.toString();
			pathValue = escapePath(pathValue, false);
			result.push("--" + optionName + "=" + pathValue);
		}

		public static function setValues(optionName:String, values:Array, result:Array):void
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

		public static function setCommaArray(optionName:String, values:Array, result:Array):void
		{
			result.push("--" + optionName + "=" + values.join(","));
		}

		public static function appendValues(optionName:String, values:Array, result:Array):void
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

		public static function appendPaths(optionName:String, paths:Array, result:Array):void
		{
			var pathsCount:int = paths.length;
			for(var i:int = 0; i < pathsCount; i++)
			{
				var currentPath:String = paths[i];
				currentPath = escapePath(currentPath, false);
				result.push("--" + optionName + "+=" + currentPath);
			}
		}

		public static function setThenAppendPaths(optionName:String, paths:Array, result:Array):void
		{
			var pathsCount:int = paths.length;
			for(var i:int = 0; i < pathsCount; i++)
			{
				var currentPath:String = paths[i];
				currentPath = escapePath(currentPath, false);
				if(i === 0)
				{
					result.push("--" + optionName + "=" + currentPath);
				}
				else
				{
					result.push("--" + optionName + "+=" + currentPath);
				}
			}
		}
	}
}