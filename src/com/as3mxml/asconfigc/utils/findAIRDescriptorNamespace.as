/*
Copyright 2016-2023 Bowler Hat LLC

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
	public function findAIRDescriptorNamespace(airDescriptorContents:String):String
	{
		if (!airDescriptorContents) {
			return null;
		}
		var startIndex:int = airDescriptorContents.indexOf(AIR_NAMESPACE_PREFIX);
		if (startIndex == -1) {
			return null;
		}
		startIndex += AIR_NAMESPACE_PREFIX.length;
		var endIndex:int = airDescriptorContents.indexOf("\"", startIndex);
		if (endIndex == -1) {
			return null;
		}
		return airDescriptorContents.substring(startIndex, endIndex);
	}
}

const AIR_NAMESPACE_PREFIX:String = "<application xmlns=\"";