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
package nextgenas.test.assert
{
	import nextgenas.test.errors.AssertionError;

	public class Assert
	{
		public static function strictEqual(actual:*, expected:*, message:String = null):void
		{
			if(actual === expected)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function notStrictEqual(actual:*, expected:*, message:String = null):void
		{
			if(actual !== expected)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function equal(actual:*, expected:*, message:String = null):void
		{
			if(actual == expected)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function notEqual(actual:*, expected:*, message:String = null):void
		{
			if(actual != expected)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function true(actual:*, message:String = null):void
		{
			if(actual === true)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function false(actual:*, message:String = null):void
		{
			if(actual === false)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function null(actual:*, message:String = null):void
		{
			if(actual === null)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function notNull(actual:*, message:String = null):void
		{
			if(actual !== null)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function undefined(actual:*, message:String = null):void
		{
			if(actual === undefined)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function defined(actual:*, message:String = null):void
		{
			if(actual !== undefined)
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function NaN(actual:*, message:String = null):void
		{
			if(isNaN(actual))
			{
				return;
			}
			throw new AssertionError(message);
		}

		public static function notNaN(actual:*, message:String = null):void
		{
			if(!isNaN(actual))
			{
				return;
			}
			throw new AssertionError(message);
		}
	}
}