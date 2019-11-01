package tests
{
	import com.as3mxml.asconfigc.AIRPlatformType;
	import com.as3mxml.asconfigc.ASConfigFields;
	import com.as3mxml.asconfigc.utils.ConfigUtils;

	import org.apache.royale.test.Assert;

	public class ExtendConfigTopLevelTests
	{
		//--- copySourcePathAssets

		[Test]
		public function testCopySourcePathAssetsWithBaseOnly():void
		{
			var baseValue:Boolean = false;
			var baseConfig:Object =
			{
				"copySourcePathAssets": baseValue
			};
			var config:Object =
			{
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.COPY_SOURCE_PATH_ASSETS));
			var resultValue:* = result[ASConfigFields.COPY_SOURCE_PATH_ASSETS];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testCopySourcePathAssetsWithoutBase():void
		{
			var newValue:Boolean = true;
			var baseConfig:Object =
			{
			};
			var config:Object =
			{
				"copySourcePathAssets": newValue
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.COPY_SOURCE_PATH_ASSETS));
			var resultValue:* = result[ASConfigFields.COPY_SOURCE_PATH_ASSETS];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testCopySourcePathAssetsMerge():void
		{
			var baseValue:Boolean = false;
			var newValue:Boolean = true;
			var baseConfig:Object =
			{
				"copySourcePathAssets": baseValue
			};
			var config:Object =
			{
				"copySourcePathAssets": newValue
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.COPY_SOURCE_PATH_ASSETS));
			var resultValue:* = result[ASConfigFields.COPY_SOURCE_PATH_ASSETS];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		//--- files

		//file is an array, but unlike other arrays, it does not get merged,
		//so it should be tested as a special case

		[Test]
		public function testFilesWithBaseOnly():void
		{
			var baseValue:String = "src/Base.as";
			var baseConfig:Object =
			{
				"files": [
					baseValue
				]
			};
			var config:Object =
			{
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.FILES));
			Assert.assertTrue(Array.isArray(result[ASConfigFields.FILES]));
			var resultArray:Array = result[ASConfigFields.FILES] as Array;
			Assert.assertStrictlyEquals(resultArray.length, 1);
			var resultValue:* = resultArray[0];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testFilesWithoutBase():void
		{
			var newValue:String = "src/New.as";
			var baseConfig:Object =
			{
			};
			var config:Object =
			{
				"files": [
					newValue
				]
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.FILES));
			Assert.assertTrue(Array.isArray(result[ASConfigFields.FILES]));
			var resultFiles:Array = result[ASConfigFields.FILES] as Array;
			Assert.assertStrictlyEquals(resultFiles.length, 1);
			var resultValue:* = resultFiles[0];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testFilesMerge():void
		{
			var baseValue:String = "src/Base.as";
			var newValue:String = "src/New.as";
			var baseConfig:Object =
			{
				"files": [
					baseValue
				]
			};
			var config:Object =
			{
				"files": [
					newValue
				]
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.FILES));
			Assert.assertTrue(Array.isArray(result[ASConfigFields.FILES]));
			var resultFiles:Array = result[ASConfigFields.FILES] as Array;
			var resultValue:* = resultFiles[0];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		//--- application

		//application can be a string or a file, and it has special rules for
		//merging

		[Test]
		public function testApplicationStringWithBaseOnly():void
		{
			var baseValue:String = "src/Base-app.xml";
			var baseConfig:Object =
			{
				"application": baseValue
			};
			var config:Object =
			{
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.APPLICATION));
			var resultValue:* = result[ASConfigFields.APPLICATION];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testApplicationStringWithoutBase():void
		{
			var newValue:String = "src/New-app.xml";
			var baseConfig:Object =
			{
			};
			var config:Object =
			{
				"application": newValue
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.APPLICATION));
			var resultValue:* = result[ASConfigFields.APPLICATION];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testApplicationStringMerge():void
		{
			var baseValue:String = "src/Base-app.xml";
			var newValue:String = "src/New-app.xml";
			var baseConfig:Object =
			{
				"application": baseValue
			};
			var config:Object =
			{
				"application": newValue
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.APPLICATION));
			var resultValue:* = result[ASConfigFields.APPLICATION];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testApplicationObjectWithBaseOnly():void
		{
			var baseValue:Object =
			{
				"ios": "src/BaseIOS-app.xml",
				"android": "src/BaseAndroid-app.xml"
			};
			var baseConfig:Object =
			{
				"application": baseValue
			};
			var config:Object =
			{
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.APPLICATION));
			var resultValue:* = result[ASConfigFields.APPLICATION];
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.ANDROID));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.IOS));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.WINDOWS));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.MAC));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.AIR));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.IOS_SIMULATOR));
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.ANDROID], baseValue[AIRPlatformType.ANDROID]);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.IOS], baseValue[AIRPlatformType.IOS]);
		}

		[Test]
		public function testApplicationObjectWithoutBase():void
		{
			var newValue:Object =
			{
				"ios": "src/NewIOS-app.xml",
				"android": "src/NewAndroid-app.xml"
			};
			var baseConfig:Object =
			{
			};
			var config:Object =
			{
				"application": newValue
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.APPLICATION));
			var resultValue:* = result[ASConfigFields.APPLICATION];
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.ANDROID));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.IOS));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.WINDOWS));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.MAC));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.AIR));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.IOS_SIMULATOR));
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.ANDROID], newValue[AIRPlatformType.ANDROID]);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.IOS], newValue[AIRPlatformType.IOS]);
		}

		[Test]
		public function testApplicationObjectMerge():void
		{
			var baseValue:Object =
			{
				"ios": "src/BaseIOS-app.xml",
				"android": "src/BaseAndroid-app.xml"
			};
			var newValue:Object =
			{
				"ios": "src/NewIOS-app.xml",
				"windows": "src/NewWindows-app.xml",
				"mac": "src/NewMac-app.xml"
			};
			var baseConfig:Object =
			{
				"application": baseValue
			};
			var config:Object =
			{
				"application": newValue
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.APPLICATION));
			var resultValue:* = result[ASConfigFields.APPLICATION];
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.ANDROID));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.IOS));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.WINDOWS));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.MAC));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.AIR));
			Assert.assertTrue(!resultValue.hasOwnProperty(AIRPlatformType.IOS_SIMULATOR));
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.ANDROID], baseValue[AIRPlatformType.ANDROID]);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.IOS], newValue[AIRPlatformType.IOS]);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.WINDOWS], newValue[AIRPlatformType.WINDOWS]);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.MAC], newValue[AIRPlatformType.MAC]);
		}

		[Test]
		public function testApplicationBaseStringNewObjectMerge():void
		{
			var baseValue:String = "src/Base-app.xml";
			var newValue:Object =
			{
				"ios": "src/NewIOS-app.xml",
				"android": "src/NewAndroid-app.xml"
			};
			var baseConfig:Object =
			{
				"application": baseValue
			};
			var config:Object =
			{
				"application": newValue
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.APPLICATION));
			var resultValue:* = result[ASConfigFields.APPLICATION];
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.ANDROID));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.IOS));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.WINDOWS));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.MAC));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.AIR));
			Assert.assertTrue(resultValue.hasOwnProperty(AIRPlatformType.IOS_SIMULATOR));
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.ANDROID], newValue[AIRPlatformType.ANDROID]);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.IOS], newValue[AIRPlatformType.IOS]);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.WINDOWS], baseValue);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.MAC], baseValue);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.AIR], baseValue);
			Assert.assertStrictlyEquals(resultValue[AIRPlatformType.IOS_SIMULATOR], baseValue);
		}

		[Test]
		public function testApplicationBaseObjectNewStringMerge():void
		{
			var baseValue:Object =
			{
				"ios": "src/BaseIOS-app.xml",
				"android": "src/BaseAndroid-app.xml"
			};
			var newValue:String = "src/New-app.xml";
			var baseConfig:Object =
			{
				"application": baseValue
			};
			var config:Object =
			{
				"application": newValue
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(ASConfigFields.APPLICATION));
			var resultValue:* = result[ASConfigFields.APPLICATION];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}
	}
}