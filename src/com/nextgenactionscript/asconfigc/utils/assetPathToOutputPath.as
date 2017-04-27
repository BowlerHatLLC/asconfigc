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
	public function assetPathToOutputPath(assetPath:String, mainFile:String, sourcePaths:Vector.<String>, outputDir:String):String
	{
		if(sourcePaths === null)
		{
			sourcePaths = new <String>[];
		}
		else
		{
			//make a copy because we might modify it
			sourcePaths = sourcePaths.slice();
		}
		if(mainFile !== null)
		{
			//the parent directory of the main file is automatically added as a
			//source path by the compiler
			var mainPath:String = path.dirname(mainFile);
			if(sourcePaths.indexOf(mainPath) === -1)
			{
				sourcePaths.push(mainPath);
			}
		}
		var relativePath:String = null;
		var sourcePathCount:int = sourcePaths.length;
		for(var i:int = 0; i < sourcePathCount; i++)
		{
			var sourcePath:String = sourcePaths[i];
			//get the absolute path for each of the source paths
			sourcePath = path.resolve(sourcePath);
			console.log()
			if(assetPath.startsWith(sourcePath))
			{
				relativePath = path.relative(sourcePath, assetPath);
				break;
			}
		}
		if(relativePath === null)
		{
			throw new Error("Could not find asset in source path: " + assetPath);
		}
		return path.resolve(outputDir, relativePath);
	}
}