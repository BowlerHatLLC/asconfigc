package tests
{
	import com.as3mxml.asconfigc.AIROptions;
	import com.as3mxml.asconfigc.AIROptionsParser;
	import com.as3mxml.asconfigc.AIRPlatformType;
	import com.as3mxml.asconfigc.AIRTarget;
	import com.as3mxml.asconfigc.SigningOptions;
	import com.as3mxml.asconfigc.utils.escapePath;

	import org.apache.royale.test.Assert;

	public class AIROptionsTests
	{
		[Test]
		public function testApplicationContent():void
		{
			var filename:String = "content.swf";
			var dirPath:String = "path/to"
			var value:String = dirPath + "/" + filename;
			var args:Object = {};
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", value, args);
			Assert.assertStrictlyEquals(result.indexOf(value), -1);
			var optionIndex:int = result.indexOf("-C");
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(dirPath), optionIndex + 1);
			Assert.assertStrictlyEquals(result.indexOf(filename), optionIndex + 2);
		}

		[Test]
		public function testApplicationContentWithSpacesInPath():void
		{
			var filename:String = "my content.swf";
			var dirPath:String = "path to"
			var value:String = dirPath + "/" + filename;
			var formattedValue:String = escapePath(value);
			var formattedDirPath:String = escapePath(dirPath);
			var formattedFilename:String = escapePath(filename);
			var args:Object = {};
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", value, args);
			Assert.assertStrictlyEquals(result.indexOf(value), -1);
			Assert.assertStrictlyEquals(result.indexOf(formattedValue), -1);
			var optionIndex:int = result.indexOf("-C");
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(formattedDirPath), optionIndex + 1);
			Assert.assertStrictlyEquals(result.indexOf(formattedFilename), optionIndex + 2);
		}

		[Test]
		public function testDescriptor():void
		{
			var value:String = "path/to/application.xml";
			var args:Object = {};
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, value, "test.swf", args);
			Assert.assertNotStrictlyEquals(result.indexOf(value), -1);
		}

		[Test]
		public function testDescriptorWithSpacesInPath():void
		{
			var value:String = "path to/application.xml";
			var formattedValue:String = escapePath(value);
			var args:Object = {};
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, value, "test.swf", args);
			Assert.assertNotStrictlyEquals(result.indexOf(formattedValue), -1);
		}

		[Test]
		public function testAIRDownloadURL():void
		{
			var value:String = "http://example.com";
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {}
			args[AIRPlatformType.ANDROID][AIROptions.AIR_DOWNLOAD_URL] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.AIR_DOWNLOAD_URL);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

		[Test]
		public function testArch():void
		{
			var value:String = "x86";
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {}
			args[AIRPlatformType.ANDROID][AIROptions.ARCH] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.ARCH);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

		[Test]
		public function testResdir():void
		{
			var value:String = "path/to/res";
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {}
			args[AIRPlatformType.ANDROID][AIROptions.RESDIR] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.RESDIR);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

		[Test]
		public function testEmbedBitcode():void
		{
			var value:Boolean = true;
			var args:Object = {};
			args[AIRPlatformType.IOS] = {}
			args[AIRPlatformType.IOS][AIROptions.EMBED_BITCODE] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.EMBED_BITCODE);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value ? "yes" : "no"), optionIndex + 1);
		}

		[Test]
		public function testExtdir():void
		{
			var value:Array = [
				"path/subpath1",
				"path/subpath2",
			];
			var args:Object = {};
			args[AIROptions.EXTDIR] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex1:int = result.indexOf("-" + AIROptions.EXTDIR);
			Assert.assertNotStrictlyEquals(optionIndex1, -1);
			Assert.assertStrictlyEquals(result.indexOf(value[0]), optionIndex1 + 1);
			var optionIndex2:int = result.indexOf("-" + AIROptions.EXTDIR, optionIndex1 + 1);
			Assert.assertNotStrictlyEquals(optionIndex2, -1);
			Assert.assertStrictlyEquals(result.indexOf(value[1]), optionIndex2 + 1);
		}

		[Test]
		public function testExtdirWithSpacesInPath():void
		{
			var value:Array = [
				"path to/subpath1"
			];
			var formattedValue:String = escapePath(value[0]);
			var args:Object = {};
			args[AIROptions.EXTDIR] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex1:int = result.indexOf("-" + AIROptions.EXTDIR);
			Assert.assertNotStrictlyEquals(optionIndex1, -1);
			Assert.assertStrictlyEquals(result.indexOf(formattedValue), optionIndex1 + 1);
		}

		[Test]
		public function testFiles():void
		{
			var file1:Object = {};
			file1[AIROptions.FILES__FILE] = "air-files/file1.txt";
			file1[AIROptions.FILES__PATH] = ".";
			var file2:Object = {};
			file2[AIROptions.FILES__FILE] = "air-files/subdir/file2.txt";
			file2[AIROptions.FILES__PATH] = "other";
			var value:Array = [
				file1,
				file2
			];
			var args:Object = {};
			args[AIROptions.FILES] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex1:int = result.indexOf("-e");
			Assert.assertNotStrictlyEquals(optionIndex1, -1);
			Assert.assertStrictlyEquals(result.indexOf(file1[AIROptions.FILES__FILE]), optionIndex1 + 1);
			Assert.assertStrictlyEquals(result.indexOf(file1[AIROptions.FILES__PATH]), optionIndex1 + 2);
			var optionIndex2:int = result.indexOf("-e", optionIndex1 + 1);
			Assert.assertNotStrictlyEquals(optionIndex2, -1);
			Assert.assertStrictlyEquals(result.indexOf(file2[AIROptions.FILES__FILE]), optionIndex2 + 1);
			Assert.assertStrictlyEquals(result.indexOf(file2[AIROptions.FILES__PATH]), optionIndex2 + 2);
		}

		[Test]
		public function testFilesWithDirectory():void
		{
			var file1:Object = {};
			file1[AIROptions.FILES__FILE] = "air-files/subdir";
			file1[AIROptions.FILES__PATH] = "other";
			var value:Array = [
				file1
			];
			var fileInDir1:String = path.join(file1[AIROptions.FILES__FILE], "file2.txt");
			var fileInDir2:String = path.join(file1[AIROptions.FILES__FILE], "file3.txt");
			var dirPath1:String = path.join(file1[AIROptions.FILES__PATH], "file2.txt");
			var dirPath2:String = path.join(file1[AIROptions.FILES__PATH], "file3.txt");
			var args:Object = {};
			args[AIROptions.FILES] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex1:int = result.indexOf("-e");
			Assert.assertNotStrictlyEquals(optionIndex1, -1);
			Assert.assertStrictlyEquals(result.indexOf(fileInDir1), optionIndex1 + 1);
			Assert.assertStrictlyEquals(result.indexOf(dirPath1), optionIndex1 + 2);
			var optionIndex2:int = result.indexOf("-e", optionIndex1 + 1);
			Assert.assertNotStrictlyEquals(optionIndex2, -1);
			Assert.assertStrictlyEquals(result.indexOf(fileInDir2, optionIndex2), optionIndex2 + 1);
			Assert.assertStrictlyEquals(result.indexOf(dirPath2, optionIndex2), optionIndex2 + 2);
		}

		[Test]
		public function testHideAneLibSymbols():void
		{
			var value:Boolean = true;
			var args:Object = {};
			args[AIRPlatformType.IOS] = {}
			args[AIRPlatformType.IOS][AIROptions.HIDE_ANE_LIB_SYMBOLS] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.HIDE_ANE_LIB_SYMBOLS);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value ? "yes" : "no"), optionIndex + 1);
		}

		[Test]
		public function testOutput():void
		{
			var value:String = "path/to/file.air";
			var args:Object = {};
			args[AIROptions.OUTPUT] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			//no -output, just the path without anything else
			Assert.assertStrictlyEquals(result.indexOf("-" + AIROptions.OUTPUT), -1);
			Assert.assertNotStrictlyEquals(result.indexOf(value.toString()), -1);
		}

		[Test]
		public function testOutputWithSpacesInPath():void
		{
			var value:String = "path to/file.air";
			var formattedValue:String = escapePath(value);
			var args:Object = {};
			args[AIROptions.OUTPUT] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			//no -output, just the path without anything else
			Assert.assertStrictlyEquals(result.indexOf("-" + AIROptions.OUTPUT), -1);
			Assert.assertNotStrictlyEquals(result.indexOf(formattedValue), -1);
		}

		[Test]
		public function testAndroidOutput():void
		{
			var androidValue:String = "path/to/file.apk";
			var iOSValue:String = "path/to/file.ipa";
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.OUTPUT] = androidValue;
			args[AIRPlatformType.IOS] = {};
			args[AIRPlatformType.IOS][AIROptions.OUTPUT] = iOSValue;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			Assert.assertNotStrictlyEquals(result.indexOf(androidValue), -1);
			Assert.assertStrictlyEquals(result.indexOf(iOSValue), -1);
		}

		[Test]
		public function testIOSOutput():void
		{
			var androidValue:String = "path/to/file.apk";
			var iOSValue:String = "path/to/file.ipa";
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.OUTPUT] = androidValue;
			args[AIRPlatformType.IOS] = {};
			args[AIRPlatformType.IOS][AIROptions.OUTPUT] = iOSValue;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			Assert.assertNotStrictlyEquals(result.indexOf(iOSValue), -1);
			Assert.assertStrictlyEquals(result.indexOf(androidValue), -1);
		}

		[Test]
		public function testAndroidPlatformSDK():void
		{
			var iOSValue:String = "path/to/ios_sdk";
			var androidValue:String = "path/to/android_sdk";
			var args:Object = {};
			args[AIRPlatformType.IOS] = {}
			args[AIRPlatformType.IOS][AIROptions.PLATFORMSDK] = iOSValue;
			args[AIRPlatformType.ANDROID] = {}
			args[AIRPlatformType.ANDROID][AIROptions.PLATFORMSDK] = androidValue;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.PLATFORMSDK);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(androidValue), optionIndex + 1);
			Assert.assertStrictlyEquals(result.indexOf(iOSValue), -1);
		}

		[Test]
		public function testIOSPlatformSDK():void
		{
			var iOSValue:String = "path/to/ios_sdk";
			var androidValue:String = "path/to/android_sdk";
			var args:Object = {};
			args[AIRPlatformType.IOS] = {}
			args[AIRPlatformType.IOS][AIROptions.PLATFORMSDK] = iOSValue;
			args[AIRPlatformType.ANDROID] = {}
			args[AIRPlatformType.ANDROID][AIROptions.PLATFORMSDK] = androidValue;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.PLATFORMSDK);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(iOSValue), optionIndex + 1);
			Assert.assertStrictlyEquals(result.indexOf(androidValue), -1);
		}

		[Test]
		public function testAndroidPlatformSDKWithSpacesInPath():void
		{
			var value:String = "path to/android_sdk";
			var formattedValue:String = escapePath(value);
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {}
			args[AIRPlatformType.ANDROID][AIROptions.PLATFORMSDK] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.PLATFORMSDK);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(formattedValue), optionIndex + 1);
		}

		[Test]
		public function testIOSPlatformSDKWithSpacesInPath():void
		{
			var value:String = "path to/ios_sdk";
			var formattedValue:String = escapePath(value);
			var args:Object = {};
			args[AIRPlatformType.IOS] = {}
			args[AIRPlatformType.IOS][AIROptions.PLATFORMSDK] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.PLATFORMSDK);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(formattedValue), optionIndex + 1);
		}

		[Test]
		public function testSampler():void
		{
			var value:Boolean = true;
			var args:Object = {};
			args[AIRPlatformType.IOS] = {}
			args[AIRPlatformType.IOS][AIROptions.SAMPLER] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.SAMPLER);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
		}

		[Test]
		public function testTarget():void
		{
			var value:String = AIRTarget.NATIVE;
			var args:Object = {};
			args[AIROptions.TARGET] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.TARGET);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value.toString()), optionIndex + 1);
		}

		[Test]
		public function testIOSTarget():void
		{
			var androidTarget:String = "apk-captive-runtime";
			var iOSTarget:String = "ipa-ad-hoc";
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.TARGET] = androidTarget;
			args[AIRPlatformType.IOS] = {};
			args[AIRPlatformType.IOS][AIROptions.TARGET] = iOSTarget;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			Assert.assertNotStrictlyEquals(result.indexOf(iOSTarget), -1);
			Assert.assertStrictlyEquals(result.indexOf(androidTarget), -1);
		}

		[Test]
		public function testAndroidTarget():void
		{
			var androidTarget:String = "apk-captive-runtime";
			var iOSTarget:String = "ipa-ad-hoc";
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.TARGET] = androidTarget;
			args[AIRPlatformType.IOS] = {};
			args[AIRPlatformType.IOS][AIROptions.TARGET] = iOSTarget;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			Assert.assertNotStrictlyEquals(result.indexOf(androidTarget), -1);
			Assert.assertStrictlyEquals(result.indexOf(iOSTarget), -1);
		}

	//------ signing options

		[Test]
		public function testSigningOptionsAlias():void
		{
			var value:String = "AIRcert";
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = {};
			args[AIROptions.SIGNING_OPTIONS][SigningOptions.ALIAS] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + SigningOptions.ALIAS);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

		[Test]
		public function testSigningOptionsKeystore():void
		{
			var value:String = "path/to/keystore.p12";
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = {};
			args[AIROptions.SIGNING_OPTIONS][SigningOptions.KEYSTORE] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + SigningOptions.KEYSTORE);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

		[Test]
		public function testSigningOptionsKeystoreWithSpacesInPath():void
		{
			var value:String = "path to/keystore.p12";
			var formattedValue:String = escapePath(value, true);
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = {};
			args[AIROptions.SIGNING_OPTIONS][SigningOptions.KEYSTORE] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + SigningOptions.KEYSTORE);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(formattedValue), optionIndex + 1);
		}

		[Test]
		public function testSigningOptionsProviderName():void
		{
			var value:String = "className";
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = {};
			args[AIROptions.SIGNING_OPTIONS][SigningOptions.PROVIDER_NAME] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + SigningOptions.PROVIDER_NAME);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

		[Test]
		public function testSigningOptionsStoretype():void
		{
			var value:String = "pkcs12";
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = {};
			args[AIROptions.SIGNING_OPTIONS][SigningOptions.STORETYPE] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + SigningOptions.STORETYPE);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

		[Test]
		public function testSigningOptionsTsa():void
		{
			var value:String = "none";
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = {};
			args[AIROptions.SIGNING_OPTIONS][SigningOptions.TSA] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.AIR, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + SigningOptions.TSA);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

		[Test]
		public function testSigningOptionsProvisioningProfile():void
		{
			var value:String = "path/to/file.mobileprovision";
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = {};
			args[AIROptions.SIGNING_OPTIONS][SigningOptions.PROVISIONING_PROFILE] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.IOS, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + SigningOptions.PROVISIONING_PROFILE);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(value), optionIndex + 1);
		}

	//------ overrides

		[Test]
		public function testOutputPlatformOverride():void
		{
			var androidValue:String = "path/to/file.apk";
			var defaultValue:String = "path/to/file.air";
			var args:Object = {};
			args[AIROptions.OUTPUT] = defaultValue;
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.OUTPUT] = androidValue;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			Assert.assertNotStrictlyEquals(result.indexOf(androidValue), -1);
			Assert.assertStrictlyEquals(result.indexOf(defaultValue), -1);
		}

		[Test]
		public function testTargetPlatformOverride():void
		{
			var androidTarget:String = "apk-captive-runtime";
			var defaultTarget:String = "bundle";
			var args:Object = {};
			args[AIROptions.TARGET] = defaultTarget;
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.TARGET] = androidTarget;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			Assert.assertNotStrictlyEquals(result.indexOf(androidTarget), -1);
			Assert.assertStrictlyEquals(result.indexOf(defaultTarget), -1);
		}

		[Test]
		public function testExtdirPlatformOverride():void
		{
			var androidValue:Array = [
				"path/subpath1",
				"path/subpath2",
			];
			var defaultValue:Array = [
				"path/subpath3"
			];
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {}
			args[AIRPlatformType.ANDROID][AIROptions.EXTDIR] = androidValue;
			args[AIROptions.EXTDIR] = defaultValue;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex1:int = result.indexOf("-" + AIROptions.EXTDIR);
			Assert.assertNotStrictlyEquals(optionIndex1, -1);
			Assert.assertStrictlyEquals(result.indexOf(androidValue[0]), optionIndex1 + 1);
			var optionIndex2:int = result.indexOf("-" + AIROptions.EXTDIR, optionIndex1 + 1);
			Assert.assertNotStrictlyEquals(optionIndex2, -1);
			Assert.assertStrictlyEquals(result.indexOf(androidValue[1]), optionIndex2 + 1);
		}

		[Test]
		public function testSigningOptionsPlatformOverride():void
		{
			var androidValue:Object = {};
			androidValue[SigningOptions.KEYSTORE] = "path/to/android_keystore.p12";
			androidValue[SigningOptions.STORETYPE] = "pkcs12";
			var defaultValue:Object = {};
			defaultValue[SigningOptions.KEYSTORE] = "path/to/keystore.p12";
			defaultValue[SigningOptions.STORETYPE] = "pkcs12";
			androidValue[SigningOptions.TSA] = "none";
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = defaultValue;
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.SIGNING_OPTIONS] = androidValue;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex1:int = result.indexOf("-" + SigningOptions.KEYSTORE);
			Assert.assertNotStrictlyEquals(optionIndex1, -1);
			Assert.assertStrictlyEquals(result.indexOf(androidValue[SigningOptions.KEYSTORE]), optionIndex1 + 1);
			var optionIndex2:int = result.indexOf("-" + SigningOptions.STORETYPE);
			Assert.assertNotStrictlyEquals(optionIndex2, -1);
			Assert.assertStrictlyEquals(result.indexOf(androidValue[SigningOptions.STORETYPE]), optionIndex2 + 1);
			//this one doesn't exist in the android signing options
			Assert.assertStrictlyEquals(result.indexOf(defaultValue[SigningOptions.TSA]), -1);
		}

		[Test]
		public function testSigningOptionsDebug():void
		{
			var value:Object = {};
			var debugSigningOptions:Object = {};
			debugSigningOptions[SigningOptions.KEYSTORE] = "debug.p12";
			debugSigningOptions[SigningOptions.STORETYPE] = "pkcs12";
			value.debug = debugSigningOptions;
			var releaseSigningOptions:Object = {};
			releaseSigningOptions[SigningOptions.KEYSTORE] = "release.keystore";
			releaseSigningOptions[SigningOptions.STORETYPE] = "jks";
			value.release = releaseSigningOptions;
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, true, "application.xml", "test.swf", args);
			var optionIndex1:int = result.indexOf("-" + SigningOptions.KEYSTORE);
			Assert.assertNotStrictlyEquals(optionIndex1, -1);
			Assert.assertStrictlyEquals(result.indexOf(debugSigningOptions[SigningOptions.KEYSTORE]), optionIndex1 + 1);
			var optionIndex2:int = result.indexOf("-" + SigningOptions.STORETYPE);
			Assert.assertNotStrictlyEquals(optionIndex2, -1);
			Assert.assertStrictlyEquals(result.indexOf(debugSigningOptions[SigningOptions.STORETYPE]), optionIndex2 + 1);
		}

		[Test]
		public function testSigningOptionsRelease():void
		{
			var value:Object = {};
			var debugSigningOptions:Object = {};
			debugSigningOptions[SigningOptions.KEYSTORE] = "debug.p12";
			debugSigningOptions[SigningOptions.STORETYPE] = "pkcs12";
			value.debug = debugSigningOptions;
			var releaseSigningOptions:Object = {};
			releaseSigningOptions[SigningOptions.KEYSTORE] = "release.keystore";
			releaseSigningOptions[SigningOptions.STORETYPE] = "jks";
			value.release = releaseSigningOptions;
			var args:Object = {};
			args[AIROptions.SIGNING_OPTIONS] = value;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex1:int = result.indexOf("-" + SigningOptions.KEYSTORE);
			Assert.assertNotStrictlyEquals(optionIndex1, -1);
			Assert.assertStrictlyEquals(result.indexOf(releaseSigningOptions[SigningOptions.KEYSTORE]), optionIndex1 + 1);
			var optionIndex2:int = result.indexOf("-" + SigningOptions.STORETYPE);
			Assert.assertNotStrictlyEquals(optionIndex2, -1);
			Assert.assertStrictlyEquals(result.indexOf(releaseSigningOptions[SigningOptions.STORETYPE]), optionIndex2 + 1);
		}

		[Test]
		public function testConnectDebugAndroid():void
		{
			var connect:Boolean = true;
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.CONNECT] = connect;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, true, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
		}

		[Test]
		public function testConnectHostStringDebugAndroid():void
		{
			var connect:String = "192.16.1.100";
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.CONNECT] = connect;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, true, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertNotStrictlyEquals(optionIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(connect), optionIndex + 1);
		}

		[Test]
		public function testNoConnectDebugAndroid():void
		{
			var connect:Boolean = false;
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.CONNECT] = connect;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, true, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertStrictlyEquals(optionIndex, -1);
		}

		[Test]
		public function testConnectReleaseAndroid():void
		{
			var connect:Boolean = true;
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.CONNECT] = connect;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var optionIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertStrictlyEquals(optionIndex, -1);
		}

		[Test]
		public function testListenDebugAndroid():void
		{
			var listen:Boolean = true;
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.LISTEN] = listen;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, true, "application.xml", "test.swf", args);
			var listenIndex:int = result.indexOf("-" + AIROptions.LISTEN);
			Assert.assertNotStrictlyEquals(listenIndex, -1);
			var connectIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertStrictlyEquals(connectIndex, -1);
		}

		[Test]
		public function testListenReleaseAndroid():void
		{
			var listen:Boolean = true;
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.CONNECT] = listen;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, false, "application.xml", "test.swf", args);
			var listenIndex:int = result.indexOf("-" + AIROptions.LISTEN);
			Assert.assertStrictlyEquals(listenIndex, -1);
			var connectIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertStrictlyEquals(connectIndex, -1);
		}

		[Test]
		public function testNoListenDebugAndroid():void
		{
			var listen:Boolean = false;
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.LISTEN] = listen;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, true, "application.xml", "test.swf", args);
			var listenIndex:int = result.indexOf("-" + AIROptions.LISTEN);
			Assert.assertStrictlyEquals(listenIndex, -1);
			var connectIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertStrictlyEquals(connectIndex, -1);
		}

		[Test]
		public function testListenPortDebugAndroid():void
		{
			var listen:Number = 9000;
			var args:Object = {};
			args[AIRPlatformType.ANDROID] = {};
			args[AIRPlatformType.ANDROID][AIROptions.LISTEN] = listen;
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, true, "application.xml", "test.swf", args);
			var listenIndex:int = result.indexOf("-" + AIROptions.LISTEN);
			Assert.assertNotStrictlyEquals(listenIndex, -1);
			Assert.assertStrictlyEquals(result.indexOf(listen), listenIndex + 1);
			var connectIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertStrictlyEquals(connectIndex, -1);
		}

		[Test]
		public function testDefaultsDebugAndroid():void
		{
			var args:Object = {};
			//no listen or connect
			args[AIRPlatformType.ANDROID] = {};
			var result:Array = AIROptionsParser.parse(AIRPlatformType.ANDROID, true, "application.xml", "test.swf", args);
			var connectIndex:int = result.indexOf("-" + AIROptions.CONNECT);
			Assert.assertNotStrictlyEquals(connectIndex, -1);
			var listenIndex:int = result.indexOf("-" + AIROptions.LISTEN);
			Assert.assertStrictlyEquals(listenIndex, -1);
		}
	}
}