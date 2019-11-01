package
{
	import org.apache.royale.events.Event;
	import org.apache.royale.test.RoyaleUnitCore;
	import org.apache.royale.test.listeners.FailureListener;
	import org.apache.royale.test.listeners.TraceListener;

	import tests.AIROptionsTests;
	import tests.AssetPathToOutputPathTests;
	import tests.CompilerOptionsTests;
	import tests.ExtendConfigAIROptionsTests;
	import tests.ExtendConfigCompilerOptionsTests;
	import tests.ExtendConfigTopLevelTests;
	import tests.FindApplicationContentTests;
	import tests.FindOutputDirectoryTests;
	import tests.FindSourcePathAssetsTests;

	public class TestASConfigC
	{
		public function TestASConfigC()
		{
			this._failureListener = new FailureListener();
			this._royaleUnit = new RoyaleUnitCore();
			this._royaleUnit.addListener(new TraceListener());
			this._royaleUnit.addListener(this._failureListener);
			this._royaleUnit.addEventListener(Event.COMPLETE, royaleUnit_completeHandler);
			this._royaleUnit.runClasses(
				AIROptionsTests,
				CompilerOptionsTests,
				FindSourcePathAssetsTests,
				FindOutputDirectoryTests,
				FindApplicationContentTests,
				AssetPathToOutputPathTests,
				ExtendConfigTopLevelTests,
				ExtendConfigCompilerOptionsTests,
				ExtendConfigAIROptionsTests
			);
		}

		private var _failureListener:FailureListener;
		private var _royaleUnit:RoyaleUnitCore;

		private function royaleUnit_completeHandler(event:Event):void
		{
			var exitCode:int = 0;
			if(this._failureListener.failed)
			{
				exitCode = 1;
			}
			process.exit(exitCode);
		}
	}
}