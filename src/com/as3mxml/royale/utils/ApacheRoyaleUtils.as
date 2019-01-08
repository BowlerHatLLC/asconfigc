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
package com.as3mxml.royale.utils
{
	/**
	 * Utilities for finding and running executables from an Apache Royale SDK.
	 */
	public class ApacheRoyaleUtils
	{
		/**
		 * @private
		 */
		private static const ASJSC:String = "asjsc";

		/**
		 * @private
		 */
		private static const ENV_ROYALE_HOME:String = "ROYALE_HOME";

		/**
		 * @private
		 */
		private static const ENV_PATH:String = "PATH";

		/**
		 * @private
		 */
		private static const ROYALE_ASJS:String = "royale-asjs";

		/**
		 * @private
		 */
		private static const NODE_MODULES:String = "node_modules";

		/**
		 * @private
		 */
		private static const NPM_ORG_ROYALE:String = "@apache-royale";

		/**
		 * @private
		 */
		private static const NPM_PACKAGE_ROYALE_JS:String = "royale-js";

		/**
		 * @private
		 */
		private static const NPM_PACKAGE_ROYALE_SWF:String = "royale-js-swf";

		/**
		 * @private
		 */
		private static const ROYALE_SDK_DESCRIPTION:String = "royale-sdk-description.xml";

		/**
		 * Determines if a directory contains a valid Apache Royale SDK.
		 */
		public static function isValidSDK(absolutePath:String):String
		{
			if(!absolutePath)
			{
				return null;
			}
			if(isValidSDKInternal(absolutePath))
			{
				return absolutePath;
			}
			var royalePath:String = path.join(absolutePath, ROYALE_ASJS);
			if(isValidSDKInternal(royalePath))
			{
				return royalePath;
			}
			return null;
		}

		private static function isValidSDKInternal(absolutePath:String):Boolean
		{
			if(!absolutePath)
			{
				return false;
			}
			var sdkDescriptionPath:String = path.join(absolutePath, ROYALE_SDK_DESCRIPTION);
			if(!fs.existsSync(sdkDescriptionPath) || fs.statSync(sdkDescriptionPath).isDirectory())
			{
				return false;
			}
			return true;
		}

		/**
		 * Attempts to find a valid Apache Royale SDK by searching for
		 * installed npm modules, testing the ROYALE_HOME environment variable,
		 * and finally, testing the PATH environment variable.
		 */
		public static function findSDK():String
		{
			var sdkPath:String = null;

			//look for an npm module
			try
			{
				sdkPath = path.join(process.cwd(), NODE_MODULES, NPM_ORG_ROYALE, NPM_PACKAGE_ROYALE_JS);
				sdkPath = isValidSDK(sdkPath)
				if(sdkPath != null)
				{
					return sdkPath;
				}
			}
			catch(error) {};
			try
			{
				sdkPath = path.join(process.cwd(), NODE_MODULES, NPM_ORG_ROYALE, NPM_PACKAGE_ROYALE_SWF);
				sdkPath = isValidSDK(sdkPath)
				if(sdkPath != null)
				{
					return sdkPath;
				}
			}
			catch(error) {};

			if(ENV_ROYALE_HOME in process.env)
			{
				sdkPath = process.env[ENV_ROYALE_HOME];
				sdkPath = isValidSDK(sdkPath)
				if(sdkPath != null)
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
						sdkPath = path.join(path.dirname(asjscPath), NODE_MODULES, NPM_ORG_ROYALE, NPM_PACKAGE_ROYALE_JS);
						sdkPath = isValidSDK(sdkPath)
						if(sdkPath != null)
						{
							return sdkPath;
						}
						sdkPath = path.join(path.dirname(asjscPath), NODE_MODULES, NPM_ORG_ROYALE, NPM_PACKAGE_ROYALE_SWF);
						sdkPath = isValidSDK(sdkPath)
						if(sdkPath != null)
						{
							return sdkPath;
						}
					}
					asjscPath = path.join(currentPath, ASJSC);
					if(fs.existsSync(asjscPath))
					{
						//this may a symbolic link rather than the actual file,
						//such as when Apache Royale is installed with NPM on
						//Mac, so get the real path.
						asjscPath = fs.realpathSync(asjscPath);
						sdkPath = path.join(path.dirname(asjscPath), "..", "..");
						sdkPath = isValidSDK(sdkPath)
						if(sdkPath != null)
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