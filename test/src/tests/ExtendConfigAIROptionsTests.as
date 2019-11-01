package tests
{
	import com.as3mxml.asconfigc.AIROptions;
	import com.as3mxml.asconfigc.ASConfigFields;
	import com.as3mxml.asconfigc.SigningOptions;
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = airOptions[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testOutputWithBaseOnly():void
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.OUTPUT));
			var resultValue:* = airOptions[AIROptions.OUTPUT];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		//--- files
		//this air option is an array of objects, and a certain key should not
		//be duplicated

		[Test]
		public function testFilesWithBaseOnly():void
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.FILES));
			Assert.assertTrue(Array.isArray(airOptions[AIROptions.FILES]));
			var resultValue:Array = airOptions[AIROptions.FILES] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__FILE], baseFile);
			Assert.assertStrictlyEquals(resultValue[0][AIROptions.FILES__PATH], basePath);
		}

		[Test]
		public function testFilesWithoutBase():void
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
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
		public function testSigningOptionsWithBaseOnly():void
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.SIGNING_OPTIONS));
			var signingOptions:Object = airOptions[AIROptions.SIGNING_OPTIONS];
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(!signingOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.KEYSTORE], baseKeystore);
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.STORETYPE], baseStoretype);
		}

		[Test]
		public function testSigningWithoutBase():void
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
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
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.AIR_OPTIONS));
			var airOptions:Object = result[ASConfigFields.AIR_OPTIONS];
			Assert.assertTrue(airOptions.hasOwnProperty(AIROptions.SIGNING_OPTIONS));
			var signingOptions:Object = airOptions[AIROptions.SIGNING_OPTIONS];
			Assert.assertTrue(!signingOptions.hasOwnProperty(SigningOptions.KEYSTORE));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.PROVIDER_NAME));
			Assert.assertTrue(signingOptions.hasOwnProperty(SigningOptions.STORETYPE));
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.PROVIDER_NAME], newProviderName);
			Assert.assertStrictlyEquals(signingOptions[SigningOptions.STORETYPE], newStoretype);
		}
	}
}