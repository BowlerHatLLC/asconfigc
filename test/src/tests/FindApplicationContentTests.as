package tests
{
	import com.as3mxml.asconfigc.utils.findApplicationContent;

	import nextgenas.test.assert.Assert;

	public class FindApplicationContentTests
	{
		[Test]
		public function testApplicationContentWithOutputPath():void
		{
			var mainFile:String = null;
			var outputPath:String = "./source-path-assets/bin/Test.swf";
			var isSWF:Boolean = true;
			var applicationContent:String = findApplicationContent(mainFile, outputPath, isSWF);
			Assert.strictEqual(applicationContent, "Test.swf",
				"Incorrect application content with output path: " + outputPath);
		}

		[Test]
		public function testApplicationContentWithMainFileForSWF():void
		{
			var mainFile:String = "./source-path-assets/src/Main.as";
			var outputPath:String = null;
			var isSWF:Boolean = true;
			var applicationContent:String = findApplicationContent(mainFile, outputPath, isSWF);
			Assert.strictEqual(applicationContent, "Main.swf",
				"Incorrect application content with main file for SWF: " + mainFile);
		}

		[Test]
		public function testApplicationContentWithMainFileForJS():void
		{
			var mainFile:String = "./source-path-assets/src/Main.as";
			var outputPath:String = null;
			var isSWF:Boolean = false;
			var applicationContent:String = findApplicationContent(mainFile, outputPath, isSWF);
			Assert.strictEqual(applicationContent, "index.html",
				"Incorrect application content with main file for JS: " + mainFile);
		}
	}
}