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
	public function findAIRDescriptorOutputPath(mainFile:String, airDescriptor:String, outputPath:String, isSWF:Boolean):String
	{
		var outputDir:String = findOutputDirectory(mainFile, outputPath, isSWF);
		var fileName:String = null;
		if(airDescriptor)
		{
			fileName = path.basename(airDescriptor);
		}
		else
		{
			var appID:String = generateApplicationID(mainFile, outputPath);
			if(appID == null)
			{
				return null;
			}
			fileName = appID + "-app.xml";
		}
		return path.resolve(outputDir, fileName);
	}
}