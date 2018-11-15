package com.as3mxml.asconfigc.utils
{
	public function folderContains(folder:String, child:String):Boolean
	{
		if(folder === child)
		{
			return true;
		}
		var parentTokens:Array = folder.split(path.sep);
		var childTokens:Array = child.split(path.sep);
		if(parentTokens.length > childTokens.length)
		{
			return false;
		}
		return parentTokens.every(function(token:String, index:int, array:Array):Boolean
		{
			return childTokens[index] === token;
		})
	}
}