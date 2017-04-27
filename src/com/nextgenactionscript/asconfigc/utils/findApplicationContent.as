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
package com.nextgenactionscript.asconfigc.utils
{
	public function findApplicationContent(mainFile:String, outputPath:String, isSWF:Boolean):String
	{
		if(outputPath === null)
		{
			if(isSWF)
			{
				if(mainFile === null)
				{
					return null;
				}
				//replace .as or .mxml with .swf
				var fileName:String = path.basename(mainFile);
				return fileName.substr(0, fileName.length - path.extname(mainFile).length) + ".swf";
			}
			//An AIR app will load an HTML file as its main content
			return "index.html";
		}
		return path.basename(outputPath);
	}
}