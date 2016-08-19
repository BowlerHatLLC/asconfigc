/*
Copyright 2016 Bowler Hat LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
*/
package nextgenas.test.listeners
{
	import nextgenas.test.TestRunner;
	import nextgenas.test.events.TestEvent;
	import nextgenas.test.errors.AssertionError;

	public class TraceListener
	{
		public function TraceListener(runner:TestRunner)
		{
			runner.addEventListener(TestEvent.TEST_RUN_START, testRunStartHandler);
			runner.addEventListener(TestEvent.TEST_RUN_COMPLETE, testRunCompleteHandler);
			runner.addEventListener(TestEvent.TEST_RUN_FAIL, testRunFailHandler);
			runner.addEventListener(TestEvent.TEST_START, testStartHandler);
			runner.addEventListener(TestEvent.TEST_COMPLETE, testCompleteHandler);
			runner.addEventListener(TestEvent.TEST_FAIL, testFailHandler);
		}

		private var _startTime:Number;
		private var _passCount:int;
		private var _failCount:int;
		private var _failures:Vector.<String>;

		private function finish():void
		{
			var totalTime:Number = ((new Date()).getTime() - this._startTime) / 1000;
			trace("Time: " + totalTime);

			var failureMessageCount:int = this._failures.length;
			if(failureMessageCount > 0)
			{
				if(this._failCount === 1)
				{
					trace("There was 1 failure:");
				}
				else
				{
					trace("There were " + this._failCount + " failures:");
				}
				for(var i:int = 0; i < failureMessageCount; i++)
				{
					trace((i + 1) + " " + this._failures[i]);
				}
			}

			var totalCount:int = this._passCount + this._failCount;
			var testString:String = "tests";
			if(totalCount === 1)
			{
				testString = "test";
			}

			if(this._failCount > 0)
			{
				var failureString:String = "failures";
				if(this._failCount === 1)
				{
					failureString = "failure";
				}
				trace("FAILURE (" + totalCount + " " + testString + ", " + this._failCount + " " + failureString + ")");
			}
			else
			{
				trace("OK (" + this._passCount + " " + testString + ")");
			}
		}

		private function testRunStartHandler(event:TestEvent):void
		{
			this._startTime = (new Date()).getTime();
			this._passCount = 0;
			this._failCount = 0;
			this._failures = new <String>[];
		}

		private function testRunFailHandler(event:TestEvent):void
		{
			finish();
		}

		private function testRunCompleteHandler(event:TestEvent):void
		{
			finish();
		}

		private function testStartHandler(event:TestEvent):void
		{
			trace(event.testName + " .");
		}

		private function testCompleteHandler(event:TestEvent):void
		{
			this._passCount++;
		}

		private function testFailHandler(event:TestEvent):void
		{
			this._failCount++;
			var error:Error = event.error;
			if(error is AssertionError)
			{
				trace(event.testName + " F");
			}
			else //some other error
			{
				trace(event.testName + " E");
			}

			var message:String = event.testName;
			if(error is Error)
			{
				var errorMessage:String = error.message;
				if(errorMessage)
				{
					message += " " + errorMessage;
				}
				message += " " + error.stack;
			}
			else //fall back to the normal toString()
			{
				message += " " + error;
			}
			this._failures.push(message);
		}
	}
}