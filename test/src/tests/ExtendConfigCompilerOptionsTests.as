package tests
{
	import com.as3mxml.asconfigc.CompilerOptions;
	import com.as3mxml.asconfigc.TopLevelFields;
	import com.as3mxml.asconfigc.utils.ConfigUtils;

	import org.apache.royale.test.Assert;

	public class ExtendConfigCompilerOptionsTests
	{
		//--- warnings

		[Test]
		public function testWarningsWithBaseAndEmptyCompilerOptions():void
		{
			var baseValue:Boolean = false;
			var baseConfig:Object =
			{
				"compilerOptions": {
					"warnings": baseValue
				}
			};
			var config:Object =
			{
				"compilerOptions": {
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.WARNINGS));
			var resultValue:* = compilerOptions[CompilerOptions.WARNINGS];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testWarningsWithBaseOnly():void
		{
			var baseValue:Boolean = false;
			var baseConfig:Object =
			{
				"compilerOptions": {
					"warnings": baseValue
				}
			};
			var config:Object =
			{
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.WARNINGS));
			var resultValue:* = compilerOptions[CompilerOptions.WARNINGS];
			Assert.assertStrictlyEquals(resultValue, baseValue);
		}

		[Test]
		public function testWarningsWithEmptyBaseCompilerOptions():void
		{
			var newValue:Boolean = true;
			var baseConfig:Object =
			{
				"compilerOptions": {
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"warnings": newValue
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.WARNINGS));
			var resultValue:* = compilerOptions[CompilerOptions.WARNINGS];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testWarningsWithoutBaseCompilerOptions():void
		{
			var newValue:Boolean = true;
			var baseConfig:Object =
			{
			};
			var config:Object =
			{
				"compilerOptions": {
					"warnings": newValue
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.WARNINGS));
			var resultValue:* = compilerOptions[CompilerOptions.WARNINGS];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		[Test]
		public function testWarningsMerge():void
		{
			var baseValue:Boolean = false;
			var newValue:Boolean = true;
			var baseConfig:Object =
			{
				"compilerOptions": {
					"warnings": baseValue
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"warnings": newValue
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.WARNINGS));
			var resultValue:* = compilerOptions[CompilerOptions.WARNINGS];
			Assert.assertStrictlyEquals(resultValue, newValue);
		}

		//--- source-path
		//since this compiler option supports appending --source-path+=src
		//the array is merged

		[Test]
		public function testSourcePathWithBaseOnly():void
		{
			var baseValue:String = "./base/src";
			var baseConfig:Object =
			{
				"compilerOptions": {
					"source-path": [
						baseValue
					]
				}
			};
			var config:Object =
			{
				"compilerOptions": {
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.SOURCE_PATH));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.SOURCE_PATH]));
			var resultValue:Array = compilerOptions[CompilerOptions.SOURCE_PATH] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0], baseValue);
		}

		[Test]
		public function testSourcePathWithBaseAndEmptyArray():void
		{
			var baseValue:String = "./base/src";
			var baseConfig:Object =
			{
				"compilerOptions": {
					"source-path": [
						baseValue
					]
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"source-path": [
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.SOURCE_PATH));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.SOURCE_PATH]));
			var resultValue:Array = compilerOptions[CompilerOptions.SOURCE_PATH] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0], baseValue);
		}

		[Test]
		public function testSourcePathWithoutBase():void
		{
			var newValue:String = "./new/src";
			var baseConfig:Object =
			{
				"compilerOptions": {
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"source-path": [
						newValue
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.SOURCE_PATH));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.SOURCE_PATH]));
			var resultValue:Array = compilerOptions[CompilerOptions.SOURCE_PATH] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0], newValue);
		}

		[Test]
		public function testSourcePathWithBaseEmpty():void
		{
			var newValue:String = "./new/src";
			var baseConfig:Object =
			{
				"compilerOptions": {
					"source-path": [
					]
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"source-path": [
						newValue
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.SOURCE_PATH));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.SOURCE_PATH]));
			var resultValue:Array = compilerOptions[CompilerOptions.SOURCE_PATH] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0], newValue);
		}

		[Test]
		public function testSourcePathMerge():void
		{
			var baseValue:String = "./base/src";
			var newValue:String = "./new/src";
			var baseConfig:Object =
			{
				"compilerOptions": {
					"source-path": [
						baseValue
					]
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"source-path": [
						newValue
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.SOURCE_PATH));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.SOURCE_PATH]));
			var resultValue:Array = compilerOptions[CompilerOptions.SOURCE_PATH] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 2);
			Assert.assertStrictlyEquals(resultValue[0], baseValue);
			Assert.assertStrictlyEquals(resultValue[1], newValue);
		}

		[Test]
		public function testSourcePathMergeDuplicates():void
		{
			var baseValue:String = "./duplicate/src";
			var newValue:String = "./duplicate/src";
			var baseConfig:Object =
			{
				"compilerOptions": {
					"source-path": [
						baseValue
					]
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"source-path": [
						newValue
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.SOURCE_PATH));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.SOURCE_PATH]));
			var resultValue:Array = compilerOptions[CompilerOptions.SOURCE_PATH] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0], baseValue);
		}

		//--- define
		//this compiler option is an array of objects, and a certain key should
		//not be duplicated

		[Test]
		public function testDefineWithBaseOnly():void
		{
			var baseName:String = "CONFIG::BASE";
			var baseValue:Boolean = false;
			var baseConfig:Object =
			{
				"compilerOptions": {
					"define": [
						{
							"name": baseName,
							"value": baseValue
						}
					]
				}
			};
			var config:Object =
			{
				"compilerOptions": {}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.DEFINE));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.DEFINE]));
			var resultValue:Array = compilerOptions[CompilerOptions.DEFINE] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0][CompilerOptions.DEFINE__NAME], baseName);
			Assert.assertStrictlyEquals(resultValue[0][CompilerOptions.DEFINE__VALUE], baseValue);
		}

		[Test]
		public function testDefineWithoutBase():void
		{
			var newName:String = "CONFIG::NEW";
			var newValue:Boolean = false;
			var baseConfig:Object =
			{
				"compilerOptions": {}
			};
			var config:Object =
			{
				"compilerOptions": {
					"define": [
						{
							"name": newName,
							"value": newValue
						}
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.DEFINE));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.DEFINE]));
			var resultValue:Array = compilerOptions[CompilerOptions.DEFINE] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0][CompilerOptions.DEFINE__NAME], newName);
			Assert.assertStrictlyEquals(resultValue[0][CompilerOptions.DEFINE__VALUE], newValue);
		}

		[Test]
		public function testDefineMerge():void
		{
			var baseName:String = "CONFIG::BASE";
			var baseValue:Boolean = false;
			var newName:String = "CONFIG::NEW";
			var newValue:Boolean = false;
			var baseConfig:Object =
			{
				"compilerOptions": {
					"define": [
						{
							"name": baseName,
							"value": baseValue
						}
					]
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"define": [
						{
							"name": newName,
							"value": newValue
						}
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.DEFINE));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.DEFINE]));
			var resultValue:Array = compilerOptions[CompilerOptions.DEFINE] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 2);
			Assert.assertStrictlyEquals(resultValue[0][CompilerOptions.DEFINE__NAME], newName);
			Assert.assertStrictlyEquals(resultValue[0][CompilerOptions.DEFINE__VALUE], newValue);
			Assert.assertStrictlyEquals(resultValue[1][CompilerOptions.DEFINE__NAME], baseName);
			Assert.assertStrictlyEquals(resultValue[1][CompilerOptions.DEFINE__VALUE], baseValue);
		}

		[Test]
		public function testDefineMergeDuplicate():void
		{
			var baseName:String = "CONFIG::DUPLICATE";
			var baseValue:Boolean = false;
			var newName:String = "CONFIG::DUPLICATE";
			var newValue:Boolean = true;
			var baseConfig:Object =
			{
				"compilerOptions": {
					"define": [
						{
							"name": baseName,
							"value": baseValue
						}
					]
				}
			};
			var config:Object =
			{
				"compilerOptions": {
					"define": [
						{
							"name": newName,
							"value": newValue
						}
					]
				}
			};
			var result:Object = ConfigUtils.mergeConfigs(config, baseConfig);
			Assert.assertTrue(result.hasOwnProperty(TopLevelFields.COMPILER_OPTIONS));
			var compilerOptions:Object = result[TopLevelFields.COMPILER_OPTIONS];
			Assert.assertTrue(compilerOptions.hasOwnProperty(CompilerOptions.DEFINE));
			Assert.assertTrue(Array.isArray(compilerOptions[CompilerOptions.DEFINE]));
			var resultValue:Array = compilerOptions[CompilerOptions.DEFINE] as Array;
			Assert.assertStrictlyEquals(resultValue.length, 1);
			Assert.assertStrictlyEquals(resultValue[0][CompilerOptions.DEFINE__NAME], newName);
			Assert.assertStrictlyEquals(resultValue[0][CompilerOptions.DEFINE__VALUE], newValue);
		}
	}
}