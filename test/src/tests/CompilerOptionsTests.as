package tests
{
	import com.nextgenactionscript.asconfigc.CompilerOptions;
	import com.nextgenactionscript.asconfigc.CompilerOptionsParser;

	import nextgenas.test.assert.Assert;
	import com.nextgenactionscript.asconfigc.utils.escapePath;

	public class CompilerOptionsTests
	{
		[Test]
		public function testAccessible():void
		{
			var args:Object = {};
			args[CompilerOptions.ACCESSIBLE] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.ACCESSIBLE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.ACCESSIBLE + "=true",
				"Incorrect argument value for " + CompilerOptions.ACCESSIBLE);
		}

		[Test]
		public function testAdvancedTelemetry():void
		{
			var args:Object = {};
			args[CompilerOptions.ADVANCED_TELEMETRY] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.ADVANCED_TELEMETRY);
			Assert.strictEqual(result[0], "--" + CompilerOptions.ADVANCED_TELEMETRY + "=true",
				"Incorrect argument value for " + CompilerOptions.ADVANCED_TELEMETRY);
		}

		[Test]
		public function testBenchmark():void
		{
			var args:Object = {};
			args[CompilerOptions.BENCHMARK] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.BENCHMARK);
			Assert.strictEqual(result[0], "--" + CompilerOptions.BENCHMARK + "=true",
				"Incorrect argument value for " + CompilerOptions.BENCHMARK);
		}

		[Test]
		public function testDebug():void
		{
			var args:Object = {};
			args[CompilerOptions.DEBUG] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DEBUG);
			Assert.strictEqual(result[0], "--" + CompilerOptions.DEBUG + "=true",
				"Incorrect argument value for " + CompilerOptions.DEBUG);
		}

		[Test]
		public function testDebugPassword():void
		{
			var value:String = "12345";
			var args:Object = {};
			args[CompilerOptions.DEBUG_PASSWORD] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DEBUG_PASSWORD);
			Assert.strictEqual(result[0], "--" + CompilerOptions.DEBUG_PASSWORD + "=" + value,
				"Incorrect argument value for " + CompilerOptions.DEBUG_PASSWORD);
		}

		[Test]
		public function testDefaultFrameRate():void
		{
			var value:int = 52;
			var args:Object = {};
			args[CompilerOptions.DEFAULT_FRAME_RATE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DEFAULT_FRAME_RATE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.DEFAULT_FRAME_RATE + "=" + value,
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
			Assert.strictEqual(result.length, 3,
				"Incorrect argument count for " + CompilerOptions.DEFAULT_SIZE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.DEFAULT_SIZE,
				"Incorrect argument 0 value for " + CompilerOptions.DEFAULT_SIZE);
			Assert.strictEqual(result[1], value.width.toString(),
				"Incorrect argument 1 value for " + CompilerOptions.DEFAULT_SIZE);
			Assert.strictEqual(result[2], value.height.toString(),
				"Incorrect argument 2 value for " + CompilerOptions.DEFAULT_SIZE);
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
			Assert.strictEqual(result.length, 5,
				"Incorrect argument count for " + CompilerOptions.DEFINE);
			Assert.strictEqual(result[0],
				"--" + CompilerOptions.DEFINE + "+=" + value[0].name + "," + value[0].value,
				"Incorrect argument 0 value for " + CompilerOptions.DEFINE);
			Assert.strictEqual(result[1],
				"--" + CompilerOptions.DEFINE + "+=" + value[1].name + ",\"" + value[1].value + "\"",
				"Incorrect argument 1 value for " + CompilerOptions.DEFINE);
			Assert.strictEqual(result[2],
				"--" + CompilerOptions.DEFINE + "+=" + value[2].name + ",\"\\\"test\\\"\"",
				"Incorrect argument 2 value for " + CompilerOptions.DEFINE);
			Assert.strictEqual(result[3],
				"--" + CompilerOptions.DEFINE + "+=" + value[3].name + "," + value[3].value,
				"Incorrect argument 3 value for " + CompilerOptions.DEFINE);
			Assert.strictEqual(result[4],
				"--" + CompilerOptions.DEFINE + "+=" + value[4].name + ",\"" + value[4].value + "\"",
				"Incorrect argument 4 value for " + CompilerOptions.DEFINE);
		}

		[Test]
		public function testDumpConfig():void
		{
			var value:String = "./path/to/file.xml";
			var args:Object = {};
			args[CompilerOptions.DUMP_CONFIG] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DUMP_CONFIG);
			Assert.strictEqual(result[0], "--" + CompilerOptions.DUMP_CONFIG + "=" + value,
				"Incorrect argument value for " + CompilerOptions.DUMP_CONFIG);
		}

		[Test]
		public function testDumpConfigWithSpacesInPath():void
		{
			var value:String = "./path to/file.xml";
			var formattedValue:String = escapePath(value);
			var args:Object = {};
			args[CompilerOptions.DUMP_CONFIG] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.DUMP_CONFIG);
			Assert.strictEqual(result[0], "--" + CompilerOptions.DUMP_CONFIG + "=" + formattedValue,
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.EXTERNAL_LIBRARY_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.EXTERNAL_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.EXTERNAL_LIBRARY_PATH);
			Assert.strictEqual(result[1], "--" + CompilerOptions.EXTERNAL_LIBRARY_PATH + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.EXTERNAL_LIBRARY_PATH);
		}

		[Test]
		public function testHTMLOutputFilename():void
		{
			var value:String = "output.html";
			var args:Object = {};
			args[CompilerOptions.HTML_OUTPUT_FILENAME] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.HTML_OUTPUT_FILENAME);
			Assert.strictEqual(result[0], "--" + CompilerOptions.HTML_OUTPUT_FILENAME + "=" + value,
				"Incorrect argument value for " + CompilerOptions.HTML_OUTPUT_FILENAME);
		}

		[Test]
		public function testHTMLTemplate():void
		{
			var value:String = "test1/html-template-file.html";
			var args:Object = {};
			args[CompilerOptions.HTML_TEMPLATE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.HTML_TEMPLATE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.HTML_TEMPLATE + "=" + value,
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_CLASSES);
			Assert.strictEqual(result[0], "--" + CompilerOptions.INCLUDE_CLASSES + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.INCLUDE_CLASSES);
			Assert.strictEqual(result[1], "--" + CompilerOptions.INCLUDE_CLASSES + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.INCLUDE_CLASSES);
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_NAMESPACES);
			Assert.strictEqual(result[0], "--" + CompilerOptions.INCLUDE_NAMESPACES + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.INCLUDE_NAMESPACES);
			Assert.strictEqual(result[1], "--" + CompilerOptions.INCLUDE_NAMESPACES + "+=" + value[1],
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.INCLUDE_SOURCES);
			Assert.strictEqual(result[0], "--" + CompilerOptions.INCLUDE_SOURCES + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.INCLUDE_SOURCES);
			Assert.strictEqual(result[1], "--" + CompilerOptions.INCLUDE_SOURCES + "+=" + value[1],
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
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.JS_COMPILER_OPTION + "+=\"" + value[0] + "\"",
				"Incorrect argument 0 value for " + CompilerOptions.JS_COMPILER_OPTION);
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH);
			Assert.strictEqual(result[1], "--" + CompilerOptions.JS_EXTERNAL_LIBRARY_PATH + "+=" + value[1],
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
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_LIBRARY_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.JS_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.JS_LIBRARY_PATH);
		}

		[Test]
		public function testJSOutputType():void
		{
			var value:String = "node";
			var args:Object = {};
			args[CompilerOptions.JS_OUTPUT_TYPE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.JS_OUTPUT_TYPE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.JS_OUTPUT_TYPE + "=" + value,
				"Incorrect argument value for " + CompilerOptions.JS_OUTPUT_TYPE);
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.KEEP_AS3_METADATA);
			Assert.strictEqual(result[0], "--" + CompilerOptions.KEEP_AS3_METADATA + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.KEEP_AS3_METADATA);
			Assert.strictEqual(result[1], "--" + CompilerOptions.KEEP_AS3_METADATA + "+=" + value[1],
				"Incorrect argument 1 value for " + CompilerOptions.KEEP_AS3_METADATA);
		}

		[Test]
		public function testKeepGeneratedActionScript():void
		{
			var args:Object = {};
			args[CompilerOptions.KEEP_GENERATED_ACTIONSCRIPT] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.KEEP_GENERATED_ACTIONSCRIPT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.KEEP_GENERATED_ACTIONSCRIPT + "=true",
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
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LIBRARY_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.LIBRARY_PATH + "+=" + value[0],
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
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LIBRARY_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.LIBRARY_PATH + "+=" + formattedPath,
				"Incorrect argument value for " + CompilerOptions.LIBRARY_PATH);
		}

		[Test]
		public function testLinkReport():void
		{
			var value:String = "path/to/link-report.xml";
			var args:Object = {};
			args[CompilerOptions.LINK_REPORT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LINK_REPORT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.LINK_REPORT + "=" + value,
				"Incorrect argument value for " + CompilerOptions.LINK_REPORT);
		}

		[Test]
		public function testLinkReportWithSpacesInPath():void
		{
			var value:String = "path to/link-report.xml";
			var formattedValue:String = escapePath(value);
			var args:Object = {};
			args[CompilerOptions.LINK_REPORT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LINK_REPORT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.LINK_REPORT + "=" + formattedValue,
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
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.LOAD_CONFIG);
			Assert.strictEqual(result[0], "--" + CompilerOptions.LOAD_CONFIG + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.LOAD_CONFIG);
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.LOCALE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.LOCALE + "=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.LOCALE);
			Assert.strictEqual(result[1], "--" + CompilerOptions.LOCALE + "+=" + value[1],
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
					manifest: "path/to/manifest.xml"
				}
			];
			var args:Object = {};
			args[CompilerOptions.NAMESPACE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 6,
				"Incorrect argument count for " + CompilerOptions.NAMESPACE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.NAMESPACE,
				"Incorrect argument 0 value for " + CompilerOptions.NAMESPACE);
			Assert.strictEqual(result[1], value[0].uri,
				"Incorrect argument 1 value for " + CompilerOptions.NAMESPACE);
			Assert.strictEqual(result[2], value[0].manifest,
				"Incorrect argument 2 value for " + CompilerOptions.NAMESPACE);
			Assert.strictEqual(result[3], "--" + CompilerOptions.NAMESPACE,
				"Incorrect argument 3 value for " + CompilerOptions.NAMESPACE);
			Assert.strictEqual(result[4], value[1].uri,
				"Incorrect argument 4 value for " + CompilerOptions.NAMESPACE);
			Assert.strictEqual(result[5], value[1].manifest,
				"Incorrect argument 5 value for " + CompilerOptions.NAMESPACE);
		}

		[Test]
		public function testOmitTraceStatements():void
		{
			var args:Object = {};
			args[CompilerOptions.OMIT_TRACE_STATEMENTS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.OMIT_TRACE_STATEMENTS);
			Assert.strictEqual(result[0], "--" + CompilerOptions.OMIT_TRACE_STATEMENTS + "=true",
				"Incorrect argument value for " + CompilerOptions.OMIT_TRACE_STATEMENTS);
		}

		[Test]
		public function testOptimize():void
		{
			var args:Object = {};
			args[CompilerOptions.OPTIMIZE] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.OPTIMIZE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.OPTIMIZE + "=true",
				"Incorrect argument value for " + CompilerOptions.OPTIMIZE);
		}

		[Test]
		public function testOutput():void
		{
			var value:String = "path/to/Output.swf";
			var args:Object = {};
			args[CompilerOptions.OUTPUT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.OUTPUT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.OUTPUT + "=" + value,
				"Incorrect argument value for " + CompilerOptions.OUTPUT);
		}

		[Test]
		public function testOutputWithSpacesInPath():void
		{
			var value:String = "path to/Output.swf";
			var formattedValue:String = escapePath(value);
			var args:Object = {};
			args[CompilerOptions.OUTPUT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.OUTPUT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.OUTPUT + "=" + formattedValue,
				"Incorrect argument value for " + CompilerOptions.OUTPUT);
		}

		[Test]
		public function testPreloader():void
		{
			var value:String = "mx.preloaders.SparkDownloadProgressBar";
			var args:Object = {};
			args[CompilerOptions.PRELOADER] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.PRELOADER);
			Assert.strictEqual(result[0], "--" + CompilerOptions.PRELOADER + "=" + value,
				"Incorrect argument value for " + CompilerOptions.PRELOADER);
		}

		[Test]
		public function testRemoveCirculars():void
		{
			var args:Object = {};
			args[CompilerOptions.REMOVE_CIRCULARS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.REMOVE_CIRCULARS);
			Assert.strictEqual(result[0], "--" + CompilerOptions.REMOVE_CIRCULARS + "=true",
				"Incorrect argument value for " + CompilerOptions.REMOVE_CIRCULARS);
		}

		[Test]
		public function testSizeReport():void
		{
			var value:String = "path/to/size-report.xml";
			var args:Object = {};
			args[CompilerOptions.SIZE_REPORT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SIZE_REPORT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.SIZE_REPORT + "=" + value,
				"Incorrect argument value for " + CompilerOptions.SIZE_REPORT);
		}

		[Test]
		public function testSizeReportWithSpacesInPath():void
		{
			var value:String = "path to/size-report.xml";
			var formattedValue:String = escapePath(value);
			var args:Object = {};
			args[CompilerOptions.SIZE_REPORT] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SIZE_REPORT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.SIZE_REPORT + "=" + formattedValue,
				"Incorrect argument value for " + CompilerOptions.SIZE_REPORT);
		}

		[Test]
		public function testSourceMap():void
		{
			var args:Object = {};
			args[CompilerOptions.SOURCE_MAP] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SOURCE_MAP);
			Assert.strictEqual(result[0], "--" + CompilerOptions.SOURCE_MAP + "=true",
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.SOURCE_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.SOURCE_PATH + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.SOURCE_PATH);
			Assert.strictEqual(result[1], "--" + CompilerOptions.SOURCE_PATH + "+=" + value[1],
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
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SOURCE_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.SOURCE_PATH + "+=" + formattedPath,
				"Incorrect argument 0 value for " + CompilerOptions.SOURCE_PATH);
		}

		[Test]
		public function testStaticLinkRuntimeSharedLibraries():void
		{
			var args:Object = {};
			args[CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES);
			Assert.strictEqual(result[0], "--" + CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES + "=true",
				"Incorrect argument value for " + CompilerOptions.STATIC_LINK_RUNTIME_SHARED_LIBRARIES);
		}

		[Test]
		public function testStrict():void
		{
			var args:Object = {};
			args[CompilerOptions.STRICT] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.STRICT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.STRICT + "=true",
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
			Assert.strictEqual(result.length, 2,
				"Incorrect argument count for " + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument 0 value for " + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH);
			Assert.strictEqual(result[1], "--" + CompilerOptions.SWF_EXTERNAL_LIBRARY_PATH + "+=" + value[1],
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
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SWF_LIBRARY_PATH);
			Assert.strictEqual(result[0], "--" + CompilerOptions.SWF_LIBRARY_PATH + "+=" + value[0],
				"Incorrect argument value for " + CompilerOptions.SWF_LIBRARY_PATH);
		}

		[Test]
		public function testSWFVersion():void
		{
			var value:int = 30;
			var args:Object = {};
			args[CompilerOptions.SWF_VERSION] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.SWF_VERSION);
			Assert.strictEqual(result[0], "--" + CompilerOptions.SWF_VERSION + "=" + value,
				"Incorrect argument value for " + CompilerOptions.SWF_VERSION);
		}

		[Test]
		public function testTargetPlayer():void
		{
			var value:String = "22.0";
			var args:Object = {};
			args[CompilerOptions.TARGET_PLAYER] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.TARGET_PLAYER);
			Assert.strictEqual(result[0], "--" + CompilerOptions.TARGET_PLAYER + "=" + value,
				"Incorrect argument value for " + CompilerOptions.TARGET_PLAYER);
		}

		[Test]
		public function testTargetsWithOneValue():void
		{
			var value:Array = ["JS"];
			var args:Object = {};
			args[CompilerOptions.TARGETS] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.TARGETS);
			Assert.strictEqual(result[0], "--" + CompilerOptions.TARGETS + "=" + value[0],
				"Incorrect argument value for " + CompilerOptions.TARGETS);
		}

		[Test]
		public function testTargetsWithTwoValues():void
		{
			var value:Array = ["JS","SWF"];
			var args:Object = {};
			args[CompilerOptions.TARGETS] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.TARGETS);
			Assert.strictEqual(result[0], "--" + CompilerOptions.TARGETS + "=" + value[0] + "," + value[1],
				"Incorrect argument value for " + CompilerOptions.TARGETS);
		}

		[Test]
		public function testToolsLocale():void
		{
			var value:String = "fr_FR";
			var args:Object = {};
			args[CompilerOptions.TOOLS_LOCALE] = value;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.TOOLS_LOCALE);
			Assert.strictEqual(result[0], "--" + CompilerOptions.TOOLS_LOCALE + "=" + value,
				"Incorrect argument value for " + CompilerOptions.TOOLS_LOCALE);
		}

		[Test]
		public function testUseDirectBlit():void
		{
			var args:Object = {};
			args[CompilerOptions.USE_DIRECT_BLIT] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.USE_DIRECT_BLIT);
			Assert.strictEqual(result[0], "--" + CompilerOptions.USE_DIRECT_BLIT + "=true",
				"Incorrect argument value for " + CompilerOptions.USE_DIRECT_BLIT);
		}

		[Test]
		public function testUseGPU():void
		{
			var args:Object = {};
			args[CompilerOptions.USE_GPU] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.USE_GPU);
			Assert.strictEqual(result[0], "--" + CompilerOptions.USE_GPU + "=true",
				"Incorrect argument value for " + CompilerOptions.USE_GPU);
		}

		[Test]
		public function testUseNetwork():void
		{
			var args:Object = {};
			args[CompilerOptions.USE_NETWORK] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.USE_NETWORK);
			Assert.strictEqual(result[0], "--" + CompilerOptions.USE_NETWORK + "=true",
				"Incorrect argument value for " + CompilerOptions.USE_NETWORK);
		}

		[Test]
		public function testUseResourceBundleMetadata():void
		{
			var args:Object = {};
			args[CompilerOptions.USE_RESOURCE_BUNDLE_METADATA] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.USE_RESOURCE_BUNDLE_METADATA);
			Assert.strictEqual(result[0], "--" + CompilerOptions.USE_RESOURCE_BUNDLE_METADATA + "=true",
				"Incorrect argument value for " + CompilerOptions.USE_RESOURCE_BUNDLE_METADATA);
		}

		[Test]
		public function testVerboseStacktraces():void
		{
			var args:Object = {};
			args[CompilerOptions.VERBOSE_STACKTRACES] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.VERBOSE_STACKTRACES);
			Assert.strictEqual(result[0], "--" + CompilerOptions.VERBOSE_STACKTRACES + "=true",
				"Incorrect argument value for " + CompilerOptions.VERBOSE_STACKTRACES);
		}

		[Test]
		public function testWarnings():void
		{
			var args:Object = {};
			args[CompilerOptions.WARNINGS] = true;
			var result:Array = CompilerOptionsParser.parse(args);
			Assert.strictEqual(result.length, 1,
				"Incorrect argument count for " + CompilerOptions.WARNINGS);
			Assert.strictEqual(result[0], "--" + CompilerOptions.WARNINGS + "=true",
				"Incorrect argument value for " + CompilerOptions.WARNINGS);
		}
	}
}