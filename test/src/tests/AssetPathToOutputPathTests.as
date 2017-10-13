package tests
{
	import com.nextgenactionscript.asconfigc.utils.assetPathToOutputPath;

	import nextgenas.test.assert.Assert;

	public class AssetPathToOutputPathTests
	{
		[Test]
		public function testOutputPathForAssetAtRootOfImplicitSourcePathForMainClass():void
		{
			var mainFile:String = path.resolve("./source-path-assets/src/Main.as");
			var assetPath:String = path.resolve("./source-path-assets/src/asset-at-root.txt");
			var outputDirectory:String = "./source-path-assets/bin";
			var result:String = assetPathToOutputPath(assetPath, mainFile, null, outputDirectory);
			var expectedResult:String = path.resolve("./source-path-assets/bin/asset-at-root.txt");
			Assert.strictEqual(result, expectedResult,
				"Incorrect output path for asset with path.")
		}

		[Test]
		public function testOutputPathForAssetAtRootOfSourcePath():void
		{
			var assetPath:String = path.resolve("./source-path-assets/src/asset-at-root.txt");
			var sourcePaths:Vector.<String> = new <String>[path.resolve("./source-path-assets/src")];
			var outputDirectory:String = "./source-path-assets/bin";
			var result:String = assetPathToOutputPath(assetPath, null, sourcePaths, outputDirectory);
			var expectedResult:String = path.resolve("./source-path-assets/bin/asset-at-root.txt");
			Assert.strictEqual(result, expectedResult,
				"Incorrect output path for asset with path.")
		}

		[Test]
		public function testOutputPathForAssetInSubDirectoryOfSourcePath():void
		{
			var assetPath:String = path.resolve("./source-path-assets/src/com/example/asset-in-package.txt");
			var sourcePaths:Vector.<String> = new <String>[path.resolve("./source-path-assets/src")];
			var outputDirectory:String = "./source-path-assets/bin";
			var result:String = assetPathToOutputPath(assetPath, null, sourcePaths, outputDirectory);
			var expectedResult:String = path.resolve("./source-path-assets/bin/com/example/asset-in-package.txt");
			Assert.strictEqual(result, expectedResult,
				"Incorrect output path for asset with path.")
		}
	}
}