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
package com.as3mxml.asconfigc
{
	import com.as3mxml.asconfigc.utils.findOutputFileName;

	public class HTMLTemplateOptionsParser
	{
		public static function parse(compilerOptions:Object, mainFile:String, outputPath:String):Object
		{
			var result:Object = {};
			
			if(compilerOptions != null && CompilerOptions.DEFAULT_SIZE in compilerOptions)
			{
				var defaultSizeJSON:Object = compilerOptions[CompilerOptions.DEFAULT_SIZE];
				result[HTMLTemplateOptions.WIDTH] = defaultSizeJSON[CompilerOptions.DEFAULT_SIZE__WIDTH];
				result[HTMLTemplateOptions.HEIGHT] = defaultSizeJSON[CompilerOptions.DEFAULT_SIZE__HEIGHT];
			}
			else
			{
				result[HTMLTemplateOptions.WIDTH] = "100%";
				result[HTMLTemplateOptions.HEIGHT] = "100%";
			}
			
			if(compilerOptions != null && CompilerOptions.DEFAULT_BACKGROUND_COLOR in compilerOptions)
			{
				result[HTMLTemplateOptions.BGCOLOR] = compilerOptions[CompilerOptions.DEFAULT_BACKGROUND_COLOR];
			}
			else
			{
				result[HTMLTemplateOptions.BGCOLOR] = "#ffffff";
			}
			
			if(compilerOptions != null && CompilerOptions.TARGET_PLAYER in compilerOptions)
			{
				var targetPlayer:String = compilerOptions[CompilerOptions.TARGET_PLAYER];
				var parts:Array = targetPlayer.split(".");
				result[HTMLTemplateOptions.VERSION_MAJOR] = parts[0];
				if(parts.length > 1)
				{
					result[HTMLTemplateOptions.VERSION_MINOR] = parts[1];
				}
				else
				{
					result[HTMLTemplateOptions.VERSION_MINOR] = "0";
				}
				if(parts.length > 2)
				{
					result[HTMLTemplateOptions.VERSION_REVISION] = parts[2];
				}
				else
				{
					result[HTMLTemplateOptions.VERSION_REVISION] = "0";
				}
			}
			else
			{
				//TODO: get the default target-player value from the SDK
				result[HTMLTemplateOptions.VERSION_MAJOR] = "9";
				result[HTMLTemplateOptions.VERSION_MINOR] = "0";
				result[HTMLTemplateOptions.VERSION_REVISION] = "124";
			}

			var outputFileName:String = findOutputFileName(mainFile, outputPath);
			if(outputFileName)
			{
				var swfName:String = outputFileName.substr(0, outputFileName.length - path.extname(outputFileName).length);
				result[HTMLTemplateOptions.SWF] = swfName;
				if(mainFile != null)
				{
					var mainFileName:String = path.basename(mainFile);
					mainFileName = mainFileName.substr(0, mainFileName.length - path.extname(mainFileName).length);
					result[HTMLTemplateOptions.APPLICATION] = mainFileName;
				}
				else
				{
					result[HTMLTemplateOptions.APPLICATION] = swfName;
				}
			}
			else
			{
					result[HTMLTemplateOptions.APPLICATION] = "";
			}
			
			result[HTMLTemplateOptions.EXPRESS_INSTALL_SWF] = "playerProductInstall.swf";
			result[HTMLTemplateOptions.USE_BROWSER_HISTORY] = "--";
			//TODO: get the title token value from the main MXML application
			result[HTMLTemplateOptions.TITLE] = "";

			return result;
		}
	}
}