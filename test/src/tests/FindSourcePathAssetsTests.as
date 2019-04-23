package tests
{
	import com.as3mxml.asconfigc.utils.findSourcePathAssets;

	import nextgenas.test.assert.Assert;

	public class FindSourcePathAssetsTests
	{
		[Test]
		public function testAssetsWithMainFileAndNoSourcePath():void
		{
			var mainFile:String = "./source-path-assets/src/Main.as";
			var sourcePaths:Vector.<String> = new <String>[];
			var outputDirectory:String = "./source-path-assets/bin";
			var excludes:Vector.<String> = new <String>[];
			var assetPaths:Array =
				findSourcePathAssets(mainFile, sourcePaths, outputDirectory, excludes);
			Assert.strictEqual(assetPaths.length, 2, "Incorrect number of assets with main file and no source paths.");
			var expectedPaths:Vector.<String> = new <String>
			[
				path.resolve("./source-path-assets/src/asset-at-root.txt"),
				path.resolve("./source-path-assets/src/com/example/asset-in-package.txt"),
			];
			var pathCount:int = expectedPaths.length;
			for(var i:int = 0; i < pathCount; i++)
			{
				var expectedPath:String = expectedPaths[i];
				Assert.true(assetPaths.indexOf(expectedPath) !== -1,
					"Could not find asset with path: " + expectedPath);
			}
		}

		[Test]
		public function testAssetsWithMainFileAndSameSourcePath():void
		{
			var mainFile:String = "./source-path-assets/src/Main.as";
			var sourcePaths:Vector.<String> = new <String>["./source-path-assets/src"];
			var outputDirectory:String = "./source-path-assets/bin";
			var excludes:Vector.<String> = new <String>[];
			var assetPaths:Array =
				findSourcePathAssets(mainFile, sourcePaths, outputDirectory, excludes);
			Assert.strictEqual(assetPaths.length, 2, "Incorrect number of assets with main file and source path.");
			var expectedPaths:Vector.<String> = new <String>
			[
				path.resolve("./source-path-assets/src/asset-at-root.txt"),
				path.resolve("./source-path-assets/src/com/example/asset-in-package.txt"),
			];
			var pathCount:int = expectedPaths.length;
			for(var i:int = 0; i < pathCount; i++)
			{
				var expectedPath:String = expectedPaths[i];
				Assert.true(assetPaths.indexOf(expectedPath) !== -1,
					"Could not find asset with path: " + expectedPath);
			}
		}

		[Test]
		public function testAssetsWithMainFileAndSourcePath():void
		{
			var mainFile:String = "./source-path-assets/src/Main.as";
			var sourcePaths:Vector.<String> = new <String>["./source-path-assets/src2"];
			var outputDirectory:String = "./source-path-assets/bin";
			var excludes:Vector.<String> = new <String>[];
			var assetPaths:Array =
				findSourcePathAssets(mainFile, sourcePaths, outputDirectory, excludes);
			Assert.strictEqual(assetPaths.length, 3, "Incorrect number of assets with main file and source path.");
			var expectedPaths:Vector.<String> = new <String>
			[
				path.resolve("./source-path-assets/src/asset-at-root.txt"),
				path.resolve("./source-path-assets/src/com/example/asset-in-package.txt"),
				path.resolve("./source-path-assets/src2/asset-in-source-path.txt"),
			];
			var pathCount:int = expectedPaths.length;
			for(var i:int = 0; i < pathCount; i++)
			{
				var expectedPath:String = expectedPaths[i];
				Assert.true(assetPaths.indexOf(expectedPath) !== -1,
					"Could not find asset with path: " + expectedPath);
			}
		}

		[Test]
		public function testExclude():void
		{
			var mainFile:String = "./source-path-assets/src/Main.as";
			var sourcePaths:Vector.<String> = new <String>[];
			var outputDirectory:String = "./source-path-assets/bin";
			var excludes:Vector.<String> = new <String>["./source-path-assets/src/asset-at-root.txt"];
			var assetPaths:Array =
				findSourcePathAssets(mainFile, sourcePaths, outputDirectory, excludes);
			Assert.strictEqual(assetPaths.length, 1, "Incorrect number of assets with excludes.");
			var expectedPaths:Vector.<String> = new <String>
			[
				path.resolve("./source-path-assets/src/com/example/asset-in-package.txt"),
			];
			var pathCount:int = expectedPaths.length;
			for(var i:int = 0; i < pathCount; i++)
			{
				var expectedPath:String = expectedPaths[i];
				Assert.true(assetPaths.indexOf(expectedPath) !== -1,
					"Could not find asset with path: " + expectedPath);
			}
		}
	}
}