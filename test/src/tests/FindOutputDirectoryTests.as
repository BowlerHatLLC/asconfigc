package tests
{
	import com.as3mxml.asconfigc.utils.findOutputDirectory;

	import nextgenas.test.assert.Assert;

	public class FindOutputDirectoryTests
	{
		[Test]
		public function testOutputDirectoryWithOutputPath():void
		{
			var mainFile:String = null;
			var outputPath:String = "./source-path-assets/bin/Test.swf";
			var isSWF:Boolean = true;
			var outputDirectory:String = findOutputDirectory(mainFile, outputPath, isSWF);
			Assert.strictEqual(outputDirectory, path.resolve("./source-path-assets/bin"),
				"Incorrect output directory with output path: " + outputPath);
		}

		[Test]
		public function testOutputDirectoryWithMainFileForSWF():void
		{
			var mainFile:String = "./source-path-assets/Main.as";
			var outputPath:String = null;
			var isSWF:Boolean = true;
			var outputDirectory:String = findOutputDirectory(mainFile, outputPath, isSWF);
			Assert.strictEqual(outputDirectory, path.resolve("./source-path-assets"),
				"Incorrect output directory with main file for SWF: " + mainFile);
		}

		[Test]
		public function testOutputDirectoryWithMainFileInSrcForSWF():void
		{
			var mainFile:String = "./source-path-assets/src/Main.as";
			var outputPath:String = null;
			var isSWF:Boolean = true;
			var outputDirectory:String = findOutputDirectory(mainFile, outputPath, isSWF);
			Assert.strictEqual(outputDirectory, path.resolve("./source-path-assets/src"),
				"Incorrect output directory with main file for SWF: " + mainFile);
		}

		[Test]
		public function testOutputDirectoryWithMainFileForJS():void
		{
			var mainFile:String = "./path/to/Main.as";
			var outputPath:String = null;
			var isSWF:Boolean = false;
			var outputDirectory:String = findOutputDirectory(mainFile, outputPath, isSWF);
			Assert.strictEqual(outputDirectory, path.resolve("./path/to"),
				"Incorrect output directory with main file for JS: " + mainFile);
		}

		[Test]
		public function testOutputDirectoryWithMainFileInSrcForJS():void
		{
			var mainFile:String = "./source-path-assets/src/Main.as";
			var outputPath:String = null;
			var isSWF:Boolean = false;
			var outputDirectory:String = findOutputDirectory(mainFile, outputPath, isSWF);
			Assert.strictEqual(outputDirectory, path.resolve("./source-path-assets"),
				"Incorrect output directory with main file for JS: " + mainFile);
		}

		[Test]
		public function testOutputDirectoryWithMainFileInSrcMainRoyaleForJS():void
		{
			var mainFile:String = "./source-path-assets/src/main/royale/Main.as";
			var outputPath:String = null;
			var isSWF:Boolean = false;
			var outputDirectory:String = findOutputDirectory(mainFile, outputPath, isSWF);
			Assert.strictEqual(outputDirectory, path.resolve("./source-path-assets"),
				"Incorrect output directory with main file for JS: " + mainFile);
		}

		[Test]
		public function testOutputDirectoryWithMainFileInSrcMainFlexForJS():void
		{
			var mainFile:String = "./source-path-assets/src/main/flex/Main.as";
			var outputPath:String = null;
			var isSWF:Boolean = false;
			var outputDirectory:String = findOutputDirectory(mainFile, outputPath, isSWF);
			Assert.strictEqual(outputDirectory, path.resolve("./source-path-assets"),
				"Incorrect output directory with main file for JS: " + mainFile);
		}
	}
}