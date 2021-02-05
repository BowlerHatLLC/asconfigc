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
	public function findSourcePathAssets(mainFile:String, sourcePaths:Vector.<String>,
		outputDirectory:String, excludes:Vector.<String>):Array
	{
		var result:Set = new Set();
		if(!sourcePaths)
		{
			sourcePaths = new <String>[];
		}
		//make a copy because we might modify this array
		sourcePaths = sourcePaths.slice();
		if(mainFile)
		{
			//the parent directory of the main file is automatically added as a
			//source path by the compiler
			var mainPath:String = path.dirname(mainFile);
			if(sourcePaths.indexOf(mainPath) === -1)
			{
				sourcePaths.push(mainPath);
			}
		}
		var sourcePathsCount:int = sourcePaths.length;
		for(var i:int = 0; i < sourcePathsCount; i++)
		{
			//get the absolute path for each of the source paths
			sourcePaths[i] = path.resolve(sourcePaths[i]);
		}
		if(sourcePaths.indexOf(outputDirectory) !== -1)
		{
			console.warn("Assets in source path will not be copied because the output directory is a source path: " + outputDirectory);
			return Array.from(result);
		}
		if(excludes)
		{
			var excludesCount:int = excludes.length;
			for(i = 0; i < excludesCount; i++)
			{
				//get the absolute path for each of the excludes
				excludes[i] = path.resolve(excludes[i]);
			}
		}
		for(i = 0; i < sourcePathsCount; i++)
		{
			var sourcePath:String = sourcePaths[i];
			var files:Array = fs.readdirSync(sourcePath);
			var fileCount:int = files.length;
			for(var j:int = 0; j < fileCount; j++)
			{
				var file:String = files[j];
				var fullPath:String = path.resolve(sourcePath, file);
				if(fs.statSync(fullPath).isDirectory())
				{
					//add this directory to the source paths
					sourcePaths.push(fullPath);
					sourcePathsCount++;
					continue;
				}
				var extname:String = path.extname(file);
				if(extname === ".as" || extname === ".mxml")
				{
					continue;
				}
				if(excludes && excludes.indexOf(fullPath) !== -1)
				{
					continue;
				}
				result.add(fullPath);
			}
		}
		return Array.from(result);
	}
}