
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
package com.as3mxml.utils
{
	/**
	 * Attempts to find a Java executable by testing the JAVA_HOME
	 * environment variable followed by the PATH environment variable.
	 */
	public function findJava():String
	{
		var executableFile:String = "java";
		if(process.platform === "win32")
		{
			executableFile += ".exe";
		}

		if("JAVA_HOME" in process.env)
		{
			var javaHome:String = process.env["JAVA_HOME"];
			var javaPath:String = path.join(javaHome, "bin", executableFile);
			if(fs.existsSync(javaPath))
			{
				return javaPath;
			}
		}

		if("PATH" in process.env)
		{
			var paths:Array = process.env["PATH"].split(path.delimiter);
			var pathCount:int = paths.length;
			for(var i:int = 0; i < pathCount; i++)
			{
				var currentPath:String = paths[i];
				javaPath = path.join(currentPath, executableFile);
				if(fs.existsSync(javaPath))
				{
					return javaPath;
				}
			}
		}
		return null;
	}
}