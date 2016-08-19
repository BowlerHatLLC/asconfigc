package
{
	import tests.CompilerOptionsTests;
	import nextgenas.test.TestRunner;
	import nextgenas.test.events.TestEvent;
	import nextgenas.test.listeners.TraceListener;

	public class TestASConfigC
	{
		public function TestASConfigC()
		{
			this._runner = new TestRunner();
			new TraceListener(this._runner);
			this._runner.addEventListener(TestEvent.TEST_RUN_COMPLETE, runner_testRunCompleteHandler);
			this._runner.addEventListener(TestEvent.TEST_RUN_FAIL, runner_testRunFailHandler);
			this._runner.run(new <Class>
			[
				CompilerOptionsTests,
			]);
		}

		private var _runner:TestRunner;

		private function runner_testRunCompleteHandler(event:TestEvent):void
		{
			process.exit(0);
		}

		private function runner_testRunFailHandler(event:TestEvent):void
		{
			process.exit(1);
		}
	}
}