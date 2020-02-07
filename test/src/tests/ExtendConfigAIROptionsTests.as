package tests
{
	import com.as3mxml.asconfigc.AIROptions;
	import com.as3mxml.asconfigc.AIRPlatformType;
	import com.as3mxml.asconfigc.SigningOptions;
	import com.as3mxml.asconfigc.TopLevelFields;
	import com.as3mxml.asconfigc.utils.ConfigUtils;

	import org.apache.royale.test.Assert;

	public class ExtendConfigAIROptionsTests
	{
		//--- output

		[Test]
		public function testOutputWithBaseAndEmptyAIROptions():void
		{
			var baseValue:String = "bin-debug/Base.air";
			var baseConfig:Object =
			{
				"airOptions": {
					"output": baseValue
				}
			};
			var config:Object =
			{
				"airOptions": {
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = airOptions[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testOutputWithoutOverrideAIROptions():void
		{
			var baseValue:String = "bin-debug/Base.air";
			var baseConfig:Object =
			{
				"airOptions": {
					"output": baseValue
				}
			};
			var config:Object =
			{
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = airOptions[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testOutputWithEmptyBaseAIROptions():void
		{
			var newValue:String = "bin-debug/New.air";
			var baseConfig:Object =
			{
				"airOptions": {
				}
			};
			var config:Object =
			{
				"airOptions": {
					"output": newValue
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = airOptions[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testOutputWithoutBaseAIROptions():void
		{
			var newValue:String = "bin-debug/New.air";
			var baseConfig:Object =
			{
			};
			var config:Object =
			{
				"airOptions": {
					"output": newValue
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = airOptions[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testOutputMerge():void
		{
			var baseValue:String = "bin-debug/Base.air";
			var newValue:String = "bin-debug/New.air";
			var baseConfig:Object =
			{
				"airOptions": {
					"output": baseValue
				}
			};
			var config:Object =
			{
				"airOptions": {
					"output": newValue
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = airOptions[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		//--- files
		//this air option is an array of objects, and a certain key should not
		//be duplicated

		[Test]
		public function testFilesWithEmptyOverrideAIROptions():void
		{
			var baseFile:String = "assets/base.png";
			var basePath:String = "base.png";
			var baseConfig:Object =
			{
				"airOptions": {
					"files": [
						{
							"file": baseFile,
							"path": basePath
						}
					]
				}
			};
			var config:Object =
			{
				"airOptions": {}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.FILES));
			Assert.assertTrue(Array.isArray(airOptions[AIROptions.FILES]));
			var resultValue:Array = airOptions[AIROptions.FILES] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__FILE], baseFile);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__PATH], basePath);
		}

		[Test]
		public function testFilesWithEmptyBaseAIROptions():void
		{
			var newFile:String = "assets/new.png";
			var newPath:String = "new.png";
			var baseConfig:Object =
			{
				"airOptions": {}
			};
			var config:Object =
			{
				"airOptions": {
					"files": [
						{
							"file": newFile,
							"path": newPath
						}
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.FILES));
			Assert.assertTrue(Array.isArray(airOptions[AIROptions.FILES]));
			var resultValue:Array = airOptions[AIROptions.FILES] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__FILE], newFile);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__PATH], newPath);
		}

		[Test]
		public function testFilesMerge():void
		{
			var baseFile:String = "assets/base.png";
			var basePath:String = "base.png";
			var newFile:String = "assets/new.png";
			var newPath:String = "new.png";
			var baseConfig:Object =
			{
				"airOptions": {
					"files": [
						{
							"file": baseFile,
							"path": basePath
						}
					]
				}
			};
			var config:Object =
			{
				"airOptions": {
					"files": [
						{
							"file": newFile,
							"path": newPath
						}
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.FILES));
			Assert.assertTrue(Array.isArray(airOptions[AIROptions.FILES]));
			var resultValue:Array = airOptions[AIROptions.FILES] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 2);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__FILE], newFile);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__PATH], newPath);
			Assert.assertStrictlyEquals(resultValue[1][AIROptions.FILES__FILE], baseFile);
			Assert.assertStrictlyEquals(resultValue[1][AIROptions.FILES__PATH], basePath);
		}

		[Test]
		public function testFilesMergeDuplicate():void
		{
			var baseFile:String = "assets/base.png";
			var basePath:String = "duplicate.png";
			var newFile:String = "assets/new.png";
			var newPath:String = "duplicate.png";
			var baseConfig:Object =
			{
				"airOptions": {
					"files": [
						{
							"file": baseFile,
							"path": basePath
						}
					]
				}
			};
			var config:Object =
			{
				"airOptions": {
					"files": [
						{
							"file": newFile,
							"path": newPath
						}
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.FILES));
			Assert.assertTrue(Array.isArray(airOptions[AIROptions.FILES]));
			var resultValue:Array = airOptions[AIROptions.FILES] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__FILE], newFile);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__PATH], newPath);
		}

		//--- signingOptions
		//this air option is a complex object, but it should just replace the
		//base and not get merged

		[Test]
		public function testSigningOptionsWithoutOverride():void
		{
			var baseKeystore:String = "signing/base.p12";
			var baseStoretype:String = "pkcs12";
			var baseConfig:Object =
			{
				"airOptions": {
					"signingOptions": {
						"keystore": baseKeystore,
						"storetype": baseStoretype
					}
				}
			};
			var config:Object =
			{
				"airOptions": {}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.SIGNING_OPTIONS));
			var signingOptions:Object = airOptions[AIROptions.SIGNING_OPTIONS];
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(!signingOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.KEYSTORE], baseKeystore);
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.STORETYPE], baseStoretype);
		}

		[Test]
		public function testSigningOptionsWithoutBase():void
		{
			var newProviderName:String = "Apple";
			var newStoretype:String = "KeychainStore";
			var baseConfig:Object =
			{
				"airOptions": {}
			};
			var config:Object =
			{
				"airOptions": {
					"signingOptions": {
						"providerName": newProviderName,
						"storetype": newStoretype
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.SIGNING_OPTIONS));
			var signingOptions:Object = airOptions[AIROptions.SIGNING_OPTIONS];
			Assert.assertTrue(!signingOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.PROVIDER_NAME], newProviderName);
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.STORETYPE], newStoretype);
		}

		[Test]
		public function testSigningOptionsMerge():void
		{
			var baseKeystore:String = "signing/base.p12";
			var baseStoretype:String = "pkcs12";
			var newProviderName:String = "Apple";
			var newStoretype:String = "KeychainStore";
			var baseConfig:Object =
			{
				"airOptions": {
					"signingOptions": {
						"keystore": baseKeystore,
						"storetype": baseStoretype
					}
				}
			};
			var config:Object =
			{
				"airOptions": {
					"signingOptions": {
						"providerName": newProviderName,
						"storetype": newStoretype
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.SIGNING_OPTIONS));
			var signingOptions:Object = airOptions[AIROptions.SIGNING_OPTIONS];
			Assert.assertTrue(!signingOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.PROVIDER_NAME], newProviderName);
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.STORETYPE], newStoretype);
		}

		[Test]
		public function testSigningOptionsMergeWithDual():void
		{
			var baseDebugKeystore:String = "signing/base-debug.p12";
			var baseDebugStoretype:String = "pkcs12";
			var baseReleaseKeystore:String = "signing/base-release.p12";
			var baseReleaseStoretype:String = "pkcs12";
			var newDebugProviderName:String = "Apple";
			var newDebugStoretype:String = "KeychainStore";
			var newReleaseProviderName:String = "Adobe";
			var newReleaseStoretype:String = "KeychainStore";

			var baseConfig:Object =
			{
				"airOptions": {
					"signingOptions": {
						"debug": {
							"keystore": baseDebugKeystore,
							"storetype": baseDebugStoretype
						},
						"release": {
							"keystore": baseReleaseKeystore,
							"storetype": baseReleaseStoretype
						}
					}
				}
			};
			var config:Object =
			{
				"airOptions": {
					"signingOptions": {
						"debug": {
							"providerName": newDebugProviderName,
							"storetype": newDebugStoretype
						},	
						"release": {
							"providerName": newReleaseProviderName,
							"storetype": newReleaseStoretype
						}
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.SIGNING_OPTIONS));
			var signingOptions:Object = airOptions[AIROptions.SIGNING_OPTIONS];
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.DEBUG));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.RELEASE));
			var debugOptions:Object = signingOptions[SigningOptions.DEBUG];
			var releaseOptions:Object = signingOptions[SigningOptions.RELEASE];
			Assert.assertTrue(!debugOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(debugOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(debugOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(debugOptions[SigningOptions.PROVIDER_NAME], newDebugProviderName);
			Assert.assertStrictlyEquals(debugOptions[SigningOptions.STORETYPE], newDebugStoretype);
			Assert.assertTrue(!releaseOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(releaseOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(releaseOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(releaseOptions[SigningOptions.PROVIDER_NAME], newReleaseProviderName);
			Assert.assertStrictlyEquals(releaseOptions[SigningOptions.STORETYPE], newReleaseStoretype);
		}

		[Test]
		public function testSigningOptionsMergeWithSingleInBaseAndDualInOverride():void
		{
			var baseKeystore:String = "signing/base.p12";
			var baseStoretype:String = "pkcs12";
			var newDebugProviderName:String = "Apple";
			var newDebugStoretype:String = "KeychainStore";
			var newReleaseProviderName:String = "Adobe";
			var newReleaseStoretype:String = "KeychainStore";

			var baseConfig:Object =
			{
				"airOptions": {
					"signingOptions": {
						"keystore": baseKeystore,
						"storetype": baseStoretype
					}
				}
			};
			var config:Object =
			{
				"airOptions": {
					"signingOptions": {
						"debug": {
							"providerName": newDebugProviderName,
							"storetype": newDebugStoretype
						}
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.SIGNING_OPTIONS));
			var signingOptions:Object = airOptions[AIROptions.SIGNING_OPTIONS];
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.DEBUG));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.RELEASE));
			var debugOptions:Object = signingOptions[SigningOptions.DEBUG];
			var releaseOptions:Object = signingOptions[SigningOptions.RELEASE];
			Assert.assertTrue(!debugOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(debugOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(debugOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(debugOptions[SigningOptions.PROVIDER_NAME], newDebugProviderName);
			Assert.assertStrictlyEquals(debugOptions[SigningOptions.STORETYPE], newDebugStoretype);
			Assert.assertTrue(releaseOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(!releaseOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(releaseOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(releaseOptions[SigningOptions.KEYSTORE], baseKeystore);
			Assert.assertStrictlyEquals(releaseOptions[SigningOptions.STORETYPE], baseStoretype);
		}

		[Test]
		public function testSigningOptionsMergeWithDualInBaseAndSingleInOverride():void
		{
			var baseDebugKeystore:String = "signing/base-debug.p12";
			var baseDebugStoretype:String = "pkcs12";
			var baseReleaseKeystore:String = "signing/base-release.p12";
			var baseReleaseStoretype:String = "pkcs12";
			var newProviderName:String = "Apple";
			var newStoretype:String = "KeychainStore";

			var baseConfig:Object =
			{
				"airOptions": {
					"signingOptions": {
						"debug": {
							"keystore": baseDebugKeystore,
							"storetype": baseDebugStoretype
						},
						"release": {
							"keystore": baseReleaseKeystore,
							"storetype": baseReleaseStoretype
						}
					}
				}
			};
			var config:Object =
			{
				"airOptions": {
					"signingOptions": {
						"providerName": newProviderName,
						"storetype": newStoretype
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.SIGNING_OPTIONS));
			var signingOptions:Object = airOptions[AIROptions.SIGNING_OPTIONS];
			Assert.assertFalse(signingOptions.hasOwnProperty(SigningOptions.DEBUG));
			Assert.assertFalse(signingOptions.hasOwnProperty(SigningOptions.RELEASE));
			Assert.assertTrue(!signingOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.PROVIDER_NAME], newProviderName);
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.STORETYPE], newStoretype);
		}

		//--- output (platform)

		[Test]
		public function testOutputPlatformWithBaseAndEmptyPlatform():void
		{
			var baseValue:String = "bin-debug/Base.apk";
			var baseConfig:Object =
			{
				"airOptions": {
					"android": {
						"output": baseValue
					}
				}
			};
			var config:Object =
			{
				"airOptions": {
					"android": {
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIRPlatformType.ANDROID));
			var android:Object = airOptions[AIRPlatformType.ANDROID];
			Assert.assertTrue(android.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = android[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testOutputPlatformWithoutOverridePlatform():void
		{
			var baseValue:String = "bin-debug/Base.apk";
			var baseConfig:Object =
			{
				"airOptions": {
					"android": {
						"output": baseValue
					}
				}
			};
			var config:Object =
			{
				"airOptions": {

				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIRPlatformType.ANDROID));
			var android:Object = airOptions[AIRPlatformType.ANDROID];
			Assert.assertTrue(android.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = android[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testOutputPlatformWithoutOverrideAIROptions():void
		{
			var baseValue:String = "bin-debug/Base.apk";
			var baseConfig:Object =
			{
				"airOptions": {
					"android": {
						"output": baseValue
					}
				}
			};
			var config:Object =
			{
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIRPlatformType.ANDROID));
			var android:Object = airOptions[AIRPlatformType.ANDROID];
			Assert.assertTrue(android.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = android[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testOutputPlatformWithEmptyBasePlatform():void
		{
			var newValue:String = "bin-debug/New.apk";
			var baseConfig:Object =
			{
				"airOptions": {
					"android": {
					}
				}
			};
			var config:Object =
			{
				"airOptions": {
					"android": {
						"output": newValue
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIRPlatformType.ANDROID));
			var android:Object = airOptions[AIRPlatformType.ANDROID];
			Assert.assertTrue(android.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = android[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testOutputPlatformWithoutBasePlatform():void
		{
			var newValue:String = "bin-debug/New.apk";
			var baseConfig:Object =
			{
				"airOptions": {

				}
			};
			var config:Object =
			{
				"airOptions": {
					"android": {
						"output": newValue
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIRPlatformType.ANDROID));
			var android:Object = airOptions[AIRPlatformType.ANDROID];
			Assert.assertTrue(android.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = android[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testOutputPlatformWithoutBaseAIROptions():void
		{
			var newValue:String = "bin-debug/New.apk";
			var baseConfig:Object =
			{
			};
			var config:Object =
			{
				"airOptions": {
					"android": {
						"output": newValue
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIRPlatformType.ANDROID));
			var android:Object = airOptions[AIRPlatformType.ANDROID];
			Assert.assertTrue(android.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = android[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testOutputPlatformMerge():void
		{
			var baseValue:String = "bin-debug/Base.apk";
			var newValue:String = "bin-debug/New.apk";
			var baseConfig:Object =
			{
				"airOptions": {
					"android": {
						"output": baseValue
					}
				}
			};
			var config:Object =
			{
				"airOptions": {
					"android": {
						"output": newValue
					}
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.AIR_OPTIONS));
			var airOptions:Object = result[TopLevelFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIRPlatformType.ANDROID));
			var android:Object = airOptions[AIRPlatformType.ANDROID];
			Assert.assertTrue(android.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = android[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}
	}
}