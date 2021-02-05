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
package com.as3mxml.asconfigc
{
	public class SigningOptions
	{
		public static const ALIAS:String = "alias";
		public static const STORETYPE:String = "storetype";
		public static const KEYSTORE:String = "keystore";
		public static const STOREPASS:String = "storepass";
		public static const PROVIDER_NAME:String = "providerName";
		public static const TSA:String = "tsa";
		public static const PROVISIONING_PROFILE:String = "provisioning-profile";

		//these aren't real options, but they might exist to provide separate
		//options for debug and relesae builds
		public static const DEBUG:String = "debug";
		public static const RELEASE:String = "release";
	}
}