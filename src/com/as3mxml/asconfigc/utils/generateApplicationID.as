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
	public function generateApplicationID(mainFile:String, outputPath:String, projectPath:String):String
	{
		var fileName:String = null;
		if(mainFile)
		{
			fileName = path.basename(mainFile);
		}
		if(!fileName && outputPath)
		{
			if (outputPath.endsWith(".swf")) {
				fileName = path.basename(outputPath);
			}
		}
		if (!fileName && projectPath) {
			if (fs.existsSync(projectPath) && fs.statSync(projectPath).isDirectory()) {
				projectPath = fs.realpathSync(projectPath);
				fileName = path.basename(projectPath);
			}
		}
		if(!fileName)
		{
			return null;
		}
		var extensionIndex:int = fileName.indexOf(".");
		if(extensionIndex == -1)
		{
			return fileName;
		}
		return fileName.substr(0, extensionIndex);
	}
}