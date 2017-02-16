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
package com.nextgenactionscript.asconfigc
{
	public class ConfigName
	{
		public static const JS:String = "js";
		public static const NODE:String = "node";
		public static const FLEX:String = "flex";
		public static const AIR:String = "air";
		public static const AIRMOBILE:String = "airmobile";

		public static function validate(type:String):Boolean
		{
			if(type === JS || type === NODE || type === FLEX ||
				type === AIR || type === AIRMOBILE)
			{
				return true;
			}
			return false;
		}
	}
}