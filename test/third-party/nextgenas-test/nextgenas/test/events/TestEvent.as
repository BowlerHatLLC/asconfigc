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
package nextgenas.test.events
{
	public class TestEvent
	{
		public static const TEST_RUN_START:String = "testRunStart";
		public static const TEST_RUN_COMPLETE:String = "testRunComplete";
		public static const TEST_RUN_FAIL:String = "testRunFail";
		public static const TEST_START:String = "testStart";
		public static const TEST_COMPLETE:String = "testComplete";
		public static const TEST_FAIL:String = "testFail";

		public function TestEvent(type:String, testName:String = null, error:Error = null)
		{
			this._type = type;
			this._testName = testName;
			this._error = error;
		}

		private var _type:String;

		public function get type():String
		{
			return this._type;
		}

		private var _testName:String;

		public function get testName():String
		{
			return this._testName;
		}

		private var _error:Error;

		public function get error():Error
		{
			return this._error;
		}
	}
}