package 
{
	[JSModule(name="tmp")]
	/**
	 * @externs
	 */
	public class tmp
	{
		public static function fileSync(options:Object = null):FileSyncResult
		{
			return null;
		}

		public static function setGracefulCleanup():void {}
	}
}

interface FileSyncResult
{
	function get name():String;
	function get fd():Object;
}