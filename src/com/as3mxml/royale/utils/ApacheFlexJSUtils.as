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
package com.as3mxml.royale.utils
{
	/**
	 * Utilities for finding and running executables from a legacy Apache FlexJS SDK.
	 */
	public class ApacheFlexJSUtils
	{
		/**
		 * @private
		 */
		private static const ASJSC:String = "asjsc";

		/**
		 * @private
		 */
		private static const ENV_FLEX_HOME:String = "FLEX_HOME";

		/**
		 * @private
		 */
		private static const ENV_PATH:String = "PATH";

		/**
		 * @private
		 */
		private static const NODE_MODULES:String = "node_modules";

		/**
		 * @private
		 */
		private static const NPM_PACKAGE_FLEXJS:String = "flexjs";

		/**
		 * @private
		 */
		private static const FLEX_SDK_DESCRIPTION:String = "flex-sdk-description.xml";

		/**
		 * Determines if a directory contains a valid legacy Apache FlexJS SDK.
		 */
		public static function isValidSDK(absolutePath:String):Boolean
		{
			if(!absolutePath)
			{
				return false;
			}
			var sdkDescriptionPath:String = path.join(absolutePath, FLEX_SDK_DESCRIPTION);
			if(!fs.existsSync(sdkDescriptionPath) || fs.statSync(sdkDescriptionPath).isDirectory())
			{
				return false;
			}
			//if asjsc does not exist, it may be a legacy Flex SDK or an older version
			//that is not supported
			var asjscPath:String = path.join(absolutePath, "js", "bin", ASJSC);
			if(!fs.existsSync(asjscPath) || fs.statSync(asjscPath).isDirectory())
			{
				return false;
			}
			return true;
		}

		/**
		 * Attempts to find a valid Apache FlexJS SDK by searching for the
		 * flexjs NPM module, testing the FLEX_HOME environment variable, and
		 * finally, testing the PATH environment variable.
		 */
		public static function findSDK():String
		{
			var sdkPath:String = null;

			//look for an npm module
			try
			{
				sdkPath = path.join(process.cwd(), NODE_MODULES, NPM_PACKAGE_FLEXJS);
				if(isValidSDK(sdkPath))
				{
					return sdkPath;
				}
			}
			catch(error) {};

			if(ENV_FLEX_HOME in process.env)
			{
				sdkPath = process.env[ENV_FLEX_HOME];
				if(isValidSDK(sdkPath))
				{
					return sdkPath;
				}
			}

			if(ENV_PATH in process.env)
			{
				var paths:Array = process.env[ENV_PATH].split(path.delimiter);
				var pathCount:int = paths.length;
				for(var i:int = 0; i < pathCount; i++)
				{
					var currentPath:String = paths[i];
					//first check if this directory contains the NPM version for
					//Windows
					var asjscPath:String = path.join(currentPath, ASJSC + ".cmd");
					if(fs.existsSync(asjscPath))
					{
						sdkPath = path.join(path.dirname(asjscPath), NODE_MODULES, NPM_PACKAGE_FLEXJS);
						if(isValidSDK(sdkPath))
						{
							return sdkPath;
						}
					}
					asjscPath = path.join(currentPath, ASJSC);
					if(fs.existsSync(asjscPath))
					{
						//this may a symbolic link rather than the actual file,
						//such as when Apache FlexJS is installed with NPM on
						//Mac, so get the real path.
						asjscPath = fs.realpathSync(asjscPath);
						sdkPath = path.join(path.dirname(asjscPath), "..", "..");
						if(isValidSDK(sdkPath))
						{
							return sdkPath;
						}
					}
				}
			}
			return null;
		}
	}
}