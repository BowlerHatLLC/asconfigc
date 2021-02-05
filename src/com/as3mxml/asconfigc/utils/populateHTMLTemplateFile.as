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
	public function populateHTMLTemplateFile(content:String, options:Object):String
	{
		if(options === null)
		{
			return content;
		}
		for(var key:String in options)
		{
			var token:String = "${" + key + "}";
			var value:String = options[key];
			var index:int = content.indexOf(token);
			while(index !== -1)
			{
				content = content.substr(0, index) + value + content.substr(index + token.length);
				index = content.indexOf(token);
			}
		}
		return content;
	}
}