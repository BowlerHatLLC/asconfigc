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
	public function escapePath(pathToEscape:String, force:Boolean = true):String
	{
		if(!force && pathToEscape.indexOf(" ") === -1)
		{
			return pathToEscape;
		}
		//we don't want spaces in paths or they will be interpreted as new
		//command line options
		if(process.platform === "win32")
		{
			//on windows, paths may be wrapped in quotes to include spaces
			pathToEscape = "\"" + pathToEscape + "\"";
		}
		else
		{
			//on other platforms, a backslash preceding a string will
			//include the space in the path
			pathToEscape = pathToEscape.replace(/[ ]/g, "\\ ");
		}
		return pathToEscape;
	}
}