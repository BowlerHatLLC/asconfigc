package tests
{
	import com.as3mxml.asconfigc.CompilerOptions;
	import com.as3mxml.asconfigc.CompilerOptionsParser;
	import com.as3mxml.asconfigc.utils.escapePath;

	import org.apache.royale.test.Assert;

	public class CompilerOptionsTests
	{
		[Test]
		public function testAccessible():void
		{
			var args:Object = {};
			args[CompilerOptions.ACCESSIBLE] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.ACCESSIBLE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.ACCESSIBLE + "=true",
				"Incorrect argument value for " + CompilerOptions.ACCESSIBLE);
		}

		[Test]
		public function testAdvancedTelemetry():void
		{
			var args:Object = {};
			args[CompilerOptions.ADVANCED_TELEMETRY] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.ADVANCED_TELEMETRY);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.ADVANCED_TELEMETRY + "=true",
				"Incorrect argument value for " + CompilerOptions.ADVANCED_TELEMETRY);
		}

		[Test]
		public function testBenchmark():void
		{
			var args:Object = {};
			args[CompilerOptions.BENCHMARK] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.BENCHMARK);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.BENCHMARK + "=true",
				"Incorrect argument value for " + CompilerOptions.BENCHMARK);
		}

		[Test]
		public function testDebug():void
		{
			var args:Object = {};
			args[CompilerOptions.DEBUG] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DEBUG);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.DEBUG + "=true",
				"Incorrect argument value for " + CompilerOptions.DEBUG);
		}

		[Test]
		public function testDebugPassword():void
		{
			var value:String = "12345";
			var args:Object = {};
			args[CompilerOptions.DEBUG_PASSWORD] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DEBUG_PASSWORD);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.DEBUG_PASSWORD + "=" + value,
				"Incorrect argument value for " + CompilerOptions.DEBUG_PASSWORD);
		}

		[Test]
		public function testDefaultFrameRate():void
		{
			var value:int = 52;
			var args:Object = {};
			args[CompilerOptions.DEFAULT_FRAME_RATE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DEFAULT_FRAME_RATE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.DEFAULT_FRAME_RATE + "=" + value,
				"Incorrect argument value for " + CompilerOptions.DEFAULT_FRAME_RATE);
		}

		[Test]
		public function testDefaultSize():void
		{
			var value:Object =
			{
				width: 828,
				height: 367
			}
			var args:Object = {};
			args[CompilerOptions.DEFAULT_SIZE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 3,
				"Incorrect argument count for " + CompilerOptions.DEFAULT_SIZE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.DEFAULT_SIZE,
				"Incorrect argument 0 value for " + CompilerOptions.DEFAULT_SIZE);
			Assert.assertStrictlyEquals(result[1], value.width.toString(),
				"Incorrect argument 1 value for " + CompilerOptions.DEFAULT_SIZE);
			Assert.assertStrictlyEquals(result[2], value.height.toString(),
				"Incorrect argument 2 value for " + CompilerOptions.DEFAULT_SIZE);
		}

		[Test]
		public function testDefaultsCssFiles():void
		{
			var value:Array =
			[
				"./test1.css",
				"./test2/test.css"
			];
			var args:Object = {};
			args[CompilerOptions.DEFAULTS_CSS_FILES] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.DEFAULTS_CSS_FILES);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.DEFAULTS_CSS_FILES + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.DEFAULTS_CSS_FILES);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.DEFAULTS_CSS_FILES + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.DEFAULTS_CSS_FILES);
		}

		[Test]
		public function testDefine():void
		{
			var value:Array =
			[
				{
					name: "CONFIG::bool",
					value: true
				},
				{
					name: "CONFIG::str",
					value: "'test'"
				},
				{
					name: "CONFIG::str2",
					value: "\"test\""
				},
				{
					name: "CONFIG::num",
					value: 12.3
				},
				{
					name: "CONFIG::expr",
					value: "2 + 4"
				}
			];
			var args:Object = {};
			args[CompilerOptions.DEFINE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 5,
				"Incorrect argument count for " + CompilerOptions.DEFINE);
			Assert.assertStrictlyEquals(result[0],
				"--" + CompilerOptions.DEFINE + "+=" + value[0].name + "," + value[0].value,
				"Incorrect argument 0 value for " + CompilerOptions.DEFINE);
			Assert.assertStrictlyEquals(result[1],
				"--" + CompilerOptions.DEFINE + "+=" + value[1].name + ",\"" + value[1].value + "\"",
				"Incorrect argument 1 value for " + CompilerOptions.DEFINE);
			Assert.assertStrictlyEquals(result[2],
				"--" + CompilerOptions.DEFINE + "+=" + value[2].name + ",\"\\\"test\\\"\"",
				"Incorrect argument 2 value for " + CompilerOptions.DEFINE);
			Assert.assertStrictlyEquals(result[3],
				"--" + CompilerOptions.DEFINE + "+=" + value[3].name + "," + value[3].value,
				"Incorrect argument 3 value for " + CompilerOptions.DEFINE);
			Assert.assertStrictlyEquals(result[4],
				"--" + CompilerOptions.DEFINE + "+=" + value[4].name + ",\"" + value[4].value + "\"",
				"Incorrect argument 4 value for " + CompilerOptions.DEFINE);
		}

		[Test]
		public function testJSDefine():void
		{
			var value:Array =
			[
				{
					name: "CONFIG::bool",
					value: true
				},
				{
					name: "CONFIG::str",
					value: "'test'"
				},
				{
					name: "CONFIG::str2",
					value: "\"test\""
				},
				{
					name: "CONFIG::num",
					value: 12.3
				},
				{
					name: "CONFIG::expr",
					value: "2 + 4"
				}
			];
			var args:Object = {};
			args[CompilerOptions.JS_DEFINE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 5,
				"Incorrect argument count for " + CompilerOptions.JS_DEFINE);
			Assert.assertStrictlyEquals(result[0],
				"--" + CompilerOptions.JS_DEFINE + "+=" + value[0].name + "," + value[0].value,
				"Incorrect argument 0 value for " + CompilerOptions.JS_DEFINE);
			Assert.assertStrictlyEquals(result[1],
				"--" + CompilerOptions.JS_DEFINE + "+=" + value[1].name + ",\"" + value[1].value + "\"",
				"Incorrect argument 1 value for " + CompilerOptions.JS_DEFINE);
			Assert.assertStrictlyEquals(result[2],
				"--" + CompilerOptions.JS_DEFINE + "+=" + value[2].name + ",\"\\\"test\\\"\"",
				"Incorrect argument 2 value for " + CompilerOptions.JS_DEFINE);
			Assert.assertStrictlyEquals(result[3],
				"--" + CompilerOptions.JS_DEFINE + "+=" + value[3].name + "," + value[3].value,
				"Incorrect argument 3 value for " + CompilerOptions.JS_DEFINE);
			Assert.assertStrictlyEquals(result[4],
				"--" + CompilerOptions.JS_DEFINE + "+=" + value[4].name + ",\"" + value[4].value + "\"",
				"Incorrect argument 4 value for " + CompilerOptions.JS_DEFINE);
		}

		[Test]
		public function testDirectory():void
		{
			var args:Object = {};
			args[CompilerOptions.DIRECTORY] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DIRECTORY);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.DIRECTORY + "=true",
				"Incorrect argument value for " + CompilerOptions.DIRECTORY);
		}

		[Test]
		public function testDumpConfig():void
		{
			var value:String = "./path/to/file.xml";
			var args:Object = {};
			args[CompilerOptions.DUMP_CONFIG] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DUMP_CONFIG);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.DUMP_CONFIG + "=" + value,
				"Incorrect argument value for " + CompilerOptions.DUMP_CONFIG);
		}

		[Test]
		public function testDumpConfigWithSpacesInPath():void
		{
			var value:String = "./path to/file.xml";
			var formattedValue:String = escapePath(value, true);
			var args:Object = {};
			args[CompilerOptions.DUMP_CONFIG] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DUMP_CONFIG);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.DUMP_CONFIG + "=" + formattedValue,
				"Incorrect argument value for " + CompilerOptions.DUMP_CONFIG);
		}

		[Test]
		public function testExternalLibraryPath():void
		{
			var value:Array =
			[
				"./test1",
				"./test2/test.swc"
			];
			var args:Object = {};
			args[CompilerOptions.EXTERNAL_LIBRARY_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.EXTERNAL_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.EXTERNAL_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.EXTERNAL_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.EXTERNAL_LIBRARY_PATH + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.EXTERNAL_LIBRARY_PATH);
		}

		[Test]
		public function testHTMLOutputFilename():void
		{
			var value:String = "output.html";
			var args:Object = {};
			args[CompilerOptions.HTML_OUTPUT_FILENAME] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.HTML_OUTPUT_FILENAME);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.HTML_OUTPUT_FILENAME + "=" + value,
				"Incorrect argument value for " + CompilerOptions.HTML_OUTPUT_FILENAME);
		}

		[Test]
		public function testHTMLTemplate():void
		{
			var value:String = "test1/html-template-file.html";
			var args:Object = {};
			args[CompilerOptions.HTML_TEMPLATE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.HTML_TEMPLATE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.HTML_TEMPLATE + "=" + value,
				"Incorrect argument value for " + CompilerOptions.HTML_TEMPLATE);
		}

		[Test]
		public function testIncludeClasses():void
		{
			var value:Array =
			[
				"com.example.SomeClass",
				"AnotherClass"
			];
			var args:Object = {};
			args[CompilerOptions.INCLUDE_CLASSES] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_CLASSES);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.INCLUDE_CLASSES + "=" + value[0] + "," + value[1],
				"Incorrect argument value for " + CompilerOptions.INCLUDE_CLASSES);
		}

		[Test]
		public function testIncludeFile():void
		{
			var value:Array =
			[
				{ file: "myfile.txt", path: "assets/myfile2.txt" },
				{ file: "path/with spaces/to/another.png", path: "another file.png" }
			];
			var formattedFile1:String = escapePath(value[1].file, true);
			var formattedPath1:String = escapePath(value[1].path, true);
			var args:Object = {};
			args[CompilerOptions.INCLUDE_FILE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_FILE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.INCLUDE_FILE + "+=" + value[0].path + "," + value[0].file,
				"Incorrect argument value for " + CompilerOptions.INCLUDE_FILE);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.INCLUDE_FILE + "+=" + formattedPath1 + "," + formattedFile1,
				"Incorrect argument value for " + CompilerOptions.INCLUDE_FILE);
		}

		[Test]
		public function testIncludeLibraries():void
		{
			var value:Array =
			[
				"./test1/file.swc"
			];
			var args:Object = {};
			args[CompilerOptions.INCLUDE_LIBRARIES] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_LIBRARIES);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.INCLUDE_LIBRARIES + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.INCLUDE_LIBRARIES);
		}

		[Test]
		public function testIncludeLibrariesWithSpacesInPath():void
		{
			var value:Array =
			[
				"./test 3.swc"
			];
			var formattedPath:String = escapePath(value[0], true);
			var args:Object = {};
			args[CompilerOptions.INCLUDE_LIBRARIES] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_LIBRARIES);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.INCLUDE_LIBRARIES + "+=" + formattedPath,
				"Incorrect argument value for " + CompilerOptions.INCLUDE_LIBRARIES);
		}

		[Test]
		public function testIncludeNamespaces():void
		{
			var value:Array =
			[
				"http://ns.example.com",
				"library://example.com/library"
			];
			var args:Object = {};
			args[CompilerOptions.INCLUDE_NAMESPACES] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_NAMESPACES);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.INCLUDE_NAMESPACES + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.INCLUDE_NAMESPACES);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.INCLUDE_NAMESPACES + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.INCLUDE_NAMESPACES);
		}

		[Test]
		public function testIncludeSources():void
		{
			var value:Array =
			[
				"./test1",
				"test2"
			];
			var args:Object = {};
			args[CompilerOptions.INCLUDE_SOURCES] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_SOURCES);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.INCLUDE_SOURCES + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.INCLUDE_SOURCES);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.INCLUDE_SOURCES + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.INCLUDE_SOURCES);
		}

		[Test]
		public function testJSCompilerOption():void
		{
			var value:Array =
			[
				"--compilation_level WHITESPACE_ONLY"
			];
			var args:Object = {};
			args[CompilerOptions.JS_COMPILER_OPTION] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.JS_COMPILER_OPTION + "+=\"" + value[0] + "\"",
				"Incorrect argument 0 value for " + CompilerOptions.JS_COMPILER_OPTION);
		}

		[Test]
		public function testJSDefaultInitializers():void
		{
			var args:Object = {};
			args[CompilerOptions.JS_DEFAULT_INITIALIZERS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_DEFAULT_INITIALIZERS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.JS_DEFAULT_INITIALIZERS + "=true",
				"Incorrect argument value for " + CompilerOptions.JS_DEFAULT_INITIALIZERS);
		}

		[Test]
		public function testJSExternalLibraryPath():void
		{
			var value:Array =
			[
				"./test1",
				"./test2/test.swc"
			];
			var args:Object = {};
			args[CompilerOptions.JS_EXTERNAL_LIBRARY_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH);
		}

		[Test]
		public function testJSLibraryPath():void
		{
			var value:Array =
			[
				"./test1/file.swc"
			];
			var args:Object = {};
			args[CompilerOptions.JS_LIBRARY_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.JS_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.JS_LIBRARY_PATH);
		}

		[Test]
		public function testJSOutput():void
		{
			var value:String = "path/to/Output";
			var args:Object = {};
			args[CompilerOptions.JS_OUTPUT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_OUTPUT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.JS_OUTPUT + "=" + value,
				"Incorrect argument value for " + CompilerOptions.JS_OUTPUT);
		}

		[Test]
		public function testJSOutputType():void
		{
			var value:String = "node";
			var args:Object = {};
			args[CompilerOptions.JS_OUTPUT_TYPE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_OUTPUT_TYPE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.JS_OUTPUT_TYPE + "=" + value,
				"Incorrect argument value for " + CompilerOptions.JS_OUTPUT_TYPE);
		}

		[Test]
		public function testKeepAllTypeSelectors():void
		{
			var args:Object = {};
			args[CompilerOptions.KEEP_ALL_TYPE_SELECTORS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.KEEP_ALL_TYPE_SELECTORS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.KEEP_ALL_TYPE_SELECTORS + "=true",
				"Incorrect argument value for " + CompilerOptions.KEEP_ALL_TYPE_SELECTORS);
		}

		[Test]
		public function testKeepAS3Metadata():void
		{
			var value:Array =
			[
				"Inject",
				"Test",
			];
			var args:Object = {};
			args[CompilerOptions.KEEP_AS3_METADATA] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.KEEP_AS3_METADATA);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.KEEP_AS3_METADATA + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.KEEP_AS3_METADATA);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.KEEP_AS3_METADATA + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.KEEP_AS3_METADATA);
		}

		[Test]
		public function testKeepGeneratedActionScript():void
		{
			var args:Object = {};
			args[CompilerOptions.KEEP_GENERATED_ACTIONSCRIPT] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.KEEP_GENERATED_ACTIONSCRIPT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.KEEP_GENERATED_ACTIONSCRIPT + "=true",
				"Incorrect argument value for " + CompilerOptions.KEEP_GENERATED_ACTIONSCRIPT);
		}

		[Test]
		public function testLibraryPath():void
		{
			var value:Array =
			[
				"./test1/file.swc"
			];
			var args:Object = {};
			args[CompilerOptions.LIBRARY_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.LIBRARY_PATH);
		}

		[Test]
		public function testLibraryPathWithSpacesInPath():void
		{
			var value:Array =
			[
				"./test 3"
			];
			var formattedPath:String = escapePath(value[0], true);
			var args:Object = {};
			args[CompilerOptions.LIBRARY_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.LIBRARY_PATH + "+=" + formattedPath,
				"Incorrect argument value for " + CompilerOptions.LIBRARY_PATH);
		}

		[Test]
		public function testLinkReport():void
		{
			var value:String = "path/to/link-report.xml";
			var args:Object = {};
			args[CompilerOptions.LINK_REPORT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LINK_REPORT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.LINK_REPORT + "=" + value,
				"Incorrect argument value for " + CompilerOptions.LINK_REPORT);
		}

		[Test]
		public function testLinkReportWithSpacesInPath():void
		{
			var value:String = "path to/link-report.xml";
			var formattedValue:String = escapePath(value, true);
			var args:Object = {};
			args[CompilerOptions.LINK_REPORT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LINK_REPORT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.LINK_REPORT + "=" + formattedValue,
				"Incorrect argument value for " + CompilerOptions.LINK_REPORT);
		}

		[Test]
		public function testLoadConfig():void
		{
			var value:Array =
			[
				"test1/test-config.xml"
			];
			var args:Object = {};
			args[CompilerOptions.LOAD_CONFIG] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LOAD_CONFIG);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.LOAD_CONFIG + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.LOAD_CONFIG);
		}

		[Test]
		public function testLoadExterns():void
		{
			var value:Array =
			[
				"test1/test-externs.xml"
			];
			var args:Object = {};
			args[CompilerOptions.LOAD_EXTERNS] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LOAD_EXTERNS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.LOAD_EXTERNS + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.LOAD_EXTERNS);
		}

		[Test]
		public function testJSLoadConfig():void
		{
			var value:Array =
			[
				"test1/test-config.xml"
			];
			var args:Object = {};
			args[CompilerOptions.JS_LOAD_CONFIG] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_LOAD_CONFIG);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.JS_LOAD_CONFIG + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.JS_LOAD_CONFIG);
		}

		[Test]
		public function testLocale():void
		{
			var value:Array =
			[
				"en_US",
				"fr_FR",
			];
			var args:Object = {};
			args[CompilerOptions.LOCALE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.LOCALE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.LOCALE + "=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.LOCALE);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.LOCALE + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.LOCALE);
		}

		[Test]
		public function testNamespace():void
		{
			var value:Array =
			[
				{
					uri: "http://ns.example.com",
					manifest: "manifest.xml"
				},
				{
					uri: "library://example.com/library",
					manifest: "path/with spaces/to/manifest.xml"
				}
			];
			var formattedManifest:String = escapePath(value[1].manifest, true);
			var args:Object = {};
			args[CompilerOptions.NAMESPACE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.NAMESPACE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.NAMESPACE + "+=" + value[0].uri + "," + value[0].manifest,
				"Incorrect argument 0 value for " + CompilerOptions.NAMESPACE);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.NAMESPACE + "+=" + value[1].uri + "," + formattedManifest,
				"Incorrect argument 1 value for " + CompilerOptions.NAMESPACE);
		}

		[Test]
		public function testOmitTraceStatements():void
		{
			var args:Object = {};
			args[CompilerOptions.OMIT_TRACE_STATEMENTS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.OMIT_TRACE_STATEMENTS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.OMIT_TRACE_STATEMENTS + "=true",
				"Incorrect argument value for " + CompilerOptions.OMIT_TRACE_STATEMENTS);
		}

		[Test]
		public function testOptimize():void
		{
			var args:Object = {};
			args[CompilerOptions.OPTIMIZE] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.OPTIMIZE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.OPTIMIZE + "=true",
				"Incorrect argument value for " + CompilerOptions.OPTIMIZE);
		}

		[Test]
		public function testOutput():void
		{
			var value:String = "path/to/Output.swf";
			var args:Object = {};
			args[CompilerOptions.OUTPUT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.OUTPUT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.OUTPUT + "=" + value,
				"Incorrect argument value for " + CompilerOptions.OUTPUT);
		}

		[Test]
		public function testOutputWithSpacesInPath():void
		{
			var value:String = "path to/Output.swf";
			var formattedValue:String = escapePath(value, true);
			var args:Object = {};
			args[CompilerOptions.OUTPUT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.OUTPUT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.OUTPUT + "=" + formattedValue,
				"Incorrect argument value for " + CompilerOptions.OUTPUT);
		}

		[Test]
		public function testPreloader():void
		{
			var value:String = "mx.preloaders.SparkDownloadProgressBar";
			var args:Object = {};
			args[CompilerOptions.PRELOADER] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.PRELOADER);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.PRELOADER + "=" + value,
				"Incorrect argument value for " + CompilerOptions.PRELOADER);
		}

		[Test]
		public function testRemoveCirculars():void
		{
			var args:Object = {};
			args[CompilerOptions.REMOVE_CIRCULARS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.REMOVE_CIRCULARS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.REMOVE_CIRCULARS + "=true",
				"Incorrect argument value for " + CompilerOptions.REMOVE_CIRCULARS);
		}

		[Test]
		public function testShowUnusedTypeSelectorWarnings():void
		{
			var args:Object = {};
			args[CompilerOptions.SHOW_UNUSED_TYPE_SELECTOR_WARNINGS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SHOW_UNUSED_TYPE_SELECTOR_WARNINGS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SHOW_UNUSED_TYPE_SELECTOR_WARNINGS + "=true",
				"Incorrect argument value for " + CompilerOptions.SHOW_UNUSED_TYPE_SELECTOR_WARNINGS);
		}

		[Test]
		public function testSizeReport():void
		{
			var value:String = "path/to/size-report.xml";
			var args:Object = {};
			args[CompilerOptions.SIZE_REPORT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SIZE_REPORT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SIZE_REPORT + "=" + value,
				"Incorrect argument value for " + CompilerOptions.SIZE_REPORT);
		}

		[Test]
		public function testSizeReportWithSpacesInPath():void
		{
			var value:String = "path to/size-report.xml";
			var formattedValue:String = escapePath(value, true);
			var args:Object = {};
			args[CompilerOptions.SIZE_REPORT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SIZE_REPORT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SIZE_REPORT + "=" + formattedValue,
				"Incorrect argument value for " + CompilerOptions.SIZE_REPORT);
		}

		[Test]
		public function testSourceMap():void
		{
			var args:Object = {};
			args[CompilerOptions.SOURCE_MAP] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SOURCE_MAP);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SOURCE_MAP + "=true",
				"Incorrect argument value for " + CompilerOptions.SOURCE_MAP);
		}

		[Test]
		public function testSourcePath():void
		{
			var value:Array =
			[
				"./test1",
				"./test2"
			];
			var args:Object = {};
			args[CompilerOptions.SOURCE_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.SOURCE_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SOURCE_PATH + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.SOURCE_PATH);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.SOURCE_PATH + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.SOURCE_PATH);
		}

		[Test]
		public function testSourcePathWithSpacesInPath():void
		{
			var value:Array =
			[
				"./test 3"
			];
			var formattedPath:String = escapePath(value[0], true);
			var args:Object = {};
			args[CompilerOptions.SOURCE_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SOURCE_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SOURCE_PATH + "+=" + formattedPath,
				"Incorrect argument 0 value for " + CompilerOptions.SOURCE_PATH);
		}

		[Test]
		public function testStaticLinkRuntimeSharedLibraries():void
		{
			var args:Object = {};
			args[CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES + "=true",
				"Incorrect argument value for " + CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES);
		}

		[Test]
		public function testStrict():void
		{
			var args:Object = {};
			args[CompilerOptions.STRICT] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.STRICT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.STRICT + "=true",
				"Incorrect argument value for " + CompilerOptions.STRICT);
		}

		[Test]
		public function testSWFExternalLibraryPath():void
		{
			var value:Array =
			[
				"./test1",
				"./test2/test.swc"
			];
			var args:Object = {};
			args[CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH);
		}

		[Test]
		public function testSWFLibraryPath():void
		{
			var value:Array =
			[
				"./test1/file.swc"
			];
			var args:Object = {};
			args[CompilerOptions.SWF_LIBRARY_PATH] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SWF_LIBRARY_PATH);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SWF_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.SWF_LIBRARY_PATH);
		}

		[Test]
		public function testSWFVersion():void
		{
			var value:int = 30;
			var args:Object = {};
			args[CompilerOptions.SWF_VERSION] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SWF_VERSION);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.SWF_VERSION + "=" + value,
				"Incorrect argument value for " + CompilerOptions.SWF_VERSION);
		}

		[Test]
		public function testTargetPlayer():void
		{
			var value:String = "22.0";
			var args:Object = {};
			args[CompilerOptions.TARGET_PLAYER] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.TARGET_PLAYER);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.TARGET_PLAYER + "=" + value,
				"Incorrect argument value for " + CompilerOptions.TARGET_PLAYER);
		}

		[Test]
		public function testTargetsWithOneValue():void
		{
			var value:Array = ["JS"];
			var args:Object = {};
			args[CompilerOptions.TARGETS] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.TARGETS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.TARGETS + "=" + value[0],
				"Incorrect argument value for " + CompilerOptions.TARGETS);
		}

		[Test]
		public function testTargetsWithTwoValues():void
		{
			var value:Array = ["JS","SWF"];
			var args:Object = {};
			args[CompilerOptions.TARGETS] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.TARGETS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.TARGETS + "=" + value[0] + "," + value[1],
				"Incorrect argument value for " + CompilerOptions.TARGETS);
		}

		[Test]
		public function testTheme():void
		{
			var value:String = "./path/to/file.swc";
			var args:Object = {};
			args[CompilerOptions.THEME] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.THEME);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.THEME + "=" + value,
				"Incorrect argument value for " + CompilerOptions.THEME);
		}

		[Test]
		public function testThemeMultiple():void
		{
			var value:Array =
			[
				"./path/to/file.swc",
				"another_file.swc"
			];
			var args:Object = {};
			args[CompilerOptions.THEME] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.THEME);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.THEME + "=" + value[0],
				"Incorrect argument value for " + CompilerOptions.THEME);
			Assert.assertStrictlyEquals(result[1], "--" + CompilerOptions.THEME + "+=" + value[1],
				"Incorrect argument value for " + CompilerOptions.THEME);
		}

		[Test]
		public function testToolsLocale():void
		{
			var value:String = "fr_FR";
			var args:Object = {};
			args[CompilerOptions.TOOLS_LOCALE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.TOOLS_LOCALE);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.TOOLS_LOCALE + "=" + value,
				"Incorrect argument value for " + CompilerOptions.TOOLS_LOCALE);
		}

		[Test]
		public function testUseDirectBlit():void
		{
			var args:Object = {};
			args[CompilerOptions.USE_DIRECT_BLIT] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.USE_DIRECT_BLIT);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.USE_DIRECT_BLIT + "=true",
				"Incorrect argument value for " + CompilerOptions.USE_DIRECT_BLIT);
		}

		[Test]
		public function testUseGPU():void
		{
			var args:Object = {};
			args[CompilerOptions.USE_GPU] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.USE_GPU);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.USE_GPU + "=true",
				"Incorrect argument value for " + CompilerOptions.USE_GPU);
		}

		[Test]
		public function testUseNetwork():void
		{
			var args:Object = {};
			args[CompilerOptions.USE_NETWORK] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.USE_NETWORK);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.USE_NETWORK + "=true",
				"Incorrect argument value for " + CompilerOptions.USE_NETWORK);
		}

		[Test]
		public function testUseResourceBundleMetadata():void
		{
			var args:Object = {};
			args[CompilerOptions.USE_RESOURCE_BUNDLE_METADATA] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.USE_RESOURCE_BUNDLE_METADATA);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.USE_RESOURCE_BUNDLE_METADATA + "=true",
				"Incorrect argument value for " + CompilerOptions.USE_RESOURCE_BUNDLE_METADATA);
		}

		[Test]
		public function testVerboseStacktraces():void
		{
			var args:Object = {};
			args[CompilerOptions.VERBOSE_STACKTRACES] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.VERBOSE_STACKTRACES);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.VERBOSE_STACKTRACES + "=true",
				"Incorrect argument value for " + CompilerOptions.VERBOSE_STACKTRACES);
		}

		[Test]
		public function testWarnings():void
		{
			var args:Object = {};
			args[CompilerOptions.WARNINGS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.WARNINGS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.WARNINGS + "=true",
				"Incorrect argument value for " + CompilerOptions.WARNINGS);
		}

		[Test]
		public function testWarnPublicVars():void
		{
			var args:Object = {};
			args[CompilerOptions.WARN_PUBLIC_VARS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.assertStrictlyEquals(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.WARN_PUBLIC_VARS);
			Assert.assertStrictlyEquals(result[0], "--" + CompilerOptions.WARN_PUBLIC_VARS + "=true",
				"Incorrect argument value for " + CompilerOptions.WARN_PUBLIC_VARS);
		}
	}
}